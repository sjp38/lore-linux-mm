Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B484C900001
	for <linux-mm@kvack.org>; Thu,  5 May 2011 15:33:20 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 4/4] VM/RMAP: Move avc freeing outside the lock
Date: Thu,  5 May 2011 12:32:52 -0700
Message-Id: <1304623972-9159-5-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Now that the avc locking is batched move the freeing of AVCs
outside the lock. This lowers lock contention somewhat more on
a fork/exit intensive workload.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/rmap.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 2076d78..92070f4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -302,7 +302,6 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain,
 			    struct anon_vma_lock_state *avs)
 {
 	struct anon_vma *anon_vma = anon_vma_chain->anon_vma;
-	int empty;
 
 	/* If anon_vma_fork fails, we can get an empty anon_vma_chain. */
 	if (!anon_vma)
@@ -310,19 +309,14 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain,
 
 	anon_vma_lock_batch(anon_vma, avs);
 	list_del(&anon_vma_chain->same_anon_vma);
-
-	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
-
-	if (empty)
-		put_anon_vma(anon_vma);
 }
 
 void unlink_anon_vmas(struct vm_area_struct *vma)
 {
 	struct anon_vma_chain *avc, *next;
 	struct anon_vma_lock_state avs;
-	
+	LIST_HEAD(avmas);
+
 	/*
 	 * Unlink each anon_vma chained to the VMA.  This list is ordered
 	 * from newest to oldest, ensuring the root anon_vma gets freed last.
@@ -330,10 +324,20 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 	init_anon_vma_lock_batch(&avs);
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
 		anon_vma_unlink(avc, &avs);
-		list_del(&avc->same_vma);
-		anon_vma_chain_free(avc);
+		list_move(&avc->same_vma, &avmas);
 	}
 	anon_vma_unlock_batch(&avs);
+
+	/* Now free them outside the lock */
+	list_for_each_entry_safe(avc, next, &avmas, same_vma) {
+		/* 
+		 * list_empty check can be done lockless because
+		 * once it is empty noone will readd.
+		 */
+		if (list_empty(&avc->anon_vma->head))
+			put_anon_vma(avc->anon_vma);
+		anon_vma_chain_free(avc);		
+	}
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
