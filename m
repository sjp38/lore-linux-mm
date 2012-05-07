Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 65B896B0083
	for <linux-mm@kvack.org>; Mon,  7 May 2012 15:32:06 -0400 (EDT)
Date: Mon, 7 May 2012 14:32:03 -0500
From: Russ Anderson <rja@sgi.com>
Subject: [patch] mm: nobootmem: fix sign extend problem in __free_pages_memory()
Message-ID: <20120507193202.GA11518@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, David Miller <davem@davemloft.net>
Cc: Russ Anderson <rja@sgi.com>

Systems with 8 TBytes of memory or greater can hit a problem 
where only the the first 8 TB of memory shows up.  This is
due to "int i" being smaller than "unsigned long start_aligned",
causing the high bits to be dropped.

The fix is to change i to unsigned long to match start_aligned
and end_aligned.

Thanks to Jack Steiner (steiner@sgi.com) for assistance tracking
this down.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 mm/nobootmem.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux/mm/nobootmem.c
===================================================================
--- linux.orig/mm/nobootmem.c	2012-05-05 08:39:39.470845187 -0500
+++ linux/mm/nobootmem.c	2012-05-05 08:39:42.714784530 -0500
@@ -82,8 +82,7 @@ void __init free_bootmem_late(unsigned l
 
 static void __init __free_pages_memory(unsigned long start, unsigned long end)
 {
-	int i;
-	unsigned long start_aligned, end_aligned;
+	unsigned long i, start_aligned, end_aligned;
 	int order = ilog2(BITS_PER_LONG);
 
 	start_aligned = (start + (BITS_PER_LONG - 1)) & ~(BITS_PER_LONG - 1);
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
