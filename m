Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 265476B006C
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:31:54 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 22 Jul 2012 20:31:53 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2E1751FF001B
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 02:31:44 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6N2Vj8B286070
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 20:31:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6N2VjXQ004535
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 20:31:45 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH RESEND v4 1/3] mm/sparse: optimize sparse_index_alloc
Date: Mon, 23 Jul 2012 10:31:40 +0800
Message-Id: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
descriptors are allocated from slab or bootmem. When allocating
from slab, let slab/bootmem allocator to clear the memory chunk.
We needn't clear that explicitly.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/sparse.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index c7bb952..d882e88 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -65,14 +65,12 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 
 	if (slab_is_available()) {
 		if (node_state(nid, N_HIGH_MEMORY))
-			section = kmalloc_node(array_size, GFP_KERNEL, nid);
+			section = kzalloc_node(array_size, GFP_KERNEL, nid);
 		else
-			section = kmalloc(array_size, GFP_KERNEL);
-	} else
+			section = kzalloc(array_size, GFP_KERNEL);
+	} else {
 		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
-
-	if (section)
-		memset(section, 0, array_size);
+	}
 
 	return section;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
