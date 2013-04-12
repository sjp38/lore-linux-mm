Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 1500D6B0062
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:33 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:32 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A8B271FF003C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:09:28 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1ESeN123370
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:28 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1ESUJ007360
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:28 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 11/25] memory_hotplug: factor out locks in mem_online_cpu()
Date: Thu, 11 Apr 2013 18:13:43 -0700
Message-Id: <1365729237-29711-12-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

In dynamic numa, when onlining nodes, lock_memory_hotplug() is already
held when mem_online_node()'s functionality is needed.

Factor out the locking and create a new function __mem_online_node() to
allow reuse.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/memory_hotplug.h |  1 +
 mm/memory_hotplug.c            | 29 ++++++++++++++++-------------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index cd393014..391824d 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -248,6 +248,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
 static inline void try_offline_node(int nid) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+extern int __mem_online_node(int nid);
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index deea8c2..f5ea9b7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1058,26 +1058,29 @@ static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
 	return;
 }
 
-
-/*
- * called by cpu_up() to online a node without onlined memory.
- */
-int mem_online_node(int nid)
+int __mem_online_node(int nid)
 {
-	pg_data_t	*pgdat;
-	int	ret;
+	pg_data_t *pgdat;
+	int ret;
 
-	lock_memory_hotplug();
 	pgdat = hotadd_new_pgdat(nid, 0);
-	if (!pgdat) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!pgdat)
+		return -ENOMEM;
+
 	node_set_online(nid);
 	ret = register_one_node(nid);
 	BUG_ON(ret);
+	return ret;
+}
 
-out:
+/*
+ * called by cpu_up() to online a node without onlined memory.
+ */
+int mem_online_node(int nid)
+{
+	int ret;
+	lock_memory_hotplug();
+	ret = __mem_online_node(nid);
 	unlock_memory_hotplug();
 	return ret;
 }
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
