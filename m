Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5E86B0072
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 04:52:15 -0400 (EDT)
Received: by wixw10 with SMTP id w10so55214373wix.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:52:14 -0700 (PDT)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com. [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id lf5si182004wjb.111.2015.03.23.01.52.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 01:52:13 -0700 (PDT)
Received: by wegp1 with SMTP id p1so131768666weg.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:52:12 -0700 (PDT)
Date: Mon, 23 Mar 2015 09:52:09 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] mm: Introducing arch_remap hook
Message-ID: <20150323085209.GA28965@gmail.com>
References: <cover.1426866405.git.ldufour@linux.vnet.ibm.com>
 <503499aae380db1c4673f146bcba6ad095021257.1426866405.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <503499aae380db1c4673f146bcba6ad095021257.1426866405.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> Some architecture would like to be triggered when a memory area is moved
> through the mremap system call.
> 
> This patch is introducing a new arch_remap mm hook which is placed in the
> path of mremap, and is called before the old area is unmapped (and the
> arch_unmap hook is called).
> 
> To no break the build, this patch adds the empty hook definition to the
> architectures that were not using the generic hook's definition.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  arch/s390/include/asm/mmu_context.h      | 6 ++++++
>  arch/um/include/asm/mmu_context.h        | 5 +++++
>  arch/unicore32/include/asm/mmu_context.h | 6 ++++++
>  arch/x86/include/asm/mmu_context.h       | 6 ++++++
>  include/asm-generic/mm_hooks.h           | 6 ++++++
>  mm/mremap.c                              | 9 +++++++--
>  6 files changed, 36 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
> index 8fb3802f8fad..ddd861a490ba 100644
> --- a/arch/s390/include/asm/mmu_context.h
> +++ b/arch/s390/include/asm/mmu_context.h
> @@ -131,4 +131,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
>  {
>  }
>  
> +static inline void arch_remap(struct mm_struct *mm,
> +			      unsigned long old_start, unsigned long old_end,
> +			      unsigned long new_start, unsigned long new_end)
> +{
> +}
> +
>  #endif /* __S390_MMU_CONTEXT_H */
> diff --git a/arch/um/include/asm/mmu_context.h b/arch/um/include/asm/mmu_context.h
> index 941527e507f7..f499b017c1f9 100644
> --- a/arch/um/include/asm/mmu_context.h
> +++ b/arch/um/include/asm/mmu_context.h
> @@ -27,6 +27,11 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
>  				     struct vm_area_struct *vma)
>  {
>  }
> +static inline void arch_remap(struct mm_struct *mm,
> +			      unsigned long old_start, unsigned long old_end,
> +			      unsigned long new_start, unsigned long new_end)
> +{
> +}
>  /*
>   * end asm-generic/mm_hooks.h functions
>   */
> diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
> index 1cb5220afaf9..39a0a553172e 100644
> --- a/arch/unicore32/include/asm/mmu_context.h
> +++ b/arch/unicore32/include/asm/mmu_context.h
> @@ -97,4 +97,10 @@ static inline void arch_bprm_mm_init(struct mm_struct *mm,
>  {
>  }
>  
> +static inline void arch_remap(struct mm_struct *mm,
> +			      unsigned long old_start, unsigned long old_end,
> +			      unsigned long new_start, unsigned long new_end)
> +{
> +}
> +
>  #endif
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index 883f6b933fa4..75cb71f4be1e 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -172,4 +172,10 @@ static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
>  		mpx_notify_unmap(mm, vma, start, end);
>  }
>  
> +static inline void arch_remap(struct mm_struct *mm,
> +			      unsigned long old_start, unsigned long old_end,
> +			      unsigned long new_start, unsigned long new_end)
> +{
> +}
> +
>  #endif /* _ASM_X86_MMU_CONTEXT_H */

So instead of spreading these empty prototypes around mmu_context.h 
files, why not add something like this to the PPC definition:

 #define __HAVE_ARCH_REMAP

and define the empty prototype for everyone else? It's a bit like how 
the __HAVE_ARCH_PTEP_* namespace works.

That should shrink this patch considerably.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
