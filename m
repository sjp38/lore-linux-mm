Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 319F76B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 01:14:54 -0500 (EST)
Date: Fri, 2 Mar 2012 14:14:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] mm: use global_dirty_limit in throttle_vm_writeout()
Message-ID: <20120302061451.GA6468@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When starting a memory hog task, a desktop box w/o swap is found to go
unresponsive for a long time. It's solely caused by lots of congestion
waits in throttle_vm_writeout():

 gnome-system-mo-4201 553.073384: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
 gnome-system-mo-4201 553.073386: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
           gtali-4237 553.080377: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
           gtali-4237 553.080378: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
            Xorg-3483 553.103375: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
            Xorg-3483 553.103377: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000

The root cause is, the dirty threshold is knocked down a lot by the
memory hog task. Fixed by using global_dirty_limit which decreases
gradually on such events and can guarantee we stay above (the also
decreasing) nr_dirty in the progress of following down to the new
dirty threshold.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    1 +
 1 file changed, 1 insertion(+)

--- linux.orig/mm/page-writeback.c	2012-03-02 14:05:01.633763187 +0800
+++ linux/mm/page-writeback.c	2012-03-02 14:11:52.929772962 +0800
@@ -1472,6 +1472,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
+		dirty_thresh = hard_dirty_limit(dirty_thresh);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
