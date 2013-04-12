Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 0F80F6B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:42 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:42 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 078D53E40040
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:27 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1Ed9m161230
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:39 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1Edxe029933
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:39 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 19/25] dnuma: memlayout: add memory_add_physaddr_to_nid() for memory_hotplug
Date: Thu, 11 Apr 2013 18:13:51 -0700
Message-Id: <1365729237-29711-20-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memlayout.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memlayout.c b/mm/memlayout.c
index 45e7df6..4dc6706 100644
--- a/mm/memlayout.c
+++ b/mm/memlayout.c
@@ -247,3 +247,19 @@ void memlayout_global_init(void)
 
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
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
