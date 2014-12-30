Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 937C96B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 02:22:35 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hn15so12289182igb.3
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 23:22:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d2si20544970igl.44.2014.12.29.23.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 23:22:34 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141220020331.GM1942@devil.localdomain>
	<201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
	<20141220223504.GI15665@dastard>
	<201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141229181937.GE32618@dhcp22.suse.cz>
In-Reply-To: <20141229181937.GE32618@dhcp22.suse.cz>
Message-Id: <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
Date: Tue, 30 Dec 2014 15:42:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> but this task managed to make some progress because we can clearly see
> that pid 12718 (oom victim) managed to move on and get to OOM killer
> many times
> [  961.062042] a.out(12718) the OOM killer was skipped for 1965000 times.
> [...]
> [  983.140589] a.out(12718) the OOM killer was skipped for 2059000 times.
> 
Excuse me for the confusing message. The a.out(12718) printed here is not
the caller of OOM killer but the victim keeping the OOM killer disabled.
Thus, this task could not manage to make some progress and I called it
"a stalled case".

> There are still other cases where we can livelock but
> this seems to be a clear bug in grab_cache_page_write_begin.

We might want to discuss below case as a separate topic, but is a TIF_MEMDIE
stall anyway. I retested using 3.19-rc2 with diff shown below. If I start
a.out and b.out (where b.out is a copy of a.out) with slight delay (a few
deciseconds), I can observe that the a.out is unable to die due to b.out
asking for memory or holding lock.
http://I-love.SAKURA.ne.jp/tmp/serial-20141230-ab-1.txt.xz is a case
where I think a.out keeps the OOM killer disabled and
http://I-love.SAKURA.ne.jp/tmp/serial-20141230-ab-2.txt.xz is a case
where I think a.out cannot die within reasonable duration due to b.out .
I don't know whether cgroups can help or not, but I think we need to be
prepared for cases where sending SIGKILL to all threads sharing the same
memory does not help.

---------- diff start ----------
mm-get-rid-of-radix-tree-gfp-mask-for-pagecache_get_page-was-re-how-to-handle-tif_memdie-stalls.patch
oom-dont-count-on-mm-less-current-process.patch
oom-make-sure-that-tif_memdie-is-set-under-task_lock.patch
my patch for debug printk() on memory allocation stall
my patch for boot failure by bd809af16e3ab1f8 "x86: Enable PAT to use cache mode translation tables"

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index a97ee08..cab1578 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -718,9 +718,6 @@ void __init zone_sizes_init(void)
 
 void update_cache_mode_entry(unsigned entry, enum page_cache_mode cache)
 {
-	/* entry 0 MUST be WB (hardwired to speed up translations) */
-	BUG_ON(!entry && cache != _PAGE_CACHE_MODE_WB);
-
 	__cachemode2pte_tbl[cache] = __cm_idx2pte(entry);
 	__pte2cachemode_tbl[entry] = cache;
 }
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7ea069c..4b3736f 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -251,7 +251,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
 #define FGP_NOWAIT		0x00000020
 
 struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
-		int fgp_flags, gfp_t cache_gfp_mask, gfp_t radix_gfp_mask);
+		int fgp_flags, gfp_t cache_gfp_mask);
 
 /**
  * find_get_page - find and get a page reference
@@ -266,13 +266,13 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 static inline struct page *find_get_page(struct address_space *mapping,
 					pgoff_t offset)
 {
-	return pagecache_get_page(mapping, offset, 0, 0, 0);
+	return pagecache_get_page(mapping, offset, 0, 0);
 }
 
 static inline struct page *find_get_page_flags(struct address_space *mapping,
 					pgoff_t offset, int fgp_flags)
 {
-	return pagecache_get_page(mapping, offset, fgp_flags, 0, 0);
+	return pagecache_get_page(mapping, offset, fgp_flags, 0);
 }
 
 /**
@@ -292,7 +292,7 @@ static inline struct page *find_get_page_flags(struct address_space *mapping,
 static inline struct page *find_lock_page(struct address_space *mapping,
 					pgoff_t offset)
 {
-	return pagecache_get_page(mapping, offset, FGP_LOCK, 0, 0);
+	return pagecache_get_page(mapping, offset, FGP_LOCK, 0);
 }
 
 /**
@@ -319,7 +319,7 @@ static inline struct page *find_or_create_page(struct address_space *mapping,
 {
 	return pagecache_get_page(mapping, offset,
 					FGP_LOCK|FGP_ACCESSED|FGP_CREAT,
-					gfp_mask, gfp_mask & GFP_RECLAIM_MASK);
+					gfp_mask);
 }
 
 /**
@@ -340,8 +340,7 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 {
 	return pagecache_get_page(mapping, index,
 			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
-			mapping_gfp_mask(mapping),
-			GFP_NOFS);
+			mapping_gfp_mask(mapping));
 }
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8db31ef..69d367f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1701,6 +1701,14 @@ struct task_struct {
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
+	/* Jiffies spent since the start of outermost memory allocation */
+	unsigned long gfp_start;
+	/* GFP flags passed to innermost memory allocation */
+	gfp_t gfp_flags;
+	/* # of shrink_slab() calls since outermost memory allocation. */
+	unsigned int shrink_slab_counter;
+	/* # of OOM-killer skipped. */
+	atomic_t oom_killer_skip_counter;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index b5797b7..e7fc702 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4502,6 +4502,22 @@ out_unlock:
 	return retval;
 }
 
+static void print_memalloc_info(const struct task_struct *p)
+{
+	const gfp_t gfp = p->gfp_flags & __GFP_WAIT;
+
+	/*
+	 * __alloc_pages_nodemask() doesn't use smp_wmb() between
+	 * updating ->gfp_start and ->gfp_flags. But reading stale
+	 * ->gfp_start value harms nothing but printing bogus duration.
+	 * Correct duration will be printed when this function is
+	 * called for the next time.
+	 */
+	if (unlikely(gfp))
+		printk(KERN_INFO "MemAlloc: %ld jiffies on 0x%x\n",
+		       jiffies - p->gfp_start, gfp);
+}
+
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
 void sched_show_task(struct task_struct *p)
@@ -4536,6 +4552,7 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), ppid,
 		(unsigned long)task_thread_info(p)->flags);
 
+	print_memalloc_info(p);
 	print_worker_info(KERN_INFO, p);
 	show_stack(p, NULL);
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index bd8543c..673e458 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1046,8 +1046,7 @@ EXPORT_SYMBOL(find_lock_entry);
  * @mapping: the address_space to search
  * @offset: the page index
  * @fgp_flags: PCG flags
- * @cache_gfp_mask: gfp mask to use for the page cache data page allocation
- * @radix_gfp_mask: gfp mask to use for radix tree node allocation
+ * @gfp_mask: gfp mask to use for the page cache data page allocation
  *
  * Looks up the page cache slot at @mapping & @offset.
  *
@@ -1056,11 +1055,9 @@ EXPORT_SYMBOL(find_lock_entry);
  * FGP_ACCESSED: the page will be marked accessed
  * FGP_LOCK: Page is return locked
  * FGP_CREAT: If page is not present then a new page is allocated using
- *		@cache_gfp_mask and added to the page cache and the VM's LRU
- *		list. If radix tree nodes are allocated during page cache
- *		insertion then @radix_gfp_mask is used. The page is returned
- *		locked and with an increased refcount. Otherwise, %NULL is
- *		returned.
+ *		@gfp_mask and added to the page cache and the VM's LRU
+ *		list. The page is returned locked and with an increased
+ *		refcount. Otherwise, %NULL is returned.
  *
  * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
  * if the GFP flags specified for FGP_CREAT are atomic.
@@ -1068,7 +1065,7 @@ EXPORT_SYMBOL(find_lock_entry);
  * If there is a page cache page, it is returned with an increased refcount.
  */
 struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
-	int fgp_flags, gfp_t cache_gfp_mask, gfp_t radix_gfp_mask)
+	int fgp_flags, gfp_t gfp_mask)
 {
 	struct page *page;
 
@@ -1105,13 +1102,11 @@ no_page:
 	if (!page && (fgp_flags & FGP_CREAT)) {
 		int err;
 		if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
-			cache_gfp_mask |= __GFP_WRITE;
-		if (fgp_flags & FGP_NOFS) {
-			cache_gfp_mask &= ~__GFP_FS;
-			radix_gfp_mask &= ~__GFP_FS;
-		}
+			gfp_mask |= __GFP_WRITE;
+		if (fgp_flags & FGP_NOFS)
+			gfp_mask &= ~__GFP_FS;
 
-		page = __page_cache_alloc(cache_gfp_mask);
+		page = __page_cache_alloc(gfp_mask);
 		if (!page)
 			return NULL;
 
@@ -1122,7 +1117,8 @@ no_page:
 		if (fgp_flags & FGP_ACCESSED)
 			__SetPageReferenced(page);
 
-		err = add_to_page_cache_lru(page, mapping, offset, radix_gfp_mask);
+		err = add_to_page_cache_lru(page, mapping, offset,
+				gfp_mask & GFP_RECLAIM_MASK);
 		if (unlikely(err)) {
 			page_cache_release(page);
 			page = NULL;
@@ -2443,8 +2439,7 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 		fgp_flags |= FGP_NOFS;
 
 	page = pagecache_get_page(mapping, index, fgp_flags,
-			mapping_gfp_mask(mapping),
-			GFP_KERNEL);
+			mapping_gfp_mask(mapping));
 	if (page)
 		wait_for_stable_page(page);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9c..2f3ece1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -304,6 +304,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	rcu_read_lock();
 	for_each_process_thread(g, p) {
 		unsigned int points;
+		unsigned int count;
 
 		switch (oom_scan_process_thread(p, totalpages, nodemask,
 						force_kill)) {
@@ -314,6 +315,14 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_CONTINUE:
 			continue;
 		case OOM_SCAN_ABORT:
+			count = atomic_inc_return(&p->oom_killer_skip_counter);
+			if (count % 1000 == 0)
+				printk(KERN_INFO "%s(pid=%d,flags=0x%x) "
+				       "waited for %s(pid=%d,flags=0x%x) for "
+				       "%u times at select_bad_process().\n",
+				       current->comm, current->pid,
+				       current->gfp_flags, p->comm, p->pid,
+				       p->gfp_flags, count);
 			rcu_read_unlock();
 			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
@@ -438,11 +447,22 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
-	if (task_will_free_mem(p)) {
+	task_lock(p);
+	if (p->mm && task_will_free_mem(p)) {
+		unsigned int count =
+			atomic_inc_return(&p->oom_killer_skip_counter);
+		if (count % 1000 == 0)
+			printk(KERN_INFO "%s(pid=%d,flags=0x%x) waited for "
+			       "%s(pid=%d,flags=0x%x) for %u times at "
+			       "oom_kill_process().\n", current->comm,
+			       current->pid, current->gfp_flags, p->comm,
+			       p->pid, p->gfp_flags, count);
 		set_tsk_thread_flag(p, TIF_MEMDIE);
+		task_unlock(p);
 		put_task_struct(p);
 		return;
 	}
+	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
@@ -492,6 +512,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
+	set_tsk_thread_flag(victim, TIF_MEMDIE);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -522,7 +543,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
@@ -643,8 +663,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * But don't select if current has already released its mm and cleared
+	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if (current->mm &&
+	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..a3b0c5a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2877,6 +2877,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	int classzone_idx;
+	const gfp_t old_gfp_flags = current->gfp_flags;
+
+	if (!old_gfp_flags) {
+		current->gfp_start = jiffies;
+		current->shrink_slab_counter = 0;
+	}
+	current->gfp_flags = gfp_mask;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2885,7 +2892,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+		goto nopage;
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
@@ -2893,7 +2900,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * of GFP_THISNODE and a memoryless node
 	 */
 	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
+		goto nopage;
 
 	if (IS_ENABLED(CONFIG_CMA) && migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
@@ -2937,6 +2944,9 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
+nopage:
+	current->gfp_flags = old_gfp_flags;
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd9a72b..7d736d6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -368,6 +368,7 @@ unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
+	const unsigned long start = jiffies;
 
 	if (nr_scanned == 0)
 		nr_scanned = SWAP_CLUSTER_MAX;
@@ -397,6 +398,13 @@ unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
 
 	up_read(&shrinker_rwsem);
 out:
+	if (++current->shrink_slab_counter % 100000 == 0)
+		printk(KERN_INFO "%s(pid=%d,flags=0x%x) called "
+		       "shrink_slab() for %u times. This time freed "
+		       "%lu object and took %lu jiffies. Spent %lu "
+		       "jiffies till now.\n", current->comm, current->pid,
+		       current->gfp_flags, current->shrink_slab_counter, freed,
+		       jiffies - start, jiffies - current->gfp_start);
 	cond_resched();
 	return freed;
 }
---------- diff end ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
