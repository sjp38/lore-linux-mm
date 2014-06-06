Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id F34246B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 07:36:20 -0400 (EDT)
Received: by mail-vc0-f177.google.com with SMTP id hy4so2752215vcb.8
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 04:36:20 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id qs6si19043101pbc.21.2014.06.06.04.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 06 Jun 2014 04:36:20 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N6Q00CD4W846R90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Jun 2014 12:36:04 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] mm: rmap: fix use-after-free in __put_anon_vma
Date: Fri, 06 Jun 2014 15:30:55 +0400
Message-id: <1402054255-4930-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dvyukov@google.com, koct9i@gmail.com, Andrey Ryabinin <a.ryabinin@samsung.com>, v3.0+@samsung.com

While working address sanitizer for kernel I've discovered use-after-free
bug in __put_anon_vma.
For the last anon_vma, anon_vma->root freed before child anon_vma.
Later in anon_vma_free(anon_vma) we are referencing to already freed anon_vma->root
to check rwsem.
This patch puts freeing of child anon_vma before freeing of anon_vma->root.

Cc: stable@vger.kernel.org # v3.0+
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/rmap.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..161bffc7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1564,10 +1564,11 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 {
 	struct anon_vma *root = anon_vma->root;
 
-	if (root != anon_vma && atomic_dec_and_test(&root->refcount))
+	if (root != anon_vma && atomic_dec_and_test(&root->refcount)) {
+		anon_vma_free(anon_vma);
 		anon_vma_free(root);
-
-	anon_vma_free(anon_vma);
+	} else
+		anon_vma_free(anon_vma);
 }
 
 static struct anon_vma *rmap_walk_anon_lock(struct page *page,
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
