Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAED6B0262
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 04:59:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so35002139wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 01:59:25 -0700 (PDT)
Received: from ou.quest-ce.net ([2001:bc8:3541:100::1])
        by mx.google.com with ESMTPS id dw15si17939199wjb.134.2016.07.29.01.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jul 2016 01:59:23 -0700 (PDT)
Message-ID: <1469782754.16837.20.camel@opteya.com>
From: Yann Droneaud <ydroneaud@opteya.com>
Date: Fri, 29 Jul 2016 10:59:14 +0200
In-Reply-To: <20160728204730.27453-2-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
	 <20160728204730.27453-2-jason@lakedaemon.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 1/7] random: Simplify API for random address requests
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>, william.c.roberts@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, tytso@mit.edu, arnd@arndb.de, gregkh@linuxfoundation.org, catalin.marinas@arm.com, will.deacon@arm.com, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, nnk@google.com, jeffv@google.com, dcashman@android.com

Hi,

Le jeudi 28 juillet 2016 A  20:47 +0000, Jason Cooper a A(C)critA :
> To date, all callers of randomize_range() have set the length to 0,
> and check for a zero return value.A A For the current callers, the only
> way to get zero returned is if end <= start.A A Since they are all
> adding a constant to the start address, this is unnecessary.
> 
> We can remove a bunch of needless checks by simplifying the API to do
> just what everyone wants, return an address between [start, start +
> range).
> 
> While we're here, s/get_random_int/get_random_long/.A A No current call
> site is adversely affected by get_random_int(), since all current
> range requests are < UINT_MAX.A A However, we should match caller
> expectations to avoid coming up short (ha!) in the future.
> 
> Address generation within [start, start + range) behavior is
> preserved.
> 
> All current callers to randomize_range() chose to use the start
> address if randomize_range() failed.A A Therefore, we simplify things
> by just returning the start address on error.
> 
> randomize_range() will be removed once all callers have been
> converted over to randomize_addr().
> 
> Signed-off-by: Jason Cooper <jason@lakedaemon.net>
> ---
> A drivers/char/random.cA A | 26 ++++++++++++++++++++++++++
> A include/linux/random.h |A A 1 +
> A 2 files changed, 27 insertions(+)
> 
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 0158d3bff7e5..3610774bcc53 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1840,6 +1840,32 @@ randomize_range(unsigned long start, unsigned
> long end, unsigned long len)
> A 	return PAGE_ALIGN(get_random_int() % range + start);
> A }
> A 
> +/**
> + * randomize_addr - Generate a random, page aligned address
> + * @start:	The smallest acceptable address the caller will take.
> + * @range:	The size of the area, starting at @start, within which the
> + *		random address must fall.
> + *
> + * Before page alignment, the random address generated can be any value from
> + * @start, to @start + @range - 1 inclusive.
> + *
> + * If @start + @range would overflow, @range is capped.
> + *
> + * Return: A page aligned address within [start, start + range).

PAGE_ALIGN(start + range - 1) can be greater than start + range ..

In the worst case, when start = 0, range = ULONG_MAX, the result would
be 0.

In order to stay in the bounds, the start address must be rounded up,
and the random offset must be rounded down.

Something I haven't found the time to send was looking like this:

A  unsigned long base = PAGE_ALIGN(start);

A  range -= (base - start);
A  range >>= PAGE_SHIFT;

A  return base + ((get_random_int() % range) << PAGE_SHIFT);


> A A On error,
> + * @start is returned.
> + */
> +unsigned long
> +randomize_addr(unsigned long start, unsigned long range)
> +{
> +	if (range == 0)
> +		return start;
> +
> +	if (start > ULONG_MAX - range)
> +		range = ULONG_MAX - start;
> +
> +	return PAGE_ALIGN(get_random_long() % range + start);
> +}
> +
> A /* Interface for in-kernel drivers of true hardware RNGs.
> A  * Those devices may produce endless random bits and will be throttled
> A  * when our pool is full.
> diff --git a/include/linux/random.h b/include/linux/random.h
> index e47e533742b5..f1ca2fa4c071 100644
> --- a/include/linux/random.h
> +++ b/include/linux/random.h
> @@ -35,6 +35,7 @@ extern const struct file_operations random_fops, urandom_fops;
> A unsigned int get_random_int(void);
> A unsigned long get_random_long(void);
> A unsigned long randomize_range(unsigned long start, unsigned long end, unsigned long len);
> +unsigned long randomize_addr(unsigned long start, unsigned long range);
> A 
> A u32 prandom_u32(void);
> A void prandom_bytes(void *buf, size_t nbytes);


Regards.

-- 
Yann Droneaud
OPTEYA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
