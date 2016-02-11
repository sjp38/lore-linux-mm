Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 43E8B6B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 19:24:18 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id e127so20239300pfe.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 16:24:18 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xb2si8314150pab.232.2016.02.10.16.24.17
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 16:24:17 -0800 (PST)
Message-ID: <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 10 Feb 2016 16:24:16 -0800
In-Reply-To: <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
	 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
	 <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
	 <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Wed, 2016-02-10 at 13:28 -0800, Andrew Morton wrote:

> 
> If a process is unmapping 4MB then it's pretty crazy for us to be
> hitting the percpu_counter 32 separate times for that single operation.
> 
> Is there some way in which we can batch up the modifications within the
> caller and update the counter less frequently?  Perhaps even in a
> single hit?

I think the problem is the batch size is too small and we overflow
the local counter into the global counter for 4M allocations.
The reason for the small batch size was because we use
percpu_counter_read_positive in __vm_enough_memory and it is not precise
and the error could grow with large batch size.

Let's switch to the precise __percpu_counter_compare that is 
unaffected by batch size.  It will do precise comparison and only add up
the local per cpu counters when the global count is not precise
enough.  

So maybe something like the following patch with a relaxed batch size.
I have not tested this patch much other than compiling and booting
the kernel.  I wonder if this works for Andrey. We could relax the batch
size further, but that will mean that we will incur the overhead
of summing the per cpu counters earlier when the global count get close
to the allowed limit.

Thanks.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/mm/mm_init.c b/mm/mm_init.c
index fdadf91..996c332 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -151,8 +151,8 @@ static void __meminit mm_compute_batch(void)
 	s32 nr = num_present_cpus();
 	s32 batch = max_t(s32, nr*2, 32);
 
-	/* batch size set to 0.4% of (total memory/#cpus), or max int32 */
-	memsized_batch = min_t(u64, (totalram_pages/nr)/256, 0x7fffffff);
+	/* batch size set to 3% of (total memory/#cpus), or max int32 */
+	memsized_batch = min_t(u64, (totalram_pages/nr)/32, 0x7fffffff);
 
 	vm_committed_as_batch = max_t(s32, memsized_batch, batch);
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index 79bcc9f..eec9dfd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -131,7 +131,7 @@ struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
  */
 unsigned long vm_memory_committed(void)
 {
-	return percpu_counter_read_positive(&vm_committed_as);
+	return percpu_counter_sum(&vm_committed_as);
 }
 EXPORT_SYMBOL_GPL(vm_memory_committed);
 
@@ -155,10 +155,6 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 {
 	long free, allowed, reserve;
 
-	VM_WARN_ONCE(percpu_counter_read(&vm_committed_as) <
-			-(s64)vm_committed_as_batch * num_online_cpus(),
-			"memory commitment underflow");
-
 	vm_acct_memory(pages);
 
 	/*
@@ -224,7 +220,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= min_t(long, mm->total_vm / 32, reserve);
 	}
 
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+	if (__percpu_counter_compare(&vm_committed_as, allowed, vm_committed_as_batch) < 0)
 		return 0;
 error:
 	vm_unacct_memory(pages);
diff --git a/mm/nommu.c b/mm/nommu.c
index ab14a20..53e4cae 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -70,7 +70,7 @@ atomic_long_t mmap_pages_allocated;
  */
 unsigned long vm_memory_committed(void)
 {
-	return percpu_counter_read_positive(&vm_committed_as);
+	return percpu_counter_sum(&vm_committed_as);
 }
 
 EXPORT_SYMBOL_GPL(vm_memory_committed);
@@ -1914,7 +1914,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= min_t(long, mm->total_vm / 32, reserve);
 	}
 
-	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+	if (__percpu_counter_compare(&vm_committed_as, allowed, vm_committed_as_batch) < 0)
 		return 0;
 
 error:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
