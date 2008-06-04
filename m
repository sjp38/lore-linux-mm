Message-Id: <20080604113111.898361699@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
Date: Wed, 04 Jun 2008 21:29:46 +1000
From: npiggin@suse.de
Subject: [patch 07/21] mm: introduce non panic alloc_bootmem
Content-Disposition: inline; filename=__alloc_bootmem_node_nopanic.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Straight forward variant of the existing __alloc_bootmem_node, only 
difference is that it doesn't panic on failure. We use this in a
subsequent patch when allocating giant hugepages at boot -- don't want
to panic if we can't allocate as many as the user asked for.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/bootmem.h |    4 ++++
 mm/bootmem.c            |   12 ++++++++++++
 2 files changed, 16 insertions(+)

Index: linux-2.6/mm/bootmem.c
===================================================================
--- linux-2.6.orig/mm/bootmem.c	2008-06-04 20:47:34.000000000 +1000
+++ linux-2.6/mm/bootmem.c	2008-06-04 20:51:21.000000000 +1000
@@ -576,6 +576,18 @@ void * __init alloc_bootmem_section(unsi
 }
 #endif
 
+void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	void *ptr;
+
+	ptr = alloc_bootmem_core(pgdat->bdata, size, align, goal, 0);
+	if (ptr)
+		return ptr;
+
+	return __alloc_bootmem_nopanic(size, align, goal);
+}
+
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif
Index: linux-2.6/include/linux/bootmem.h
===================================================================
--- linux-2.6.orig/include/linux/bootmem.h	2008-06-04 20:47:34.000000000 +1000
+++ linux-2.6/include/linux/bootmem.h	2008-06-04 20:51:21.000000000 +1000
@@ -87,6 +87,10 @@ extern void *__alloc_bootmem_node(pg_dat
 				  unsigned long size,
 				  unsigned long align,
 				  unsigned long goal);
+extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
+				  unsigned long size,
+				  unsigned long align,
+				  unsigned long goal);
 extern unsigned long init_bootmem_node(pg_data_t *pgdat,
 				       unsigned long freepfn,
 				       unsigned long startpfn,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
