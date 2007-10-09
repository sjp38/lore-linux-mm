Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l99Fa1bH011216
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 01:36:01 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99FZoXp2502712
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 01:35:50 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99FWwV5020200
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 01:32:58 +1000
Message-ID: <470B9FB3.3050804@linux.vnet.ibm.com>
Date: Tue, 09 Oct 2007 21:05:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [4/6]
 avoid handling !LRU  page in mem_cgroup_isolate_pages
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com> <20071009185341.d395bece.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009185341.d395bece.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch makes mem_cgroup_isolate_pages() to be
> 
>   - ignore !PageLRU pages.
>   - fixes the bug that it makes no progress if page_zone(page) != zone
>     page once find. (just increment scan in this case.)
> 
> kswapd and memory migraion removes a page from list when it handles
> a page for reclaiming/migration. 
> 
> __isolate_lru_page() doesn't moves page !PageLRU pages, then, it will
> be safe to avoid touching the page and its page_cgroup.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/memcontrol.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> Index: devel-2.6.23-rc8-mm2/mm/memcontrol.c
> ===================================================================
> --- devel-2.6.23-rc8-mm2.orig/mm/memcontrol.c
> +++ devel-2.6.23-rc8-mm2/mm/memcontrol.c
> @@ -227,7 +227,7 @@ unsigned long mem_cgroup_isolate_pages(u
>  	unsigned long scan;
>  	LIST_HEAD(pc_list);
>  	struct list_head *src;
> -	struct page_cgroup *pc;
> +	struct page_cgroup *pc, *tmp;
> 
>  	if (active)
>  		src = &mem_cont->active_list;
> @@ -235,11 +235,18 @@ unsigned long mem_cgroup_isolate_pages(u
>  		src = &mem_cont->inactive_list;
> 
>  	spin_lock(&mem_cont->lru_lock);
> -	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> -		pc = list_entry(src->prev, struct page_cgroup, lru);
> +	scan = 0;
> +	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
> +		if (scan++ > nr_taken)
> +			break;
>  		page = pc->page;
>  		VM_BUG_ON(!pc);
> 
> +		if (unlikely(!PageLRU(page))) {
> +			scan--;
> +			continue;
> +		}
> +
>  		if (PageActive(page) && !active) {
>  			__mem_cgroup_move_lists(pc, true);
>  			scan--;
> 

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
