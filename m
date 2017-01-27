Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 431FE6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 20:59:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 194so335269177pgd.7
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:59:32 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id x190si803471pgd.418.2017.01.26.17.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 17:59:31 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 3so5946597pgj.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:59:31 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm/memblock: switch to use NUMA_NO_NODE instead of MAX_NUMNODES in for_each_mem_pfn_range()
Date: Fri, 27 Jan 2017 09:59:22 +0800
Message-Id: <20170127015922.36249-2-richard.weiyang@gmail.com>
In-Reply-To: <20170127015922.36249-1-richard.weiyang@gmail.com>
References: <20170127015922.36249-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

As in commit <b115423357e0> '(mm/memblock: switch to use NUMA_NO_NODE
instead of MAX_NUMNODES)', NUMA_NO_NODE is recommended to be the selector
of the nid.

This patch does the same thing.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/memblock.h | 2 +-
 mm/memblock.c            | 6 +++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 5b759c9acf97..4bf9d3f7c539 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -207,7 +207,7 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
  * @i: an integer used as loop variable
- * @nid: node selector, %MAX_NUMNODES for all nodes
+ * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @p_start: ptr to ulong for start pfn of the range, can be %NULL
  * @p_end: ptr to ulong for end pfn of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
diff --git a/mm/memblock.c b/mm/memblock.c
index 7d27566cee11..8d41421aa589 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1084,12 +1084,16 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 	struct memblock_type *type = &memblock.memory;
 	struct memblock_region *r;
 
+	if (WARN_ONCE(nid == MAX_NUMNODES,
+	"Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
+
 	while (++*idx < type->cnt) {
 		r = &type->regions[*idx];
 
 		if (PFN_UP(r->base) >= PFN_DOWN(r->base + r->size))
 			continue;
-		if (nid == MAX_NUMNODES || nid == r->nid)
+		if (nid == NUMA_NO_NODE || nid == r->nid)
 			break;
 	}
 	if (*idx >= type->cnt) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
