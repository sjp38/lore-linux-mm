Date: Fri, 20 Apr 2007 22:12:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: slab allocators: Remove multiple alignment specifications.
Message-ID: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

It is not necessary to tell the slab allocators to align to a cacheline
if an explicit alignment was already specified. It is rather confusing
to specify multiple alignments.

Make sure that the call sites only use one form of alignment.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/powerpc/mm/hugetlbpage.c	2007-04-20 19:25:14.000000000 -0700
+++ linux-2.6.21-rc6/arch/powerpc/mm/hugetlbpage.c	2007-04-20 19:25:40.000000000 -0700
@@ -1063,7 +1063,7 @@ static int __init hugetlbpage_init(void)
 	huge_pgtable_cache = kmem_cache_create("hugepte_cache",
 					       HUGEPTE_TABLE_SIZE,
 					       HUGEPTE_TABLE_SIZE,
-					       SLAB_HWCACHE_ALIGN,
+					       0,
 					       zero_ctor, NULL);
 	if (! huge_pgtable_cache)
 		panic("hugetlbpage_init(): could not create hugepte cache\n");
Index: linux-2.6.21-rc6/arch/powerpc/mm/init_64.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/powerpc/mm/init_64.c	2007-04-20 19:25:14.000000000 -0700
+++ linux-2.6.21-rc6/arch/powerpc/mm/init_64.c	2007-04-20 19:25:40.000000000 -0700
@@ -183,7 +183,7 @@ void pgtable_cache_init(void)
 		    "for size: %08x...\n", name, i, size);
 		pgtable_cache[i] = kmem_cache_create(name,
 						     size, size,
-						     SLAB_HWCACHE_ALIGN,
+						     0,
 						     zero_ctor,
 						     NULL);
 		if (! pgtable_cache[i])
Index: linux-2.6.21-rc6/arch/sparc64/mm/init.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/sparc64/mm/init.c	2007-04-20 19:25:14.000000000 -0700
+++ linux-2.6.21-rc6/arch/sparc64/mm/init.c	2007-04-20 19:25:40.000000000 -0700
@@ -191,7 +191,7 @@ void pgtable_cache_init(void)
 {
 	pgtable_cache = kmem_cache_create("pgtable_cache",
 					  PAGE_SIZE, PAGE_SIZE,
-					  SLAB_HWCACHE_ALIGN,
+					  0,
 					  zero_ctor,
 					  NULL);
 	if (!pgtable_cache) {
Index: linux-2.6.21-rc6/arch/sparc64/mm/tsb.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/sparc64/mm/tsb.c	2007-04-20 19:25:14.000000000 -0700
+++ linux-2.6.21-rc6/arch/sparc64/mm/tsb.c	2007-04-20 19:25:40.000000000 -0700
@@ -262,7 +262,7 @@ void __init tsb_cache_init(void)
 
 		tsb_caches[i] = kmem_cache_create(name,
 						  size, size,
-						  SLAB_HWCACHE_ALIGN,
+						  0,
 						  NULL, NULL);
 		if (!tsb_caches[i]) {
 			prom_printf("Could not create %s cache\n", name);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
