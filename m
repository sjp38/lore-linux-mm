Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j0Q0No8S017707
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 19:23:50 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0Q0NoEr077564
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 19:23:50 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j0Q0Nnep020751
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 19:23:49 -0500
Subject: [RFC][PATCH 5/5] do not unnecessarily memset the pgdats
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 25 Jan 2005 16:23:48 -0800
Message-Id: <E1CtayL-00077d-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
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

 arch/i386/mm/init.c             |    0 
 memhotplug-dave/mm/page_alloc.c |    2 --
 2 files changed, 2 deletions(-)

diff -puN arch/i386/kernel/setup.c~A2.2-dont-memset-pgdats arch/i386/kernel/setup.c
diff -puN arch/i386/mm/discontig.c~A2.2-dont-memset-pgdats arch/i386/mm/discontig.c
diff -puN include/asm-i386/mmzone.h~A2.2-dont-memset-pgdats include/asm-i386/mmzone.h
diff -puN mm/page_alloc.c~A2.2-dont-memset-pgdats mm/page_alloc.c
--- memhotplug/mm/page_alloc.c~A2.2-dont-memset-pgdats	2005-01-25 14:23:52.000000000 -0800
+++ memhotplug-dave/mm/page_alloc.c	2005-01-25 14:23:52.000000000 -0800
@@ -1488,7 +1488,6 @@ static void __init build_zonelists(pg_da
 	/* initialize zonelists */
 	for (i = 0; i < GFP_ZONETYPES; i++) {
 		zonelist = pgdat->node_zonelists + i;
-		memset(zonelist, 0, sizeof(*zonelist));
 		zonelist->zones[0] = NULL;
 	}
 
@@ -1535,7 +1534,6 @@ static void __init build_zonelists(pg_da
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
