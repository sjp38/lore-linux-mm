Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA18817
	for <linux-mm@kvack.org>; Wed, 15 Jul 1998 12:57:14 -0400
Received: from boole.suse.de (Boole.suse.de [192.168.102.7])
	by Galois.suse.de (8.8.8/8.8.8) with ESMTP id SAA15830
	for <linux-mm@kvack.org>; Wed, 15 Jul 1998 18:56:20 +0200
Message-ID: <19980715185619.49044@boole.suse.de>
Date: Wed, 15 Jul 1998 18:56:19 +0200
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: [PATCH] stricter pagecache pruning
References: <Pine.LNX.3.96.980711092706.5292B-200000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.980711092706.5292B-200000@mirkwood.dummy.home>; from Rik van Riel on Sat, Jul 11, 1998 at 09:31:26AM +0200
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 11, 1998 at 09:31:26AM +0200, Rik van Riel wrote:
> Hi,
> 
> I hope this patch will alleviate some of Andrea's
> problems with the page cache growing out of bounds.
> 
> It makes sure that, when the cache uses too much,
> shrink_mmap() is called continuously; only the
> last thing tried can be something else.
> 
> I'd like to hear some results, as I haven't tried
> it myself ... It seems obvious enough, so it would
> probably be best if it's tried ASAP with as many
> different machines/loads as possible.

Your patch has one side effect ... it reduces the scans of the
other possibilies, to be more precisely, the scanning of the dcache
should also be forced.

A few weeks ago I've send a simple patch which may reduce
the problem. The part in there was:

--------------------------------------------------------
diff -urN linux-2.1.103/mm/vmscan.c linux/mm/vmscan.c
--- linux-2.1.103/mm/vmscan.c	Sun May  3 02:44:59 1998
+++ linux/mm/vmscan.c	Mon Jun  8 15:46:11 1998
@@ -28,6 +28,9 @@
 #include <asm/bitops.h>
 #include <asm/pgtable.h>
 
+extern int inodes_stat[];
+extern int dentry_stat[];
+
 /* 
  * When are we next due for a page scan? 
  */
@@ -446,11 +449,13 @@
 
 	/* We try harder if we are waiting .. */
 	stop = 3;
-	if (gfp_mask & __GFP_WAIT)
+	if (gfp_mask & __GFP_WAIT || nr_free_pages <= freepages.min);
 		stop = 0;
 	if (((buffermem >> PAGE_SHIFT) * 100 > buffer_mem.borrow_percent * num_physpages)
 		   || (page_cache_size * 100 > page_cache.borrow_percent * num_physpages))
 		state = 0;
+	else if (dentry_stat[0] > 3*(inodes_stat[0] >> 1))
+		state = 3;
 
 	switch (state) {
 		do {
--------------------------------------------------------

Let's combine this with yours :-)


        Werner
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
