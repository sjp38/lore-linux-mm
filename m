Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 856706B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 04:43:41 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/4] mm, rmap: do easy-job first in anon_vma_fork
Date: Tue,  6 Aug 2013 17:43:37 +0900
Message-Id: <1375778620-31593-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we fail due to some errorous situation, it is better to quit
without doing heavy work. So changing order of execution.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/rmap.c b/mm/rmap.c
index a149e3a..c2f51cb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -278,19 +278,19 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 	if (!pvma->anon_vma)
 		return 0;
 
+	/* First, allocate required objects */
+	avc = anon_vma_chain_alloc(GFP_KERNEL);
+	if (!avc)
+		goto out_error;
+	anon_vma = anon_vma_alloc();
+	if (!anon_vma)
+		goto out_error_free_avc;
+
 	/*
-	 * First, attach the new VMA to the parent VMA's anon_vmas,
+	 * Then attach the new VMA to the parent VMA's anon_vmas,
 	 * so rmap can find non-COWed pages in child processes.
 	 */
 	if (anon_vma_clone(vma, pvma))
-		return -ENOMEM;
-
-	/* Then add our own anon_vma. */
-	anon_vma = anon_vma_alloc();
-	if (!anon_vma)
-		goto out_error;
-	avc = anon_vma_chain_alloc(GFP_KERNEL);
-	if (!avc)
 		goto out_error_free_anon_vma;
 
 	/*
@@ -312,10 +312,11 @@ int anon_vma_fork(struct vm_area_struct *vma, struct vm_area_struct *pvma)
 
 	return 0;
 
- out_error_free_anon_vma:
+out_error_free_anon_vma:
 	put_anon_vma(anon_vma);
- out_error:
-	unlink_anon_vmas(vma);
+out_error_free_avc:
+	anon_vma_chain_free(avc);
+out_error:
 	return -ENOMEM;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
