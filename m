Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A23B96B004D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 14:05:21 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 82E9782C2A9
	for <linux-mm@kvack.org>; Tue, 26 May 2009 14:19:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lpqB4Zy8XzF6 for <linux-mm@kvack.org>;
	Tue, 26 May 2009 14:19:25 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6CB6282C38F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 14:18:40 -0400 (EDT)
Date: Tue, 26 May 2009 14:04:35 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Use integer fields lookup for gfp_zone and check for
 errors in flags passed to the page allocator
In-Reply-To: <20090525113004.GD12160@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0905261401100.5632@gentwo.org>
References: <alpine.DEB.1.10.0905221438120.5515@qirst.com> <20090525113004.GD12160@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 May 2009, Mel Gorman wrote:

> I expect that the machine would start running into reclaim issues with
> enough uptime because it'll not be using Highmem as it should. Similarly,
> the GFP_DMA32 may also be a problem as the new implementation is going
> ZONE_DMA when ZONE_NORMAL would have been ok in this case.

Right. The fallback for DMA32 is wrong. Should fall back to ZONE_NORMAL.
Not to DMA. And the config variable to check for highmem was wrong.


Subject: Fix gfp zone patch

1. If there is no DMA32 fall back to NORMAL instead of DMA

2. Use the correct config variable for HIGHMEM

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>


---
 include/linux/gfp.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2009-05-26 12:59:19.000000000 -0500
+++ linux-2.6/include/linux/gfp.h	2009-05-26 12:59:31.000000000 -0500
@@ -112,7 +112,7 @@ static inline int allocflags_to_migratet
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }

-#ifdef CONFIG_ZONE_HIGHMEM
+#ifdef CONFIG_HIGHMEM
 #define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
 #else
 #define OPT_ZONE_HIGHMEM ZONE_NORMAL
@@ -127,7 +127,7 @@ static inline int allocflags_to_migratet
 #ifdef CONFIG_ZONE_DMA32
 #define OPT_ZONE_DMA32 ZONE_DMA32
 #else
-#define OPT_ZONE_DMA32 OPT_ZONE_DMA
+#define OPT_ZONE_DMA32 ZONE_NORMAL
 #endif

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
