Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8AECF828DF
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 09:51:27 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id xg9so15101962igb.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 06:51:27 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id l69si5938310iod.80.2016.02.10.06.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 06:51:26 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/3] mm: dedupclicate memory overcommitment code
Date: Wed, 10 Feb 2016 17:52:20 +0300
Message-ID: <1455115941-8261-2-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Currently we have two copies of the same code which implements memory
overcommitment logic. Let's move it into mm/util.c and hence avoid
duplication. No functional changes here.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/mmap.c  | 124 -------------------------------------------------------------
 mm/nommu.c | 116 ---------------------------------------------------------
 mm/util.c  | 124 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 124 insertions(+), 240 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 4afb2a2..f088c60 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -122,130 +122,6 @@ void vma_set_page_prot(struct vm_area_struct *vma)
 	}
 }
 
-
-int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
-int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
-unsigned long sysctl_overcommit_kbytes __read_mostly;
-int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
-unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
-/*
- * Make sure vm_committed_as in one cacheline and not cacheline shared with
- * other variables. It can be updated by several CPUs frequently.
- */
-struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
-
-/*
- * The global memory commitment made in the system can be a metric
- * that can be used to drive ballooning decisions when Linux is hosted
- * as a guest. On Hyper-V, the host implements a policy engine for dynamically
- * balancing memory across competing virtual machines that are hosted.
- * Several metrics drive this policy engine including the guest reported
- * memory commitment.
- */
-unsigned long vm_memory_committed(void)
-{
-	return percpu_counter_read_positive(&vm_committed_as);
-}
-EXPORT_SYMBOL_GPL(vm_memory_committed);
-
-/*
- * Check that a process has enough memory to allocate a new virtual
- * mapping. 0 means there is enough memory for the allocation to
- * succeed and -ENOMEM implies there is not.
- *
- * We currently support three overcommit policies, which are set via the
- * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
- *
- * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
- * Additional code 2002 Jul 20 by Robert Love.
- *
- * cap_sys_admin is 1 if the process has admin privileges, 0 otherwise.
- *
- * Note this is a helper function intended to be used by LSMs which
- * wish to use this logic.
- */
-int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
-{
-	long free, allowed, reserve;
-
-	VM_WARN_ONCE(percpu_counter_read(&vm_committed_as) <
-			-(s64)vm_committed_as_batch * num_online_cpus(),
-			"memory commitment underflow");
-
-	vm_acct_memory(pages);
-
-	/*
-	 * Sometimes we want to use more memory than we have
-	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
-		return 0;
-
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
-		free = global_page_state(NR_FREE_PAGES);
-		free += global_page_state(NR_FILE_PAGES);
-
-		/*
-		 * shmem pages shouldn't be counted as free in this
-		 * case, they can't be purged, only swapped out, and
-		 * that won't affect the overall amount of available
-		 * memory in the system.
-		 */
-		free -= global_page_state(NR_SHMEM);
-
-		free += get_nr_swap_pages();
-
-		/*
-		 * Any slabs which are created with the
-		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
-		 * which are reclaimable, under pressure.  The dentry
-		 * cache and most inode caches should fall into this
-		 */
-		free += global_page_state(NR_SLAB_RECLAIMABLE);
-
-		/*
-		 * Leave reserved pages. The pages are not for anonymous pages.
-		 */
-		if (free <= totalreserve_pages)
-			goto error;
-		else
-			free -= totalreserve_pages;
-
-		/*
-		 * Reserve some for root
-		 */
-		if (!cap_sys_admin)
-			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
-
-		if (free > pages)
-			return 0;
-
-		goto error;
-	}
-
-	allowed = vm_commit_limit();
-	/*
-	 * Reserve some for root
-	 */
-	if (!cap_sys_admin)
-		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
-
-	/*
-	 * Don't let a single process grow so big a user can't recover
-	 */
-	if (mm) {
-		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
-		allowed -= min_t(long, mm->total_vm / 32, reserve);
-	}
-
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
-		return 0;
-error:
-	vm_unacct_memory(pages);
-
-	return -ENOMEM;
-}
-
 /*
  * Requires inode->i_mapping->i_mmap_rwsem
  */
diff --git a/mm/nommu.c b/mm/nommu.c
index 9bdf8b1..6402f27 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -47,33 +47,11 @@ struct page *mem_map;
 unsigned long max_mapnr;
 EXPORT_SYMBOL(max_mapnr);
 unsigned long highest_memmap_pfn;
-struct percpu_counter vm_committed_as;
-int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
-int sysctl_overcommit_ratio = 50; /* default is 50% */
-unsigned long sysctl_overcommit_kbytes __read_mostly;
-int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
-unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
-unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
 
-/*
- * The global memory commitment made in the system can be a metric
- * that can be used to drive ballooning decisions when Linux is hosted
- * as a guest. On Hyper-V, the host implements a policy engine for dynamically
- * balancing memory across competing virtual machines that are hosted.
- * Several metrics drive this policy engine including the guest reported
- * memory commitment.
- */
-unsigned long vm_memory_committed(void)
-{
-	return percpu_counter_read_positive(&vm_committed_as);
-}
-
-EXPORT_SYMBOL_GPL(vm_memory_committed);
-
 EXPORT_SYMBOL(mem_map);
 
 /* list of mapped, potentially shareable regions */
@@ -1828,100 +1806,6 @@ void unmap_mapping_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
-/*
- * Check that a process has enough memory to allocate a new virtual
- * mapping. 0 means there is enough memory for the allocation to
- * succeed and -ENOMEM implies there is not.
- *
- * We currently support three overcommit policies, which are set via the
- * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
- *
- * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
- * Additional code 2002 Jul 20 by Robert Love.
- *
- * cap_sys_admin is 1 if the process has admin privileges, 0 otherwise.
- *
- * Note this is a helper function intended to be used by LSMs which
- * wish to use this logic.
- */
-int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
-{
-	long free, allowed, reserve;
-
-	vm_acct_memory(pages);
-
-	/*
-	 * Sometimes we want to use more memory than we have
-	 */
-	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
-		return 0;
-
-	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
-		free = global_page_state(NR_FREE_PAGES);
-		free += global_page_state(NR_FILE_PAGES);
-
-		/*
-		 * shmem pages shouldn't be counted as free in this
-		 * case, they can't be purged, only swapped out, and
-		 * that won't affect the overall amount of available
-		 * memory in the system.
-		 */
-		free -= global_page_state(NR_SHMEM);
-
-		free += get_nr_swap_pages();
-
-		/*
-		 * Any slabs which are created with the
-		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
-		 * which are reclaimable, under pressure.  The dentry
-		 * cache and most inode caches should fall into this
-		 */
-		free += global_page_state(NR_SLAB_RECLAIMABLE);
-
-		/*
-		 * Leave reserved pages. The pages are not for anonymous pages.
-		 */
-		if (free <= totalreserve_pages)
-			goto error;
-		else
-			free -= totalreserve_pages;
-
-		/*
-		 * Reserve some for root
-		 */
-		if (!cap_sys_admin)
-			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
-
-		if (free > pages)
-			return 0;
-
-		goto error;
-	}
-
-	allowed = vm_commit_limit();
-	/*
-	 * Reserve some 3% for root
-	 */
-	if (!cap_sys_admin)
-		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
-
-	/*
-	 * Don't let a single process grow so big a user can't recover
-	 */
-	if (mm) {
-		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
-		allowed -= min_t(long, mm->total_vm / 32, reserve);
-	}
-
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
-		return 0;
-
-error:
-	vm_unacct_memory(pages);
-
-	return -ENOMEM;
-}
-
 int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	BUG();
diff --git a/mm/util.c b/mm/util.c
index 4fb14ca..47a57e5 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -396,6 +396,13 @@ int __page_mapcount(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__page_mapcount);
 
+int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;
+int sysctl_overcommit_ratio __read_mostly = 50;
+unsigned long sysctl_overcommit_kbytes __read_mostly;
+int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
+unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
+unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
+
 int overcommit_ratio_handler(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp,
 			     loff_t *ppos)
@@ -437,6 +444,123 @@ unsigned long vm_commit_limit(void)
 	return allowed;
 }
 
+/*
+ * Make sure vm_committed_as in one cacheline and not cacheline shared with
+ * other variables. It can be updated by several CPUs frequently.
+ */
+struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
+
+/*
+ * The global memory commitment made in the system can be a metric
+ * that can be used to drive ballooning decisions when Linux is hosted
+ * as a guest. On Hyper-V, the host implements a policy engine for dynamically
+ * balancing memory across competing virtual machines that are hosted.
+ * Several metrics drive this policy engine including the guest reported
+ * memory commitment.
+ */
+unsigned long vm_memory_committed(void)
+{
+	return percpu_counter_read_positive(&vm_committed_as);
+}
+EXPORT_SYMBOL_GPL(vm_memory_committed);
+
+/*
+ * Check that a process has enough memory to allocate a new virtual
+ * mapping. 0 means there is enough memory for the allocation to
+ * succeed and -ENOMEM implies there is not.
+ *
+ * We currently support three overcommit policies, which are set via the
+ * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
+ *
+ * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
+ * Additional code 2002 Jul 20 by Robert Love.
+ *
+ * cap_sys_admin is 1 if the process has admin privileges, 0 otherwise.
+ *
+ * Note this is a helper function intended to be used by LSMs which
+ * wish to use this logic.
+ */
+int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
+{
+	long free, allowed, reserve;
+
+	VM_WARN_ONCE(percpu_counter_read(&vm_committed_as) <
+			-(s64)vm_committed_as_batch * num_online_cpus(),
+			"memory commitment underflow");
+
+	vm_acct_memory(pages);
+
+	/*
+	 * Sometimes we want to use more memory than we have
+	 */
+	if (sysctl_overcommit_memory == OVERCOMMIT_ALWAYS)
+		return 0;
+
+	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
+		free = global_page_state(NR_FREE_PAGES);
+		free += global_page_state(NR_FILE_PAGES);
+
+		/*
+		 * shmem pages shouldn't be counted as free in this
+		 * case, they can't be purged, only swapped out, and
+		 * that won't affect the overall amount of available
+		 * memory in the system.
+		 */
+		free -= global_page_state(NR_SHMEM);
+
+		free += get_nr_swap_pages();
+
+		/*
+		 * Any slabs which are created with the
+		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
+		 * which are reclaimable, under pressure.  The dentry
+		 * cache and most inode caches should fall into this
+		 */
+		free += global_page_state(NR_SLAB_RECLAIMABLE);
+
+		/*
+		 * Leave reserved pages. The pages are not for anonymous pages.
+		 */
+		if (free <= totalreserve_pages)
+			goto error;
+		else
+			free -= totalreserve_pages;
+
+		/*
+		 * Reserve some for root
+		 */
+		if (!cap_sys_admin)
+			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
+
+		if (free > pages)
+			return 0;
+
+		goto error;
+	}
+
+	allowed = vm_commit_limit();
+	/*
+	 * Reserve some for root
+	 */
+	if (!cap_sys_admin)
+		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
+
+	/*
+	 * Don't let a single process grow so big a user can't recover
+	 */
+	if (mm) {
+		reserve = sysctl_user_reserve_kbytes >> (PAGE_SHIFT - 10);
+		allowed -= min_t(long, mm->total_vm / 32, reserve);
+	}
+
+	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+		return 0;
+error:
+	vm_unacct_memory(pages);
+
+	return -ENOMEM;
+}
+
 /**
  * get_cmdline() - copy the cmdline value to a buffer.
  * @task:     the task whose cmdline value to copy.
-- 
2.4.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
