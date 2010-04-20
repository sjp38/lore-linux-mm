Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A08DB6B01F2
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:01:16 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 01/14] mm,migration: Take a reference to the anon_vma before migrating
Date: Tue, 20 Apr 2010 22:01:03 +0100
Message-Id: <1271797276-31358-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
locking an anon_vma and it does not appear to have sufficient locking to
ensure the anon_vma does not disappear from under it.

This patch copies an approach used by KSM to take a reference on the
anon_vma while pages are being migrated.  This should prevent rmap_walk()
running into nasty surprises later because anon_vma has been freed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/rmap.h |   23 +++++++++++++++++++++++
 mm/migrate.c         |   12 ++++++++++++
 mm/rmap.c            |   10 +++++-----
 3 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d25bd22..567d43f 100644
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
@@ -81,6 +84,26 @@ static inline int ksm_refcount(struct anon_vma *anon_vma)
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
index 5938db5..b768a1d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -543,6 +543,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	int rcu_locked = 0;
 	int charge = 0;
 	struct mem_cgroup *mem = NULL;
+	struct anon_vma *anon_vma = NULL;
 
 	if (!newpage)
 		return -ENOMEM;
@@ -599,6 +600,8 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	if (PageAnon(page)) {
 		rcu_read_lock();
 		rcu_locked = 1;
+		anon_vma = page_anon_vma(page);
+		atomic_inc(&anon_vma->migrate_refcount);
 	}
 
 	/*
@@ -638,6 +641,15 @@ skip_unmap:
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
index c59eaea..4bad2c5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -249,7 +249,8 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
+	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
+					!migrate_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -274,6 +275,7 @@ static void anon_vma_ctor(void *data)
 
 	spin_lock_init(&anon_vma->lock);
 	ksm_refcount_init(anon_vma);
+	migrate_refcount_init(anon_vma);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -1365,10 +1367,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
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
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
