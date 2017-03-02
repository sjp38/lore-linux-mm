Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A31A76B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 00:25:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 1so80391232pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 21:25:46 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r63si259398plb.315.2017.03.01.21.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 21:25:45 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v3 4/4] mm: Adaptive hash table scaling
Date: Thu,  2 Mar 2017 00:33:45 -0500
Message-Id: <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org

Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
is provided every time memory quadruples the sizes of hash tables will only
double instead of quadrupling as well. This algorithm starts working only
when memory size reaches a certain point, currently set to 64G.

This is example of dentry hash table size, before and after four various
memory configurations:

MEMORY	   SCALE	 HASH_SIZE
	old	new	old	new
    8G	 13	 13      8M      8M
   16G	 13	 13     16M     16M
   32G	 13	 13     32M     32M
   64G	 13	 13     64M     64M
  128G	 13	 14    128M     64M
  256G	 13	 14    256M    128M
  512G	 13	 15    512M    128M
 1024G	 13	 15   1024M    256M
 2048G	 13	 16   2048M    256M
 4096G	 13	 16   4096M    512M
 8192G	 13	 17   8192M    512M
16384G	 13	 17  16384M   1024M
32768G	 13	 18  32768M   1024M
65536G	 13	 18  65536M   2048M

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 fs/dcache.c             |    2 +-
 fs/inode.c              |    2 +-
 include/linux/bootmem.h |    1 +
 mm/page_alloc.c         |   19 +++++++++++++++++++
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 363502f..808ea99 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3585,7 +3585,7 @@ static void __init dcache_init(void)
 					sizeof(struct hlist_bl_head),
 					dhash_entries,
 					13,
-					HASH_ZERO,
+					HASH_ZERO | HASH_ADAPT,
 					&d_hash_shift,
 					&d_hash_mask,
 					0,
diff --git a/fs/inode.c b/fs/inode.c
index 1b15a7c..32c8ee4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1953,7 +1953,7 @@ void __init inode_init(void)
 					sizeof(struct hlist_head),
 					ihash_entries,
 					14,
-					HASH_ZERO,
+					HASH_ZERO | HASH_ADAPT,
 					&i_hash_shift,
 					&i_hash_mask,
 					0,
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index e223d91..dbaf312 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -359,6 +359,7 @@ static inline void __init memblock_free_late(
 #define HASH_SMALL	0x00000002	/* sub-page allocation allowed, min
 					 * shift passed via *_hash_shift */
 #define HASH_ZERO	0x00000004	/* Zero allocated hash table */
+#define	HASH_ADAPT	0x00000008	/* Adaptive scale for large memory */
 
 /* Only NUMA needs hash distribution. 64bit NUMA architectures have
  * sufficient vmalloc space.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b0f7a4..608055e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7124,6 +7124,17 @@ static unsigned long __init arch_reserved_kernel_pages(void)
 #endif
 
 /*
+ * Adaptive scale is meant to reduce sizes of hash tables on large memory
+ * machines. As memory size is increased the scale is also increased but at
+ * slower pace.  Starting from ADAPT_SCALE_BASE (64G), every time memory
+ * quadruples the scale is increased by one, which means the size of hash table
+ * only doubles, instead of quadrupling as well.
+ */
+#define ADAPT_SCALE_BASE	(64ul << 30)
+#define ADAPT_SCALE_SHIFT	2
+#define ADAPT_SCALE_NPAGES	(ADAPT_SCALE_BASE >> PAGE_SHIFT)
+
+/*
  * allocate a large system hash table from bootmem
  * - it is assumed that the hash table must contain an exact power-of-2
  *   quantity of entries
@@ -7154,6 +7165,14 @@ static unsigned long __init arch_reserved_kernel_pages(void)
 		if (PAGE_SHIFT < 20)
 			numentries = round_up(numentries, (1<<20)/PAGE_SIZE);
 
+		if (flags & HASH_ADAPT) {
+			unsigned long adapt;
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
