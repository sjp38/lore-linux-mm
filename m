Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CC2646B0032
	for <linux-mm@kvack.org>; Sun, 11 Aug 2013 13:44:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 12 Aug 2013 03:37:19 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 805E32CE8051
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 03:44:09 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7BHhq9n6750628
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 03:43:58 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7BHi1Pk026622
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 03:44:02 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 9/9] prepare to remove /proc/sys/vm/hugepages_treat_as_movable
In-Reply-To: <1376025702-14818-10-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1376025702-14818-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sun, 11 Aug 2013 23:13:58 +0530
Message-ID: <871u60ruld.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Now we have extended hugepage migration and it's opened to many users
> of page migration, which is a good reason to consider hugepage as movable.
> So we can go to the direction to remove this parameter. In order to
> allow userspace to prepare for the removal, let's leave this sysctl handler
> as noop for a while.
>
> Note that hugepage migration is available only for the architectures
> which implement hugepage on a pmd basis. On the other architectures,
> allocating hugepages from MOVABLE is not a good idea because it can
> break memory hotremove (which expects that all pages of ZONE_MOVABLE are
> movable.) So we choose GFP flags in accordance with mobility of hugepage.
>
> ChangeLog v5:
>  - choose GFP flags in accordance with mobility of hugepage
>
> ChangeLog v3:
>  - use WARN_ON_ONCE
>
> ChangeLog v2:
>  - shift to noop function instead of completely removing the parameter
>  - rename patch title
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Ok that mostly address the issue I raised last time, but how do archs
that don't support hugepage migration force the hugepage allocation from
movable zone. They were able to do that before with the sysctl you are
removing in this patch isn't it ? May be keep that interface and print a
warn_on of archs that support hugepage migration ?


> ---
>  Documentation/sysctl/vm.txt | 13 ++-----------
>  mm/hugetlb.c                | 26 +++++++++++++++-----------
>  2 files changed, 17 insertions(+), 22 deletions(-)
>
> diff --git v3.11-rc3.orig/Documentation/sysctl/vm.txt v3.11-rc3/Documentation/sysctl/vm.txt
> index 36ecc26..6e211a1 100644
> --- v3.11-rc3.orig/Documentation/sysctl/vm.txt
> +++ v3.11-rc3/Documentation/sysctl/vm.txt
> @@ -200,17 +200,8 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
>
>  hugepages_treat_as_movable
>
> -This parameter is only useful when kernelcore= is specified at boot time to
> -create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
> -are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
> -value written to hugepages_treat_as_movable allows huge pages to be allocated
> -from ZONE_MOVABLE.
> -
> -Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
> -pages pool can easily grow or shrink within. Assuming that applications are
> -not running that mlock() a lot of memory, it is likely the huge pages pool
> -can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
> -into nr_hugepages and triggering page reclaim.
> +This parameter is obsolete and planned to be removed. The value has no effect
> +on kernel's behavior.
>
>  ==============================================================
>
> diff --git v3.11-rc3.orig/mm/hugetlb.c v3.11-rc3/mm/hugetlb.c
> index 3121915..b888873 100644
> --- v3.11-rc3.orig/mm/hugetlb.c
> +++ v3.11-rc3/mm/hugetlb.c
> @@ -34,7 +34,6 @@
>  #include "internal.h"
>
>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> -static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
>
>  int hugetlb_max_hstate __read_mostly;
> @@ -535,6 +534,15 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>  	return page;
>  }
>
> +/* Movability of hugepages depends on migration support. */
> +static inline int htlb_alloc_mask(struct hstate *h)
> +{
> +	if (hugepage_migration_support(h))
> +		return GFP_HIGHUSER_MOVABLE;
> +	else
> +		return GFP_HIGHUSER;
> +}
> +
>  static struct page *dequeue_huge_page_vma(struct hstate *h,
>  				struct vm_area_struct *vma,
>  				unsigned long address, int avoid_reserve)
> @@ -550,7 +558,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  retry_cpuset:
>  	cpuset_mems_cookie = get_mems_allowed();
>  	zonelist = huge_zonelist(vma, address,
> -					htlb_alloc_mask, &mpol, &nodemask);
> +					htlb_alloc_mask(h), &mpol, &nodemask);
>  	/*
>  	 * A child process with MAP_PRIVATE mappings created by their parent
>  	 * have no page reserves. This check ensures that reservations are
> @@ -566,7 +574,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  						MAX_NR_ZONES - 1, nodemask) {
> -		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
> +		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask(h))) {
>  			page = dequeue_huge_page_node(h, zone_to_nid(zone));
>  			if (page) {
>  				if (!avoid_reserve)
> @@ -723,7 +731,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  		return NULL;
>
>  	page = alloc_pages_exact_node(nid,
> -		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
> +		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
>  						__GFP_REPEAT|__GFP_NOWARN,
>  		huge_page_order(h));
>  	if (page) {
> @@ -948,12 +956,12 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  	spin_unlock(&hugetlb_lock);
>
>  	if (nid == NUMA_NO_NODE)
> -		page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
> +		page = alloc_pages(htlb_alloc_mask(h)|__GFP_COMP|
>  				   __GFP_REPEAT|__GFP_NOWARN,
>  				   huge_page_order(h));
>  	else
>  		page = alloc_pages_exact_node(nid,
> -			htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
> +			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
>  			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
>
>  	if (page && arch_prepare_hugepage(page)) {
> @@ -2132,11 +2140,7 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
>  			void __user *buffer,
>  			size_t *length, loff_t *ppos)
>  {
> -	proc_dointvec(table, write, buffer, length, ppos);
> -	if (hugepages_treat_as_movable)
> -		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
> -	else
> -		htlb_alloc_mask = GFP_HIGHUSER;
> +	WARN_ON_ONCE("This knob is obsolete and has no effect. It is scheduled for removal.\n");
>  	return 0;
>  }
>
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
