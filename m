Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 32C586B0071
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:57 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:25:56 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B546438C804D
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:38 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PcCD323986
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:38 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PaCh011025
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:37 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 02/17] mmzone: add various zone_*() helper functions.
Date: Tue, 15 Jan 2013 16:24:39 -0800
Message-Id: <1358295894-24167-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

Add zone_is_initialized(), zone_is_empty(), zone_spans_pfn(), and
zone_end_pfn().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..696cb7c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -543,6 +543,26 @@ static inline int zone_is_oom_locked(const struct zone *zone)
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
 }
 
+static inline unsigned zone_end_pfn(const struct zone *zone)
+{
+	return zone->zone_start_pfn + zone->spanned_pages;
+}
+
+static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
+{
+	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
+}
+
+static inline bool zone_is_initialized(struct zone *zone)
+{
+	return !!zone->wait_table;
+}
+
+static inline bool zone_is_empty(struct zone *zone)
+{
+	return zone->spanned_pages == 0;
+}
+
 /*
  * The "priority" of VM scanning is how much of the queues we will scan in one
  * go. A value of 12 for DEF_PRIORITY implies that we will scan 1/4096th of the
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
