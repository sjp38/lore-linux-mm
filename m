Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2761F6B00E9
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 04:51:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so12604070pab.40
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 01:51:48 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id gj10si22213986pbc.248.2014.11.12.01.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 12 Nov 2014 01:51:47 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEX004WG7E8NED0@mailout3.samsung.com> for
 linux-mm@kvack.org; Wed, 12 Nov 2014 18:51:45 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [RFC PATCH] mm: mincore: use PAGE_SIZE instead of PAGE_CACHE_SIZE
Date: Wed, 12 Nov 2014 17:50:37 +0800
Message-id: <000001cffe5e$44893f60$cd9bbe20$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

This is a RFC patch, because current PAGE_SIZE is equal to PAGE_CACHE_SIZE,
there isn't any difference and issue when running.

However, the current code mixes these two aligned_size inconsistently, and if
they are not equal in future mincore_unmapped_range() would check more file
pages than wanted.

According to man-page, mincore uses PAGE_SIZE as its size unit, so this patch
uses PAGE_SIZE instead of PAGE_CACHE_SIZE.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/mincore.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 725c809..8c19bce 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -102,11 +102,18 @@ static void mincore_unmapped_range(struct vm_area_struct *vma,
 	int i;
 
 	if (vma->vm_file) {
-		pgoff_t pgoff;
+		pgoff_t pgoff, pgoff_end;
+		int j, count;
+		unsigned char res;
 
+		count = 1 << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 		pgoff = linear_page_index(vma, addr);
-		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+		pgoff_end = linear_page_index(vma, end);
+		for (i = 0; pgoff < pgoff_end; pgoff++) {
+			res = mincore_page(vma->vm_file->f_mapping, pgoff);
+			for (j = 0; j < count; j++)
+				vec[i++] = res;
+		}
 	} else {
 		for (i = 0; i < nr; i++)
 			vec[i] = 0;
@@ -258,7 +265,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
  * return values:
  *  zero    - success
  *  -EFAULT - vec points to an illegal address
- *  -EINVAL - addr is not a multiple of PAGE_CACHE_SIZE
+ *  -EINVAL - addr is not a multiple of PAGE_SIZE
  *  -ENOMEM - Addresses in the range [addr, addr + len] are
  *		invalid for the address space of this process, or
  *		specify one or more pages which are not currently
@@ -273,14 +280,14 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned char *tmp;
 
 	/* Check the start address: needs to be page-aligned.. */
- 	if (start & ~PAGE_CACHE_MASK)
+	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
 	/* ..and we need to be passed a valid user-space range */
 	if (!access_ok(VERIFY_READ, (void __user *) start, len))
 		return -ENOMEM;
 
-	/* This also avoids any overflows on PAGE_CACHE_ALIGN */
+	/* This also avoids any overflows on PAGE_ALIGN */
 	pages = len >> PAGE_SHIFT;
 	pages += (len & ~PAGE_MASK) != 0;
 
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
