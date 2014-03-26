Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 77C696B0035
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 19:49:53 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2626380pad.14
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 16:49:53 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id td10si118184pac.99.2014.03.26.16.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Mar 2014 16:49:52 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [PATCH] mm: convert some level-less printks to pr_*
Date: Wed, 26 Mar 2014 16:49:43 -0700
Message-Id: <1395877783-18910-2-git-send-email-mitchelh@codeaurora.org>
In-Reply-To: <1395877783-18910-1-git-send-email-mitchelh@codeaurora.org>
References: <1395877783-18910-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

printk is meant to be used with an associated log level. There are some
instances of printk scattered around the mm code where the log level is
missing. Add a log level and adhere to suggestions by
scripts/checkpatch.pl by moving to the pr_* macros.

Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
---
 mm/bounce.c    |  5 +++--
 mm/mempolicy.c |  3 ++-
 mm/mmap.c      | 19 ++++++++++---------
 mm/nommu.c     |  3 ++-
 mm/slub.c      |  7 ++++---
 mm/vmscan.c    |  3 ++-
 6 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/mm/bounce.c b/mm/bounce.c
index 523918b8c6..7fca8ef660 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -15,6 +15,7 @@
 #include <linux/hash.h>
 #include <linux/highmem.h>
 #include <linux/bootmem.h>
+#include <linux/printk.h>
 #include <asm/tlbflush.h>
 
 #include <trace/events/block.h>
@@ -34,7 +35,7 @@ static __init int init_emergency_pool(void)
 
 	page_pool = mempool_create_page_pool(POOL_SIZE, 0);
 	BUG_ON(!page_pool);
-	printk("bounce pool size: %d pages\n", POOL_SIZE);
+	pr_info("bounce pool size: %d pages\n", POOL_SIZE);
 
 	return 0;
 }
@@ -86,7 +87,7 @@ int init_emergency_isa_pool(void)
 				       mempool_free_pages, (void *) 0);
 	BUG_ON(!isa_page_pool);
 
-	printk("isa bounce pool size: %d pages\n", ISA_POOL_SIZE);
+	pr_info("isa bounce pool size: %d pages\n", ISA_POOL_SIZE);
 	return 0;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ae3c8f3595..81ae17cf92 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -91,6 +91,7 @@
 #include <linux/ctype.h>
 #include <linux/mm_inline.h>
 #include <linux/mmu_notifier.h>
+#include <linux/printk.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -2751,7 +2752,7 @@ void __init numa_policy_init(void)
 		node_set(prefer, interleave_nodes);
 
 	if (do_set_mempolicy(MPOL_INTERLEAVE, 0, &interleave_nodes))
-		printk("numa_policy_init: interleaving failed\n");
+		pr_warn("numa_policy_init: interleaving failed\n");
 
 	check_numabalancing_enable();
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index 20ff0c3327..52f85997e0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -36,6 +36,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/memory.h>
+#include <linux/printk.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -360,20 +361,20 @@ static int browse_rb(struct rb_root *root)
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
@@ -387,7 +388,7 @@ static int browse_rb(struct rb_root *root)
 	for (nd = pn; nd; nd = rb_prev(nd))
 		j++;
 	if (i != j) {
-		printk("backwards %d, forwards %d\n", j, i);
+		pr_info("backwards %d, forwards %d\n", j, i);
 		bug = 1;
 	}
 	return bug ? -1 : i;
@@ -422,17 +423,17 @@ void validate_mm(struct mm_struct *mm)
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
@@ -3237,7 +3238,7 @@ static struct notifier_block reserve_mem_nb = {
 static int __meminit init_reserve_notifier(void)
 {
 	if (register_hotmemory_notifier(&reserve_mem_nb))
-		printk("Failed registering memory add/remove notifier for admin reserve");
+		pr_info("Failed registering memory add/remove notifier for admin reserve");
 
 	return 0;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 8740213b16..331dede25f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -30,6 +30,7 @@
 #include <linux/syscalls.h>
 #include <linux/audit.h>
 #include <linux/sched/sysctl.h>
+#include <linux/printk.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -1241,7 +1242,7 @@ error_free:
 	return ret;
 
 enomem:
-	printk("Allocation of length %lu from process %d (%s) failed\n",
+	pr_warn("Allocation of length %lu from process %d (%s) failed\n",
 	       len, current->pid, current->comm);
 	show_free_areas(0);
 	return -ENOMEM;
diff --git a/mm/slub.c b/mm/slub.c
index 25f14ad8f8..58d98d6c7c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -33,6 +33,7 @@
 #include <linux/stacktrace.h>
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
+#include <linux/printk.h>
 
 #include <trace/events/kmem.h>
 
@@ -1774,15 +1775,15 @@ static inline void note_cmpxchg_failure(const char *n,
 
 #ifdef CONFIG_PREEMPT
 	if (tid_to_cpu(tid) != tid_to_cpu(actual_tid))
-		printk("due to cpu change %d -> %d\n",
+		pr_info("due to cpu change %d -> %d\n",
 			tid_to_cpu(tid), tid_to_cpu(actual_tid));
 	else
 #endif
 	if (tid_to_event(tid) != tid_to_event(actual_tid))
-		printk("due to cpu running other code. Event %ld->%ld\n",
+		pr_info("due to cpu running other code. Event %ld->%ld\n",
 			tid_to_event(tid), tid_to_event(actual_tid));
 	else
-		printk("for unknown reason: actual=%lx was=%lx target=%lx\n",
+		pr_info("for unknown reason: actual=%lx was=%lx target=%lx\n",
 			actual_tid, tid, next_tid(tid));
 #endif
 	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b4096..67c3db4735 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -43,6 +43,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/printk.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -477,7 +478,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
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
