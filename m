Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 048BC6B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:59:51 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so1335349qcv.24
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:59:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lc5si2393161qcb.23.2014.05.20.10.59.50
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 10:59:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] memory-failure: Don't let collect_procs() skip over processes for MF_ACTION_REQUIRED
Date: Tue, 20 May 2014 13:59:33 -0400
Message-Id: <537b9817.05f1e50a.14fb.ffffc342SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <d6101e631fb61e9e097207939a93faa799be9a82.1400607328.git.tony.luck@intel.com>
References: <cover.1400607328.git.tony.luck@intel.com> <d6101e631fb61e9e097207939a93faa799be9a82.1400607328.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, bp@suse.de, gong.chen@linux.jf.intel.com

On Tue, May 20, 2014 at 09:46:43AM -0700, Tony Luck wrote:
> When Linux sees an "action optional" machine check (where h/w has
> reported an error that is not in the current execution path) we
> generally do not want to signal a process, since most processes
> do not have a SIGBUS handler - we'd just prematurely terminate the
> process for a problem that they might never actually see.
> 
> task_early_kill() decides whether to consider a process - and it
> checks whether this specific process has been marked for early signals
> with "prctl", or if the system administrator has requested early
> signals for all processes using /proc/sys/vm/memory_failure_early_kill.
> 
> But for MF_ACTION_REQUIRED case we must not defer. The error is in
> the execution path of the current thread so we must send the SIGBUS
> immediatley.
> 
> Fix by passing a flag argument through collect_procs*() to
> task_early_kill() so it knows whether we can defer or must
> take action.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

> ---
>  mm/memory-failure.c | 21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 642c8434b166..f0967f72991c 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -380,10 +380,12 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
>  	}
>  }
>  
> -static int task_early_kill(struct task_struct *tsk)
> +static int task_early_kill(struct task_struct *tsk, int force_early)
>  {
>  	if (!tsk->mm)
>  		return 0;
> +	if (force_early)
> +		return 1;
>  	if (tsk->flags & PF_MCE_PROCESS)
>  		return !!(tsk->flags & PF_MCE_EARLY);
>  	return sysctl_memory_failure_early_kill;
> @@ -393,7 +395,7 @@ static int task_early_kill(struct task_struct *tsk)
>   * Collect processes when the error hit an anonymous page.
>   */
>  static void collect_procs_anon(struct page *page, struct list_head *to_kill,
> -			      struct to_kill **tkc)
> +			      struct to_kill **tkc, int force_early)
>  {
>  	struct vm_area_struct *vma;
>  	struct task_struct *tsk;
> @@ -409,7 +411,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
>  	for_each_process (tsk) {
>  		struct anon_vma_chain *vmac;
>  
> -		if (!task_early_kill(tsk))
> +		if (!task_early_kill(tsk, force_early))
>  			continue;
>  		anon_vma_interval_tree_foreach(vmac, &av->rb_root,
>  					       pgoff, pgoff) {
> @@ -428,7 +430,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
>   * Collect processes when the error hit a file mapped page.
>   */
>  static void collect_procs_file(struct page *page, struct list_head *to_kill,
> -			      struct to_kill **tkc)
> +			      struct to_kill **tkc, int force_early)
>  {
>  	struct vm_area_struct *vma;
>  	struct task_struct *tsk;
> @@ -439,7 +441,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>  	for_each_process(tsk) {
>  		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>  
> -		if (!task_early_kill(tsk))
> +		if (!task_early_kill(tsk, force_early))
>  			continue;
>  
>  		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff,
> @@ -465,7 +467,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>   * First preallocate one tokill structure outside the spin locks,
>   * so that we can kill at least one process reasonably reliable.
>   */
> -static void collect_procs(struct page *page, struct list_head *tokill)
> +static void collect_procs(struct page *page, struct list_head *tokill,
> +				int force_early)
>  {
>  	struct to_kill *tk;
>  
> @@ -476,9 +479,9 @@ static void collect_procs(struct page *page, struct list_head *tokill)
>  	if (!tk)
>  		return;
>  	if (PageAnon(page))
> -		collect_procs_anon(page, tokill, &tk);
> +		collect_procs_anon(page, tokill, &tk, force_early);
>  	else
> -		collect_procs_file(page, tokill, &tk);
> +		collect_procs_file(page, tokill, &tk, force_early);
>  	kfree(tk);
>  }
>  
> @@ -963,7 +966,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	 * there's nothing that can be done.
>  	 */
>  	if (kill)
> -		collect_procs(ppage, &tokill);
> +		collect_procs(ppage, &tokill, flags & MF_ACTION_REQUIRED);
>  
>  	ret = try_to_unmap(ppage, ttu);
>  	if (ret != SWAP_SUCCESS)
> -- 
> 1.8.4.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
