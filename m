Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0C36B0262
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:28:57 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y10so76544983qty.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 21:28:57 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id t46si26974214qtt.28.2016.09.20.21.28.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 21:28:57 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 3/5] mm/vmalloc.c: correct lazy_max_pages() return value
Message-ID: <57E20C49.8010304@zoho.com>
Date: Wed, 21 Sep 2016 12:27:53 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

From: zijun_hu <zijun_hu@htc.com>

correct lazy_max_pages() return value if the number of online
CPUs is power of 2

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/vmalloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a125ae8..2804224 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -594,7 +594,9 @@ static unsigned long lazy_max_pages(void)
 {
 	unsigned int log;
 
-	log = fls(num_online_cpus());
+	log = num_online_cpus();
+	if (log > 1)
+		log = (unsigned int)get_count_order(log);
 
 	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
