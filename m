Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DBD186B0081
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:40:31 -0500 (EST)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1] mm: Export a function to get vm committed memory
Date: Tue, 13 Nov 2012 07:02:37 -0800
Message-Id: <1352818957-9229-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com, dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

It will be useful to be able to access global memory commitment from device
drivers. On the Hyper-V platform, the host has a policy engine to balance
the available physical memory amongst all competing virtual machines
hosted on a given node. This policy engine is driven by a number of metrics
including the memory commitment reported by the guests. The balloon driver
for Linux on Hyper-V will use this function to retrieve guest memory commitment.
This function is also used in Xen self ballooning code.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/xen/xen-selfballoon.c |    2 +-
 include/linux/mman.h          |    2 ++
 mm/mmap.c                     |   15 +++++++++++++++
 mm/nommu.c                    |   16 ++++++++++++++++
 4 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 7d041cb..2552d3e 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -222,7 +222,7 @@ static void selfballoon_process(struct work_struct *work)
 	if (xen_selfballooning_enabled) {
 		cur_pages = totalram_pages;
 		tgt_pages = cur_pages; /* default is no change */
-		goal_pages = percpu_counter_read_positive(&vm_committed_as) +
+		goal_pages = vm_memory_committed() +
 				totalreserve_pages +
 				MB2PAGES(selfballoon_reserved_mb);
 #ifdef CONFIG_FRONTSWAP
diff --git a/include/linux/mman.h b/include/linux/mman.h
index d09dde1..9aa863d 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -11,6 +11,8 @@ extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
 
+unsigned long vm_memory_committed(void);
+
 static inline void vm_acct_memory(long pages)
 {
 	percpu_counter_add(&vm_committed_as, pages);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2d94235..3dd0a17 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -89,6 +89,21 @@ int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
 
 /*
+ * The global memory commitment made in the system can be a metric
+ * that can be used to drive ballooning decisions when Linux is hosted
+ * as a guest. On Hyper-V, the host implements a policy engine for dynamically
+ * balancing memory across competing virtual machines that are hosted.
+ * Several metrics drive this policy engine including the guest reported
+ * memory commitment.
+ */
+
+unsigned long vm_memory_committed(void)
+{
+	return percpu_counter_read_positive(&vm_committed_as);
+}
+EXPORT_SYMBOL_GPL(vm_memory_committed);
+
+/*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to
  * succeed and -ENOMEM implies there is not.
diff --git a/mm/nommu.c b/mm/nommu.c
index 45131b4..f11e703 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -66,6 +66,22 @@ int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
 
+/*
+ * The global memory commitment made in the system can be a metric
+ * that can be used to drive ballooning decisions when Linux is hosted
+ * as a guest. On Hyper-V, the host implements a policy engine for dynamically
+ * balancing memory across competing virtual machines that are hosted.
+ * Several metrics drive this policy engine including the guest reported
+ * memory commitment.
+ */
+
+unsigned long vm_memory_committed(void)
+{
+	return percpu_counter_read_positive(&vm_committed_as);
+}
+
+EXPORT_SYMBOL_GPL(vm_memory_committed);
+
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(num_physpages);
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
