Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0Q0NhCO423020
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 19:23:43 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0Q0NhBp269642
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 17:23:43 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0Q0Nge7009503
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 17:23:42 -0700
Subject: [RFC][PATCH 3/5] remove-free_all_bootmem() #define
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 25 Jan 2005 16:23:40 -0800
Message-Id: <E1CtayD-0006sU-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>


in arch/i386/mm/init.c, there's a #define for __free_all_bootmem():

#ifndef CONFIG_DISCONTIGMEM
#define __free_all_bootmem() free_all_bootmem()
#else
#define __free_all_bootmem() free_all_bootmem_node(NODE_DATA(0))
#endif /* !CONFIG_DISCONTIGMEM */

However, both of those functions end up eventuall calling the same
thing:

	free_all_bootmem_core(NODE_DATA(0))

This might have once been a placeholder for a more complex bootmem
init call, but that never happened.  So, kill off the DISCONTIG
version, and just call free_all_bootmem() directly in both cases.

---

 memhotplug-dave/arch/i386/mm/init.c |    8 +-------
 1 files changed, 1 insertion(+), 7 deletions(-)

diff -puN arch/i386/mm/init.c~A1.3-remove-free_all_bootmem-define arch/i386/mm/init.c
--- memhotplug/arch/i386/mm/init.c~A1.3-remove-free_all_bootmem-define	2005-01-25 13:59:50.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/init.c	2005-01-25 14:00:14.000000000 -0800
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
