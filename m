Subject: PATCH: Fix to slab.c for SMP (test9-pre7)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 28 Sep 2000 03:00:37 +0200
Message-ID: <ytt4s31ib4a.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
        In previous mails I reported that test9-preX (X>=3) freezes
        when running in SMP mmap001.  I have found that the problem
        was in how was handing the slab cache by cpu.  With this patch
        mmap001 returns to work (i.e. it loops a lot in the VM layer,
        but the same loops than in UP).

Linus, if you see no problems, please apply. (If you want the patch
without the shrink_[id]_caches part, please, let me know).

This patch does:

- shrink_[id]_caches return the count of the freed pages (from ingo
  and marcelo patch)
- removes the ret variable in smp_call_function (it was unused)
- removes the slab_cache_drain_mask/slab_drain_local_cache and its
  references for the timer interrupt code.  That calls are now done
  with smp_call_function, that lets us to simplify a lot the code (we
  don't need the cache_drain_wait queue anymore.
- Change the cache_drain_sem semaphore to cache_all_lock spinlock, as
  now we never sleep/schedule while holding it.  The name is changed
  because it is not only used by the drain routines it is also used by
  the update ones.
- slab_drain_local_cache is divided in the functions: 
    slab_drain_local_cache
    do_ccupdate_local
  as we known a compile time _which_ part of the function we want to
  call.
- pass the spinlock calls inside slab_cache_all_sync, as they are
  needed only when calling that function.  The wait queue is not
  needed anymore.  This function used global variables to pass
  arguments to slab_drain_local_cache, that has been changed to use
  global arguments.
- do_ccupdate & drain_cpu_caches code has been refunded inside
  slab_cache_all_sync, as the same code except for one line.

- In the process, the net result are ~40 less lines of code

Thanks to Phillip Rumpf, Stephen Tweedie, Alan Cox, Ingo & the rest of the
people that explained me the SMP/cross CPU mysteries.

Any comments, suggestions are welcome


Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/arch/i386/kernel/smp.c working/arch/i386/kernel/smp.c
--- base/arch/i386/kernel/smp.c	Tue Sep 26 03:46:03 2000
+++ working/arch/i386/kernel/smp.c	Wed Sep 27 23:45:30 2000
@@ -464,7 +464,7 @@
  */
 {
 	struct call_data_struct data;
-	int ret, cpus = smp_num_cpus-1;
+	int cpus = smp_num_cpus-1;
 
 	if (!cpus)
 		return 0;
@@ -485,7 +485,6 @@
 	while (atomic_read(&data.started) != cpus)
 		barrier();
 
-	ret = 0;
 	if (wait)
 		while (atomic_read(&data.finished) != cpus)
 			barrier();
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/fs/dcache.c working/fs/dcache.c
--- base/fs/dcache.c	Tue Sep 26 03:34:00 2000
+++ working/fs/dcache.c	Wed Sep 27 00:34:13 2000
@@ -572,14 +572,8 @@
 	if (priority)
 		count = dentry_stat.nr_unused / priority;
 	prune_dcache(count);
-	/* FIXME: kmem_cache_shrink here should tell us
-	   the number of pages freed, and it should
-	   work in a __GFP_DMA/__GFP_HIGHMEM behaviour
-	   to free only the interesting pages in
-	   function of the needs of the current allocation. */
-	kmem_cache_shrink(dentry_cache);
 
-	return 0;
+	return kmem_cache_shrink(dentry_cache);
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/fs/inode.c working/fs/inode.c
--- base/fs/inode.c	Tue Sep 26 03:34:00 2000
+++ working/fs/inode.c	Wed Sep 27 00:34:13 2000
@@ -471,14 +471,8 @@
 	if (priority)
 		count = inodes_stat.nr_unused / priority;
 	prune_icache(count);
-	/* FIXME: kmem_cache_shrink here should tell us
-	   the number of pages freed, and it should
-	   work in a __GFP_DMA/__GFP_HIGHMEM behaviour
-	   to free only the interesting pages in
-	   function of the needs of the current allocation. */
-	kmem_cache_shrink(inode_cachep);
 
-	return 0;
+	return kmem_cache_shrink(inode_cachep);
 }
 
 /*
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/slab.h working/include/linux/slab.h
--- base/include/linux/slab.h	Wed Sep 27 00:16:36 2000
+++ working/include/linux/slab.h	Wed Sep 27 16:23:51 2000
@@ -76,14 +76,6 @@
 extern kmem_cache_t	*fs_cachep;
 extern kmem_cache_t	*sigact_cachep;
 
-#ifdef CONFIG_SMP
-extern unsigned long slab_cache_drain_mask;
-extern void slab_drain_local_cache(void);
-#else
-#define slab_cache_drain_mask 0
-#define slab_drain_local_cache()	do { } while (0)
-#endif
-
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_SLAB_H */
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/kernel/timer.c working/kernel/timer.c
--- base/kernel/timer.c	Mon Aug 28 23:28:27 2000
+++ working/kernel/timer.c	Wed Sep 27 23:38:09 2000
@@ -22,7 +22,6 @@
 #include <linux/smp_lock.h>
 #include <linux/interrupt.h>
 #include <linux/kernel_stat.h>
-#include <linux/slab.h>
 
 #include <asm/uaccess.h>
 
@@ -596,9 +595,6 @@
 		kstat.per_cpu_system[cpu] += system;
 	} else if (local_bh_count(cpu) || local_irq_count(cpu) > 1)
 		kstat.per_cpu_system[cpu] += system;
-
-	if (slab_cache_drain_mask & (1UL << cpu))
-		slab_drain_local_cache();
 }
 
 /*
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/slab.c working/mm/slab.c
--- base/mm/slab.c	Tue Sep 26 03:34:05 2000
+++ working/mm/slab.c	Thu Sep 28 02:49:05 2000
@@ -579,7 +579,6 @@
 		kmem_cache_free(cachep->slabp_cache, slabp);
 }
 
-
 /**
  * kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
@@ -838,47 +837,39 @@
 }
 
 #ifdef CONFIG_SMP
-static DECLARE_MUTEX(cache_drain_sem);
-static kmem_cache_t *cache_to_drain = NULL;
-static DECLARE_WAIT_QUEUE_HEAD(cache_drain_wait);
-unsigned long slab_cache_drain_mask;
+static spinlock_t cache_all_lock = SPIN_LOCK_UNLOCKED;
+
+static void free_block (kmem_cache_t* cachep, void** objpp, int len);
+
+static void slab_drain_local_cache(void *info)
+{
+	kmem_cache_t *cachep = (kmem_cache_t *)info;
+	cpucache_t *cc = cc_data(cachep);
+		
+	if (cc && cc->avail) {
+		free_block(cachep, cc_entry(cc), cc->avail);
+		cc->avail = 0;
+	}
+}
 
 /*
- * Waits for all CPUs to execute slab_drain_local_cache().
- * Caller must be holding cache_drain_sem.
+ * Waits for all CPUs to execute func().
  */
-static void slab_drain_all_sync(void)
+static void slab_cache_all_sync(void (*func) (void *arg), void *arg)
 {
-	DECLARE_WAITQUEUE(wait, current);
-
+	spin_lock(&cache_all_lock);
 	local_irq_disable();
-	slab_drain_local_cache();
+	func(arg);
 	local_irq_enable();
 
-	add_wait_queue(&cache_drain_wait, &wait);
-	current->state = TASK_UNINTERRUPTIBLE;
-	while (slab_cache_drain_mask != 0UL)
-		schedule();
-	current->state = TASK_RUNNING;
-	remove_wait_queue(&cache_drain_wait, &wait);
+	if (smp_call_function(func, arg, 1, 1))
+		BUG();
+	spin_unlock(&cache_all_lock);
 }
 
 static void drain_cpu_caches(kmem_cache_t *cachep)
 {
-	unsigned long cpu_mask = 0;
-	int i;
-
-	for (i = 0; i < smp_num_cpus; i++)
-		cpu_mask |= (1UL << cpu_logical_map(i));
-
-	down(&cache_drain_sem);
-
-	cache_to_drain = cachep;
-	slab_cache_drain_mask = cpu_mask;
-	slab_drain_all_sync();
-	cache_to_drain = NULL;
-
-	up(&cache_drain_sem);
+	slab_cache_all_sync(slab_drain_local_cache, (void *)cachep);
 }
 #else
 #define drain_cpu_caches(cachep)	do { } while (0)
@@ -887,7 +878,7 @@
 static int __kmem_cache_shrink(kmem_cache_t *cachep)
 {
 	slab_t *slabp;
-	int ret;
+	int ret, freed = 0;
 
 	drain_cpu_caches(cachep);
 
@@ -912,8 +903,9 @@
 		spin_unlock_irq(&cachep->spinlock);
 		kmem_slab_destroy(cachep, slabp);
 		spin_lock_irq(&cachep->spinlock);
+		freed++;
 	}
-	ret = !list_empty(&cachep->slabs);
+	ret = ((1 << cachep->gfporder) * freed);
 	spin_unlock_irq(&cachep->spinlock);
 	return ret;
 }
@@ -923,7 +915,7 @@
  * @cachep: The cache to shrink.
  *
  * Releases as many slabs as possible for a cache.
- * To help debugging, a zero exit status indicates all slabs were released.
+ * Returns the ammount of freed pages
  */
 int kmem_cache_shrink(kmem_cache_t *cachep)
 {
@@ -961,8 +953,9 @@
 						kmem_cache_t, next);
 	list_del(&cachep->next);
 	up(&cache_chain_sem);
-
-	if (__kmem_cache_shrink(cachep)) {
+	__kmem_cache_shrink(cachep); 
+	
+	if (!list_empty(&cachep->slabs)) {
 		printk(KERN_ERR "kmem_cache_destroy: Can't free all objects %p\n",
 		       cachep);
 		down(&cache_chain_sem);
@@ -1599,48 +1592,13 @@
 	cpucache_t *new[NR_CPUS];
 } ccupdate_struct_t;
 
-static ccupdate_struct_t *ccupdate_state = NULL;
-
-/* Called from per-cpu timer interrupt. */
-void slab_drain_local_cache(void)
+static void do_ccupdate_local(void *info)
 {
-	if (ccupdate_state != NULL) {
-		ccupdate_struct_t *new = ccupdate_state;
-		cpucache_t *old = cc_data(new->cachep);
-
-		cc_data(new->cachep) = new->new[smp_processor_id()];
-		new->new[smp_processor_id()] = old;
-	} else {
-		kmem_cache_t *cachep = cache_to_drain;
-		cpucache_t *cc = cc_data(cachep);
-
-		if (cc && cc->avail) {
-			free_block(cachep, cc_entry(cc), cc->avail);
-			cc->avail = 0;
-		}
-	}
-
-	clear_bit(smp_processor_id(), &slab_cache_drain_mask);
-	if (slab_cache_drain_mask == 0)
-		wake_up(&cache_drain_wait);
-}
-
-static void do_ccupdate(ccupdate_struct_t *data)
-{
-	unsigned long cpu_mask = 0;
-	int i;
-
-	for (i = 0; i < smp_num_cpus; i++)
-		cpu_mask |= (1UL << cpu_logical_map(i));
-
-	down(&cache_drain_sem);
-
-	ccupdate_state = data;
-	slab_cache_drain_mask = cpu_mask;
-	slab_drain_all_sync();
-	ccupdate_state = NULL;
-
-	up(&cache_drain_sem);
+	ccupdate_struct_t *new = (ccupdate_struct_t *)info;
+	cpucache_t *old = cc_data(new->cachep);
+	
+	cc_data(new->cachep) = new->new[smp_processor_id()];
+	new->new[smp_processor_id()] = old;
 }
 
 /* called with cache_chain_sem acquired.  */
@@ -1666,7 +1624,6 @@
 		for (i = 0; i< smp_num_cpus; i++) {
 			cpucache_t* ccnew;
 
-
 			ccnew = kmalloc(sizeof(void*)*limit+
 					sizeof(cpucache_t), GFP_KERNEL);
 			if (!ccnew)
@@ -1681,7 +1638,7 @@
 	cachep->batchcount = batchcount;
 	spin_unlock_irq(&cachep->spinlock);
 
-	do_ccupdate(&new);
+	slab_cache_all_sync(do_ccupdate_local, (void *)&new);
 
 	for (i = 0; i < smp_num_cpus; i++) {
 		cpucache_t* ccold = new.new[cpu_logical_map(i)];


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
