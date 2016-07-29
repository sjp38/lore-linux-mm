Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC836B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:48:03 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so104457139pac.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:48:03 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hm6si18455446pac.254.2016.07.29.06.48.02
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 06:48:02 -0700 (PDT)
Date: Fri, 29 Jul 2016 14:48:05 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 4/7] arm64: Use simpler API for random address requests
Message-ID: <20160729134804.GJ16593@arm.com>
References: <20160728204730.27453-1-jason@lakedaemon.net>
 <20160728204730.27453-5-jason@lakedaemon.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160728204730.27453-5-jason@lakedaemon.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: william.c.roberts@intel.com, Yann Droneaud <ydroneaud@opteya.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, tytso@mit.edu, arnd@arndb.de, gregkh@linuxfoundation.org, catalin.marinas@arm.com, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, nnk@google.com, jeffv@google.com, dcashman@android.com

On Thu, Jul 28, 2016 at 08:47:27PM +0000, Jason Cooper wrote:
> Currently, all callers to randomize_range() set the length to 0 and
> calculate end by adding a constant to the start address.  We can
> simplify the API to remove a bunch of needless checks and variables.
> 
> Use the new randomize_addr(start, range) call to set the requested
> address.
> 
> Signed-off-by: Jason Cooper <jason@lakedaemon.net>
> ---
>  arch/arm64/kernel/process.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 6cd2612236dc..11bf454baf86 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -374,12 +374,8 @@ unsigned long arch_align_stack(unsigned long sp)
>  
>  unsigned long arch_randomize_brk(struct mm_struct *mm)
>  {
> -	unsigned long range_end = mm->brk;
> -
>  	if (is_compat_task())
> -		range_end += 0x02000000;
> +		return randomize_addr(mm->brk, 0x02000000);
>  	else
> -		range_end += 0x40000000;
> -
> -	return randomize_range(mm->brk, range_end, 0) ? : mm->brk;
> +		return randomize_addr(mm->brk, 0x40000000);

Looks fine to me, once the core code has settled down:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
