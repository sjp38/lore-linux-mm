Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 28F2C6B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 16:20:27 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p4SKKOsl028340
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:20:24 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by wpaz17.hot.corp.google.com with ESMTP id p4SKKMjR016230
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:20:23 -0700
Received: by pvg12 with SMTP id 12so1171649pvg.19
        for <linux-mm@kvack.org>; Sat, 28 May 2011 13:20:22 -0700 (PDT)
Date: Sat, 28 May 2011 13:20:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
Message-ID: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On one machine I've been getting hangs, a page fault's anon_vma_prepare()
waiting in anon_vma_lock(), other processes waiting for that page's lock.

This is a replay of last year's f18194275c39
"mm: fix hang on anon_vma->root->lock".

The new page_lock_anon_vma() places too much faith in its refcount: when
it has acquired the mutex_trylock(), it's possible that a racing task in
anon_vma_alloc() has just reallocated the struct anon_vma, set refcount
to 1, and is about to reset its anon_vma->root.

Fix this by saving anon_vma->root, and relying on the usual page_mapped()
check instead of a refcount check: if page is still mapped, the anon_vma
is still ours; if page is not still mapped, we're no longer interested.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/rmap.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- linux.orig/mm/rmap.c	2011-05-27 20:07:44.000000000 -0700
+++ linux/mm/rmap.c	2011-05-27 20:31:04.596303434 -0700
@@ -405,6 +405,7 @@ out:
 struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma = NULL;
+	struct anon_vma *root_anon_vma;
 	unsigned long anon_mapping;
 
 	rcu_read_lock();
@@ -415,13 +416,15 @@ struct anon_vma *page_lock_anon_vma(stru
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	if (mutex_trylock(&anon_vma->root->mutex)) {
+	root_anon_vma = ACCESS_ONCE(anon_vma->root);
+	if (mutex_trylock(&root_anon_vma->mutex)) {
 		/*
-		 * If we observe a !0 refcount, then holding the lock ensures
-		 * the anon_vma will not go away, see __put_anon_vma().
+		 * If the page is still mapped, then this anon_vma is still
+		 * its anon_vma, and holding the mutex ensures that it will
+		 * not go away, see __put_anon_vma().
 		 */
-		if (!atomic_read(&anon_vma->refcount)) {
-			anon_vma_unlock(anon_vma);
+		if (!page_mapped(page)) {
+			mutex_unlock(&root_anon_vma->mutex);
 			anon_vma = NULL;
 		}
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
