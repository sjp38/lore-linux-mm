Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6199F6B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 03:33:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so15433010wme.4
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 00:33:21 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q31si6846408lfi.259.2016.12.05.00.33.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 00:33:20 -0800 (PST)
Message-ID: <584523E4.9030600@huawei.com>
Date: Mon, 5 Dec 2016 16:23:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH] mm: use ACCESS_ONCE in page_cpupid_xchg_last()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

By reading the code, I find the following code maybe optimized by
compiler, maybe page->flags and old_flags use the same register,
so use ACCESS_ONCE in page_cpupid_xchg_last() to fix the problem.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/mmzone.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmzone.c b/mm/mmzone.c
index 5652be8..e0b698e 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
 	int last_cpupid;
 
 	do {
-		old_flags = flags = page->flags;
+		old_flags = flags = ACCESS_ONCE(page->flags);
 		last_cpupid = page_cpupid_last(page);
 
 		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
