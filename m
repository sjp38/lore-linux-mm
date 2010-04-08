Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 259D862008E
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:13 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 49 of 67] Take a reference to the anon_vma before migrating
Message-Id: <2d878eacfb3080618cf8.1270691492@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Mel Gorman <mel@csn.ul.ie>

rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
locking an anon_vma and it does not appear to have sufficient locking to
ensure the anon_vma does not disappear from under it.

This patch copies an approach used by KSM to take a reference on the
anon_vma while pages are being migrated. This should prevent rmap_walk()
running into nasty surprises later because anon_vma has been freed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -29,6 +29,9 @@ struct anon_vma {
 #ifdef CONFIG_KSM
 	atomic_t ksm_refcount;
 #endif
+#ifdef CONFIG_MIGRATION
+	atomic_t migrate_refcount;
+#endif
 	/*
 	 * NOTE: the LSB of the head.next is set by
 	 * mm_take_all_locks() _after_ taking the above lock. So the
@@ -81,6 +84,26 @@ static inline int ksm_refcount(struct an
 	return 0;
 }
 #endif /* CONFIG_KSM */
+#ifdef CONFIG_MIGRATION
+static inline void migrate_refcount_init(struct anon_vma *anon_vma)
+{
+	atomic_set(&anon_vma->migrate_refcount, 0);
+}
+
+static inline int migrate_refcount(struct anon_vma *anon_vma)
+{
+	return atomic_read(&anon_vma->migrate_refcount);
+}
+#else
+static inline void migrate_refcount_init(struct anon_vma *anon_vma)
+{
+}
+
+static inline int migrate_refcount(struct anon_vma *anon_vma)
+{
+	return 0;
+}
+#endif /* CONFIG_MIGRATE */
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -549,6 +549,7 @@ static int unmap_and_move(new_page_t get
 	int rcu_locked = 0;
 	int charge = 0;
 	struct mem_cgroup *mem = NULL;
+	struct anon_vma *anon_vma = NULL;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -608,6 +609,8 @@ static int unmap_and_move(new_page_t get
 	if (PageAnon(page)) {
 		rcu_read_lock();
 		rcu_locked = 1;
+		anon_vma = page_anon_vma(page);
+		atomic_inc(&anon_vma->migrate_refcount);
 	}
 
 	/*
@@ -647,6 +650,15 @@ skip_unmap:
 	if (rc)
 		remove_migration_ptes(page, page);
 rcu_unlock:
+
+	/* Drop an anon_vma reference if we took one */
+	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
+		int empty = list_empty(&anon_vma->head);
+		spin_unlock(&anon_vma->lock);
+		if (empty)
+			anon_vma_free(anon_vma);
+	}
+
 	if (rcu_locked)
 		rcu_read_unlock();
 uncharge:
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -250,7 +250,8 @@ static void anon_vma_unlink(struct anon_
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
+	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
+					!migrate_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -275,6 +276,7 @@ static void anon_vma_ctor(void *data)
 
 	spin_lock_init(&anon_vma->lock);
 	ksm_refcount_init(anon_vma);
+	migrate_refcount_init(anon_vma);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -1365,10 +1367,8 @@ static int rmap_walk_anon(struct page *p
 	/*
 	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
 	 * because that depends on page_mapped(); but not all its usages
-	 * are holding mmap_sem, which also gave the necessary guarantee
-	 * (that this anon_vma's slab has not already been destroyed).
-	 * This needs to be reviewed later: avoiding page_lock_anon_vma()
-	 * is risky, and currently limits the usefulness of rmap_walk().
+	 * are holding mmap_sem. Users without mmap_sem are required to
+	 * take a reference count to prevent the anon_vma disappearing
 	 */
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
