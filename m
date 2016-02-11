Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 98C4E6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 08:35:13 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id 5so36357124igt.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 05:35:13 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 70si13057220ioo.141.2016.02.11.05.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 05:35:12 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
 <CALYGNiMX5NCRie8TfTZvUm3czBt5CYS+VznxAbtCFVJXtYM=2Q@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <56BC8E4E.2010504@virtuozzo.com>
Date: Thu, 11 Feb 2016 16:36:14 +0300
MIME-Version: 1.0
In-Reply-To: <CALYGNiMX5NCRie8TfTZvUm3czBt5CYS+VznxAbtCFVJXtYM=2Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>

On 02/10/2016 08:46 PM, Konstantin Khlebnikov wrote:
> On Wed, Feb 10, 2016 at 5:52 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> Currently we use percpu_counter for accounting committed memory. Change
>> of committed memory on more than vm_committed_as_batch pages leads to
>> grab of counter's spinlock. The batch size is quite small - from 32 pages
>> up to 0.4% of the memory/cpu (usually several MBs even on large machines).
>>
>> So map/munmap of several MBs anonymous memory in multiple processes leads
>> to high contention on that spinlock.
>>
>> Instead of percpu_counter we could use ordinary per-cpu variables.
>> Dump test case (8-proccesses running map/munmap of 4MB,
>> vm_committed_as_batch = 2MB on test setup) showed 2.5x performance
>> improvement.
>>
>> The downside of this approach is slowdown of vm_memory_committed().
>> However, it doesn't matter much since it usually is not in a hot path.
>> The only exception is __vm_enough_memory() with overcommit set to
>> OVERCOMMIT_NEVER. In that case brk1 test from will-it-scale benchmark
>> shows 1.1x - 1.3x performance regression.
>>
>> So I think it's a good tradeoff. We've got significantly increased
>> scalability for the price of some overhead in vm_memory_committed().
> 
> I think thats a no go. 30% regression for your not-so-big machine.
> For 4096 cores regression will be enourmous. Link: https://xkcd.com/619/
> 

Bayan. Linux already supports 8192 cpus. So I set possible_cpus=8192 to see how bad it is.
brk1 test with disabled overcommit (OVERCOMMIT_NEVER) showed ~500x regression. I guess that's too much.

I've tried another approach - convert 'vm_committed_as' to atomic_t variable.
On 8-proccesses map/munmap of 4K this shows only 2%-3% regression (comparing to mainline).
And for 4MB map/munmap this gives 125% improvement.

So, for me, this sounds like a good way to go, although, it worth check regression of small
allocations on bigger machines.

---

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index df4661a..f30e387 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -41,7 +41,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	si_meminfo(&i);
 	si_swapinfo(&i);
-	committed = percpu_counter_read_positive(&vm_committed_as);
+	committed = vm_memory_committed();
 
 	cached = global_page_state(NR_FILE_PAGES) -
 			total_swapcache_pages() - i.bufferram;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 979bc83..82dac6e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1881,7 +1881,11 @@ extern void memmap_init_zone(unsigned long, int, unsigned long,
 extern void setup_per_zone_wmarks(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
+#ifdef CONFIG_MMU
+static inline void mmap_init(void) {}
+#else
 extern void __init mmap_init(void);
+#endif
 extern void show_mem(unsigned int flags);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 16373c8..21b68e8 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -2,7 +2,7 @@
 #define _LINUX_MMAN_H
 
 #include <linux/mm.h>
-#include <linux/percpu_counter.h>
+#include <linux/percpu.h>
 
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
@@ -10,19 +10,12 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_overcommit_kbytes;
-extern struct percpu_counter vm_committed_as;
-
-#ifdef CONFIG_SMP
-extern s32 vm_committed_as_batch;
-#else
-#define vm_committed_as_batch 0
-#endif
-
 unsigned long vm_memory_committed(void);
+extern atomic_t vm_committed_as;
 
 static inline void vm_acct_memory(long pages)
 {
-	__percpu_counter_add(&vm_committed_as, pages, vm_committed_as_batch);
+	atomic_add(pages, &vm_committed_as);
 }
 
 static inline void vm_unacct_memory(long pages)
diff --git a/mm/mm_init.c b/mm/mm_init.c
index fdadf91..d96c71f 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -142,51 +142,6 @@ early_param("mminit_loglevel", set_mminit_loglevel);
 struct kobject *mm_kobj;
 EXPORT_SYMBOL_GPL(mm_kobj);
 
-#ifdef CONFIG_SMP
-s32 vm_committed_as_batch = 32;
-
-static void __meminit mm_compute_batch(void)
-{
-	u64 memsized_batch;
-	s32 nr = num_present_cpus();
-	s32 batch = max_t(s32, nr*2, 32);
-
-	/* batch size set to 0.4% of (total memory/#cpus), or max int32 */
-	memsized_batch = min_t(u64, (totalram_pages/nr)/256, 0x7fffffff);
-
-	vm_committed_as_batch = max_t(s32, memsized_batch, batch);
-}
-
-static int __meminit mm_compute_batch_notifier(struct notifier_block *self,
-					unsigned long action, void *arg)
-{
-	switch (action) {
-	case MEM_ONLINE:
-	case MEM_OFFLINE:
-		mm_compute_batch();
-	default:
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block compute_batch_nb __meminitdata = {
-	.notifier_call = mm_compute_batch_notifier,
-	.priority = IPC_CALLBACK_PRI, /* use lowest priority */
-};
-
-static int __init mm_compute_batch_init(void)
-{
-	mm_compute_batch();
-	register_hotmemory_notifier(&compute_batch_nb);
-
-	return 0;
-}
-
-__initcall(mm_compute_batch_init);
-
-#endif
-
 static int __init mm_sysfs_init(void)
 {
 	mm_kobj = kobject_create_and_add("mm", kernel_kobj);
diff --git a/mm/mmap.c b/mm/mmap.c
index f088c60..c796d73 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3184,17 +3184,6 @@ void mm_drop_all_locks(struct mm_struct *mm)
 }
 
 /*
- * initialise the VMA slab
- */
-void __init mmap_init(void)
-{
-	int ret;
-
-	ret = percpu_counter_init(&vm_committed_as, 0, GFP_KERNEL);
-	VM_BUG_ON(ret);
-}
-
-/*
  * Initialise sysctl_user_reserve_kbytes.
  *
  * This is intended to prevent a user from starting a single memory hogging
diff --git a/mm/nommu.c b/mm/nommu.c
index 6402f27..2d52dbc 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -533,10 +533,6 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
  */
 void __init mmap_init(void)
 {
-	int ret;
-
-	ret = percpu_counter_init(&vm_committed_as, 0, GFP_KERNEL);
-	VM_BUG_ON(ret);
 	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC|SLAB_ACCOUNT);
 }
 
diff --git a/mm/util.c b/mm/util.c
index 47a57e5..9130983 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -402,6 +402,7 @@ unsigned long sysctl_overcommit_kbytes __read_mostly;
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
+atomic_t vm_committed_as;
 
 int overcommit_ratio_handler(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp,
@@ -445,12 +446,6 @@ unsigned long vm_commit_limit(void)
 }
 
 /*
- * Make sure vm_committed_as in one cacheline and not cacheline shared with
- * other variables. It can be updated by several CPUs frequently.
- */
-struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
-
-/*
  * The global memory commitment made in the system can be a metric
  * that can be used to drive ballooning decisions when Linux is hosted
  * as a guest. On Hyper-V, the host implements a policy engine for dynamically
@@ -460,7 +455,7 @@ struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
  */
 unsigned long vm_memory_committed(void)
 {
-	return percpu_counter_read_positive(&vm_committed_as);
+	return atomic_read(&vm_committed_as);
 }
 EXPORT_SYMBOL_GPL(vm_memory_committed);
 
@@ -484,8 +479,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 {
 	long free, allowed, reserve;
 
-	VM_WARN_ONCE(percpu_counter_read(&vm_committed_as) <
-			-(s64)vm_committed_as_batch * num_online_cpus(),
+	VM_WARN_ONCE(atomic_read(&vm_committed_as) < 0,
 			"memory commitment underflow");
 
 	vm_acct_memory(pages);
@@ -553,7 +547,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= min_t(long, mm->total_vm / 32, reserve);
 	}
 
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+	if (vm_memory_committed() < allowed)
 		return 0;
 error:
 	vm_unacct_memory(pages);
-- 
2.4.10


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
