Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 047696B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:45:27 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 12:45:26 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F3FBE38C87A5
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:36:21 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RGaLBJ145116
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:36:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RGaLSU020749
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:36:21 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] mm/sparse: optimize sparse_index_alloc
Date: Thu, 28 Jun 2012 00:36:06 +0800
Message-Id: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, dave@linux.vnet.ibm.com, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
descriptors are allocated from slab or bootmem. When allocating
from slab, let slab/bootmem allocator to clear the memory chunk.
We needn't clear that explicitly.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/sparse.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 6a4bf91..781fa04 100644
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
