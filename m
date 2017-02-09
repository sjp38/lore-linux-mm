Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 047486B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 07:00:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so1493613pfw.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 04:00:05 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 13si9883630pfl.237.2017.02.09.04.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 04:00:05 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH 1/2 v2] mm: vmpressure: fix sending wrong events on underflow
Date: Thu,  9 Feb 2017 17:29:36 +0530
Message-Id: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

At the end of a window period, if the reclaimed pages
is greater than scanned, an unsigned underflow can
result in a huge pressure value and thus a critical event.
Reclaimed pages is found to go higher than scanned because
of the addition of reclaimed slab pages to reclaimed in
shrink_node without a corresponding increment to scanned
pages. Minchan Kim mentioned that this can also happen in
the case of a THP page where the scanned is 1 and reclaimed
could be 512.

Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
v2: Adding a comment and reordering the patches
    as per Michal's suggestion

 mm/vmpressure.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 149fdf6..6063581 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -112,9 +112,16 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 						    unsigned long reclaimed)
 {
 	unsigned long scale = scanned + reclaimed;
-	unsigned long pressure;
+	unsigned long pressure = 0;
 
 	/*
+	 * reclaimed can be greater than scanned in cases
+	 * like THP, where the scanned is 1 and reclaimed
+	 * could be 512
+	 */
+	if (reclaimed >= scanned)
+		goto out;
+	/*
 	 * We calculate the ratio (in percents) of how many pages were
 	 * scanned vs. reclaimed in a given time frame (window). Note that
 	 * time is in VM reclaimer's "ticks", i.e. number of pages
@@ -124,6 +131,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 	pressure = scale - (reclaimed * scale / scanned);
 	pressure = pressure * 100 / scale;
 
+out:
 	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
 		 scanned, reclaimed);
 
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
