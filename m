Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B92F36B009A
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:27:26 -0400 (EDT)
Subject: Re: [PATCH v2 1/2] Make the batch size of the percpu_counter
 configurable
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
References: 
	 <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
	 <20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 May 2013 16:27:29 -0700
Message-ID: <1369178849.27102.330.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2013-05-21 at 13:41 -0700, Andrew Morton wrote:

> This patch seems to add rather a lot of unnecessary code.
> 
> - The increase in the size of percu_counter is regrettable.
> 
> - The change to percpu_counter_startup() is unneeded - no
>   percpu_counters should exist at this time.  (We may have screwed this
>   up - percpu_counter_startup() shuold probably be explicitly called
>   from start_kernel()).
> 
> - Once the percpu_counter_startup() change is removed, all that code
>   which got moved out of CONFIG_HOTPLUG_CPU can be put back.
> 
> And probably other stuff.
> 
> 
> If you want to use a larger batch size for vm_committed_as, why not
> just use the existing __percpu_counter_add(..., batch)?  Easy.
> 

Andrew,

Thanks for your comments and reviews.
Will something like the following work if we get rid of the percpu
counter changes and use __percpu_counter_add(..., batch)?  In
benchmark with a lot of memory changes via brk, this makes quite
a difference when we go to a bigger batch size.

Tim

Change batch size for memory accounting to be proportional to memory available.

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
 include/linux/mman.h |  5 +++++
 mm/mmap.c            | 14 ++++++++++++++
 mm/nommu.c           | 14 ++++++++++++++
 3 files changed, 33 insertions(+)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 9aa863d..11d5ce9 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -10,12 +10,17 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
+extern int vm_committed_as_batch;
 
 unsigned long vm_memory_committed(void);
 
 static inline void vm_acct_memory(long pages)
 {
+#ifdef CONFIG_SMP
+	__percpu_counter_add(&vm_committed_as, pages, vm_committed_as_batch);
+#else
 	percpu_counter_add(&vm_committed_as, pages);
+#endif
 }
 
 static inline void vm_unacct_memory(long pages)
diff --git a/mm/mmap.c b/mm/mmap.c
index f681e18..0eef503 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3145,11 +3145,25 @@ void mm_drop_all_locks(struct mm_struct *mm)
 /*
  * initialise the VMA slab
  */
+
+int vm_committed_as_batch;
+EXPORT_SYMBOL(vm_committed_as_batch);
+
+static int mm_compute_batch(void)
+{
+	int nr = num_present_cpus();
+	int batch = max(32, nr*2);
+
+	/* batch size set to 0.4% of (total memory/#cpus) */
+	return max((int) (totalram_pages/nr) / 256, batch);
+}
+
 void __init mmap_init(void)
 {
 	int ret;
 
 	ret = percpu_counter_init(&vm_committed_as, 0);
+	vm_committed_as_batch = mm_compute_batch();
 	VM_BUG_ON(ret);
 }
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 298884d..1b7008a 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -527,11 +527,25 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 /*
  * initialise the VMA and region record slabs
  */
+
+int vm_committed_as_batch;
+EXPORT_SYMBOL(vm_committed_as_batch);
+
+static int mm_compute_batch(void)
+{
+	int nr = num_present_cpus();
+	int batch = max(32, nr*2);
+
+	/* batch size set to 0.4% of (total memory/#cpus) */
+	return max((int) (totalram_pages/nr) / 256, batch);
+}
+
 void __init mmap_init(void)
 {
 	int ret;
 
 	ret = percpu_counter_init(&vm_committed_as, 0);
+	vm_committed_as_batch = mm_compute_batch();
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
