Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1PIsahS025630
	for <linux-mm@kvack.org>; Fri, 25 Feb 2005 13:54:36 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1PIsaW6247396
	for <linux-mm@kvack.org>; Fri, 25 Feb 2005 13:54:36 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1PIsaJj004913
	for <linux-mm@kvack.org>; Fri, 25 Feb 2005 13:54:36 -0500
Subject: [PATCH] make highmem_start access only valid addresses (i386)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 25 Feb 2005 10:54:34 -0800
Message-Id: <E1D4kbj-0004UG-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

When CONFIG_HIGHMEM=y, but ZONE_NORMAL isn't quite full, there is, of course,
no actual memory at *high_memory.  This isn't a problem with normal
virt<->phys translations because it's never dereferenced, but CONFIG_NONLINEAR
is a bit more finicky.  So, don't do __va() in non-existent addresses.

BTW, this can certainly wait until the 2.6.12 series.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 sparse-dave/arch/i386/mm/init.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/i386/mm/init.c~A4-highmem_start-valid_addrs arch/i386/mm/init.c
--- sparse/arch/i386/mm/init.c~A4-highmem_start-valid_addrs	2005-02-24 08:56:43.000000000 -0800
+++ sparse-dave/arch/i386/mm/init.c	2005-02-24 08:56:43.000000000 -0800
@@ -563,9 +563,9 @@ void __init mem_init(void)
 	set_max_mapnr_init();
 
 #ifdef CONFIG_HIGHMEM
-	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE);
+	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE - 1) + 1;
 #else
-	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
+	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
 #endif
 
 	/* this will put all low memory onto the freelists */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
