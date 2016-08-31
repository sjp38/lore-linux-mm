Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 210B86B0038
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:26:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so81533751pfx.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 20:26:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g192si48336880pfb.119.2016.08.30.20.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 20:26:02 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7V3MjYf110349
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:26:01 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 255365gd7n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:26:01 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 13:25:57 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D144F2CE8046
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:55 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7V3Ptd07012712
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:55 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7V3PtOU004371
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:55 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: Move definition of 'zone_names' array into mmzone.h
Date: Wed, 31 Aug 2016 08:55:49 +0530
Message-Id: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

zone_names[] is used to identify any zone given it's index which
can be used in many other places. So moving the definition into
include/linux/mmzone.h for broader access.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 17 +++++++++++++++++
 mm/page_alloc.c        | 17 -----------------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78..01ca3f4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -341,6 +341,23 @@ enum zone_type {
 
 };
 
+static char * const zone_names[__MAX_NR_ZONES] = {
+#ifdef CONFIG_ZONE_DMA
+	 "DMA",
+#endif
+#ifdef CONFIG_ZONE_DMA32
+	 "DMA32",
+#endif
+	 "Normal",
+#ifdef CONFIG_HIGHMEM
+	 "HighMem",
+#endif
+	 "Movable",
+#ifdef CONFIG_ZONE_DEVICE
+	 "Device",
+#endif
+};
+
 #ifndef __GENERATING_BOUNDS_H
 
 struct zone {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fbe73a..8e2261c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -207,23 +207,6 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
 
 EXPORT_SYMBOL(totalram_pages);
 
-static char * const zone_names[MAX_NR_ZONES] = {
-#ifdef CONFIG_ZONE_DMA
-	 "DMA",
-#endif
-#ifdef CONFIG_ZONE_DMA32
-	 "DMA32",
-#endif
-	 "Normal",
-#ifdef CONFIG_HIGHMEM
-	 "HighMem",
-#endif
-	 "Movable",
-#ifdef CONFIG_ZONE_DEVICE
-	 "Device",
-#endif
-};
-
 char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Movable",
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
