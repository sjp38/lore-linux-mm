Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B00996B02C7
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:54:12 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 23 Jun 2012 11:54:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3C54138C801C
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:01 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5NFr0r9220540
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5NFr014012660
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 12:53:00 -0300
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 2/5] mm/sparse: optimize sparse_index_alloc
Date: Sat, 23 Jun 2012 23:52:53 +0800
Message-Id: <1340466776-4976-2-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
descriptors are allocated from slab or bootmem. When allocating
from slab, let slab allocator to clear the memory chunk. However,
the memory chunk from bootmem allocator, we have to clear that
explicitly.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index afd0998..ce50c8b 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -74,14 +74,14 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 
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
+		if (section)
+			memset(section, 0, array_size);
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
