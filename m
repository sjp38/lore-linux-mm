Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A056D6B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 18:51:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l39so2468177wrl.20
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 15:51:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor3145517wrd.53.2017.10.01.15.51.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Oct 2017 15:51:20 -0700 (PDT)
Date: Mon, 2 Oct 2017 00:51:11 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: [PATCH] mm,hugetlb,migration: don't migrate kernelcore hugepages
Message-ID: <20171001225111.GA16432@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@kernel.org, cdall@linaro.org, mchehab@kernel.org, zohar@linux.vnet.ibm.com, marc.zyngier@arm.com, mhocko@suse.com, rientjes@google.com, hannes@cmpxchg.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, aarcange@redhat.com, gerald.schaefer@de.ibm.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, will.deacon@arm.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This attempts to bring more flexibility to how hugepages are allocated
by making it possible to decide whether we want the hugepages to be
allocated from ZONE_MOVABLE or to the zone allocated by the "kernelcore="
boot parameter for non-movable allocations.

A new boot parameter is introduced, "hugepages_movable=", this sets the
default value for the "hugepages_treat_as_movable" sysctl. This allows
us to determine the zone for hugepages allocated at boot time. It only
affects 2M hugepages allocated at boot time for now because 1G
hugepages are allocated much earlier in the boot process and ignore
this sysctl completely.

The "hugepages_treat_as_movable" sysctl is also turned into a mandatory
setting that all hugepage allocations at runtime must respect (both
2M and 1G sized hugepages). The default value is changed to "1" to
preserve the existing behavior that if hugepage migration is supported,
then the pages will be allocated from ZONE_MOVABLE.

Note however if not enough contiguous memory is present in ZONE_MOVABLE
then the allocation will fallback to the non-movable zone and those
pages will not be migratable.

The implementation is a bit dirty so obviously I'm open to suggestions
for a better way to implement this behavior, or comments whether the whole
idea is fundamentally __wrong__.

Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
---
 Documentation/admin-guide/kernel-parameters.txt |  8 ++++++++
 Documentation/sysctl/vm.txt                     |  3 +++
 mm/hugetlb.c                                    | 15 +++++++++++++--
 mm/migrate.c                                    |  8 +++++++-
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 05496622b4ef..25116d32d59e 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1318,6 +1318,14 @@
 			x86-64 are 2M (when the CPU supports "pse") and 1G
 			(when the CPU supports the "pdpe1gb" cpuinfo flag).
 
+	hugepages_movable=
+			[HW,IA-64,PPC,X86-64] Default value for the
+			hugepages_treat_as_movable sysctl (default is 1).
+			When 1 this will attempt to allocate hugepages from
+			ZONE_MOVABLE, if 0 it will attempt to allocate hugepages
+			from the non-movable zone created with the "kernelcore="
+			kernel parameter.
+
 	hvc_iucv=	[S390] Number of z/VM IUCV hypervisor console (HVC)
 			       terminal devices. Valid values: 0..8
 	hvc_iucv_allow=	[S390] Comma-separated list of z/VM user IDs.
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a9ef4e..4c5755a1cf9f 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -267,6 +267,9 @@ or not. If set to non-zero, hugepages can be allocated from ZONE_MOVABLE.
 ZONE_MOVABLE is created when kernel boot parameter kernelcore= is specified,
 so this parameter has no effect if used without kernelcore=.
 
+The default value for this sysctl can also be set via the hugepages_movable=
+kernel boot parameter (to 0 or 1), default is 1.
+
 Hugepage migration is now available in some situations which depend on the
 architecture and/or the hugepage size. If a hugepage supports migration,
 allocation from ZONE_MOVABLE is always enabled for the hugepage regardless
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 424b0ef08a60..5d4efdadbd56 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -36,7 +36,7 @@
 #include <linux/userfaultfd_k.h>
 #include "internal.h"
 
-int hugepages_treat_as_movable;
+int hugepages_treat_as_movable = 1;
 
 int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
@@ -926,7 +926,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 /* Movability of hugepages depends on migration support. */
 static inline gfp_t htlb_alloc_mask(struct hstate *h)
 {
-	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
+	if (hugepages_treat_as_movable && hugepage_migration_supported(h))
 		return GFP_HIGHUSER_MOVABLE;
 	else
 		return GFP_HIGHUSER;
@@ -2805,6 +2805,17 @@ static int __init hugetlb_init(void)
 }
 subsys_initcall(hugetlb_init);
 
+static int __init hugepages_movable(char *str)
+{
+	if (!strncmp(str, "0", 1))
+		hugepages_treat_as_movable = 0;
+	else if (!strncmp(str, "1", 1))
+		hugepages_treat_as_movable = 1;
+
+	return 1;
+}
+__setup("hugepages_movable=", hugepages_movable);
+
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_bad_size(void)
 {
diff --git a/mm/migrate.c b/mm/migrate.c
index 6954c1435833..23946d88e533 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1266,6 +1266,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	int page_was_mapped = 0;
 	struct page *new_hpage;
 	struct anon_vma *anon_vma = NULL;
+	bool zone_movable_present;
 
 	/*
 	 * Movability of hugepages depends on architectures and hugepage size.
@@ -1274,7 +1275,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	 * tables or check whether the hugepage is pmd-based or not before
 	 * kicking migration.
 	 */
-	if (!hugepage_migration_supported(page_hstate(hpage))) {
+	zone_movable_present = (NODE_DATA(page_to_nid(hpage))->node_zones[ZONE_MOVABLE].spanned_pages > 0);
+
+	if (!hugepage_migration_supported(page_hstate(hpage)) ||
+		zone_movable_present ?
+		!(zone_idx(page_zone(hpage)) == ZONE_MOVABLE) :
+			false) {
 		putback_active_hugepage(hpage);
 		return -ENOSYS;
 	}
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
