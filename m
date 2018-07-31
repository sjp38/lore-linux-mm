Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D45D6B026B
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:07:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u4-v6so9054741pgr.2
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:07:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m11-v6si6161325pgk.468.2018.07.31.02.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 02:07:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 6/6] mm, slab: shorten kmalloc cache names for large sizes
Date: Tue, 31 Jul 2018 11:06:49 +0200
Message-Id: <20180731090649.16028-7-vbabka@suse.cz>
In-Reply-To: <20180731090649.16028-1-vbabka@suse.cz>
References: <20180731090649.16028-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

Kmalloc cache names can get quite long for large object sizes, when the sizes
are expressed in bytes. Use 'k' and 'M' prefixes to make the names as short
as possible e.g. in /proc/slabinfo. This works, as we mostly use power-of-two
sizes, with exceptions only below 1k.

Example: 'kmalloc-4194304' becomes 'kmalloc-4M'

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Roman Gushchin <guro@fb.com>
---
 mm/slab_common.c | 38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 03f40b273ea3..a07fcb2551f6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1050,15 +1050,15 @@ const struct kmalloc_info_struct kmalloc_info[] __initconst = {
 	{"kmalloc-16",             16},		{"kmalloc-32",             32},
 	{"kmalloc-64",             64},		{"kmalloc-128",           128},
 	{"kmalloc-256",           256},		{"kmalloc-512",           512},
-	{"kmalloc-1024",         1024},		{"kmalloc-2048",         2048},
-	{"kmalloc-4096",         4096},		{"kmalloc-8192",         8192},
-	{"kmalloc-16384",       16384},		{"kmalloc-32768",       32768},
-	{"kmalloc-65536",       65536},		{"kmalloc-131072",     131072},
-	{"kmalloc-262144",     262144},		{"kmalloc-524288",     524288},
-	{"kmalloc-1048576",   1048576},		{"kmalloc-2097152",   2097152},
-	{"kmalloc-4194304",   4194304},		{"kmalloc-8388608",   8388608},
-	{"kmalloc-16777216", 16777216},		{"kmalloc-33554432", 33554432},
-	{"kmalloc-67108864", 67108864}
+	{"kmalloc-1k",           1024},		{"kmalloc-2k",           2048},
+	{"kmalloc-4k",           4096},		{"kmalloc-8k",           8192},
+	{"kmalloc-16k",         16384},		{"kmalloc-32k",         32768},
+	{"kmalloc-64k",         65536},		{"kmalloc-128k",       131072},
+	{"kmalloc-256k",       262144},		{"kmalloc-512k",       524288},
+	{"kmalloc-1M",        1048576},		{"kmalloc-2M",        2097152},
+	{"kmalloc-4M",        4194304},		{"kmalloc-8M",        8388608},
+	{"kmalloc-16M",      16777216},		{"kmalloc-32M",      33554432},
+	{"kmalloc-64M",      67108864}
 };
 
 /*
@@ -1108,6 +1108,21 @@ void __init setup_kmalloc_cache_index_table(void)
 	}
 }
 
+static const char *
+kmalloc_cache_name(const char *prefix, unsigned int size)
+{
+
+	static const char units[3] = "\0kM";
+	int idx = 0;
+
+	while (size >= 1024 && (size % 1024 == 0)) {
+		size /= 1024;
+		idx++;
+	}
+
+	return kasprintf(GFP_NOWAIT, "%s-%u%c", prefix, size, units[idx]);
+}
+
 static void __init
 new_kmalloc_cache(int idx, int type, slab_flags_t flags)
 {
@@ -1115,7 +1130,7 @@ new_kmalloc_cache(int idx, int type, slab_flags_t flags)
 
 	if (type == KMALLOC_RECLAIM) {
 		flags |= SLAB_RECLAIM_ACCOUNT;
-		name = kasprintf(GFP_NOWAIT, "kmalloc-rcl-%u",
+		name = kmalloc_cache_name("kmalloc-rcl",
 						kmalloc_info[idx].size);
 		BUG_ON(!name);
 	} else {
@@ -1164,8 +1179,7 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 
 		if (s) {
 			unsigned int size = kmalloc_size(i);
-			char *n = kasprintf(GFP_NOWAIT,
-				 "dma-kmalloc-%u", size);
+			const char *n = kmalloc_cache_name("dma-kmalloc", size);
 
 			BUG_ON(!n);
 			kmalloc_caches[KMALLOC_DMA][i] = create_kmalloc_cache(
-- 
2.18.0
