Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3AEED90010E
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:46:54 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 3/4] VM/RMAP: Batch anon_vma_unlink in exit
Date: Fri, 13 May 2011 16:46:23 -0700
Message-Id: <1305330384-19540-4-git-send-email-andi@firstfloor.org>
In-Reply-To: <1305330384-19540-1-git-send-email-andi@firstfloor.org>
References: <1305330384-19540-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Apply the rmap chain lock batching to anon_vma_unlink() too.
This speeds up exit() on process chains with many processes,
when there is a lot of sharing.

Unfortunately this doesn't fix all lock contention -- file vmas
have a mapping lock that is also a problem. And even existing
anon_vmas still contend. But it's better than before.

Reviewed-by: Rik van Riel<riel@redhat.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/rmap.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 4e93770..d4d3680 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -297,7 +297,9 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	return -ENOMEM;
 }
 
-static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
+/* Caller must call anon_vma_unlock_batch */
+static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain,
+			    struct anon_vma_lock_state *avs)
 {
 	struct anon_vma *anon_vma = anon_vma_chain->anon_vma;
 	int empty;
@@ -306,12 +308,11 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 	if (!anon_vma)
 		return;
 
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_batch(anon_vma, avs);
 	list_del(&anon_vma_chain->same_anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
-	anon_vma_unlock(anon_vma);
 
 	if (empty)
 		put_anon_vma(anon_vma);
@@ -320,16 +321,19 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 void unlink_anon_vmas(struct vm_area_struct *vma)
 {
 	struct anon_vma_chain *avc, *next;
-
+	struct anon_vma_lock_state avs;
+	
 	/*
 	 * Unlink each anon_vma chained to the VMA.  This list is ordered
 	 * from newest to oldest, ensuring the root anon_vma gets freed last.
 	 */
+	anon_vma_lock_batch_init(&avs);
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
-		anon_vma_unlink(avc);
+		anon_vma_unlink(avc, &avs);
 		list_del(&avc->same_vma);
 		anon_vma_chain_free(avc);
 	}
+	anon_vma_unlock_batch(&avs);
 }
 
 static void anon_vma_ctor(void *data)
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
