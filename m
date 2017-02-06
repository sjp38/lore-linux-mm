Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAC36B0069
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 07:24:56 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so105301080pgf.3
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 04:24:56 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id j130si561405pfc.6.2017.02.06.04.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 04:24:55 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH 2/2 RESEND] mm: vmpressure: fix sending wrong events on underflow
Date: Mon,  6 Feb 2017 17:54:10 +0530
Message-Id: <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org>
In-Reply-To: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
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
 mm/vmpressure.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 149fdf6..3281b34 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -112,8 +112,10 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 						    unsigned long reclaimed)
 {
 	unsigned long scale = scanned + reclaimed;
-	unsigned long pressure;
+	unsigned long pressure = 0;
 
+	if (reclaimed >= scanned)
+		goto out;
 	/*
 	 * We calculate the ratio (in percents) of how many pages were
 	 * scanned vs. reclaimed in a given time frame (window). Note that
@@ -124,6 +126,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
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
