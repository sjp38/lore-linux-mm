Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA8644405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:58:49 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q39so4513011wrb.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:49 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id c142si918671wmc.89.2017.02.15.12.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 12:58:48 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id i10so32709021wrb.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:48 -0800 (PST)
From: Nicolai Stange <nicstange@gmail.com>
Subject: [RFC 3/3] sparse-vmemmap: let vmemmap_verify() ignore NUMA_NO_NODE requests
Date: Wed, 15 Feb 2017 21:58:26 +0100
Message-Id: <20170215205826.13356-4-nicstange@gmail.com>
In-Reply-To: <20170215205826.13356-1-nicstange@gmail.com>
References: <20170215205826.13356-1-nicstange@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>

On x86, Kasan's initizalization in arch/x86/mm/kasan_init_64.c calls
vmemmap_populate() and thus, since commit 7b79d10a2d64 ("mm: convert
kmalloc_section_memmap() to populate_section_memmap()"),
vmemmap_populate_basepages() with a node value of NUMA_NO_NODE.

Since a page's actual NUMA node is never equal to NUMA_NO_NODE, this
results in excessive warnings from vmemmap_verify():

  [ffffed00179c6e00-ffffed00179c7dff] potential offnode page_structs
  [ffffed00179c7e00-ffffed00179c8dff] potential offnode page_structs
  [ffffed00179c8e00-ffffed00179c9dff] potential offnode page_structs
  [ffffed00179c9e00-ffffed00179cadff] potential offnode page_structs
  [ffffed00179cae00-ffffed00179cbdff] potential offnode page_structs
  [...]

Make vmemmap_verify() return early if the requested node equals
NUMA_NO_NODE.

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 mm/sparse-vmemmap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index f08872b58e48..e38aaf6c312c 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -165,6 +165,9 @@ void __meminit vmemmap_verify(pte_t *pte, int node,
 	unsigned long pfn = pte_pfn(*pte);
 	int actual_node = early_pfn_to_nid(pfn);
 
+	if (node == NUMA_NO_NODE)
+		return;
+
 	if (node_distance(actual_node, node) > LOCAL_DISTANCE)
 		pr_warn("[%lx-%lx] potential offnode page_structs\n",
 			start, end - 1);
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
