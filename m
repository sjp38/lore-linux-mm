Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD7416B0082
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 11:14:27 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id va2so2905293obc.37
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 08:14:27 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id zc3si20003194pbc.176.2014.06.06.08.14.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 06 Jun 2014 08:14:27 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N6R000VM6C0I310@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Jun 2014 16:14:24 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2] mm: rmap: fix use-after-free in __put_anon_vma
Date: Fri, 06 Jun 2014 19:09:30 +0400
Message-id: <1402067370-5773-1-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <20140606115620.GS3213@twins.programming.kicks-ass.net>
References: <20140606115620.GS3213@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, koct9i@gmail.com, Andrey Ryabinin <a.ryabinin@samsung.com>, stable@vger.kernel.org

While working address sanitizer for kernel I've discovered use-after-free
bug in __put_anon_vma.
For the last anon_vma, anon_vma->root freed before child anon_vma.
Later in anon_vma_free(anon_vma) we are referencing to already freed anon_vma->root
to check rwsem.
This patch puts freeing of child anon_vma before freeing of anon_vma->root.

Cc: <stable@vger.kernel.org> # v3.0+
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---

Changes since v1:
 - just made it more simple following Peter's suggestion

 mm/rmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..cb5f70a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1564,10 +1564,10 @@ void __put_anon_vma(struct anon_vma *anon_vma)
 {
 	struct anon_vma *root = anon_vma->root;
 
+	anon_vma_free(anon_vma);
+
 	if (root != anon_vma && atomic_dec_and_test(&root->refcount))
 		anon_vma_free(root);
-
-	anon_vma_free(anon_vma);
 }
 
 static struct anon_vma *rmap_walk_anon_lock(struct page *page,
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
