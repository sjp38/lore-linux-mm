Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5C8556B01BA
	for <linux-mm@kvack.org>; Wed, 26 May 2010 15:42:46 -0400 (EDT)
Date: Wed, 26 May 2010 15:40:10 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 3/5] track the root (oldest) anon_vma
Message-ID: <20100526154010.3904df5c@annuminas.surriel.com>
In-Reply-To: <20100526153819.6e5cec0d@annuminas.surriel.com>
References: <20100526153819.6e5cec0d@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Subject: track the root (oldest) anon_vma

Track the root (oldest) anon_vma in each anon_vma tree.   Because we only
take the lock on the root anon_vma, we cannot use the lock on higher-up
anon_vmas to lock anything.  This makes it impossible to do an indirect
lookup of the root anon_vma, since the data structures could go away from
under us.

However, a direct pointer is safe because the root anon_vma is always the
last one that gets freed on munmap or exit, by virtue of the same_vma list
order and unlink_anon_vmas walking the list forward.

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/rmap.h |    1 +
 mm/rmap.c            |   18 ++++++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

Index: linux-2.6.34/include/linux/rmap.h
===================================================================
--- linux-2.6.34.orig/include/linux/rmap.h
+++ linux-2.6.34/include/linux/rmap.h
@@ -26,6 +26,7 @@
  */
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
+	struct anon_vma *root;	/* Root of this anon_vma tree */
 #if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
 
 	/*
Index: linux-2.6.34/mm/rmap.c
===================================================================
--- linux-2.6.34.orig/mm/rmap.c
+++ linux-2.6.34/mm/rmap.c
@@ -132,6 +132,11 @@ int anon_vma_prepare(struct vm_area_stru
 			if (unlikely(!anon_vma))
 				goto out_enomem_free_avc;
 			allocated = anon_vma;
+			/*
+			 * This VMA had no anon_vma yet.  This anon_vma is
+			 * the root of any anon_vma tree that might form.
+			 */
+			anon_vma->root = anon_vma;
 		}
 
 		anon_vma_lock(anon_vma);
@@ -224,9 +229,15 @@ int anon_vma_fork(struct vm_area_struct 
 	avc = anon_vma_chain_alloc();
 	if (!avc)
 		goto out_error_free_anon_vma;
-	anon_vma_chain_link(vma, avc, anon_vma);
+
+	/*
+	 * The root anon_vm's spinlock is the lock actually used when we
+	 * lock any of the anon_vmas in this anon_vma tree.
+	 */
+	anon_vma->root = pvma->anon_vma->root;
 	/* Mark this anon_vma as the one where our new (COWed) pages go. */
 	vma->anon_vma = anon_vma;
+	anon_vma_chain_link(vma, avc, anon_vma);
 
 	return 0;
 
@@ -261,7 +272,10 @@ void unlink_anon_vmas(struct vm_area_str
 {
 	struct anon_vma_chain *avc, *next;
 
-	/* Unlink each anon_vma chained to the VMA. */
+	/*
+	 * Unlink each anon_vma chained to the VMA.  This list is ordered
+	 * from newest to oldest, ensuring the root anon_vma gets freed last.
+	 */
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
 		anon_vma_unlink(avc);
 		list_del(&avc->same_vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
