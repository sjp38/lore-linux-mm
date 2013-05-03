Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id EF2146B02E6
	for <linux-mm@kvack.org>; Fri,  3 May 2013 13:15:23 -0400 (EDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v2 2/2] Make batch size for memory accounting configured according to size of memory
Date: Fri,  3 May 2013 03:10:53 -0700
Message-Id: <c95559dd238a811d0ef089b8e3a7a496c48634d8.1367574872.git.tim.c.chen@linux.intel.com>
In-Reply-To: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
References: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
In-Reply-To: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
References: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

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
 mm/mmap.c  | 11 ++++++++++-
 mm/nommu.c | 11 ++++++++++-
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 0db0de1..6c1fcd09 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3090,10 +3090,19 @@ void mm_drop_all_locks(struct mm_struct *mm)
 /*
  * initialise the VMA slab
  */
+static int mm_compute_batch(void)
+{
+	int nr = num_online_cpus();
+
+	/* batch size set to 0.4% of (total memory/#cpus) */
+	return (int) (totalram_pages/nr) / 256;
+}
+
 void __init mmap_init(void)
 {
 	int ret;
 
-	ret = percpu_counter_init(&vm_committed_as, 0);
+	ret = percpu_counter_and_batch_init(&vm_committed_as, 0,
+						&mm_compute_batch);
 	VM_BUG_ON(ret);
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 2f3ea74..2a250d3 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -526,11 +526,20 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 /*
  * initialise the VMA and region record slabs
  */
+static int mm_compute_batch(void)
+{
+	int nr = num_online_cpus();
+
+	/* batch size set to 0.4% of (total memory/#cpus) */
+	return (int) (totalram_pages/nr) / 256;
+}
+
 void __init mmap_init(void)
 {
 	int ret;
 
-	ret = percpu_counter_init(&vm_committed_as, 0);
+	ret = percpu_counter_and_batch_init(&vm_committed_as, 0,
+				&mm_compute_batch);
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
