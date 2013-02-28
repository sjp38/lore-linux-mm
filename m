Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 687DA6B0023
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:57:56 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:57:55 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2180D38C801C
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:57:46 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLvj3X224522
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:57:45 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLvYhG013352
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:35 -0700
Received: from kernel.stglabs.ibm.com (kernel.stglabs.ibm.com [9.114.214.19])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r1SLvWLZ013258
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:33 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 22/24] dnuma: memlayout: add memory_add_physaddr_to_nid() for memory_hotplug
Date: Thu, 28 Feb 2013 13:57:25 -0800
Message-Id: <1362088647-19726-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memlayout.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memlayout.c b/mm/memlayout.c
index 5fef032..b432b3a 100644
--- a/mm/memlayout.c
+++ b/mm/memlayout.c
@@ -249,3 +249,19 @@ void memlayout_global_init(void)
 
 	memlayout_commit(ml);
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+/*
+ * Provides a default memory_add_physaddr_to_nid() for memory hotplug, unless
+ * overridden by the arch.
+ */
+__weak
+int memory_add_physaddr_to_nid(u64 start)
+{
+	int nid = memlayout_pfn_to_nid(PFN_DOWN(start));
+	if (nid == NUMA_NO_NODE)
+		return 0;
+	return nid;
+}
+EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
+#endif
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
