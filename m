Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 359BE6B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 04:46:13 -0400 (EDT)
Received: by yxe10 with SMTP id 10so5941913yxe.12
        for <linux-mm@kvack.org>; Tue, 29 Sep 2009 02:06:33 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] filemap : fix the wrong offset
Date: Tue, 29 Sep 2009 17:06:25 +0800
Message-Id: <1254215185-29841-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

The offset should be in PAGE_CACHE_SHIFT unit, not in PAGE_SHIFT unit.

Though we do not fully implement the page cache in larger chunks,
but in the vma_address(), all the pages do the (PAGE_CACHE_SHIFT - PAGE_SHIFT) shift,
so do a reverse operation in filemap_fault() is needed.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/filemap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ef169f3..2d8385e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1502,7 +1502,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
-	pgoff_t offset = vmf->pgoff;
+	pgoff_t offset = vmf->pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
