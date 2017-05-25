Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3AF6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 04:06:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o65so236164880oif.15
        for <linux-mm@kvack.org>; Thu, 25 May 2017 01:06:01 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id n6si3650090otn.130.2017.05.25.01.05.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 01:06:00 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [RFC PATCH] mm: fix mlock incorrent event account
Date: Thu, 25 May 2017 15:59:39 +0800
Message-ID: <1495699179-7566-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, mhocko@suse.cz, qiuxishi@huawei.com, linux-mm@kvack.org, zhongjiang@huawei.com

From: zhong jiang <zhongjiang@huawei.com>

when clear_page_mlock call, we had finish the page isolate successfully,
but it fails to increase the UNEVICTABLE_PGMUNLOCKED account.

The patch add the event account when successful page isolation.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/mlock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index c483c5c..941930b 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -64,6 +64,7 @@ void clear_page_mlock(struct page *page)
 			    -hpage_nr_pages(page));
 	count_vm_event(UNEVICTABLE_PGCLEARED);
 	if (!isolate_lru_page(page)) {
+		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 		putback_lru_page(page);
 	} else {
 		/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
