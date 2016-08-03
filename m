Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D28106B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 13:58:25 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so118788702lfw.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 10:58:25 -0700 (PDT)
Received: from baptiste.telenet-ops.be (baptiste.telenet-ops.be. [2a02:1800:120:4::f00:13])
        by mx.google.com with ESMTPS id yb9si9200704wjb.180.2016.08.03.10.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 10:58:24 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] shmem: Fix link error if huge pages support is disabled
Date: Wed,  3 Aug 2016 19:58:19 +0200
Message-Id: <1470247099-14217-1-git-send-email-geert@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

If CONFIG_TRANSPARENT_HUGE_PAGECACHE=n, HPAGE_PMD_NR evaluates to
BUILD_BUG_ON(), and may cause (e.g. with gcc 4.12):

    mm/built-in.o: In function `shmem_alloc_hugepage':
    shmem.c:(.text+0x17570): undefined reference to `__compiletime_assert_1365'

To fix this, move the assignment to hindex after the check for huge
pages support.

Fixes: 800d8c63b2e989c2 ("shmem: add huge pages support")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 mm/shmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 2ac19a61d5655b82..7f7748a0f9e1f738 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1362,13 +1362,14 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 	struct vm_area_struct pvma;
 	struct inode *inode = &info->vfs_inode;
 	struct address_space *mapping = inode->i_mapping;
-	pgoff_t idx, hindex = round_down(index, HPAGE_PMD_NR);
+	pgoff_t idx, hindex;
 	void __rcu **results;
 	struct page *page;
 
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 		return NULL;
 
+	hindex = round_down(index, HPAGE_PMD_NR);
 	rcu_read_lock();
 	if (radix_tree_gang_lookup_slot(&mapping->page_tree, &results, &idx,
 				hindex, 1) && idx < hindex + HPAGE_PMD_NR) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
