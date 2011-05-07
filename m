Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B49086B0022
	for <linux-mm@kvack.org>; Sat,  7 May 2011 19:19:59 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p47NJsGw021821
	for <linux-mm@kvack.org>; Sat, 7 May 2011 16:19:58 -0700
Received: from pvc12 (pvc12.prod.google.com [10.241.209.140])
	by kpbe13.cbf.corp.google.com with ESMTP id p47NJlKk027942
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 7 May 2011 16:19:53 -0700
Received: by pvc12 with SMTP id 12so2613190pvc.14
        for <linux-mm@kvack.org>; Sat, 07 May 2011 16:19:47 -0700 (PDT)
Date: Sat, 7 May 2011 16:19:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <20110506075027.GB32495@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1105071617310.3645@sister.anvils>
References: <20110506075027.GB32495@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 6 May 2011, Michal Hocko wrote:

> Hi Andrew,
> I am sorry to repost this kind of trivial cleanup for the 4th time,
> but after recent discussion (https://lkml.org/lkml/2011/5/3/323)
> with Hugh I think that it makes sense to keep the original
> expand_{upwards,downwards} without being explicit about the stack in the
> name. As Hugh pointed out, IA64 uses expand_upwards for something that
> is not really a stack (it is a backing storage for registers).
> The following patch reworks the original one so it is not incremental.
> If you prefer incremental one I can send that one instead. 
> Just for record this patch obsoletes:
> 	mm-make-expand_downwards-symmetrical-with-expand_upwards.patch
> 	mm-make-expand_downwards-symmetrical-with-expand_upwards-v3.patch
> in your current (2011-04-29-16-25) mm tree.
> 
> ---
> From 1b679558f464530c59c93930b958a3436a250c25 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 15 Apr 2011 14:56:26 +0200
> Subject: [PATCH] mm: make expand_downwards symmetrical to expand_upwards
> 
> Currently we have expand_upwards exported while expand_downwards is
> accessible only via expand_stack or expand_stack_downwards.
> 
> check_stack_guard_page is a nice example of the asymmetry. It uses
> expand_stack for VM_GROWSDOWN while expand_upwards is called for
> VM_GROWSUP case.
> 
> Let's clean this up by exporting both functions and make those names
> consistent. Let's use expand_{upwards,downwards} because expanding
> doesn't always involve stack manipulation (an example is
> ia64_do_page_fault which uses expand_upwards for registers backing store
> expansion).
> expand_downwards has to be defined for both CONFIG_STACK_GROWS{UP,DOWN}
> because get_arg_page calls the downwards version in the early process
> initialization phase for growsup configuration.
> 
> CC: Hugh Dickins <hughd@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Thanks, Michal: yes, I much prefer it done this way:
Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  fs/exec.c          |    2 +-
>  include/linux/mm.h |    8 +++++---
>  mm/memory.c        |    2 +-
>  mm/mmap.c          |    7 +------
>  4 files changed, 8 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 5e62d26..c2668ff 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -194,7 +194,7 @@ struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
>  
>  #ifdef CONFIG_STACK_GROWSUP
>  	if (write) {
> -		ret = expand_stack_downwards(bprm->vma, pos);
> +		ret = expand_downwards(bprm->vma, pos);
>  		if (ret < 0)
>  			return NULL;
>  	}
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 692dbae..2d4f62b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1494,15 +1494,17 @@ unsigned long ra_submit(struct file_ra_state *ra,
>  			struct address_space *mapping,
>  			struct file *filp);
>  
> -/* Do stack extension */
> +/* Generic expand stack which grows the stack according to GROWS{UP,DOWN} */
>  extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
> +
> +/* CONFIG_STACK_GROWSUP still needs to to grow downwards at some places */
> +extern int expand_downwards(struct vm_area_struct *vma,
> +		unsigned long address);
>  #if VM_GROWSUP
>  extern int expand_upwards(struct vm_area_struct *vma, unsigned long address);
>  #else
>    #define expand_upwards(vma, address) do { } while (0)
>  #endif
> -extern int expand_stack_downwards(struct vm_area_struct *vma,
> -				  unsigned long address);
>  
>  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
>  extern struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr);
> diff --git a/mm/memory.c b/mm/memory.c
> index ce22a25..f404fb6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2969,7 +2969,7 @@ static inline int check_stack_guard_page(struct vm_area_struct *vma, unsigned lo
>  		if (prev && prev->vm_end == address)
>  			return prev->vm_flags & VM_GROWSDOWN ? 0 : -ENOMEM;
>  
> -		expand_stack(vma, address - PAGE_SIZE);
> +		expand_downwards(vma, address - PAGE_SIZE);
>  	}
>  	if ((vma->vm_flags & VM_GROWSUP) && address + PAGE_SIZE == vma->vm_end) {
>  		struct vm_area_struct *next = vma->vm_next;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index e27e0cf..4c10287 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1782,7 +1782,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  /*
>   * vma is the first one with address < vma->vm_start.  Have to extend vma.
>   */
> -static int expand_downwards(struct vm_area_struct *vma,
> +int expand_downwards(struct vm_area_struct *vma,
>  				   unsigned long address)
>  {
>  	int error;
> @@ -1829,11 +1829,6 @@ static int expand_downwards(struct vm_area_struct *vma,
>  	return error;
>  }
>  
> -int expand_stack_downwards(struct vm_area_struct *vma, unsigned long address)
> -{
> -	return expand_downwards(vma, address);
> -}
> -
>  #ifdef CONFIG_STACK_GROWSUP
>  int expand_stack(struct vm_area_struct *vma, unsigned long address)
>  {
> -- 
> 1.7.4.4
> 
> 
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
