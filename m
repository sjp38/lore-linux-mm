Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j14L67UZ024487
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:06:07 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j14L66Wr251844
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:06:06 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j14L66fO005899
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:06:06 -0500
Subject: [PATCH 2/3] consolidate set_max_mapnr_init() implementations
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 04 Feb 2005 13:06:05 -0800
Message-Id: <E1CxAeT-0003gI-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

discontig.c has its own version of set_max_mapnr_init().  However,
all that it really does differently from the mm/init.c version is
skip setting max_mapnr (which doesn't exist because there's no 
mem_map[]).

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/discontig.c |    9 ---------
 memhotplug-dave/arch/i386/mm/init.c      |   11 +++++++----
 2 files changed, 7 insertions(+), 13 deletions(-)

diff -puN arch/i386/mm/init.c~A1.2-cleanup-set_max_mapnr_init arch/i386/mm/init.c
--- memhotplug/arch/i386/mm/init.c~A1.2-cleanup-set_max_mapnr_init	2005-02-03 11:53:39.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/init.c	2005-02-03 11:53:39.000000000 -0800
@@ -567,19 +567,22 @@ static void __init test_wp_bit(void)
 	}
 }
 
-#ifndef CONFIG_DISCONTIGMEM
 static void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-	max_mapnr = num_physpages = highend_pfn;
+	num_physpages = highend_pfn;
 #else
-	max_mapnr = num_physpages = max_low_pfn;
+	num_physpages = max_low_pfn;
+#endif
+#ifndef CONFIG_DISCONTIGMEM
+	max_mapnr = num_physpages;
 #endif
 }
+
+#ifndef CONFIG_DISCONTIGMEM
 #define __free_all_bootmem() free_all_bootmem()
 #else
 #define __free_all_bootmem() free_all_bootmem_node(NODE_DATA(0))
-extern void set_max_mapnr_init(void);
 #endif /* !CONFIG_DISCONTIGMEM */
 
 static struct kcore_list kcore_mem, kcore_vmalloc; 
diff -puN arch/i386/mm/discontig.c~A1.2-cleanup-set_max_mapnr_init arch/i386/mm/discontig.c
--- memhotplug/arch/i386/mm/discontig.c~A1.2-cleanup-set_max_mapnr_init	2005-02-03 11:53:39.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/discontig.c	2005-02-03 11:53:39.000000000 -0800
@@ -371,12 +371,3 @@ void __init set_highmem_pages_init(int b
 	totalram_pages += totalhigh_pages;
 #endif
 }
-
-void __init set_max_mapnr_init(void)
-{
-#ifdef CONFIG_HIGHMEM
-	num_physpages = highend_pfn;
-#else
-	num_physpages = max_low_pfn;
-#endif
-}
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
