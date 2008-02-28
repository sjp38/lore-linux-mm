Message-Id: <20080228192908.126720629@redhat.com>
Date: Thu, 28 Feb 2008 14:29:08 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 00/21] VM pageout scalability improvements
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On large memory systems, the VM can spend way too much time scanning
through pages that it cannot (or should not) evict from memory. Not
only does it use up CPU time, but it also provokes lock contention
and can leave large systems under memory presure in a catatonic state.

Against 2.6.24-rc6-mm1

This patch series improves VM scalability by:

1) making the locking a little more scalable

2) putting filesystem backed, swap backed and non-reclaimable pages
   onto their own LRUs, so the system only scans the pages that it
   can/should evict from memory

3) switching to SEQ replacement for the anonymous LRUs, so the
   number of pages that need to be scanned when the system
   starts swapping is bound to a reasonable number

More info on the overall design can be found at:

	http://linux-mm.org/PageReplacementDesign


Changelog:
- pull the memcontrol lru arrayification earlier into the patch series
- use a pagevec array similar to the lru array
- clean up the code in various places
- improved pageout balancing and reduced pageout cpu use

- fix compilation on PPC and without memcontrol
- make page_is_pagecache more readable
- replace get_scan_ratio with correct version

- merge memcontroller split LRU code into the main split LRU patch,
  since it is not functionally different (it was split up only to help
  people who had seen the last version of the patch series review it)
- drop the page_file_cache debugging patch, since it never triggered
- reintroduce code to not scan anon list if swap is full
- add code to scan anon list if page cache is very small already
- use lumpy reclaim more aggressively for smaller order > 1 allocations

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
