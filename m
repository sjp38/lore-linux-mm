From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 8/8] prepare to remove
 /proc/sys/vm/hugepages_treat_as_movable
Date: Wed, 24 Jul 2013 11:46:43 +0800
Message-ID: <5388.04759639806$1374637628@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1q2R-0006yX-8j
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 05:46:55 +0200
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7779F6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:46:53 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 13:37:12 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8D4123578051
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:46:47 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O3VEaj55312540
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:31:15 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O3kjCS016868
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:46:46 +1000
Content-Disposition: inline
In-Reply-To: <1374183272-10153-9-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:32PM -0400, Naoya Horiguchi wrote:
>Now hugepages are definitely movable. So allocating hugepages from
>ZONE_MOVABLE is natural and we have no reason to keep this parameter.
>In order to allow userspace to prepare for the removal, let's leave
>this sysctl handler as noop for a while.
>
>ChangeLog v3:
> - use WARN_ON_ONCE
>
>ChangeLog v2:
> - shift to noop function instead of completely removing the parameter
> - rename patch title
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> Documentation/sysctl/vm.txt | 13 ++-----------
> mm/hugetlb.c                | 17 ++++++-----------
> 2 files changed, 8 insertions(+), 22 deletions(-)
>
>diff --git v3.11-rc1.orig/Documentation/sysctl/vm.txt v3.11-rc1/Documentation/sysctl/vm.txt
>index 36ecc26..6e211a1 100644
>--- v3.11-rc1.orig/Documentation/sysctl/vm.txt
>+++ v3.11-rc1/Documentation/sysctl/vm.txt
>@@ -200,17 +200,8 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
>
> hugepages_treat_as_movable
>
>-This parameter is only useful when kernelcore= is specified at boot time to
>-create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
>-are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
>-value written to hugepages_treat_as_movable allows huge pages to be allocated
>-from ZONE_MOVABLE.
>-
>-Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
>-pages pool can easily grow or shrink within. Assuming that applications are
>-not running that mlock() a lot of memory, it is likely the huge pages pool
>-can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
>-into nr_hugepages and triggering page reclaim.
>+This parameter is obsolete and planned to be removed. The value has no effect
>+on kernel's behavior.
>
> ==============================================================
>
>diff --git v3.11-rc1.orig/mm/hugetlb.c v3.11-rc1/mm/hugetlb.c
>index 9575e8a..aab5aef 100644
>--- v3.11-rc1.orig/mm/hugetlb.c
>+++ v3.11-rc1/mm/hugetlb.c
>@@ -34,7 +34,6 @@
> #include "internal.h"
>
> const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
>-static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
> unsigned long hugepages_treat_as_movable;
>
> int hugetlb_max_hstate __read_mostly;
>@@ -546,7 +545,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> retry_cpuset:
> 	cpuset_mems_cookie = get_mems_allowed();
> 	zonelist = huge_zonelist(vma, address,
>-					htlb_alloc_mask, &mpol, &nodemask);
>+					GFP_HIGHUSER_MOVABLE, &mpol, &nodemask);
> 	/*
> 	 * A child process with MAP_PRIVATE mappings created by their parent
> 	 * have no page reserves. This check ensures that reservations are
>@@ -562,7 +561,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>
> 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> 						MAX_NR_ZONES - 1, nodemask) {
>-		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
>+		if (cpuset_zone_allowed_softwall(zone, GFP_HIGHUSER_MOVABLE)) {
> 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
> 			if (page) {
> 				if (!avoid_reserve)
>@@ -719,7 +718,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
> 		return NULL;
>
> 	page = alloc_pages_exact_node(nid,
>-		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
>+		GFP_HIGHUSER_MOVABLE|__GFP_COMP|__GFP_THISNODE|
> 						__GFP_REPEAT|__GFP_NOWARN,
> 		huge_page_order(h));
> 	if (page) {
>@@ -944,12 +943,12 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
> 	spin_unlock(&hugetlb_lock);
>
> 	if (nid == NUMA_NO_NODE)
>-		page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
>+		page = alloc_pages(GFP_HIGHUSER_MOVABLE|__GFP_COMP|
> 				   __GFP_REPEAT|__GFP_NOWARN,
> 				   huge_page_order(h));
> 	else
> 		page = alloc_pages_exact_node(nid,
>-			htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
>+			GFP_HIGHUSER_MOVABLE|__GFP_COMP|__GFP_THISNODE|
> 			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
>
> 	if (page && arch_prepare_hugepage(page)) {
>@@ -2128,11 +2127,7 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
> 			void __user *buffer,
> 			size_t *length, loff_t *ppos)
> {
>-	proc_dointvec(table, write, buffer, length, ppos);
>-	if (hugepages_treat_as_movable)
>-		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
>-	else
>-		htlb_alloc_mask = GFP_HIGHUSER;
>+	WARN_ON_ONCE("This knob is obsolete and has no effect. It is scheduled for removal.\n");
> 	return 0;
> }
>
>-- 
>1.8.3.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
