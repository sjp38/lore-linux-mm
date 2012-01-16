Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id CFC4E6B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 05:06:11 -0500 (EST)
Date: Mon, 16 Jan 2012 10:06:00 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH] proc: clear_refs: do not clear reserved pages
Message-ID: <20120116100600.GA9068@mudshark.cambridge.arm.com>
References: <1326467587-22218-1-git-send-email-will.deacon@arm.com>
 <alpine.LFD.2.02.1201131748380.2722@xanadu.home>
 <alpine.LSU.2.00.1201140901260.2381@eggly.anvils>
 <20120115150706.GA7474@mudshark.cambridge.arm.com>
 <alpine.LFD.2.02.1201152314420.2722@xanadu.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1201152314420.2722@xanadu.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nico@fluxnic.net>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "moussaba@micron.com" <moussaba@micron.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

On Mon, Jan 16, 2012 at 04:19:43AM +0000, Nicolas Pitre wrote:
> On Sun, 15 Jan 2012, Will Deacon wrote:
> > Something like what I've got below seems to do the trick, and clear_refs
> > also seems to behave when it's presented with the gate_vma. If Russell is
> > happy with the approach, we can move to the gate_vma in the future.
> 
> I like it much better, although I haven't tested it fully yet.
> 
> However your patch is missing the worst of the current ARM hack I would 
> be glad to see go as follows:
> 
> diff --git a/arch/arm/include/asm/mmu_context.h b/arch/arm/include/asm/mmu_context.h
> index 71605d9f8e..876e545297 100644
> --- a/arch/arm/include/asm/mmu_context.h
> +++ b/arch/arm/include/asm/mmu_context.h
> @@ -18,6 +18,7 @@
>  #include <asm/cacheflush.h>
>  #include <asm/cachetype.h>
>  #include <asm/proc-fns.h>
> +#include <asm-generic/mm_hooks.h>
>  
>  void __check_kvm_seq(struct mm_struct *mm);
>  
> @@ -133,32 +135,4 @@ switch_mm(struct mm_struct *prev, struct mm_struct *next,
>  #define deactivate_mm(tsk,mm)	do { } while (0)
>  #define activate_mm(prev,next)	switch_mm(prev, next, NULL)
>  
> -/*
> - * We are inserting a "fake" vma for the user-accessible vector page so
> - * gdb and friends can get to it through ptrace and /proc/<pid>/mem.
> - * But we also want to remove it before the generic code gets to see it
> - * during process exit or the unmapping of it would  cause total havoc.
> - * (the macro is used as remove_vma() is static to mm/mmap.c)
> - */
> -#define arch_exit_mmap(mm) \
> -do { \
> -	struct vm_area_struct *high_vma = find_vma(mm, 0xffff0000); \
> -	if (high_vma) { \
> -		BUG_ON(high_vma->vm_next);  /* it should be last */ \
> -		if (high_vma->vm_prev) \
> -			high_vma->vm_prev->vm_next = NULL; \
> -		else \
> -			mm->mmap = NULL; \
> -		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
> -		mm->mmap_cache = NULL; \
> -		mm->map_count--; \
> -		remove_vma(high_vma); \
> -	} \
> -} while (0)
> -
> -static inline void arch_dup_mmap(struct mm_struct *oldmm,
> -				 struct mm_struct *mm)
> -{
> -}
> -
>  #endif

Nice, I missed those hunks! I'm more than happy to include this for v2
(which I'll just post to the ARM list). I'll also give this some testing on
the boards that I have.

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
