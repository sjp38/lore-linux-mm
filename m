Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7586B0292
	for <linux-mm@kvack.org>; Sun, 25 Jun 2017 23:58:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p14so105749150pgc.9
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 20:58:28 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 82si503553pfn.127.2017.06.25.20.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 20:58:27 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id u36so985742pgn.3
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 20:58:27 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/memory_hotplug: just build zonelist for new added node
Date: Mon, 26 Jun 2017 11:58:22 +0800
Message-Id: <20170626035822.50155-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

In commit (9adb62a5df9c0fbef7) "mm/hotplug: correctly setup fallback
zonelists when creating new pgdat" tries to build the correct zonelist for
a new added node, while it is not necessary to rebuild it for already exist
nodes.

In build_zonelists(), it will iterate on nodes with memory. For a new added
node, it will have memory until node_states_set_node() is called in
online_pages().

This patch will avoid to rebuild the zonelists for already exist nodes.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 560eafe8234d..fc8181b44fd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5200,15 +5200,17 @@ static int __build_all_zonelists(void *data)
 	memset(node_load, 0, sizeof(node_load));
 #endif
 
-	if (self && !node_online(self->node_id)) {
+	/* This node is hotadded and no memory preset yet.
+	 * So just build zonelists is fine, no need to touch other nodes.
+	 */
+	if (self && !node_online(self->node_id))
 		build_zonelists(self);
-	}
-
-	for_each_online_node(nid) {
-		pg_data_t *pgdat = NODE_DATA(nid);
+	else
+		for_each_online_node(nid) {
+			pg_data_t *pgdat = NODE_DATA(nid);
 
-		build_zonelists(pgdat);
-	}
+			build_zonelists(pgdat);
+		}
 
 	/*
 	 * Initialize the boot_pagesets that are going to be used
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
