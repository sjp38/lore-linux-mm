Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4E86C6B0279
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:26 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:25 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A7C2C6E804B
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:20 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301N8966388198
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301M0n011871
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:23 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 12/31] memory_hotplug: factor out locks in mem_online_cpu()
Date: Thu,  2 May 2013 17:00:44 -0700
Message-Id: <1367539263-19999-13-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

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
index 501e9f0..1ad85c6 100644
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
index a65235f..8e6658d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1066,26 +1066,29 @@ static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
