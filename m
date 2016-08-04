Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A21C6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 08:47:33 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so133307587lfw.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 05:47:32 -0700 (PDT)
Received: from ou.quest-ce.net ([2001:bc8:3541:100::1])
        by mx.google.com with ESMTPS id h195si3864833wmg.66.2016.08.04.05.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 05:47:31 -0700 (PDT)
Message-ID: <1470314827.2764.11.camel@opteya.com>
From: Yann Droneaud <ydroneaud@opteya.com>
Date: Thu, 04 Aug 2016 14:47:07 +0200
In-Reply-To: <20160803233913.32511-2-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net>
	 <20160803233913.32511-1-jason@lakedaemon.net>
	 <20160803233913.32511-2-jason@lakedaemon.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v3 1/7] random: Simplify API for random address requests
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, benh@kernel.crashing.org, paulus@samba.org, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, viro@zeniv.linux.org.uk, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

Hi,

Le mercredi 03 aoA>>t 2016 A  23:39 +0000, Jason Cooper a A(C)critA :
>A 
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 0158d3bff7e5..61cb434e3bea 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1840,6 +1840,39 @@ randomize_range(unsigned long start, unsigned
> long end, unsigned long len)
> A 	return PAGE_ALIGN(get_random_int() % range + start);
> A }
> A 
> +/**
> + * randomize_page - Generate a random, page aligned address
> + * @start:	The smallest acceptable address the caller will
> take.
> + * @range:	The size of the area, starting at @start, within
> which the
> + *		random address must fall.
> + *
> + * If @start + @range would overflow, @range is capped.
> + *
> + * NOTE: Historical use of randomize_range, which this replaces,
> presumed that
> + * @start was already page aligned.A A We now align it regardless.
> + *
> + * Return: A page aligned address within [start, start + range).A A On
> error,
> + * @start is returned.
> + */
> +unsigned long
> +randomize_page(unsigned long start, unsigned long range)
> +{

To prevent an underflow if start is not page aligned (but will one
would ever use a non aligned start address *and* range ? ...)

A A A A A A A A if (range < PAGE_SIZE)
A A A A A A A A A A A A A A A A return start;


> +	if (!PAGE_ALIGNED(start)) {
> +		range -= PAGE_ALIGN(start) - start;
> +		start = PAGE_ALIGN(start);
> +	}
> +
> +	if (start > ULONG_MAX - range)
> +		range = ULONG_MAX - start;
> +
> +	range >>= PAGE_SHIFT;
> +
> +	if (range == 0)
> +		return start;
> +
> +	return start + (get_random_long() % range << PAGE_SHIFT);
> +}
> +
> A /* Interface for in-kernel drivers of true hardware RNGs.
> A  * Those devices may produce endless random bits and will be
> throttled
> A  * when our pool is full.
>A 

Regards.

--A 
Yann Droneaud
OPTEYA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
