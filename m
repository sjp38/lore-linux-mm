Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24A656B004D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 12:14:14 -0400 (EDT)
Date: Wed, 11 Mar 2009 03:09:48 +1100
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] Enable hashdist by default on 64bit NUMA
Message-ID: <20090310160948.GB14613@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, davem@davemloft.net, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>


On PowerPC we allocate large boot time hashes on node 0. This leads to
an imbalance in the free memory, for example on a 64GB box (4 x 16GB
nodes):

Free memory:
Node 0: 97.03%
Node 1: 98.54%
Node 2: 98.42%
Node 3: 98.53%

If we switch to using vmalloc (like ia64 and x86-64) things are more
balanced:

Free memory:
Node 0: 97.53%
Node 1: 98.35%
Node 2: 98.33%
Node 3: 98.33%

For many HPC applications we are limited by the free available memory on
the smallest node, so even though the same amount of memory is used the
better balancing helps.

Since all 64bit NUMA capable architectures should have sufficient
vmalloc space, it makes sense to enable it via CONFIG_64BIT.

Signed-off-by: Anton Blanchard <anton@samba.org>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 95837bf..0c4d4b7 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -144,10 +144,10 @@ extern void *alloc_large_system_hash(const char *tablename,
 
 #define HASH_EARLY	0x00000001	/* Allocating during early boot? */
 
-/* Only NUMA needs hash distribution.
- * IA64 and x86_64 have sufficient vmalloc space.
+/* Only NUMA needs hash distribution. 64bit NUMA architectures have
+ * sufficient vmalloc space.
  */
-#if defined(CONFIG_NUMA) && (defined(CONFIG_IA64) || defined(CONFIG_X86_64))
+#if defined(CONFIG_NUMA) && defined(CONFIG_64BIT)
 #define HASHDIST_DEFAULT 1
 #else
 #define HASHDIST_DEFAULT 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
