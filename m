Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1SIsatW003477
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 13:54:36 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1SIsZmU058194
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 13:54:35 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1SIsZS0031436
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 13:54:35 -0500
Subject: [PATCH 2/5] do not unnecessarily memset the pgdats
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 28 Feb 2005 10:54:34 -0800
Message-Id: <E1D5q2M-0007aZ-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, kmannth@us.ibm.com, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, ygoto@us.fujitsu.com
List-ID: <linux-mm.kvack.org>

Both the pgdats and the struct zonelist are zeroed unnecessarily.
The zonelist is a member of the pgdat, so any time the pgdat is
cleared, so is the zonelist.  All of the architectures present a
zeroed pgdat to the generic code, so it's not necessary to set it
again.

Not clearing it like this allows the functions to be reused by
the memory hotplug code.  The only architecture which has a
dependence on these clears is i386.  The previous patch in this
series fixed that up.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 arch/i386/mm/init.c         |    0 
 sparse-dave/mm/page_alloc.c |    2 --
 2 files changed, 2 deletions(-)

diff -puN arch/i386/kernel/setup.c~A2.2-dont-memset-pgdats arch/i386/kernel/setup.c
diff -puN arch/i386/mm/discontig.c~A2.2-dont-memset-pgdats arch/i386/mm/discontig.c
diff -puN include/asm-i386/mmzone.h~A2.2-dont-memset-pgdats include/asm-i386/mmzone.h
diff -puN mm/page_alloc.c~A2.2-dont-memset-pgdats mm/page_alloc.c
--- sparse/mm/page_alloc.c~A2.2-dont-memset-pgdats	2005-02-24 08:56:39.000000000 -0800
+++ sparse-dave/mm/page_alloc.c	2005-02-24 08:56:39.000000000 -0800
@@ -1397,7 +1397,6 @@ static void __init build_zonelists(pg_da
 	/* initialize zonelists */
 	for (i = 0; i < GFP_ZONETYPES; i++) {
 		zonelist = pgdat->node_zonelists + i;
-		memset(zonelist, 0, sizeof(*zonelist));
 		zonelist->zones[0] = NULL;
 	}
 
@@ -1444,7 +1443,6 @@ static void __init build_zonelists(pg_da
 		struct zonelist *zonelist;
 
 		zonelist = pgdat->node_zonelists + i;
-		memset(zonelist, 0, sizeof(*zonelist));
 
 		j = 0;
 		k = ZONE_NORMAL;
diff -puN arch/i386/mm/init.c~A2.2-dont-memset-pgdats arch/i386/mm/init.c
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
