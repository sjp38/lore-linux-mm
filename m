Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 445BC6B0010
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:34 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 17:54:33 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 53CD4C90026
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:30 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0HMsTQV360584
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:54:30 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0HMsQmc022014
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 15:54:29 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 5/9] mmzone: add pgdat_{end_pfn,is_empty}() helpers & consolidate.
Date: Thu, 17 Jan 2013 14:52:57 -0800
Message-Id: <1358463181-17956-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358463181-17956-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

Add pgdat_end_pfn() and pgdat_is_empty() helpers which match the similar
zone_*() functions.

Change node_end_pfn() to be a wrapper of pgdat_end_pfn().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 696cb7c..d7abff0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -772,11 +772,17 @@ typedef struct pglist_data {
 #define nid_page_nr(nid, pagenr) 	pgdat_page_nr(NODE_DATA(nid),(pagenr))
 
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
+#define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
 
-#define node_end_pfn(nid) ({\
-	pg_data_t *__pgdat = NODE_DATA(nid);\
-	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;\
-})
+static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
+{
+	return pgdat->node_start_pfn + pgdat->node_spanned_pages;
+}
+
+static inline bool pgdat_is_empty(pg_data_t *pgdat)
+{
+	return !pgdat->node_start_pfn && !pgdat->node_spanned_pages;
+}
 
 #include <linux/memory_hotplug.h>
 
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
