Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B5E9900114
	for <linux-mm@kvack.org>; Thu,  5 May 2011 15:33:21 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/4] VM/RMAP: Batch anon vma chain root locking in fork
Date: Thu,  5 May 2011 12:32:50 -0700
Message-Id: <1304623972-9159-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

We found that the changes to take anon vma root chain lock lead
to excessive lock contention on a fork intensive workload on a 4S
system.

Use the new batch lock infrastructure to optimize the fork()
path, where it is very common to acquire always the same lock.

This patch does not really lower the contention, but batches
the lock taking/freeing to lower the bouncing overhead when
multiple forks are working at the same time. Essentially each
user will get more work done inside a locking region.

Reported-by: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/rmap.c |   69 +++++++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 49 insertions(+), 20 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 8da044a..fbac55a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -177,44 +177,72 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 	return -ENOMEM;
 }
 
+/* Caller must call anon_vma_unlock_batch. */
 static void anon_vma_chain_link(struct vm_area_struct *vma,
 				struct anon_vma_chain *avc,
-				struct anon_vma *anon_vma)
+				struct anon_vma *anon_vma,
+				struct anon_vma_lock_state *avs)
 {
 	avc->vma = vma;
 	avc->anon_vma = anon_vma;
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
 
-	anon_vma_lock(anon_vma);
+	anon_vma_lock_batch(anon_vma, avs);
 	/*
 	 * It's critical to add new vmas to the tail of the anon_vma,
 	 * see comment in huge_memory.c:__split_huge_page().
 	 */
 	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
-	anon_vma_unlock(anon_vma);
+	/* unlock in caller */
 }
 
+
 /*
  * Attach the anon_vmas from src to dst.
  * Returns 0 on success, -ENOMEM on failure.
+ * Caller must call anon_vma_unlock_batch.
  */
-int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
+static int anon_vma_clone_batch(struct vm_area_struct *dst, 
+				struct vm_area_struct *src,
+				struct anon_vma_lock_state *avs)
 {
-	struct anon_vma_chain *avc, *pavc;
-
+	struct anon_vma_chain *avc, *pavc, *avc_next;
+	LIST_HEAD(head);
+	
+	/* First allocate with sleeping */
 	list_for_each_entry_reverse(pavc, &src->anon_vma_chain, same_vma) {
 		avc = anon_vma_chain_alloc();
 		if (!avc)
 			goto enomem_failure;
-		anon_vma_chain_link(dst, avc, pavc->anon_vma);
+		list_add_tail(&avc->same_anon_vma, &head);
+	}	
+
+	/* Now take locks and link in */
+	init_anon_vma_lock_batch(avs);
+	avc = list_first_entry(&head, struct anon_vma_chain, same_anon_vma);
+	list_for_each_entry_reverse(pavc, &src->anon_vma_chain, same_vma) {
+		avc_next = list_entry(avc->same_anon_vma.next, 
+				      struct anon_vma_chain,
+				      same_anon_vma);
+		anon_vma_chain_link(dst, avc, pavc->anon_vma, avs);
+		avc = avc_next;
 	}
 	return 0;
 
  enomem_failure:
-	unlink_anon_vmas(dst);
+	list_for_each_entry (avc, &head, same_anon_vma)
+		anon_vma_chain_free(avc);
 	return -ENOMEM;
 }
 
+int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
+{
+	struct anon_vma_lock_state avs;
+	int n = anon_vma_clone_batch(dst, src, &avs);
+	anon_vma_unlock_batch(&avs);
+	return n;
+}
+
 /*
  * Attach vma to its own anon_vma, as well as to the anon_vmas that
  * the corresponding VMA in the parent process is attached to.
@@ -224,27 +252,27 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 {
 	struct anon_vma_chain *avc;
 	struct anon_vma *anon_vma;
+	struct anon_vma_lock_state avs;
 
 	/* Don't bother if the parent process has no anon_vma here. */
 	if (!pvma->anon_vma)
 		return 0;
 
-	/*
-	 * First, attach the new VMA to the parent VMA's anon_vmas,
-	 * so rmap can find non-COWed pages in child processes.
-	 */
-	if (anon_vma_clone(vma, pvma))
-		return -ENOMEM;
-
-	/* Then add our own anon_vma. */
 	anon_vma = anon_vma_alloc();
 	if (!anon_vma)
-		goto out_error;
+		return -ENOMEM;
 	avc = anon_vma_chain_alloc();
 	if (!avc)
 		goto out_error_free_anon_vma;
 
 	/*
+	 * First, attach the new VMA to the parent VMA's anon_vmas,
+	 * so rmap can find non-COWed pages in child processes.
+	 */
+	if (anon_vma_clone_batch(vma, pvma, &avs))
+		goto out_error_free_vma_chain;
+
+	/*
 	 * The root anon_vma's spinlock is the lock actually used when we
 	 * lock any of the anon_vmas in this anon_vma tree.
 	 */
@@ -257,14 +285,15 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	get_anon_vma(anon_vma->root);
 	/* Mark this anon_vma as the one where our new (COWed) pages go. */
 	vma->anon_vma = anon_vma;
-	anon_vma_chain_link(vma, avc, anon_vma);
+	anon_vma_chain_link(vma, avc, anon_vma, &avs);
+	anon_vma_unlock_batch(&avs);
 
 	return 0;
 
+ out_error_free_vma_chain:
+	anon_vma_chain_free(avc);
  out_error_free_anon_vma:
 	put_anon_vma(anon_vma);
- out_error:
-	unlink_anon_vmas(vma);
 	return -ENOMEM;
 }
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
