Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 600DB6B0008
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:03 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:27:01 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A4AA038C801F
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:26:58 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLQwm8284356
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:26:58 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLQvBS019556
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:26:57 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 14/24] memory_hotplug: factor out locks in mem_online_cpu()
Date: Thu, 28 Feb 2013 13:26:11 -0800
Message-Id: <1362086781-16725-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

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
index eae4a2a..7b0ab4f 100644
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
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
