Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j14L6B3n021649
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:06:11 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j14L6AWr232810
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:06:10 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j14L6Amg005994
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:06:10 -0500
Subject: [PATCH 3/3] remove-free_all_bootmem() #define
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 04 Feb 2005 13:06:08 -0800
Message-Id: <E1CxAeX-0003uQ-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

in arch/i386/mm/init.c, there's a #define for __free_all_bootmem():

#ifndef CONFIG_DISCONTIGMEM
#define __free_all_bootmem() free_all_bootmem()
#else
#define __free_all_bootmem() free_all_bootmem_node(NODE_DATA(0))
#endif /* !CONFIG_DISCONTIGMEM */

However, both of those functions end up eventually calling the same
thing:

	free_all_bootmem_core(NODE_DATA(0))

This might have once been a placeholder for a more complex bootmem
init call, but that never happened.  So, kill off the DISCONTIG
version, and just call free_all_bootmem() directly in both cases.
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/init.c |    8 +-------
 1 files changed, 1 insertion(+), 7 deletions(-)

diff -puN arch/i386/mm/init.c~A1.3-remove-free_all_bootmem-define arch/i386/mm/init.c
--- memhotplug/arch/i386/mm/init.c~A1.3-remove-free_all_bootmem-define	2005-02-03 11:53:40.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/init.c	2005-02-03 11:53:40.000000000 -0800
@@ -579,12 +579,6 @@ static void __init set_max_mapnr_init(vo
 #endif
 }
 
-#ifndef CONFIG_DISCONTIGMEM
-#define __free_all_bootmem() free_all_bootmem()
-#else
-#define __free_all_bootmem() free_all_bootmem_node(NODE_DATA(0))
-#endif /* !CONFIG_DISCONTIGMEM */
-
 static struct kcore_list kcore_mem, kcore_vmalloc; 
 
 void __init mem_init(void)
@@ -620,7 +614,7 @@ void __init mem_init(void)
 #endif
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages += __free_all_bootmem();
+	totalram_pages += free_all_bootmem();
 
 	reservedpages = 0;
 	for (tmp = 0; tmp < max_low_pfn; tmp++)
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
