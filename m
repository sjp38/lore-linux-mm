Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 28D586B02C5
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:54:06 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 23 Jun 2012 09:54:05 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 10743C40005
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 15:53:46 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5NFrG3L217764
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 09:53:31 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5NFr01H015001
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 09:53:00 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 1/5] mm/sparse: check size of struct mm_section
Date: Sat, 23 Jun 2012 23:52:52 +0800
Message-Id: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Platforms like PPC might need two level mem_section for SPARSEMEM
with enabled CONFIG_SPARSEMEM_EXTREME. On the other hand, the
memory section descriptor might be allocated from bootmem allocator
with PAGE_SIZE alignment. In order to fully utilize the memory chunk
allocated from bootmem allocator, it'd better to assure memory
sector descriptor won't run across the boundary (PAGE_SIZE).

The patch introduces the check on size of "struct mm_section" to
assure that.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/sparse.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 6a4bf91..afd0998 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -63,6 +63,15 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
 
+	/*
+	 * The root memory section descriptor might be allocated
+	 * from bootmem, which has minimal memory chunk requirement
+	 * of page. In order to fully utilize the memory, the sparse
+	 * memory section descriptor shouldn't run across the boundary
+	 * that bootmem allocator has.
+	 */
+	BUILD_BUG_ON(PAGE_SIZE % sizeof(struct mem_section));
+
 	if (slab_is_available()) {
 		if (node_state(nid, N_HIGH_MEMORY))
 			section = kmalloc_node(array_size, GFP_KERNEL, nid);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
