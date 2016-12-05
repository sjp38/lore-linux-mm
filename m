Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3480B6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:39:23 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so61202896wjb.7
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:39:23 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id xu5si14201109wjb.254.2016.12.05.01.39.20
        for <linux-mm@kvack.org>;
        Mon, 05 Dec 2016 01:39:22 -0800 (PST)
Message-ID: <584532DF.7080805@huawei.com>
Date: Mon, 5 Dec 2016 17:26:55 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH v2] mm: use ACCESS_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com> <26c66f28-d836-4d6e-fb40-3e2189a540ed@de.ibm.com> <0cc3c2bb-e292-2d7b-8d44-16c8e6c19899@de.ibm.com>
In-Reply-To: <0cc3c2bb-e292-2d7b-8d44-16c8e6c19899@de.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>
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
