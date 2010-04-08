Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9964662008A
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:10 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 51 of 67] Share the anon_vma ref counts between KSM and page
	migration
Message-Id: <9acd43df3ec98bdef70a.1270691494@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:34 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

From: Mel Gorman <mel@csn.ul.ie>

For clarity of review, KSM and page migration have separate refcounts on
the anon_vma. While clear, this is a waste of memory. This patch gets
KSM and page migration to share their toys in a spirit of harmony.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
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
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -318,14 +318,14 @@ static void hold_anon_vma(struct rmap_it
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
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -621,7 +621,7 @@ static int unmap_and_move(new_page_t get
 			goto rcu_unlock;
 
 		anon_vma = page_anon_vma(page);
-		atomic_inc(&anon_vma->migrate_refcount);
+		atomic_inc(&anon_vma->external_refcount);
 	}
 
 	/*
@@ -663,7 +663,7 @@ skip_unmap:
 rcu_unlock:
 
 	/* Drop an anon_vma reference if we took one */
-	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
+	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
 		int empty = list_empty(&anon_vma->head);
 		spin_unlock(&anon_vma->lock);
 		if (empty)
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -250,8 +250,7 @@ static void anon_vma_unlink(struct anon_
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
-					!migrate_refcount(anon_vma);
+	empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -275,8 +274,7 @@ static void anon_vma_ctor(void *data)
 	struct anon_vma *anon_vma = data;
 
 	spin_lock_init(&anon_vma->lock);
-	ksm_refcount_init(anon_vma);
-	migrate_refcount_init(anon_vma);
+	anonvma_external_refcount_init(anon_vma);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
