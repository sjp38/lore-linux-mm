Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9F36B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 08:11:26 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so24965326wgd.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:11:25 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id fx9si4793584wib.15.2015.03.25.05.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 05:11:24 -0700 (PDT)
Received: by wibg7 with SMTP id g7so72886075wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:11:23 -0700 (PDT)
Date: Wed, 25 Mar 2015 13:11:19 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150325121118.GA2542@gmail.com>
References: <20150323085209.GA28965@gmail.com>
 <cover.1427280806.git.ldufour@linux.vnet.ibm.com>
 <25152b76585716dc635945c3455ab9b49e645f6d.1427280806.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25152b76585716dc635945c3455ab9b49e645f6d.1427280806.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> Some processes (CRIU) are moving the vDSO area using the mremap system
> call. As a consequence the kernel reference to the vDSO base address is
> no more valid and the signal return frame built once the vDSO has been
> moved is not pointing to the new sigreturn address.
> 
> This patch handles vDSO remapping and unmapping.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/mmu_context.h | 36 +++++++++++++++++++++++++++++++++-
>  1 file changed, 35 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
> index 73382eba02dc..be5dca3f7826 100644
> --- a/arch/powerpc/include/asm/mmu_context.h
> +++ b/arch/powerpc/include/asm/mmu_context.h
> @@ -8,7 +8,6 @@
>  #include <linux/spinlock.h>
>  #include <asm/mmu.h>	
>  #include <asm/cputable.h>
> -#include <asm-generic/mm_hooks.h>
>  #include <asm/cputhreads.h>
>  
>  /*
> @@ -109,5 +108,40 @@ static inline void enter_lazy_tlb(struct mm_struct *mm,
>  #endif
>  }
>  
> +static inline void arch_dup_mmap(struct mm_struct *oldmm,
> +				 struct mm_struct *mm)
> +{
> +}
> +
> +static inline void arch_exit_mmap(struct mm_struct *mm)
> +{
> +}
> +
> +static inline void arch_unmap(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end)
> +{
> +	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
> +		mm->context.vdso_base = 0;
> +}
> +
> +static inline void arch_bprm_mm_init(struct mm_struct *mm,
> +				     struct vm_area_struct *vma)
> +{
> +}
> +
> +#define __HAVE_ARCH_REMAP
> +static inline void arch_remap(struct mm_struct *mm,
> +			      unsigned long old_start, unsigned long old_end,
> +			      unsigned long new_start, unsigned long new_end)
> +{
> +	/*
> +	 * mremap don't allow moving multiple vma so we can limit the check
> +	 * to old_start == vdso_base.

s/mremap don't allow moving multiple vma
  mremap() doesn't allow moving multiple vmas

right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
