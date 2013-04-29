Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 098676B00A7
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 20:16:49 -0400 (EDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 2/2] Make batch size for memory accounting configured according to size of memory
Date: Mon, 29 Apr 2013 10:12:29 -0700
Message-Id: <8c9bc7d4646d48154604820a3ec5952ba8949de4.1367254913.git.tim.c.chen@linux.intel.com>
In-Reply-To: <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
References: <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
In-Reply-To: <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
References: <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Currently the per cpu counter's batch size for memory accounting is
configured as twice the number of cpus in the system.  However,
for system with very large memory, it is more appropriate to make it
proportional to the memory size per cpu in the system.

For example, for a x86_64 system with 64 cpus and 128 GB of memory,
the batch size is only 2*64 pages (0.5 MB).  So any memory accounting
changes of more than 0.5MB will overflow the per cpu counter into
the global counter.  Instead, for the new scheme, the batch size
is configured to be 0.4% of the memory/cpu = 8MB (128 GB/64 /256),
which is more inline with the memory size.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/mmap.c  | 13 ++++++++++++-
 mm/nommu.c | 13 ++++++++++++-
 2 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 0db0de1..082836e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -89,6 +89,7 @@ int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
  * other variables. It can be updated by several CPUs frequently.
  */
 struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
+int vm_committed_batchsz ____cacheline_aligned_in_smp;
 
 /*
  * The global memory commitment made in the system can be a metric
@@ -3090,10 +3091,20 @@ void mm_drop_all_locks(struct mm_struct *mm)
 /*
  * initialise the VMA slab
  */
+static inline int mm_compute_batch(void)
+{
+	int nr = num_present_cpus();
+
+	/* batch size set to 0.4% of (total memory/#cpus) */
+	return (int) (totalram_pages/nr) / 256;
+}
+
 void __init mmap_init(void)
 {
 	int ret;
 
-	ret = percpu_counter_init(&vm_committed_as, 0);
+	vm_committed_batchsz = mm_compute_batch();
+	ret = percpu_counter_and_batch_init(&vm_committed_as, 0,
+						&vm_committed_batchsz);
 	VM_BUG_ON(ret);
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 2f3ea74..a87a99c 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -59,6 +59,7 @@ unsigned long max_mapnr;
 unsigned long num_physpages;
 unsigned long highest_memmap_pfn;
 struct percpu_counter vm_committed_as;
+int vm_committed_batchsz;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
@@ -526,11 +527,21 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 /*
  * initialise the VMA and region record slabs
  */
+static inline int mm_compute_batch(void)
+{
+	int nr = num_present_cpus();
+
+	/* batch size set to 0.4% of (total memory/#cpus) */
+	return (int) (totalram_pages/nr) / 256;
+}
+
 void __init mmap_init(void)
 {
 	int ret;
 
-	ret = percpu_counter_init(&vm_committed_as, 0);
+	vm_committed_batchsz = mm_compute_batch();
+	ret = percpu_counter_and_batch_init(&vm_committed_as, 0,
+			&vm_committed_batchsz);
 	VM_BUG_ON(ret);
 	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC);
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
