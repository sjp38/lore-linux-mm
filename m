Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB4C6B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 04:52:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c6so2525256pfj.5
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 01:52:07 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id e67si1202015pfg.409.2017.06.07.01.52.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 01:52:06 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: correct the comment when reclaimed pages exceed the scanned pages
Date: Wed, 7 Jun 2017 16:31:06 +0800
Message-ID: <1496824266-25235-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: minchan@kernel.org, vinayakm.list@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The commit e1587a494540 ("mm: vmpressure: fix sending wrong events on
underflow") declare that reclaimed pages exceed the scanned pages due
to the thp reclaim. it is incorrect because THP will be spilt to normal
page and loop again. which will result in the scanned pages increment.

Signed-off-by: zhongjiang <zhongjiang@huawei.com>
---
 mm/vmpressure.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 6063581..0e91ba3 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -116,8 +116,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 
 	/*
 	 * reclaimed can be greater than scanned in cases
-	 * like THP, where the scanned is 1 and reclaimed
-	 * could be 512
+	 * like reclaimed slab pages, shrink_node just add
+	 * reclaimed page without a related increment to
+	 * scanned pages.
 	 */
 	if (reclaimed >= scanned)
 		goto out;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
