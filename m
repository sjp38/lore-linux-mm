Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFB8B6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:00:58 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d4so2034118iod.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:00:58 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id 192si39649623pfw.92.2016.06.08.00.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 00:00:57 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH] mm: memcontrol: remove BUG_ON in uncharge_list
Date: Wed,  8 Jun 2016 15:00:48 +0800
Message-Id: <1465369248-13865-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

when call uncharge_list, if a page is transparent huge, and not need to
BUG_ON about non-transparent huge, since nobody should be be seeing the
page at this stage and this page cannot be raced with a THP split up

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 mm/memcontrol.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d9a215..d7a56f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5457,7 +5457,6 @@ static void uncharge_list(struct list_head *page_list)
 
 		if (PageTransHuge(page)) {
 			nr_pages <<= compound_order(page);
-			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 			nr_huge += nr_pages;
 		}
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
