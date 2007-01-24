Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l0P0ZEKL6336548
	for <linux-mm@kvack.org>; Wed, 24 Jan 2007 23:35:19 -0100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0OCb4t3244238
	for <linux-mm@kvack.org>; Wed, 24 Jan 2007 23:37:05 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0OCXZC3019316
	for <linux-mm@kvack.org>; Wed, 24 Jan 2007 23:33:35 +1100
Message-ID: <45B75208.90208@linux.vnet.ibm.com>
Date: Wed, 24 Jan 2007 18:03:12 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Christoph Lameter wrote:
> This is a patch using some of Aubrey's work plugging it in what is IMHO
> the right way. Feel free to improve on it. I have gotten repeatedly
> requests to be able to limit the pagecache. With the revised VM statistics
> this is now actually possile. I'd like to know more about possible uses of
> such a feature.
> 
> 

[snip]

Hi Christoph,

With your patch, MMAP of a file that will cross the pagecache limit hangs the
system.  As I mentioned in my previous mail, without subtracting the
NR_FILE_MAPPED, the reclaim will infinitely try and fail.

I have tested your patch with the attached fix on my PPC64 box.

Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>

---
 mm/page_alloc.c |    3 ++-
 mm/vmscan.c     |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

--- linux-2.6.20-rc5.orig/mm/page_alloc.c
+++ linux-2.6.20-rc5/mm/page_alloc.c
@@ -1171,7 +1171,8 @@ zonelist_scan:
                                goto try_next_zone;

                if ((gfp_mask & __GFP_PAGECACHE) &&
-                               zone_page_state(zone, NR_FILE_PAGES) >
+                               (zone_page_state(zone, NR_FILE_PAGES) -
+                                zone_page_state(zone, NR_FILE_MAPPED)) >
                                        zone->max_pagecache_pages)
                                goto try_next_zone;

--- linux-2.6.20-rc5.orig/mm/vmscan.c
+++ linux-2.6.20-rc5/mm/vmscan.c
@@ -936,7 +936,8 @@ static unsigned long shrink_zone(int pri
         * If the page cache is too big then focus on page cache
         * and ignore anonymous pages
         */
-       if (sc->may_swap && zone_page_state(zone, NR_FILE_PAGES)
+       if (sc->may_swap && (zone_page_state(zone, NR_FILE_PAGES) -
+                       zone_page_state(zone, NR_FILE_MAPPED))
                        > zone->max_pagecache_pages)
                sc->may_swap = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
