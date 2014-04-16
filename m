Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 000786B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 20:18:52 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so10152832pbb.14
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:18:52 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id 7si3247986pbe.3.2014.04.15.17.18.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Apr 2014 17:18:52 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [PATCH v4] mm: convert some level-less printks to pr_*
Date: Tue, 15 Apr 2014 17:18:30 -0700
Message-Id: <1397607510-16084-2-git-send-email-mitchelh@codeaurora.org>
In-Reply-To: <1397607510-16084-1-git-send-email-mitchelh@codeaurora.org>
References: <1397607510-16084-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

printk is meant to be used with an associated log level. There are some
instances of printk scattered around the mm code where the log level is
missing. Add a log level and adhere to suggestions by
scripts/checkpatch.pl by moving to the pr_* macros.

Also add the typical pr_fmt definition so that print statements can be
easily traced back to the modules where they occur, correlated one with
another, etc. This will require the removal of some (now redundant)
prefixes on a few print statements.

Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
---
 mm/bounce.c    |  7 +++++--
 mm/mempolicy.c |  5 ++++-
 mm/mmap.c      | 21 ++++++++++++---------
 mm/nommu.c     |  5 ++++-
 mm/vmscan.c    |  5 ++++-
 5 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/mm/bounce.c b/mm/bounce.c
index 523918b8c6..ab21ba203d 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -3,6 +3,8 @@
  * - Split from highmem.c
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/swap.h>
@@ -15,6 +17,7 @@
 #include <linux/hash.h>
 #include <linux/highmem.h>
 #include <linux/bootmem.h>
+#include <linux/printk.h>
 #include <asm/tlbflush.h>
 
 #include <trace/events/block.h>
@@ -34,7 +37,7 @@ static __init int init_emergency_pool(void)
 
 	page_pool = mempool_create_page_pool(POOL_SIZE, 0);
 	BUG_ON(!page_pool);
-	printk("bounce pool size: %d pages\n", POOL_SIZE);
+	pr_info("pool size: %d pages\n", POOL_SIZE);
 
 	return 0;
 }
@@ -86,7 +89,7 @@ int init_emergency_isa_pool(void)
 				       mempool_free_pages, (void *) 0);
 	BUG_ON(!isa_page_pool);
 
-	printk("isa bounce pool size: %d pages\n", ISA_POOL_SIZE);
+	pr_info("isa pool size: %d pages\n", ISA_POOL_SIZE);
 	return 0;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 78e1472933..d7c2e8fe01 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -65,6 +65,8 @@
    kernel is not always grateful with that.
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/mempolicy.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
@@ -91,6 +93,7 @@
 #include <linux/ctype.h>
 #include <linux/mm_inline.h>
 #include <linux/mmu_notifier.h>
+#include <linux/printk.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -2645,7 +2648,7 @@ void __init numa_policy_init(void)
 		node_set(prefer, interleave_nodes);
 
 	if (do_set_mempolicy(MPOL_INTERLEAVE, 0, &interleave_nodes))
-		printk("numa_policy_init: interleaving failed\n");
+		pr_err("%s: interleaving failed\n", __func__);
 
 	check_numabalancing_enable();
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index b1202cf81f..6bdf81669f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -6,6 +6,8 @@
  * Address space accounting code	<alan@lxorguk.ukuu.org.uk>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/backing-dev.h>
@@ -37,6 +39,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/memory.h>
+#include <linux/printk.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -361,20 +364,20 @@ static int browse_rb(struct rb_root *root)
 		struct vm_area_struct *vma;
 		vma = rb_entry(nd, struct vm_area_struct, vm_rb);
 		if (vma->vm_start < prev) {
-			printk("vm_start %lx prev %lx\n", vma->vm_start, prev);
+			pr_info("vm_start %lx prev %lx\n", vma->vm_start, prev);
 			bug = 1;
 		}
 		if (vma->vm_start < pend) {
-			printk("vm_start %lx pend %lx\n", vma->vm_start, pend);
+			pr_info("vm_start %lx pend %lx\n", vma->vm_start, pend);
 			bug = 1;
 		}
 		if (vma->vm_start > vma->vm_end) {
-			printk("vm_end %lx < vm_start %lx\n",
+			pr_info("vm_end %lx < vm_start %lx\n",
 				vma->vm_end, vma->vm_start);
 			bug = 1;
 		}
 		if (vma->rb_subtree_gap != vma_compute_subtree_gap(vma)) {
-			printk("free gap %lx, correct %lx\n",
+			pr_info("free gap %lx, correct %lx\n",
 			       vma->rb_subtree_gap,
 			       vma_compute_subtree_gap(vma));
 			bug = 1;
@@ -388,7 +391,7 @@ static int browse_rb(struct rb_root *root)
 	for (nd = pn; nd; nd = rb_prev(nd))
 		j++;
 	if (i != j) {
-		printk("backwards %d, forwards %d\n", j, i);
+		pr_info("backwards %d, forwards %d\n", j, i);
 		bug = 1;
 	}
 	return bug ? -1 : i;
@@ -423,17 +426,17 @@ static void validate_mm(struct mm_struct *mm)
 		i++;
 	}
 	if (i != mm->map_count) {
-		printk("map_count %d vm_next %d\n", mm->map_count, i);
+		pr_info("map_count %d vm_next %d\n", mm->map_count, i);
 		bug = 1;
 	}
 	if (highest_address != mm->highest_vm_end) {
-		printk("mm->highest_vm_end %lx, found %lx\n",
+		pr_info("mm->highest_vm_end %lx, found %lx\n",
 		       mm->highest_vm_end, highest_address);
 		bug = 1;
 	}
 	i = browse_rb(&mm->mm_rb);
 	if (i != mm->map_count) {
-		printk("map_count %d rb %d\n", mm->map_count, i);
+		pr_info("map_count %d rb %d\n", mm->map_count, i);
 		bug = 1;
 	}
 	BUG_ON(bug);
@@ -3252,7 +3255,7 @@ static struct notifier_block reserve_mem_nb = {
 static int __meminit init_reserve_notifier(void)
 {
 	if (register_hotmemory_notifier(&reserve_mem_nb))
-		printk("Failed registering memory add/remove notifier for admin reserve");
+		pr_err("Failed registering memory add/remove notifier for admin reserve\n");
 
 	return 0;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 85f8d6698d..b78e3a8f5e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -13,6 +13,8 @@
  *  Copyright (c) 2007-2010 Paul Mundt <lethal@linux-sh.org>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/vmacache.h>
@@ -32,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/audit.h>
 #include <linux/sched/sysctl.h>
+#include <linux/printk.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -1246,7 +1249,7 @@ error_free:
 	return ret;
 
 enomem:
-	printk("Allocation of length %lu from process %d (%s) failed\n",
+	pr_err("Allocation of length %lu from process %d (%s) failed\n",
 	       len, current->pid, current->comm);
 	show_free_areas(0);
 	return -ENOMEM;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b6497eda8..60551c0e38 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -11,6 +11,8 @@
  *  Multiqueue VM started 5.8.00, Rik van Riel.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/gfp.h>
@@ -43,6 +45,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/printk.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -477,7 +480,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 		if (page_has_private(page)) {
 			if (try_to_free_buffers(page)) {
 				ClearPageDirty(page);
-				printk("%s: orphaned page\n", __func__);
+				pr_info("%s: orphaned page\n", __func__);
 				return PAGE_CLEAN;
 			}
 		}
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
