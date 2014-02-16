Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8C68F6B004D
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 22:31:44 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so13567137pde.28
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 19:31:44 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id eb3si10533639pbc.326.2014.02.15.19.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sat, 15 Feb 2014 19:31:43 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N1200M5HKGSJY10@mailout1.samsung.com> for
 linux-mm@kvack.org; Sun, 16 Feb 2014 12:31:40 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [RFC PATCH] mm/vmscan: remove two un-needed mem_cgroup_page_lruvec()
 call
Date: Sun, 16 Feb 2014 11:30:54 +0800
Message-id: <000001cf2ac7$9abf23b0$d03d6b10$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: 'Mel Gorman' <mgorman@suse.de>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

In putback_inactive_pages() and move_active_pages_to_lru(),
lruvec is already an input parameter and pages are all from this lruvec,
therefore there is no need to call mem_cgroup_page_lruvec() in loop.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/vmscan.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b4..4804fdb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1393,8 +1393,6 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			continue;
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
-
 		SetPageLRU(page);
 		lru = page_lru(page);
 		add_page_to_lru_list(page, lruvec, lru);
@@ -1602,7 +1600,6 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
-		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
