Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 858C16B000E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 07:19:36 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k11-v6so885025wrm.19
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:19:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q77-v6sor444862wmd.57.2018.06.22.04.19.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 04:19:34 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 4/4] mm/memory_hotplug: Drop unnecessary checks from register_mem_sect_under_node
Date: Fri, 22 Jun 2018 13:18:39 +0200
Message-Id: <20180622111839.10071-5-osalvador@techadventures.net>
In-Reply-To: <20180622111839.10071-1-osalvador@techadventures.net>
References: <20180622111839.10071-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, Jonathan.Cameron@huawei.com, arbab@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Callers of register_mem_sect_under_node() are always passing a valid
memory_block (not NULL), so we can safely drop the check for NULL.

In the same way, register_mem_sect_under_node() is only called in case
the node is online, so we can safely remove that check as well.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 drivers/base/node.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 845d5523812b..1ac4c36e13bb 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -404,12 +404,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 	int ret, nid = *(int *)arg;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	if (!mem_blk)
-		return -EFAULT;
-
 	mem_blk->nid = nid;
-	if (!node_online(nid))
-		return 0;
 
 	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
 	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
-- 
2.13.6
