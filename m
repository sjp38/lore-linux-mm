Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 03FC38D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 17:49:24 -0500 (EST)
Subject: [RFC] mm: Make vm_acct_memory scalable for large memory allocations
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Jan 2011 14:51:59 -0800
Message-ID: <1296082319.2712.100.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

During testing of concurrent malloc/free by multiple processes on a 8
socket NHM-EX machine (8cores/socket, 64 cores total), I noticed that
malloc of large memory (e.g. 32MB) did not scale well.  A test patch
included here increased 32MB mallocs/free with 64 concurrent processes
from 69K operations/sec to 4066K operations/sec on 2.6.37 kernel, and
eliminated the cpu cycles contending for spin_lock in the vm_commited_as
percpu_counter.

Spin lock contention occurs when vm_acct_memory increments/decrements
the percpu_counter vm_committed_as by the number of pages being
used/freed. Theoretically vm_committed_as is a percpu_counter and should
streamline the concurrent update by using the local counter in
vm_commited_as.  However, if the update is greater than
percpu_counter_batch limit, then it will overflow into the global count
in vm_commited_as.  Currently percpu_counter_batch is non-configurable
and hardcoded to 2*num_online_cpus.  So any update of vm_commited_as by
more than 256 pages will cause overflow in my test scenario which has
128 logical cpus. 

In the patch, I have set an enlargement multiplication factor for
vm_commited_as's batch limit. I limit the sum of all local counters up
to 5% of the total pages before overflowing into the global counter.
This will avoid the frequent contention of the spin_lock in
vm_commited_as. Some additional work will need to be done to make
setting of this multiplication factor cpu hotplug aware.  Advise on
better approaches are welcomed.

Thanks.

Tim Chen

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index 46f6ba5..5a892d8 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -21,6 +21,7 @@ struct percpu_counter {
 #ifdef CONFIG_HOTPLUG_CPU
 	struct list_head list;	/* All percpu_counters are on a list */
 #endif
+	u32 multibatch;
 	s32 __percpu *counters;
 };
 
@@ -29,6 +30,8 @@ extern int percpu_counter_batch;
 int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
 			  struct lock_class_key *key);
 
+int percpu_counter_multibatch_init(struct percpu_counter *fbc, u32 multibatch);
+
 #define percpu_counter_init(fbc, value)					\
 	({								\
 		static struct lock_class_key __key;			\
@@ -44,7 +47,7 @@ int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs);
 
 static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
-	__percpu_counter_add(fbc, amount, percpu_counter_batch);
+	__percpu_counter_add(fbc, amount, fbc->multibatch * percpu_counter_batch);
 }
 
 static inline s64 percpu_counter_sum_positive(struct percpu_counter *fbc)
diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index 604678d..a9c6121 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -120,6 +120,7 @@ int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
 		return -ENOMEM;
 
 	debug_percpu_counter_activate(fbc);
+	fbc->multibatch = 1;
 
 #ifdef CONFIG_HOTPLUG_CPU
 	INIT_LIST_HEAD(&fbc->list);
@@ -129,6 +130,15 @@ int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
 #endif
 	return 0;
 }
+
+int percpu_counter_multibatch_init(struct percpu_counter *fbc, u32 multibatch)
+{
+	spin_lock(&fbc->lock);
+	fbc->multibatch = multibatch;
+	spin_unlock(&fbc->lock);
+	return 0;
+}
+
 EXPORT_SYMBOL(__percpu_counter_init);
 
 void percpu_counter_destroy(struct percpu_counter *fbc)
@@ -193,10 +203,12 @@ static int __cpuinit percpu_counter_hotcpu_callback(struct notifier_block *nb,
 int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
 {
 	s64	count;
+	int	batch;
 
 	count = percpu_counter_read(fbc);
+	batch = percpu_counter_batch * fbc->multibatch;
 	/* Check to see if rough count will be sufficient for comparison */
-	if (abs(count - rhs) > (percpu_counter_batch*num_online_cpus())) {
+	if (abs(count - rhs) > (batch*num_online_cpus())) {
 		if (count > rhs)
 			return 1;
 		else
diff --git a/mm/mmap.c b/mm/mmap.c
index 50a4aa0..fee6a02 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -180,7 +180,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	if (mm)
 		allowed -= mm->total_vm / 32;
 
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+	if (percpu_counter_compare(&vm_committed_as, allowed) < 0)
 		return 0;
 error:
 	vm_unacct_memory(pages);
@@ -2673,7 +2673,12 @@ void mm_drop_all_locks(struct mm_struct *mm)
 void __init mmap_init(void)
 {
 	int ret;
+	u32 multibatch;
 
 	ret = percpu_counter_init(&vm_committed_as, 0);
 	VM_BUG_ON(ret);
+	multibatch = totalram_pages / (20 * num_online_cpus() * percpu_counter_batch);
+	multibatch = max((u32) 1, multibatch);
+	ret = percpu_counter_multibatch_init(&vm_committed_as, multibatch);
+	VM_BUG_ON(ret);
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index ef4045d..31b34d7 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1952,7 +1952,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	if (mm)
 		allowed -= mm->total_vm / 32;
 
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+	if (percpu_counter_compare(&vm_committed_as, allowed) < 0)
 		return 0;
 
 error:
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
