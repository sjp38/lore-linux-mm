Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7CBD26B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 21:36:58 -0400 (EDT)
Date: Wed, 14 Aug 2013 21:36:48 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1376530608-xro7a6sr-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <520c15c5.8x7UU9fMfWfVhdiO%akpm@linux-foundation.org>
References: <520c15c5.8x7UU9fMfWfVhdiO%akpm@linux-foundation.org>
Subject: Re: +
 mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch added to -mm
 tree
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, riel@redhat.com, mhocko@suse.cz, mgorman@suse.de, liwanp@linux.vnet.ibm.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, dhillf@gmail.com, aneesh.kumar@linux.vnet.ibm.com, ak@linux.intel.com, linux-mm@kvack.org

On Wed, Aug 14, 2013 at 04:41:57PM -0700, akpm@linux-foundation.org wrote:
> Subject: + mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch added to -mm tree
> To: n-horiguchi@ah.jp.nec.com,ak@linux.intel.com,aneesh.kumar@linux.vnet.ibm.com,dhillf@gmail.com,hughd@google.com,kosaki.motohiro@jp.fujitsu.com,liwanp@linux.vnet.ibm.com,mgorman@suse.de,mhocko@suse.cz,riel@redhat.com
> From: akpm@linux-foundation.org
> Date: Wed, 14 Aug 2013 16:41:57 -0700
> 
> 
> The patch titled
>      Subject: mm: prepare to remove /proc/sys/vm/hugepages_treat_as_movable
> has been added to the -mm tree.  Its filename is
>      mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: mm: prepare to remove /proc/sys/vm/hugepages_treat_as_movable
> 
> Now we have extended hugepage migration and it's opened to many users of
> page migration, which is a good reason to consider hugepage as movable. 
> So we can go to the direction to remove this parameter.  In order to allow
> userspace to prepare for the removal, let's leave this sysctl handler as
> noop for a while.
> 
> Note that hugepage migration is available only for the architectures which
> implement hugepage on a pmd basis.  On the other architectures, allocating
> hugepages from MOVABLE is not a good idea because it can break memory
> hotremove (which expects that all pages of ZONE_MOVABLE are movable.) So
> we choose GFP flags in accordance with mobility of hugepage.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Hillf Danton <dhillf@gmail.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

According to the discussion over this patch, I revised it with the following
one. (http://thread.gmane.org/gmane.linux.kernel.mm/105114/focus=105255)

So could you replace with it?
# I took off Acked/Reviewed on it because I added non-trivial changes.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 12 Aug 2013 11:49:37 -0400
Subject: [PATCH] hugetlb: make htlb_alloc_mask dependent on migration support

Now hugepage migration is enabled, although restricted on pmd-based hugepages
for now (due to lack of testing.) So we should allocate migratable hugepages
from ZONE_MOVABLE if possible.

This patch makes GFP flags in hugepage allocation dependent on migration
support, not only the value of hugepages_treat_as_movable.
It provides no change on the behavior for architectures which do not support
hugepage migration,

ChangeLog v5:
 - choose GFP flags in accordance with mobility of hugepage
 - keep hugepages_treat_as_movable

ChangeLog v3:
 - use WARN_ON_ONCE

ChangeLog v2:
 - shift to noop function instead of completely removing the parameter
 - rename patch title

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 Documentation/sysctl/vm.txt | 30 +++++++++++++++++++-----------
 kernel/sysctl.c             |  2 +-
 mm/hugetlb.c                | 32 ++++++++++++++------------------
 3 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 36ecc26..79a797e 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -200,17 +200,25 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
 
 hugepages_treat_as_movable
 
-This parameter is only useful when kernelcore= is specified at boot time to
-create ZONE_MOVABLE for pages that may be reclaimed or migrated. Huge pages
-are not movable so are not normally allocated from ZONE_MOVABLE. A non-zero
-value written to hugepages_treat_as_movable allows huge pages to be allocated
-from ZONE_MOVABLE.
-
-Once enabled, the ZONE_MOVABLE is treated as an area of memory the huge
-pages pool can easily grow or shrink within. Assuming that applications are
-not running that mlock() a lot of memory, it is likely the huge pages pool
-can grow to the size of ZONE_MOVABLE by repeatedly entering the desired value
-into nr_hugepages and triggering page reclaim.
+This parameter controls whether we can allocate hugepages from ZONE_MOVABLE
+or not. If set to non-zero, hugepages can be allocated from ZONE_MOVABLE.
+ZONE_MOVABLE is created when kernel boot parameter kernelcore= is specified,
+so this parameter has no effect if used without kernelcore=.
+
+Hugepage migration is now available in some situations which depend on the
+architecture and/or the hugepage size. If a hugepage supports migration,
+allocation from ZONE_MOVABLE is always enabled for the hugepage regardless
+of the value of this parameter.
+IOW, this parameter affects only non-migratable hugepages.
+
+Assuming that hugepages are not migratable in your system, one usecase of
+this parameter is that users can make hugepage pool more extensible by
+enabling the allocation from ZONE_MOVABLE. This is because on ZONE_MOVABLE
+page reclaim/migration/compaction work more and you can get contiguous
+memory more likely. Note that using ZONE_MOVABLE for non-migratable
+hugepages can do harm to other features like memory hotremove (because
+memory hotremove expects that memory blocks on ZONE_MOVABLE are always
+removable,) so it's a trade-off responsible for the users.
 
 ==============================================================
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ac09d98..b4b32f5 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1225,7 +1225,7 @@ static struct ctl_table vm_table[] = {
 		.data		= &hugepages_treat_as_movable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= hugetlb_treat_movable_handler,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "nr_overcommit_hugepages",
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3121915..364f745 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -34,7 +34,6 @@
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
 int hugetlb_max_hstate __read_mostly;
@@ -535,6 +534,15 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 	return page;
 }
 
+/* Movability of hugepages depends on migration support. */
+static inline int htlb_alloc_mask(struct hstate *h)
+{
+	if (hugepages_treat_as_movable || hugepage_migration_support(h))
+		return GFP_HIGHUSER_MOVABLE;
+	else
+		return GFP_HIGHUSER;
+}
+
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
@@ -550,7 +558,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
 	zonelist = huge_zonelist(vma, address,
-					htlb_alloc_mask, &mpol, &nodemask);
+					htlb_alloc_mask(h), &mpol, &nodemask);
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
@@ -566,7 +574,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
-		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
+		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask(h))) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
 				if (!avoid_reserve)
@@ -723,7 +731,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 		return NULL;
 
 	page = alloc_pages_exact_node(nid,
-		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
@@ -948,12 +956,12 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 	spin_unlock(&hugetlb_lock);
 
 	if (nid == NUMA_NO_NODE)
-		page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
+		page = alloc_pages(htlb_alloc_mask(h)|__GFP_COMP|
 				   __GFP_REPEAT|__GFP_NOWARN,
 				   huge_page_order(h));
 	else
 		page = alloc_pages_exact_node(nid,
-			htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
+			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
 
 	if (page && arch_prepare_hugepage(page)) {
@@ -2128,18 +2136,6 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
 }
 #endif /* CONFIG_NUMA */
 
-int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
-			void __user *buffer,
-			size_t *length, loff_t *ppos)
-{
-	proc_dointvec(table, write, buffer, length, ppos);
-	if (hugepages_treat_as_movable)
-		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
-	else
-		htlb_alloc_mask = GFP_HIGHUSER;
-	return 0;
-}
-
 int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 			void __user *buffer,
 			size_t *length, loff_t *ppos)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
