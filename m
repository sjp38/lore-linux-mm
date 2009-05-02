Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A09946B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 22:47:11 -0400 (EDT)
Date: Sat, 2 May 2009 10:47:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] vmscan: don't export nr_saved_scan in /proc/zoneinfo
Message-ID: <20090502024719.GA29730@localhost>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org> <20090501012212.GA5848@localhost> <20090430194907.82b31565.akpm@linux-foundation.org> <20090502023125.GA29674@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090502023125.GA29674@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

The lru->nr_saved_scan's are not meaningful counters for even kernel
developers.  They typically are smaller than 32 and are always 0 for
large lists. So remove them from /proc/zoneinfo.

Hopefully this interface change won't break too many scripts.
/proc/zoneinfo is too unstructured to be script friendly, and I wonder
the affected scripts - if there are any - are still bleeding since the
not long ago commit "vmscan: split LRU lists into anon & file sets",
which also touched the "scanned" line :)

If we are to re-export accumulated vmscan counts in the future, they
can go to new lines in /proc/zoneinfo instead of the current form, or
to /sys/devices/system/node/node0/meminfo?

CC: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmstat.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- mm.orig/mm/vmstat.c
+++ mm/mm/vmstat.c
@@ -721,7 +721,7 @@ static void zoneinfo_show_print(struct s
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n        scanned  %lu (aa: %lu ia: %lu af: %lu if: %lu)"
+		   "\n        scanned  %lu"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
@@ -729,10 +729,6 @@ static void zoneinfo_show_print(struct s
 		   zone->pages_low,
 		   zone->pages_high,
 		   zone->pages_scanned,
-		   zone->lru[LRU_ACTIVE_ANON].nr_saved_scan,
-		   zone->lru[LRU_INACTIVE_ANON].nr_saved_scan,
-		   zone->lru[LRU_ACTIVE_FILE].nr_saved_scan,
-		   zone->lru[LRU_INACTIVE_FILE].nr_saved_scan,
 		   zone->spanned_pages,
 		   zone->present_pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
