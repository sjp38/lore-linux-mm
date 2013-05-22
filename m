Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 080C46B00A7
	for <linux-mm@kvack.org>; Tue, 21 May 2013 20:43:06 -0400 (EDT)
Subject: Re: [PATCH v2 1/2] Make the batch size of the percpu_counter
 configurable
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130521164154.bed705c6e117ceb76205cd65@linux-foundation.org>
References: 
	 <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
	 <20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
	 <1369178849.27102.330.camel@schen9-DESK>
	 <20130521164154.bed705c6e117ceb76205cd65@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 May 2013 17:43:10 -0700
Message-ID: <1369183390.27102.337.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2013-05-21 at 16:41 -0700, Andrew Morton wrote:

> I think we could use __percpu_counter_add() unconditionally here and
> just do
> 
> #ifdef CONFIG_SMP
> #define vm_committed_as_batch 0
> #else
> int vm_committed_as_batch;
> #endif
> 
> The EXPORT_SYMBOL(vm_committed_as_batch) is unneeded.
> 

Thanks.  I've made the changes suggested.

> >  void __init mmap_init(void)
> >  {
> >  	int ret;
> >  
> >  	ret = percpu_counter_init(&vm_committed_as, 0);
> > +	vm_committed_as_batch = mm_compute_batch();
> >  	VM_BUG_ON(ret);
> >  	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC);
> 
> I'm not sure that CONFIG_MMU=n && CONFIG_SMP=y even exists.  Perhaps it
> does.  But there's no point in ruling out that option here.
> 
> The nommu code becomes identical to the mmu code so we should put it in
> a shared file.  I suppose mmap.c would be as good a place as any.
> 

I've consolidated things in mman.h.

> We could make mm_compute_batch() __init and call it from mm_init(). 
> But really it should be __meminit and there should be a memory-hotplug
> notifier handler which adjusts vm_committed_as_batch's value.
> 

I'll spin off another version of the patch later to add the
memory-hotplug notifier.  In the mean time, does the following looks
good to you?

Thanks.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/mman.h | 20 +++++++++++++++++++-
 mm/mmap.c            |  4 ++++
 mm/nommu.c           |  4 ++++
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 9aa863d..443bcae 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -10,12 +10,30 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
+#ifdef CONFIG_SMP
+extern int vm_committed_as_batch;
+
+static inline void mm_compute_batch(void)
+{
+        int nr = num_present_cpus();
+        int batch = max(32, nr*2);
+
+        /* batch size set to 0.4% of (total memory/#cpus) */
+        vm_committed_as_batch = max((int) (totalram_pages/nr) / 256, batch);
+}
+#else
+#define vm_committed_as_batch 0
+
+static inline void mm_compute_batch(void)
+{
+}
+#endif
 
 unsigned long vm_memory_committed(void);
 
 static inline void vm_acct_memory(long pages)
 {
-	percpu_counter_add(&vm_committed_as, pages);
+	__percpu_counter_add(&vm_committed_as, pages, vm_committed_as_batch);
 }
 
 static inline void vm_unacct_memory(long pages)
diff --git a/mm/mmap.c b/mm/mmap.c
index f681e18..55c8773 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3145,11 +3145,15 @@ void mm_drop_all_locks(struct mm_struct *mm)
 /*
  * initialise the VMA slab
  */
+
+int vm_committed_as_batch;
+
 void __init mmap_init(void)
 {
 	int ret;
 
 	ret = percpu_counter_init(&vm_committed_as, 0);
+	mm_compute_batch();
 	VM_BUG_ON(ret);
 }
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 298884d..9ad16ba 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -527,11 +527,15 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 /*
  * initialise the VMA and region record slabs
  */
+
+int vm_committed_as_batch;
+
 void __init mmap_init(void)
 {
 	int ret;
 
 	ret = percpu_counter_init(&vm_committed_as, 0);
+	mm_compute_batch();
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
