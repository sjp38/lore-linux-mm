Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18EE36B074F
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:00:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t10-v6so5156994wrs.17
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:00:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b65-v6sor897983wmh.19.2018.08.17.02.00.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 02:00:23 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v4 2/4] mm/memory_hotplug: Drop mem_blk check from unregister_mem_sect_under_nodes
Date: Fri, 17 Aug 2018 11:00:15 +0200
Message-Id: <20180817090017.17610-3-osalvador@techadventures.net>
In-Reply-To: <20180817090017.17610-1-osalvador@techadventures.net>
References: <20180817090017.17610-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Before calling to unregister_mem_sect_under_nodes(),
remove_memory_section() already checks if we got a valid memory_block.

No need to check that again in unregister_mem_sect_under_nodes().

If more functions start using unregister_mem_sect_under_nodes() in the
future, we can always place a WARN_ON to catch null mem_blk's so we can
safely back off.

For now, let us keep the check in remove_memory_section() since it is the
only function that uses it.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/node.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 1ac4c36e13bb..dd3bdab230b2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -455,10 +455,6 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	if (!mem_blk) {
-		NODEMASK_FREE(unlinked_nodes);
-		return -EFAULT;
-	}
 	if (!unlinked_nodes)
 		return -ENOMEM;
 	nodes_clear(*unlinked_nodes);
-- 
2.13.6
