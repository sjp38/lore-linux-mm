Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7CE280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 13:07:06 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c75so39021352qka.7
        for <linux-mm@kvack.org>; Sat, 20 May 2017 10:07:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b52si12806196qta.156.2017.05.20.10.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 10:07:05 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 1/1] mm: Adaptive hash table scaling
Date: Sat, 20 May 2017 13:06:53 -0400
Message-Id: <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org

Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
is provided every time memory quadruples the sizes of hash tables will only
double instead of quadrupling as well. This algorithm starts working only
when memory size reaches a certain point, currently set to 64G.

This is example of dentry hash table size, before and after four various
memory configurations:

MEMORY    SCALE        HASH_SIZE
        old    new    old     new
    8G  13     13      8M      8M
   16G  13     13     16M     16M
   32G  13     13     32M     32M
   64G  13     13     64M     64M
  128G  13     14    128M     64M
  256G  13     14    256M    128M
  512G  13     15    512M    128M
 1024G  13     15   1024M    256M
 2048G  13     16   2048M    256M
 4096G  13     16   4096M    512M
 8192G  13     17   8192M    512M
16384G  13     17  16384M   1024M
32768G  13     18  32768M   1024M
65536G  13     18  65536M   2048M

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8afa63e81e73..15bba5c325a5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7169,6 +7169,17 @@ static unsigned long __init arch_reserved_kernel_pages(void)
 #endif
 
 /*
+ * Adaptive scale is meant to reduce sizes of hash tables on large memory
+ * machines. As memory size is increased the scale is also increased but at
+ * slower pace.  Starting from ADAPT_SCALE_BASE (64G), every time memory
+ * quadruples the scale is increased by one, which means the size of hash table
+ * only doubles, instead of quadrupling as well.
+ */
+#define ADAPT_SCALE_BASE	(64ull << 30)
+#define ADAPT_SCALE_SHIFT	2
+#define ADAPT_SCALE_NPAGES	(ADAPT_SCALE_BASE >> PAGE_SHIFT)
+
+/*
  * allocate a large system hash table from bootmem
  * - it is assumed that the hash table must contain an exact power-of-2
  *   quantity of entries
@@ -7199,6 +7210,14 @@ void *__init alloc_large_system_hash(const char *tablename,
 		if (PAGE_SHIFT < 20)
 			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
 
+		if (!high_limit) {
+			unsigned long long adapt;
+
+			for (adapt = ADAPT_SCALE_NPAGES; adapt < numentries;
+			     adapt <<= ADAPT_SCALE_SHIFT)
+				scale++;
+		}
+
 		/* limit to 1 bucket per 2^scale bytes of low memory */
 		if (scale > PAGE_SHIFT)
 			numentries >>= (scale - PAGE_SHIFT);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
