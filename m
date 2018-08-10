Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B33A16B0006
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 11:29:38 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q18-v6so7250820wrr.12
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 08:29:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16-v6sor292153wms.81.2018.08.10.08.29.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 08:29:37 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 3/3] mm/memory_hotplug: Cleanup unregister_mem_sect_under_nodes
Date: Fri, 10 Aug 2018 17:29:31 +0200
Message-Id: <20180810152931.23004-4-osalvador@techadventures.net>
In-Reply-To: <20180810152931.23004-1-osalvador@techadventures.net>
References: <20180810152931.23004-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

With the assumption that the relationship between
memory_block <-> node is 1:1, we can refactor this function a bit.

This assumption is being taken from register_mem_sect_under_node()
code.

register_mem_sect_under_node() takes the mem_blk's nid, and compares it
to the pfn's nid we are checking.
If they match, we go ahead and link both objects.
Once done, we just return.

So, the relationship between memory_block <-> node seems to stand.

Currently, unregister_mem_sect_under_nodes() defines a nodemask_t
which is being checked in the loop to see if we have already unliked certain node.
But since a memory_block can only belong to a node, we can drop the nodemask
and the check within the loop.

If we find a match between the mem_block->nid and the nid of the
pfn we are checking, we unlink the objects and return, as unlink the objects
once is enough.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/node.c | 30 +++++++++++-------------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index dd3bdab230b2..0657ed70bddd 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -448,35 +448,27 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 	return 0;
 }
 
-/* unregister memory section under all nodes that it spans */
+/* unregister memory section from the node it belongs to */
 int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 				    unsigned long phys_index)
 {
-	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
-
-	if (!unlinked_nodes)
-		return -ENOMEM;
-	nodes_clear(*unlinked_nodes);
+	int nid = mem_blk->nid;
 
 	sect_start_pfn = section_nr_to_pfn(phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
-		int nid;
+		int page_nid = get_nid_for_pfn(pfn);
 
-		nid = get_nid_for_pfn(pfn);
-		if (nid < 0)
-			continue;
-		if (!node_online(nid))
-			continue;
-		if (node_test_and_set(nid, *unlinked_nodes))
-			continue;
-		sysfs_remove_link(&node_devices[nid]->dev.kobj,
-			 kobject_name(&mem_blk->dev.kobj));
-		sysfs_remove_link(&mem_blk->dev.kobj,
-			 kobject_name(&node_devices[nid]->dev.kobj));
+		if (page_nid >= 0 && page_nid == nid) {
+			sysfs_remove_link(&node_devices[nid]->dev.kobj,
+				 kobject_name(&mem_blk->dev.kobj));
+			sysfs_remove_link(&mem_blk->dev.kobj,
+				 kobject_name(&node_devices[nid]->dev.kobj));
+			break;
+		}
 	}
-	NODEMASK_FREE(unlinked_nodes);
+
 	return 0;
 }
 
-- 
2.13.6
