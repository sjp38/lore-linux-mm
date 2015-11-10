Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C1F436B0256
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:33:53 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so210583142pac.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:53 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id rp3si5217585pbc.75.2015.11.10.05.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:33:52 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so235001122pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:52 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 3/3] tools/vm/slabinfo: update struct slabinfo members' types
Date: Tue, 10 Nov 2015 22:32:06 +0900
Message-Id: <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Align some of `struct slabinfo' members' types with
`struct kmem_cache' to suppress gcc warnings:

slabinfo.c:847:22: warning: comparison between signed
  and unsigned integer expressions [-Wsign-compare]
slabinfo.c:869:20: warning: comparison between signed
  and unsigned integer expressions [-Wsign-compare]
slabinfo.c:872:22: warning: comparison between signed
  and unsigned integer expressions [-Wsign-compare]
slabinfo.c:894:20: warning: comparison between signed
  and unsigned integer expressions [-Wsign-compare]

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 tools/vm/slabinfo.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 86e698d0..1813854 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -19,6 +19,7 @@
 #include <getopt.h>
 #include <regex.h>
 #include <errno.h>
+#include <limits.h>
 
 #define MAX_SLABS 500
 #define MAX_ALIASES 500
@@ -28,10 +29,11 @@ struct slabinfo {
 	char *name;
 	int alias;
 	int refs;
-	int aliases, align, cache_dma, cpu_slabs, destroy_by_rcu;
-	int hwcache_align, object_size, objs_per_slab;
-	int sanity_checks, slab_size, store_user, trace;
+	int aliases, cache_dma, cpu_slabs, destroy_by_rcu;
+	int sanity_checks, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
+	unsigned int hwcache_align, align, object_size;
+	unsigned int objs_per_slab, slab_size;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -766,10 +768,10 @@ static void totals(void)
 
 	int used_slabs = 0;
 	char b1[20], b2[20], b3[20], b4[20];
-	unsigned long long max = 1ULL << 63;
+	unsigned long long max = ULLONG_MAX;
 
 	/* Object size */
-	unsigned long long min_objsize = max, max_objsize = 0, avg_objsize;
+	unsigned int min_objsize = UINT_MAX, max_objsize = 0, avg_objsize;
 
 	/* Number of partial slabs in a slabcache */
 	unsigned long long min_partial = max, max_partial = 0,
-- 
2.6.2.280.g74301d6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
