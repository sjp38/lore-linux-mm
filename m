Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7FD6B5F0040
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 00:55:16 -0400 (EDT)
Date: Fri, 22 Oct 2010 12:55:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] mm: Avoid possible deadlock caused by too_many_isolated()
Message-ID: <20101022045509.GA16804@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Neil find that if too_many_isolated() returns true while performing
direct reclaim we can end up waiting for other threads to complete their
direct reclaim.  If those threads are allowed to enter the FS or IO to
free memory, but this thread is not, then it is possible that those
threads will be waiting on this thread and so we get a circular
deadlock.

some task enters direct reclaim with GFP_KERNEL
  => too_many_isolated() false
    => vmscan and run into dirty pages
      => pageout()
        => take some FS lock
	  => fs/block code does GFP_NOIO allocation
	    => enter direct reclaim again
	      => too_many_isolated() true
		  => waiting for others to progress, however the other
		     tasks may be circular waiting for the FS lock..

The fix is to let !__GFP_IO and !__GFP_FS direct reclaims enjoy higher
priority than normal ones, by lowering the throttle threshold for the
latter.

Allowing ~1/8 isolated pages in normal is large enough. For example,
for a 1GB LRU list, that's ~128MB isolated pages, or 1k blocked tasks
(each isolates 32 4KB pages), or 64 blocked tasks per logical CPU
(assuming 16 logical CPUs per NUMA node). So it's not likely some CPU
goes idle waiting (when it could make progress) because of this limit:
there are much more sleeping reclaim tasks than the number of CPU, so
the task may well be blocked by some low level queue/lock anyway.

Now !GFP_IOFS reclaims won't be waiting for GFP_IOFS reclaims to
progress. They will be blocked only when there are too many concurrent
!GFP_IOFS reclaims, however that's very unlikely because the IO-less
direct reclaims is able to progress much more faster, and they won't
deadlock each other. The threshold is raised high enough for them, so
that there can be sufficient parallel progress of !GFP_IOFS reclaims.

CC: Torsten Kaiser <just.for.lkml@googlemail.com>
CC: Minchan Kim <minchan.kim@gmail.com>
Tested-by: NeilBrown <neilb@suse.de>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- linux-next.orig/mm/vmscan.c	2010-10-13 12:35:14.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-10-19 00:13:04.000000000 +0800
@@ -1163,6 +1163,13 @@ static int too_many_isolated(struct zone
 		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
 	}
 
+	/*
+	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so that
+	 * they won't get blocked by normal ones and form circular deadlock.
+	 */
+	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
+		inactive >>= 3;
+
 	return isolated > inactive;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
