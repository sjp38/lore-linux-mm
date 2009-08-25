Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 032E96B00DF
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:04:37 -0400 (EDT)
Date: Tue, 25 Aug 2009 18:49:09 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <20090825152217.GQ14722@random.random>
Message-ID: <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils> <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> We can't stop page faults from happening during exit_mmap or munlock
> fails. The fundamental issue is the absolute lack of serialization
> after mm_users reaches 0. mmap_sem should be hot in the cache as we
> just released it a few nanoseconds before in exit_mm, we just need to
> take it one last time after mm_users is 0 to allow drivers to
> serialize safely against it so that taking mmap_sem and checking
> mm_users > 0 is enough for ksm to serialize against exit_mmap while
> still noticing when oom killer or something else wants to release all
> memory of the mm. When ksm notices it bails out and it allows memory
> to be released.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 9a16c21..f5af0d3 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -515,7 +515,18 @@ void mmput(struct mm_struct *mm)
>  
>  	if (atomic_dec_and_test(&mm->mm_users)) {
>  		exit_aio(mm);
> +
> +		/*
> +		 * Allow drivers tracking mm without pinning mm_users
> +		 * (so that mm_users is allowed to reach 0 while they
> +		 * do their tracking) to serialize against exit_mmap
> +		 * by taking mmap_sem and checking mm_users is still >
> +		 * 0 before working on the mm they're tracking.
> +		 */
> +		down_read(&mm->mmap_sem);
> +		up_read(&mm->mmap_sem);

Sorry, I just don't get it.  How does down_read here help?
Perhaps you thought ksm.c had down_write of mmap_sem in all cases?

No, and I don't think we want to change its down_reads to down_writes.
Nor do we want to change your down_read here to down_write, that will
just reintroduce the OOM deadlock that 9/12 was about solving.

(If this does work, and I'm just missing it, then I think we'd want a
ksm_prep_exit or something to make them conditional on MMF_VM_MERGEABLE.)

Hugh

>  		exit_mmap(mm);
> +
>  		set_mm_exe_file(mm, NULL);
>  		if (!list_empty(&mm->mmlist)) {
>  			spin_lock(&mmlist_lock);
> diff --git a/mm/memory.c b/mm/memory.c
> index 4a2c60d..025431e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2603,7 +2603,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>  
>  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> -	if (!pte_none(*page_table) || ksm_test_exit(mm))
> +	if (!pte_none(*page_table))
>  		goto release;
>  
>  	inc_mm_counter(mm, anon_rss);
> @@ -2753,7 +2753,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * handle that later.
>  	 */
>  	/* Only go through if we didn't race with anybody else... */
> -	if (likely(pte_same(*page_table, orig_pte) && !ksm_test_exit(mm))) {
> +	if (likely(pte_same(*page_table, orig_pte))) {
>  		flush_icache_page(vma, page);
>  		entry = mk_pte(page, vma->vm_page_prot);
>  		if (flags & FAULT_FLAG_WRITE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
