Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id l16L6nFF008188
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 21:06:49 GMT
Received: from ug-out-1314.google.com (ugc30.prod.google.com [10.66.3.30])
	by spaceape13.eur.corp.google.com with ESMTP id l16L6drB009003
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 21:06:40 GMT
Received: by ug-out-1314.google.com with SMTP id 30so679ugc
        for <linux-mm@kvack.org>; Tue, 06 Feb 2007 13:06:39 -0800 (PST)
Message-ID: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
Date: Tue, 6 Feb 2007 13:06:39 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: hugetlb: preserve hugetlb pte dirty state
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__unmap_hugepage_range() is buggy that it does not preserve dirty
state of huge_pte when unmapping hugepage range.  It causes data
corruption in the event of dop_caches being used by sys admin.
For example, an application creates a hugetlb file, modify pages,
then unmap it.  While leaving the hugetlb file alive, comes along
sys admin doing a "echo 3 > /proc/sys/vm/drop_caches".
drop_pagecache_sb() will happily frees all pages that isn't marked
dirty if there are no active mapping. Later when application remaps
the hugetlb file back and all data are gone, triggering catastrophic
flip over on application.

Not only that, the internal resv_huge_pages count will also get all
messed up.  Fix it up by marking page dirty appropriately.

Signed-off-by: Ken Chen <kenchen@google.com>

--- ./mm/hugetlb.c.orig	2007-02-06 08:28:33.000000000 -0800
+++ ./mm/hugetlb.c	2007-02-06 08:29:47.000000000 -0800
@@ -389,6 +389,8 @@
 			continue;

 		page = pte_page(pte);
+		if (pte_dirty(pte))
+			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
 	}
 	spin_unlock(&mm->page_table_lock);
--- ./fs/hugetlbfs/inode.c.orig	2007-02-06 08:29:56.000000000 -0800
+++ ./fs/hugetlbfs/inode.c	2007-02-06 08:40:44.000000000 -0800
@@ -449,10 +449,13 @@
 }

 /*
- * For direct-IO reads into hugetlb pages
+ * mark the head page dirty
  */
 static int hugetlbfs_set_page_dirty(struct page *page)
 {
+	struct page *head = (struct page *) page_private(page);
+
+	SetPageDirty(head);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
