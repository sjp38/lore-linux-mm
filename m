Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06C386B5264
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 06:44:22 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so1019144pgd.0
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 03:44:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor1807275pgv.27.2018.11.29.03.44.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 03:44:20 -0800 (PST)
From: Yongkai Wu <nic.wuyk@gmail.com>
Subject: [PATCH] hugetlbfs: Call VM_BUG_ON_PAGE earlier in free_huge_page
Date: Thu, 29 Nov 2018 19:44:03 +0800
Message-Id: <1543491843-23438-1-git-send-email-nic_w@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nic_w@163.com

A stack trace was triggered by VM_BUG_ON_PAGE(page_mapcount(page),
page) in free_huge_page().  Unfortunately, the page->mapping field
was set to NULL before this test.  This made it more difficult to
determine the root cause of the problem.

Move the VM_BUG_ON_PAGE tests earlier in the function so that if
they do trigger more information is present in the page struct.

Signed-off-by: Yongkai Wu <nic_w@163.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7f2a28a..14ef274 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)
 		(struct hugepage_subpool *)page_private(page);
 	bool restore_reserve;
 
-	set_page_private(page, 0);
-	page->mapping = NULL;
 	VM_BUG_ON_PAGE(page_count(page), page);
 	VM_BUG_ON_PAGE(page_mapcount(page), page);
+
+	set_page_private(page, 0);
+	page->mapping = NULL;
 	restore_reserve = PagePrivate(page);
 	ClearPagePrivate(page);
 
-- 
1.8.3.1
