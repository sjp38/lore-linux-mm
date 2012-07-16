Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 505F86B005C
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 00:42:03 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@shangw.pok.ibm.com>;
	Sun, 15 Jul 2012 22:42:02 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DEEEDC90050
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 00:41:11 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6G4fBXW389008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 00:41:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6GAC4hB025918
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 06:12:04 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v4 RESEND 1/3] mm/sparse: optimize sparse_index_alloc
Date: Mon, 16 Jul 2012 12:45:55 +0800
Message-Id: <1342413957-3843-1-git-send-email-shangw@linux.vnet.ibm.com>
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
