Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8F3A6B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 22:38:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t189so1277393wmt.9
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 19:38:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t66si6044424wmg.38.2017.04.08.19.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 19:38:45 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v392cg1h021018
	for <linux-mm@kvack.org>; Sat, 8 Apr 2017 22:38:44 -0400
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29qa363b1w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 08 Apr 2017 22:38:43 -0400
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 9 Apr 2017 08:08:37 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v392bFXM17825898
	for <linux-mm@kvack.org>; Sun, 9 Apr 2017 08:07:15 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v392cZtK003546
	for <linux-mm@kvack.org>; Sun, 9 Apr 2017 08:08:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/softoffline: Add page flag description in error paths
Date: Sun,  9 Apr 2017 08:08:29 +0530
Message-Id: <20170409023829.10788-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

It helps to provide page flag description along with the raw value in
error paths during soft offline process. From sample experiments

Before the patch:

[  132.317977] soft offline: 0x6100: migration failed 1, type 3ffff800008018
[  132.359057] soft offline: 0x7400: migration failed 1, type 3ffff800008018

After the patch:

[   87.694325] soft offline: 0x5900: migration failed 1, type 3ffff800008018 (uptodate|dirty|head)
[   87.736273] soft offline: 0x6c00: migration failed 1, type 3ffff800008018 (uptodate|dirty|head)

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 27f7210..fe64d77 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1543,8 +1543,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		if (ret == 1 && !PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
 			put_hwpoison_page(page);
-			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
-				pfn, page->flags);
+			pr_info("soft_offline: %#lx: unknown non LRU page type %lx (%pGp)\n",
+				pfn, page->flags, &page->flags);
 			return -EIO;
 		}
 	}
@@ -1585,8 +1585,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 				MIGRATE_SYNC, MR_MEMORY_FAILURE);
 	if (ret) {
-		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
-			pfn, ret, page->flags);
+		pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
+			pfn, ret, page->flags, &page->flags);
 		/*
 		 * We know that soft_offline_huge_page() tries to migrate
 		 * only one hugepage pointed to by hpage, so we need not
@@ -1677,14 +1677,14 @@ static int __soft_offline_page(struct page *page, int flags)
 			if (!list_empty(&pagelist))
 				putback_movable_pages(&pagelist);
 
-			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
-				pfn, ret, page->flags);
+			pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
+				pfn, ret, page->flags, &page->flags);
 			if (ret > 0)
 				ret = -EIO;
 		}
 	} else {
-		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
-			pfn, ret, page_count(page), page->flags);
+		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx (%pGp)\n",
+			pfn, ret, page_count(page), page->flags, &page->flags);
 	}
 	return ret;
 }
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
