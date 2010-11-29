Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9E55E6B0096
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 05:38:49 -0500 (EST)
Date: Mon, 29 Nov 2010 18:38:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [BUGFIX] vmstat: fix dirty threshold ordering
Message-ID: <20101129103845.GA1195@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rubin <mrubin@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The nr_dirty_[background_]threshold fields are misplaced before the
numa_* fields, and users will read strange values.

This is the right order. Before patch, nr_dirty_background_threshold
will read as 0 (the value from numa_miss).

	numa_hit 128501
	numa_miss 0
	numa_foreign 0
	numa_interleave 7388
	numa_local 128501
	numa_other 0
	nr_dirty_threshold 144291
	nr_dirty_background_threshold 72145

Cc: Michael Rubin <mrubin@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmstat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/vmstat.c	2010-11-28 16:02:12.000000000 +0800
+++ linux-next/mm/vmstat.c	2010-11-28 16:02:24.000000000 +0800
@@ -750,8 +750,6 @@ static const char * const vmstat_text[] 
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
-	"nr_dirty_threshold",
-	"nr_dirty_background_threshold",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",
@@ -761,6 +759,8 @@ static const char * const vmstat_text[] 
 	"numa_local",
 	"numa_other",
 #endif
+	"nr_dirty_threshold",
+	"nr_dirty_background_threshold",
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
