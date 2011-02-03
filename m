From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R3 1/7] mm: Add add_registered_memory() to memory hotplug API
Date: Thu, 3 Feb 2011 17:25:14 +0100
Message-ID: <20110203162514.GD1364__27501.4268620454$1296750434$gmane$org@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Pl21T-0006M7-Gf
	for glkm-linux-mm-2@m.gmane.org; Thu, 03 Feb 2011 17:27:07 +0100
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A28048D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 11:27:05 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1576021Ab1BCQZO (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 3 Feb 2011 17:25:14 +0100
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer

add_registered_memory() adds memory ealier registered
as memory resource. It is required by memory hotplug
for Xen guests, however it could be used also by other
modules.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/memory_hotplug.h |    1 +
 mm/memory_hotplug.c            |   50 ++++++++++++++++++++++++++++++---------
 2 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 8122018..fe63912 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -223,6 +223,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern int mem_online_node(int nid);
+extern int add_registered_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 321fc74..7947bdf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -532,20 +532,12 @@ out:
 }
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref add_memory(int nid, u64 start, u64 size)
+static int __ref __add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
 	int new_pgdat = 0;
-	struct resource *res;
 	int ret;
 
-	lock_memory_hotplug();
-
-	res = register_memory_resource(start, size);
-	ret = -EEXIST;
-	if (!res)
-		goto out;
-
 	if (!node_online(nid)) {
 		pgdat = hotadd_new_pgdat(nid, start);
 		ret = -ENOMEM;
@@ -579,14 +571,48 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	goto out;
 
 error:
-	/* rollback pgdat allocation and others */
+	/* rollback pgdat allocation */
 	if (new_pgdat)
 		rollback_node_hotadd(nid, pgdat);
-	if (res)
-		release_memory_resource(res);
+
+out:
+	return ret;
+}
+
+int add_registered_memory(int nid, u64 start, u64 size)
+{
+	int ret;
+
+	lock_memory_hotplug();
+	ret = __add_memory(nid, start, size);
+	unlock_memory_hotplug();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(add_registered_memory);
+
+int add_memory(int nid, u64 start, u64 size)
+{
+	int ret = -EEXIST;
+	struct resource *res;
+
+	lock_memory_hotplug();
+
+	res = register_memory_resource(start, size);
+
+	if (!res)
+		goto out;
+
+	ret = __add_memory(nid, start, size);
+
+	if (!ret)
+		goto out;
+
+	release_memory_resource(res);
 
 out:
 	unlock_memory_hotplug();
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
