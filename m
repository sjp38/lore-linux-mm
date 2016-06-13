Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A229D828E1
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:32:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 4so33176924wmz.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:32:56 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id l185si15945516wmf.120.2016.06.13.11.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 11:32:55 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id n184so16890066wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:32:55 -0700 (PDT)
Date: Mon, 13 Jun 2016 21:32:49 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC PATCH 1/3] mm, thp: revert allocstall comparing
Message-ID: <20160613183249.GB3815@debian>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
 <1465672561-29608-2-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465672561-29608-2-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, minchan@kernel.org

On Sat, Jun 11, 2016 at 10:15:59PM +0300, Ebru Akagunduz wrote:
> This patch takes back allocstall comparing when deciding
> whether swapin worthwhile because it does not work,
> if vmevent disabled.
> 
> Related commit:
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=2548306628308aa6a326640d345a737bc898941d
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
> ---
Cc'ed Minchan Kim.
>  mm/khugepaged.c | 31 ++++++++-----------------------
>  1 file changed, 8 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 0ac63f7..e3d8da7 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -68,7 +68,6 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>   */
>  static unsigned int khugepaged_max_ptes_none __read_mostly;
>  static unsigned int khugepaged_max_ptes_swap __read_mostly;
> -static unsigned long allocstall;
>  
>  static int khugepaged(void *none);
>  
> @@ -926,7 +925,6 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	struct page *new_page;
>  	spinlock_t *pmd_ptl, *pte_ptl;
>  	int isolated = 0, result = 0;
> -	unsigned long swap, curr_allocstall;
>  	struct mem_cgroup *memcg;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> @@ -955,8 +953,6 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out_nolock;
>  	}
>  
> -	swap = get_mm_counter(mm, MM_SWAPENTS);
> -	curr_allocstall = sum_vm_event(ALLOCSTALL);
>  	down_read(&mm->mmap_sem);
>  	result = hugepage_vma_revalidate(mm, address);
>  	if (result) {
> @@ -972,22 +968,15 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		up_read(&mm->mmap_sem);
>  		goto out_nolock;
>  	}
> -
>  	/*
> -	 * Don't perform swapin readahead when the system is under pressure,
> -	 * to avoid unnecessary resource consumption.
> +	 * __collapse_huge_page_swapin always returns with mmap_sem
> +	 * locked.  If it fails, release mmap_sem and jump directly
> +	 * out.  Continuing to collapse causes inconsistency.
>  	 */
> -	if (allocstall == curr_allocstall && swap != 0) {
> -		/*
> -		 * __collapse_huge_page_swapin always returns with mmap_sem
> -		 * locked.  If it fails, release mmap_sem and jump directly
> -		 * out.  Continuing to collapse causes inconsistency.
> -		 */
> -		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
> -			mem_cgroup_cancel_charge(new_page, memcg, true);
> -			up_read(&mm->mmap_sem);
> -			goto out_nolock;
> -		}
> +	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
> +		mem_cgroup_cancel_charge(new_page, memcg, true);
> +		up_read(&mm->mmap_sem);
> +		goto out_nolock;
>  	}
>  
>  	up_read(&mm->mmap_sem);
> @@ -1822,7 +1811,6 @@ static void khugepaged_wait_work(void)
>  		if (!scan_sleep_jiffies)
>  			return;
>  
> -		allocstall = sum_vm_event(ALLOCSTALL);
>  		khugepaged_sleep_expire = jiffies + scan_sleep_jiffies;
>  		wait_event_freezable_timeout(khugepaged_wait,
>  					     khugepaged_should_wakeup(),
> @@ -1830,10 +1818,8 @@ static void khugepaged_wait_work(void)
>  		return;
>  	}
>  
> -	if (khugepaged_enabled()) {
> -		allocstall = sum_vm_event(ALLOCSTALL);
> +	if (khugepaged_enabled())
>  		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
> -	}
>  }
>  
>  static int khugepaged(void *none)
> @@ -1842,7 +1828,6 @@ static int khugepaged(void *none)
>  
>  	set_freezable();
>  	set_user_nice(current, MAX_NICE);
> -	allocstall = sum_vm_event(ALLOCSTALL);
>  
>  	while (!kthread_should_stop()) {
>  		khugepaged_do_scan();
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
