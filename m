Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFC936B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:38:41 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id di3so197365374pab.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:38:41 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id k9si42776430pfa.57.2016.05.31.02.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 May 2016 02:38:40 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH][RFC] mm: memcontrol: fix a unbalance uncharged count
Date: Tue, 31 May 2016 17:38:32 +0800
Message-Id: <1464687512-10695-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

I see the number of page of hpage_nr_pages(page) is charged if page is
transparent huge or hugetlbfs pages; but when uncharge a huge page,
(1<<compound_order) page is uncharged, and maybe hpage_nr_pages(page) is
not same as 1<<compound_order.

And remove VM_BUG_ON_PAGE(!PageTransHuge(page), page); since
PageTransHuge(page) always is true, when this VM_BUG_ON_PAGE is called.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 12aaadd..28c0137 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5453,8 +5453,7 @@ static void uncharge_list(struct list_head *page_list)
 		}
 
 		if (PageTransHuge(page)) {
-			nr_pages <<= compound_order(page);
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			nr_pages = hpage_nr_pages(page);
 			nr_huge += nr_pages;
 		}
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
