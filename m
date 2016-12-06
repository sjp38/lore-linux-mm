Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBDA6B0069
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 20:58:04 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id l192so585970292oih.2
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 17:58:04 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id w21si8048277oia.24.2016.12.05.17.58.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 17:58:03 -0800 (PST)
Message-ID: <58461A0A.3070504@huawei.com>
Date: Tue, 6 Dec 2016 09:53:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com>
In-Reply-To: <584523E4.9030600@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

A compiler could re-read "old_flags" from the memory location after reading
and calculation "flags" and passes a newer value into the cmpxchg making 
the comparison succeed while it should actually fail.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>
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
+		old_flags = flags = READ_ONCE(page->flags);
 		last_cpupid = page_cpupid_last(page);
 
 		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
