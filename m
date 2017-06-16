Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 428DD83292
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 05:24:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d13so36978012pgf.12
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 02:24:06 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 102si1584372plf.599.2017.06.16.02.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 02:24:05 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id a70so5095927pge.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 02:24:05 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] mmzone: simplify zone_intersects()
Date: Fri, 16 Jun 2017 17:23:34 +0800
Message-Id: <20170616092335.5177-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Wei Yang <richard.weiyang@gmail.com>

To make sure a range intersects a zone, only two comparison is necessary.

This patch simplifies the function a little.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mmzone.h | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0176a2933c61..7e8f100cb56d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -541,15 +541,11 @@ static inline bool zone_intersects(struct zone *zone,
 {
 	if (zone_is_empty(zone))
 		return false;
-	if (start_pfn >= zone_end_pfn(zone))
+	if (start_pfn >= zone_end_pfn(zone) ||
+	    start_pfn + nr_pages <= zone->zone_start_pfn)
 		return false;
 
-	if (zone->zone_start_pfn <= start_pfn)
-		return true;
-	if (start_pfn + nr_pages > zone->zone_start_pfn)
-		return true;
-
-	return false;
+	return true;
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
