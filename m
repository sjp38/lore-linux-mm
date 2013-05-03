Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4A1FC6B02A1
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:02:09 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:02:08 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 97FA33E4003F
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:01:25 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301e7X385278
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301dpi009126
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:39 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 25/31] dnuma: memlayout: add memory_add_physaddr_to_nid() for memory_hotplug
Date: Thu,  2 May 2013 17:00:57 -0700
Message-Id: <1367539263-19999-26-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memlayout.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memlayout.c b/mm/memlayout.c
index 8b9ba9a..3e89482 100644
--- a/mm/memlayout.c
+++ b/mm/memlayout.c
@@ -336,3 +336,19 @@ void memlayout_global_init(void)
 
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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
