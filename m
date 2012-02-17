Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id F17C16B00E9
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 09:28:47 -0500 (EST)
Received: by mail-pz0-f41.google.com with SMTP id v6so4023131dad.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 06:28:47 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 2/2] rmap: anon_vma_prepare: Reduce code duplication by calling anon_vma_chain_link
Date: Fri, 17 Feb 2012 09:28:28 -0500
Message-Id: <1329488908-7304-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

Reduce code duplication by calling anon_vma_chain_link from
anon_vma_prepare.

Also move the anon_vmal_chain_link function to a more suitable location
in the file.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/rmap.c |   35 ++++++++++++++++-------------------
 1 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 74aff97..4df80bb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -120,6 +120,21 @@ static void anon_vma_chain_free(struct anon_vma_chain *anon_vma_chain)
 	kmem_cache_free(anon_vma_chain_cachep, anon_vma_chain);
 }
 
+static void anon_vma_chain_link(struct vm_area_struct *vma,
+				struct anon_vma_chain *avc,
+				struct anon_vma *anon_vma)
+{
+	avc->vma = vma;
+	avc->anon_vma = anon_vma;
+	list_add(&avc->same_vma, &vma->anon_vma_chain);
+
+	/*
+	 * It's critical to add new vmas to the tail of the anon_vma,
+	 * see comment in huge_memory.c:__split_huge_page().
+	 */
+	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
+}
+
 /**
  * anon_vma_prepare - attach an anon_vma to a memory region
  * @vma: the memory region in question
@@ -175,10 +190,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
-			avc->anon_vma = anon_vma;
-			avc->vma = vma;
-			list_add(&avc->same_vma, &vma->anon_vma_chain);
-			list_add_tail(&avc->same_anon_vma, &anon_vma->head);
+			anon_vma_chain_link(vma, avc, anon_vma);
 			allocated = NULL;
 			avc = NULL;
 		}
@@ -224,21 +236,6 @@ static inline void unlock_anon_vma_root(struct anon_vma *root)
 		mutex_unlock(&root->mutex);
 }
 
-static void anon_vma_chain_link(struct vm_area_struct *vma,
-				struct anon_vma_chain *avc,
-				struct anon_vma *anon_vma)
-{
-	avc->vma = vma;
-	avc->anon_vma = anon_vma;
-	list_add(&avc->same_vma, &vma->anon_vma_chain);
-
-	/*
-	 * It's critical to add new vmas to the tail of the anon_vma,
-	 * see comment in huge_memory.c:__split_huge_page().
-	 */
-	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
-}
-
 /*
  * Attach the anon_vmas from src to dst.
  * Returns 0 on success, -ENOMEM on failure.
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
