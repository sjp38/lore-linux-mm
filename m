Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23EE46B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 11:08:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so560693169pfx.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 08:08:50 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p125si20069937pfp.119.2016.12.06.08.08.48
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 08:08:49 -0800 (PST)
Date: Tue, 6 Dec 2016 16:08:00 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 05/10] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161206160800.GD24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-6-git-send-email-labbott@redhat.com>
 <584011CB.3050505@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <584011CB.3050505@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Thu, Dec 01, 2016 at 12:04:27PM +0000, James Morse wrote:
> On 29/11/16 18:55, Laura Abbott wrote:
> > diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> > index d55a7b0..4f0c77d 100644
> > --- a/arch/arm64/kernel/hibernate.c
> > +++ b/arch/arm64/kernel/hibernate.c
> > @@ -484,7 +481,7 @@ int swsusp_arch_resume(void)
> >  	 * Since we only copied the linear map, we need to find restore_pblist's
> >  	 * linear map address.
> >  	 */
> > -	lm_restore_pblist = LMADDR(restore_pblist);
> > +	lm_restore_pblist = lm_alias(restore_pblist);
> >  
> >  	/*
> >  	 * We need a zero page that is zero before & after resume in order to
> 
> This change causes resume from hibernate to panic in:
> > VIRTUAL_BUG_ON(x < (unsigned long) KERNEL_START ||
> > 		x > (unsigned long) KERNEL_END);
> 
> It looks like kaslr's relocation code has already fixed restore_pblist, so your
> debug virtual check catches this doing the wrong thing. My bug.
> 
> readelf -s vmlinux | grep ...
> > 103495: ffff000008080000     0 NOTYPE  GLOBAL DEFAULT    1 _text
> >  92104: ffff000008e43860     8 OBJECT  GLOBAL DEFAULT   24 restore_pblist
> > 105442: ffff000008e85000     0 NOTYPE  GLOBAL DEFAULT   24 _end
> 
> But restore_pblist == 0xffff800971b7f998 when passed to __phys_addr_symbol().

I think KASLR's a red herring; it shouldn't change the distance between
the restore_pblist symbol and {_text,_end}.

Above, ffff000008e43860 is the location of the pointer in the kernel
image (i.e. it's &restore_pblist). 0xffff800971b7f998 is the pointer
that was assigned to restore_pblist. For KASLR, the low bits (at least
up to a page boundary) shouldn't change across relocation.

Assuming it's only ever assigned a dynamic allocation, which should fall
in the linear map, the LMADDR() dance doesn't appear to be necessary.

> This fixes the problem:
> ----------------%<----------------
> diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> index 4f0c77d2ff7a..8bed26a2d558 100644
> --- a/arch/arm64/kernel/hibernate.c
> +++ b/arch/arm64/kernel/hibernate.c
> @@ -457,7 +457,6 @@ int swsusp_arch_resume(void)
>         void *zero_page;
>         size_t exit_size;
>         pgd_t *tmp_pg_dir;
> -       void *lm_restore_pblist;
>         phys_addr_t phys_hibernate_exit;
>         void __noreturn (*hibernate_exit)(phys_addr_t, phys_addr_t, void *,
>                                           void *, phys_addr_t, phys_addr_t);
> @@ -478,12 +477,6 @@ int swsusp_arch_resume(void)
>                 goto out;
> 
>         /*
> -        * Since we only copied the linear map, we need to find restore_pblist's
> -        * linear map address.
> -        */
> -       lm_restore_pblist = lm_alias(restore_pblist);
> -
> -       /*
>          * We need a zero page that is zero before & after resume in order to
>          * to break before make on the ttbr1 page tables.
>          */
> @@ -534,7 +527,7 @@ int swsusp_arch_resume(void)
>         }
> 
>         hibernate_exit(virt_to_phys(tmp_pg_dir), resume_hdr.ttbr1_el1,
> -                      resume_hdr.reenter_kernel, lm_restore_pblist,
> +                      resume_hdr.reenter_kernel, restore_pblist,
>                        resume_hdr.__hyp_stub_vectors, virt_to_phys(zero_page));
> 
>  out:
> ----------------%<----------------

Folding that in (or having it as a preparatory cleanup patch) makes
sense to me. AFAICT the logic was valid (albeit confused) until now, so
it's not strictly a fix.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
