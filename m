Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 1D8D16B005D
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 15:15:44 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so800436eaa.14
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 12:15:42 -0800 (PST)
Date: Sat, 1 Dec 2012 21:15:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 2/2] mm/migration: Make rmap_walk_anon() and
 try_to_unmap_anon() more scalable
Message-ID: <20121201201538.GB2704@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
 <20121201122649.GA20322@gmail.com>
 <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
 <20121201184135.GA32449@gmail.com>
 <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


Note, with this optimization I went a farther than the 
boundaries of the migration code - it seemed worthwile to do and 
I've reviewed all the other users of page_lock_anon_vma() as 
well and none seemed to be modifying the list inside that lock.

Please review this patch carefully - in particular the SMP races 
outlined in anon_vma_free() are exciting: I have updated the 
reasoning and it still appears to hold, but please double check 
the changes nevertheless ...

Thanks,

	Ingo

------------------->
From: Ingo Molnar <mingo@kernel.org>
Date: Sat Dec 1 20:43:04 CET 2012

rmap_walk_anon() and try_to_unmap_anon() appears to be too careful
about locking the anon vma: while it needs protection against anon
vma list modifications, it does not need exclusive access to the
list itself.

Transforming this exclusive lock to a read-locked rwsem removes a
global lock from the hot path of page-migration intense threaded
workloads which can cause pathological performance like this:

    96.43%        process 0  [kernel.kallsyms]  [k] perf_trace_sched_switch
                  |
                  --- perf_trace_sched_switch
                      __schedule
                      schedule
                      schedule_preempt_disabled
                      __mutex_lock_common.isra.6
                      __mutex_lock_slowpath
                      mutex_lock
                     |
                     |--50.61%-- rmap_walk
                     |          move_to_new_page
                     |          migrate_pages
                     |          migrate_misplaced_page
                     |          __do_numa_page.isra.69
                     |          handle_pte_fault
                     |          handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          __memset_sse2
                     |          |
                     |           --100.00%-- worker_thread
                     |                     |
                     |                      --100.00%-- start_thread
                     |
                      --49.39%-- page_lock_anon_vma
                                try_to_unmap_anon
                                try_to_unmap
                                migrate_pages
                                migrate_misplaced_page
                                __do_numa_page.isra.69
                                handle_pte_fault
                                handle_mm_fault
                                __do_page_fault
                                do_page_fault
                                page_fault
                                __memset_sse2
                                |
                                 --100.00%-- worker_thread
                                           start_thread

With this change applied the profile is now nicely flat
and there's no anon-vma related scheduling/blocking.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/rmap.h |   15 +++++++++++++--
 mm/huge_memory.c     |    4 ++--
 mm/memory-failure.c  |    4 ++--
 mm/migrate.c         |    2 +-
 mm/rmap.c            |   40 ++++++++++++++++++++--------------------
 5 files changed, 38 insertions(+), 27 deletions(-)

Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -128,6 +128,17 @@ static inline void anon_vma_unlock(struc
 	up_write(&anon_vma->root->rwsem);
 }
 
+static inline void anon_vma_lock_read(struct anon_vma *anon_vma)
+{
+	down_read(&anon_vma->root->rwsem);
+}
+
+static inline void anon_vma_unlock_read(struct anon_vma *anon_vma)
+{
+	up_read(&anon_vma->root->rwsem);
+}
+
+
 /*
  * anon_vma helper functions.
  */
@@ -220,8 +231,8 @@ int try_to_munlock(struct page *);
 /*
  * Called by memory-failure.c to kill processes.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page);
-void page_unlock_anon_vma(struct anon_vma *anon_vma);
+struct anon_vma *page_lock_anon_vma_read(struct page *page);
+void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
 /*
Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c
+++ linux/mm/huge_memory.c
@@ -1645,7 +1645,7 @@ int split_huge_page(struct page *page)
 	int ret = 1;
 
 	BUG_ON(!PageAnon(page));
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
 		goto out;
 	ret = 0;
@@ -1658,7 +1658,7 @@ int split_huge_page(struct page *page)
 
 	BUG_ON(PageCompound(page));
 out_unlock:
-	page_unlock_anon_vma(anon_vma);
+	page_unlock_anon_vma_read(anon_vma);
 out:
 	return ret;
 }
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -402,7 +402,7 @@ static void collect_procs_anon(struct pa
 	struct anon_vma *av;
 	pgoff_t pgoff;
 
-	av = page_lock_anon_vma(page);
+	av = page_lock_anon_vma_read(page);
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
@@ -423,7 +423,7 @@ static void collect_procs_anon(struct pa
 		}
 	}
 	read_unlock(&tasklist_lock);
-	page_unlock_anon_vma(av);
+	page_unlock_anon_vma_read(av);
 }
 
 /*
Index: linux/mm/migrate.c
===================================================================
--- linux.orig/mm/migrate.c
+++ linux/mm/migrate.c
@@ -751,7 +751,7 @@ static int __unmap_and_move(struct page
 	 */
 	if (PageAnon(page)) {
 		/*
-		 * Only page_lock_anon_vma() understands the subtleties of
+		 * Only page_lock_anon_vma_read() understands the subtleties of
 		 * getting a hold on an anon_vma from outside one of its mms.
 		 */
 		anon_vma = page_get_anon_vma(page);
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -87,18 +87,18 @@ static inline void anon_vma_free(struct
 	VM_BUG_ON(atomic_read(&anon_vma->refcount));
 
 	/*
-	 * Synchronize against page_lock_anon_vma() such that
+	 * Synchronize against page_lock_anon_vma_read() such that
 	 * we can safely hold the lock without the anon_vma getting
 	 * freed.
 	 *
 	 * Relies on the full mb implied by the atomic_dec_and_test() from
 	 * put_anon_vma() against the acquire barrier implied by
-	 * mutex_trylock() from page_lock_anon_vma(). This orders:
+	 * down_read_trylock() from page_lock_anon_vma_read(). This orders:
 	 *
-	 * page_lock_anon_vma()		VS	put_anon_vma()
-	 *   mutex_trylock()			  atomic_dec_and_test()
+	 * page_lock_anon_vma_read()	VS	put_anon_vma()
+	 *   down_read_trylock()		  atomic_dec_and_test()
 	 *   LOCK				  MB
-	 *   atomic_read()			  mutex_is_locked()
+	 *   atomic_read()			  rwsem_is_locked()
 	 *
 	 * LOCK should suffice since the actual taking of the lock must
 	 * happen _before_ what follows.
@@ -146,7 +146,7 @@ static void anon_vma_chain_link(struct v
  * allocate a new one.
  *
  * Anon-vma allocations are very subtle, because we may have
- * optimistically looked up an anon_vma in page_lock_anon_vma()
+ * optimistically looked up an anon_vma in page_lock_anon_vma_read()
  * and that may actually touch the spinlock even in the newly
  * allocated vma (it depends on RCU to make sure that the
  * anon_vma isn't actually destroyed).
@@ -442,7 +442,7 @@ out:
  * atomic op -- the trylock. If we fail the trylock, we fall back to getting a
  * reference like with page_get_anon_vma() and then block on the mutex.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma_read(struct page *page)
 {
 	struct anon_vma *anon_vma = NULL;
 	struct anon_vma *root_anon_vma;
@@ -457,14 +457,14 @@ struct anon_vma *page_lock_anon_vma(stru
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
-	if (down_write_trylock(&root_anon_vma->rwsem)) {
+	if (down_read_trylock(&root_anon_vma->rwsem)) {
 		/*
 		 * If the page is still mapped, then this anon_vma is still
 		 * its anon_vma, and holding the mutex ensures that it will
 		 * not go away, see anon_vma_free().
 		 */
 		if (!page_mapped(page)) {
-			up_write(&root_anon_vma->rwsem);
+			up_read(&root_anon_vma->rwsem);
 			anon_vma = NULL;
 		}
 		goto out;
@@ -484,7 +484,7 @@ struct anon_vma *page_lock_anon_vma(stru
 
 	/* we pinned the anon_vma, its safe to sleep */
 	rcu_read_unlock();
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_read(anon_vma);
 
 	if (atomic_dec_and_test(&anon_vma->refcount)) {
 		/*
@@ -492,7 +492,7 @@ struct anon_vma *page_lock_anon_vma(stru
 		 * and bail -- can't simply use put_anon_vma() because
 		 * we'll deadlock on the anon_vma_lock() recursion.
 		 */
-		anon_vma_unlock(anon_vma);
+		anon_vma_unlock_read(anon_vma);
 		__put_anon_vma(anon_vma);
 		anon_vma = NULL;
 	}
@@ -504,9 +504,9 @@ out:
 	return anon_vma;
 }
 
-void page_unlock_anon_vma(struct anon_vma *anon_vma)
+void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 {
-	anon_vma_unlock(anon_vma);
+	anon_vma_unlock_read(anon_vma);
 }
 
 /*
@@ -732,7 +732,7 @@ static int page_referenced_anon(struct p
 	struct anon_vma_chain *avc;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
 		return referenced;
 
@@ -754,7 +754,7 @@ static int page_referenced_anon(struct p
 			break;
 	}
 
-	page_unlock_anon_vma(anon_vma);
+	page_unlock_anon_vma_read(anon_vma);
 	return referenced;
 }
 
@@ -1474,7 +1474,7 @@ static int try_to_unmap_anon(struct page
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
 		return ret;
 
@@ -1501,7 +1501,7 @@ static int try_to_unmap_anon(struct page
 			break;
 	}
 
-	page_unlock_anon_vma(anon_vma);
+	page_unlock_anon_vma_read(anon_vma);
 	return ret;
 }
 
@@ -1696,7 +1696,7 @@ static int rmap_walk_anon(struct page *p
 	int ret = SWAP_AGAIN;
 
 	/*
-	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
+	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma_read()
 	 * because that depends on page_mapped(); but not all its usages
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
@@ -1704,7 +1704,7 @@ static int rmap_walk_anon(struct page *p
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		return ret;
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_read(anon_vma);
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
@@ -1712,7 +1712,7 @@ static int rmap_walk_anon(struct page *p
 		if (ret != SWAP_AGAIN)
 			break;
 	}
-	anon_vma_unlock(anon_vma);
+	anon_vma_unlock_read(anon_vma);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
