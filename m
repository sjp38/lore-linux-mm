Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4A56B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 23:22:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t126so489905pgc.9
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 20:22:05 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id d28si448877plj.363.2017.06.06.20.22.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 20:22:04 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] Revert "mm: vmpressure: fix sending wrong events on underflow"
Date: Wed, 7 Jun 2017 11:08:37 +0800
Message-ID: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: minchan@kernel.org, vinayakm.list@gmail.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This reverts commit e1587a4945408faa58d0485002c110eb2454740c.

THP lru page is reclaimed , THP is split to normal page and loop again.
reclaimed pages should not be bigger than nr_scan.  because of each
loop will increase nr_scan counter.

Signed-off-by: zhongjiang <zhongjiang@huawei.com>
---
 mm/vmpressure.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 6063581..149fdf6 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -112,16 +112,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 						    unsigned long reclaimed)
 {
 	unsigned long scale = scanned + reclaimed;
-	unsigned long pressure = 0;
+	unsigned long pressure;
 
 	/*
-	 * reclaimed can be greater than scanned in cases
-	 * like THP, where the scanned is 1 and reclaimed
-	 * could be 512
-	 */
-	if (reclaimed >= scanned)
-		goto out;
-	/*
 	 * We calculate the ratio (in percents) of how many pages were
 	 * scanned vs. reclaimed in a given time frame (window). Note that
 	 * time is in VM reclaimer's "ticks", i.e. number of pages
@@ -131,7 +124,6 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 	pressure = scale - (reclaimed * scale / scanned);
 	pressure = pressure * 100 / scale;
 
-out:
 	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
 		 scanned, reclaimed);
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
