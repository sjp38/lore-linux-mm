Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id BC6146B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 21:00:36 -0400 (EDT)
Received: by iesa3 with SMTP id a3so45343500ies.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:00:36 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id e32si4733577ioi.0.2015.06.17.18.00.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 18:00:36 -0700 (PDT)
Received: by igbiq7 with SMTP id iq7so80340895igb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:00:36 -0700 (PDT)
Date: Wed, 17 Jun 2015 18:00:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 2/4] mm, thp: khugepaged checks for THP allocability before
 scanning
In-Reply-To: <1431354940-30740-3-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1506171739490.8203@chino.kir.corp.google.com>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz> <1431354940-30740-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>

On Mon, 11 May 2015, Vlastimil Babka wrote:

> Khugepaged could be scanning for collapse candidates uselessly, if it cannot
> allocate a hugepage in the end. The hugepage preallocation mechanism prevented
> this, but only for !NUMA configurations. It was removed by the previous patch,
> and this patch replaces it with a more generic mechanism.
> 
> The patch itroduces a thp_avail_nodes nodemask, which initially assumes that
> hugepage can be allocated on any node. Whenever khugepaged fails to allocate
> a hugepage, it clears the corresponding node bit. Before scanning for collapse
> candidates, it tries to allocate a hugepage on each online node with the bit
> cleared, and set it back on success. It tries to hold on to the hugepage if
> it doesn't hold any other yet. But the assumption is that even if the hugepage
> is freed back, it should be possible to allocate it in near future without
> further reclaim and compaction attempts.
> 
> During the scaning, khugepaged avoids collapsing on nodes with the bit cleared,
> as soon as possible. If no nodes have hugepages available, scanning is skipped
> altogether.
> 

I'm not exactly sure what you mean by avoiding to do something as soon as 
possible.

> During testing, the patch did not show much difference in preventing
> thp_collapse_failed events from khugepaged, but this can be attributed to the
> sync compaction, which only khugepaged is allowed to use, and which is
> heavyweight enough to succeed frequently enough nowadays. The next patch will
> however extend the nodemask check to page fault context, where it has much
> larger impact. Also, with the future plan to convert THP collapsing to
> task_work context, this patch is a preparation to avoid useless scanning or
> heavyweight THP allocations in that context.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/huge_memory.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 63 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 565864b..b86a72a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -102,7 +102,7 @@ struct khugepaged_scan {
>  static struct khugepaged_scan khugepaged_scan = {
>  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
>  };
> -
> +static nodemask_t thp_avail_nodes = NODE_MASK_ALL;

Seems like it should have khugepaged in its name so it's understood that 
the nodemask doesn't need to be synchronized, even though it will later be 
read outside of khugepaged, or at least a comment to say only khugepaged 
can store to it.

>  
>  static int set_recommended_min_free_kbytes(void)
>  {
> @@ -2273,6 +2273,14 @@ static bool khugepaged_scan_abort(int nid)
>  	int i;
>  
>  	/*
> +	 * If it's clear that we are going to select a node where THP
> +	 * allocation is unlikely to succeed, abort
> +	 */
> +	if (khugepaged_node_load[nid] == (HPAGE_PMD_NR / 2) &&
> +				!node_isset(nid, thp_avail_nodes))
> +		return true;
> +
> +	/*
>  	 * If zone_reclaim_mode is disabled, then no extra effort is made to
>  	 * allocate memory locally.
>  	 */

If khugepaged_node_load for a node doesn't reach HPAGE_PMD_NR / 2, then 
this doesn't cause an abort.  I don't think it's necessary to try to 
optimize and abort the scan early when this is met, I think this should 
only be checked before collapse_huge_page().

> @@ -2356,6 +2364,7 @@ static struct page
>  	if (unlikely(!*hpage)) {
>  		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>  		*hpage = ERR_PTR(-ENOMEM);
> +		node_clear(node, thp_avail_nodes);
>  		return NULL;
>  	}
>  
> @@ -2363,6 +2372,42 @@ static struct page
>  	return *hpage;
>  }
>  
> +/* Return true, if THP should be allocatable on at least one node */
> +static bool khugepaged_check_nodes(struct page **hpage)
> +{
> +	bool ret = false;
> +	int nid;
> +	struct page *newpage = NULL;
> +	gfp_t gfp = alloc_hugepage_gfpmask(khugepaged_defrag());
> +
> +	for_each_online_node(nid) {
> +		if (node_isset(nid, thp_avail_nodes)) {
> +			ret = true;
> +			continue;
> +		}
> +
> +		newpage = alloc_hugepage_node(gfp, nid);
> +
> +		if (newpage) {
> +			node_set(nid, thp_avail_nodes);
> +			ret = true;
> +			/*
> +			 * Heuristic - try to hold on to the page for collapse
> +			 * scanning, if we don't hold any yet.
> +			 */
> +			if (IS_ERR_OR_NULL(*hpage)) {
> +				*hpage = newpage;
> +				//NIXME: should we count all/no allocations?
> +				count_vm_event(THP_COLLAPSE_ALLOC);

Seems like we'd only count the event when the node load has selected a 
target node and the hugepage that is allocated here is used, but if this 
approach is adopted then I think you'll need to introduce a new event to 
track when a hugepage is allocated and subsequently dropped.

> +			} else {
> +				put_page(newpage);
> +			}

Eek, rather than do put_page() why not store a preallocated hugepage for 
every node and let khugepaged_alloc_page() use it?  It would be 
unfortunate that page_to_nid(*hpage) may not equal the target node after 
scanning.

> +		}
> +	}
> +
> +	return ret;
> +}
> +
>  static bool hugepage_vma_check(struct vm_area_struct *vma)
>  {
>  	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> @@ -2590,6 +2635,10 @@ out_unmap:
>  	pte_unmap_unlock(pte, ptl);
>  	if (ret) {
>  		node = khugepaged_find_target_node();
> +		if (!node_isset(node, thp_avail_nodes)) {
> +			ret = 0;
> +			goto out;
> +		}
>  		/* collapse_huge_page will return with the mmap_sem released */
>  		collapse_huge_page(mm, address, hpage, vma, node);
>  	}
> @@ -2740,12 +2789,16 @@ static int khugepaged_wait_event(void)
>  		kthread_should_stop();
>  }
>  
> -static void khugepaged_do_scan(void)
> +/* Return false if THP allocation failed, true otherwise */
> +static bool khugepaged_do_scan(void)
>  {
>  	struct page *hpage = NULL;
>  	unsigned int progress = 0, pass_through_head = 0;
>  	unsigned int pages = READ_ONCE(khugepaged_pages_to_scan);
>  
> +	if (!khugepaged_check_nodes(&hpage))
> +		return false;
> +
>  	while (progress < pages) {
>  		cond_resched();
>  
> @@ -2764,14 +2817,14 @@ static void khugepaged_do_scan(void)
>  		spin_unlock(&khugepaged_mm_lock);
>  
>  		/* THP allocation has failed during collapse */
> -		if (IS_ERR(hpage)) {
> -			khugepaged_alloc_sleep();
> -			break;
> -		}
> +		if (IS_ERR(hpage))
> +			return false;
>  	}
>  
>  	if (!IS_ERR_OR_NULL(hpage))
>  		put_page(hpage);
> +
> +	return true;
>  }
>  
>  static void khugepaged_wait_work(void)
> @@ -2800,8 +2853,10 @@ static int khugepaged(void *none)
>  	set_user_nice(current, MAX_NICE);
>  
>  	while (!kthread_should_stop()) {
> -		khugepaged_do_scan();
> -		khugepaged_wait_work();
> +		if (khugepaged_do_scan())
> +			khugepaged_wait_work();
> +		else
> +			khugepaged_alloc_sleep();
>  	}
>  
>  	spin_lock(&khugepaged_mm_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
