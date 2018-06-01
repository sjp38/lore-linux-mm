Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 756136B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 08:54:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e26-v6so766958wmh.7
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 05:54:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i15-v6sor433520wmg.49.2018.06.01.05.54.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 05:54:10 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 1/4] mm/memory_hotplug: Make add_memory_resource use __try_online_node
Date: Fri,  1 Jun 2018 14:53:18 +0200
Message-Id: <20180601125321.30652-2-osalvador@techadventures.net>
In-Reply-To: <20180601125321.30652-1-osalvador@techadventures.net>
References: <20180601125321.30652-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

add_memory_resource() contains code to allocate a new node in case
it is necessary.
Since try_online_node() also hast some code for this purpose,
let us make use of that and remove duplicate code.

This introduces __try_online_node(), which is called by add_memory_resource()
and try_online_node().
__try_online_node() has two new parameters, start_addr of the node,
and if the node should be onlined and registered right away.
This is always wanted if we are calling from do_cpu_up(), but not
when we are calling from memhotplug code.
Nothing changes from the point of view of the users of try_online_node(),
since try_online_node passes start_addr=0 and online_node=true to
__try_online_node().

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 61 +++++++++++++++++++++++++++++------------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7deb49f69e27..29a5fc89bdb1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1034,8 +1034,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	return pgdat;
 }
 
-static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
+static void rollback_node_hotadd(int nid)
 {
+	pg_data_t *pgdat = NODE_DATA(nid);
+
 	arch_refresh_nodedata(nid, NULL);
 	free_percpu(pgdat->per_cpu_nodestats);
 	arch_free_nodedata(pgdat);
@@ -1046,28 +1048,43 @@ static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
 /**
  * try_online_node - online a node if offlined
  * @nid: the node ID
- *
+ * @start: start addr of the node
+ * @set_node_online: Whether we want to online the node
  * called by cpu_up() to online a node without onlined memory.
  */
-int try_online_node(int nid)
+static int __try_online_node(int nid, u64 start, bool set_node_online)
 {
-	pg_data_t	*pgdat;
-	int	ret;
+	pg_data_t *pgdat;
+	int ret = 1;
 
 	if (node_online(nid))
 		return 0;
 
-	mem_hotplug_begin();
-	pgdat = hotadd_new_pgdat(nid, 0);
+	pgdat = hotadd_new_pgdat(nid, start);
 	if (!pgdat) {
 		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
 		ret = -ENOMEM;
 		goto out;
 	}
-	node_set_online(nid);
-	ret = register_one_node(nid);
-	BUG_ON(ret);
+
+	if (set_node_online) {
+		node_set_online(nid);
+		ret = register_one_node(nid);
+		BUG_ON(ret);
+	}
 out:
+	return ret;
+}
+
+/*
+ * Users of this function always want to online/register the node
+ */
+int try_online_node(int nid)
+{
+	int ret;
+
+	mem_hotplug_begin();
+	ret =  __try_online_node (nid, 0, true);
 	mem_hotplug_done();
 	return ret;
 }
@@ -1099,8 +1116,6 @@ static int online_memory_block(struct memory_block *mem, void *arg)
 int __ref add_memory_resource(int nid, struct resource *res, bool online)
 {
 	u64 start, size;
-	pg_data_t *pgdat = NULL;
-	bool new_pgdat;
 	bool new_node;
 	int ret;
 
@@ -1111,11 +1126,6 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	if (ret)
 		return ret;
 
-	{	/* Stupid hack to suppress address-never-null warning */
-		void *p = NODE_DATA(nid);
-		new_pgdat = !p;
-	}
-
 	mem_hotplug_begin();
 
 	/*
@@ -1126,17 +1136,14 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	 */
 	memblock_add_node(start, size, nid);
 
-	new_node = !node_online(nid);
-	if (new_node) {
-		pgdat = hotadd_new_pgdat(nid, start);
-		ret = -ENOMEM;
-		if (!pgdat)
-			goto error;
-	}
+	ret = __try_online_node (nid, start, false);
+	new_node = !!(ret > 0);
+	if (ret < 0)
+		goto error;
+
 
 	/* call arch's memory hotadd */
 	ret = arch_add_memory(nid, start, size, NULL, true);
-
 	if (ret < 0)
 		goto error;
 
@@ -1180,8 +1187,8 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 
 error:
 	/* rollback pgdat allocation and others */
-	if (new_pgdat && pgdat)
-		rollback_node_hotadd(nid, pgdat);
+	if (new_node)
+		rollback_node_hotadd(nid);
 	memblock_remove(start, size);
 
 out:
-- 
2.13.6
