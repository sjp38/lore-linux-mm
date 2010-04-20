Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED3AE6B0204
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:02:03 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 02/14] mm,migration: Share the anon_vma ref counts between KSM and page migration
Date: Tue, 20 Apr 2010 22:01:04 +0100
Message-Id: <1271797276-31358-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For clarity of review, KSM and page migration have separate refcounts on
the anon_vma.  While clear, this is a waste of memory.  This patch gets
KSM and page migration to share their toys in a spirit of harmony.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/rmap.h |   50 ++++++++++++++++++--------------------------------
 mm/ksm.c             |    4 ++--
 mm/migrate.c         |    4 ++--
 mm/rmap.c            |    6 ++----
 4 files changed, 24 insertions(+), 40 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 567d43f..7721674 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -26,11 +26,17 @@
  */
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
-#ifdef CONFIG_KSM
-	atomic_t ksm_refcount;
-#endif
-#ifdef CONFIG_MIGRATION
-	atomic_t migrate_refcount;
+#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
+
+	/*
+	 * The external_refcount is taken by either KSM or page migration
+	 * to take a reference to an anon_vma when there is no
+	 * guarantee that the vma of page tables will exist for
+	 * the duration of the operation. A caller that takes
+	 * the reference is responsible for clearing up the
+	 * anon_vma if they are the last user on release
+	 */
+	atomic_t external_refcount;
 #endif
 	/*
 	 * NOTE: the LSB of the head.next is set by
@@ -64,46 +70,26 @@ struct anon_vma_chain {
 };
 
 #ifdef CONFIG_MMU
-#ifdef CONFIG_KSM
-static inline void ksm_refcount_init(struct anon_vma *anon_vma)
+#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
+static inline void anonvma_external_refcount_init(struct anon_vma *anon_vma)
 {
-	atomic_set(&anon_vma->ksm_refcount, 0);
+	atomic_set(&anon_vma->external_refcount, 0);
 }
 
-static inline int ksm_refcount(struct anon_vma *anon_vma)
+static inline int anonvma_external_refcount(struct anon_vma *anon_vma)
 {
-	return atomic_read(&anon_vma->ksm_refcount);
+	return atomic_read(&anon_vma->external_refcount);
 }
 #else
-static inline void ksm_refcount_init(struct anon_vma *anon_vma)
+static inline void anonvma_external_refcount_init(struct anon_vma *anon_vma)
 {
 }
 
-static inline int ksm_refcount(struct anon_vma *anon_vma)
+static inline int anonvma_external_refcount(struct anon_vma *anon_vma)
 {
 	return 0;
 }
 #endif /* CONFIG_KSM */
-#ifdef CONFIG_MIGRATION
-static inline void migrate_refcount_init(struct anon_vma *anon_vma)
-{
-	atomic_set(&anon_vma->migrate_refcount, 0);
-}
-
-static inline int migrate_refcount(struct anon_vma *anon_vma)
-{
-	return atomic_read(&anon_vma->migrate_refcount);
-}
-#else
-static inline void migrate_refcount_init(struct anon_vma *anon_vma)
-{
-}
-
-static inline int migrate_refcount(struct anon_vma *anon_vma)
-{
-	return 0;
-}
-#endif /* CONFIG_MIGRATE */
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
diff --git a/mm/ksm.c b/mm/ksm.c
index 8cdfc2a..3666d43 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -318,14 +318,14 @@ static void hold_anon_vma(struct rmap_item *rmap_item,
 			  struct anon_vma *anon_vma)
 {
 	rmap_item->anon_vma = anon_vma;
-	atomic_inc(&anon_vma->ksm_refcount);
+	atomic_inc(&anon_vma->external_refcount);
 }
 
 static void drop_anon_vma(struct rmap_item *rmap_item)
 {
 	struct anon_vma *anon_vma = rmap_item->anon_vma;
 
-	if (atomic_dec_and_lock(&anon_vma->ksm_refcount, &anon_vma->lock)) {
+	if (atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
 		int empty = list_empty(&anon_vma->head);
 		spin_unlock(&anon_vma->lock);
 		if (empty)
diff --git a/mm/migrate.c b/mm/migrate.c
index b768a1d..42a3d24 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -601,7 +601,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		rcu_read_lock();
 		rcu_locked = 1;
 		anon_vma = page_anon_vma(page);
-		atomic_inc(&anon_vma->migrate_refcount);
+		atomic_inc(&anon_vma->external_refcount);
 	}
 
 	/*
@@ -643,7 +643,7 @@ skip_unmap:
 rcu_unlock:
 
 	/* Drop an anon_vma reference if we took one */
-	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
+	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
 		int empty = list_empty(&anon_vma->head);
 		spin_unlock(&anon_vma->lock);
 		if (empty)
diff --git a/mm/rmap.c b/mm/rmap.c
index 4bad2c5..85f203e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -249,8 +249,7 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
-					!migrate_refcount(anon_vma);
+	empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -274,8 +273,7 @@ static void anon_vma_ctor(void *data)
 	struct anon_vma *anon_vma = data;
 
 	spin_lock_init(&anon_vma->lock);
-	ksm_refcount_init(anon_vma);
-	migrate_refcount_init(anon_vma);
+	anonvma_external_refcount_init(anon_vma);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
