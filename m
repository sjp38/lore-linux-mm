Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9061B6B03CE
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 17:00:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m28so15300763pgn.14
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 14:00:08 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id n1si21600163pge.422.2017.04.05.14.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 14:00:07 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id 21so15505290pgg.1
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 14:00:07 -0700 (PDT)
Date: Wed, 5 Apr 2017 13:59:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Is it safe for kthreadd to drain_all_pages?
Message-ID: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Mel,

I suspect that it's not safe for kthreadd to drain_all_pages();
but I haven't studied flush_work() etc, so don't really know what
I'm talking about: hoping that you will jump to a realization.

4.11-rc has been giving me hangs after hours of swapping load.  At
first they looked like memory leaks ("fork: Cannot allocate memory");
but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
before looking at /proc/meminfo one time, and the stat_refresh stuck
in D state, waiting for completion of flush_work like many kworkers.
kthreadd waiting for completion of flush_work in drain_all_pages().

But I only noticed that pattern later: originally tried to bisect
rc1 before rc2 came out, but underestimated how long to wait before
deciding a stage good - I thought 12 hours, but would now say 2 days.
Too late for bisection, I suspect your drain_all_pages() changes.

(I've also found order:0 page allocation stalls in /var/log/messages,
148804ms a nice example: which suggest that these hangs are perhaps a
condition it can sometimes get out of itself.  None with the patch.)

Patch below has been running well for 36 hours now:
a bit too early to be sure, but I think it's time to turn to you.


[PATCH] mm: don't let kthreadd drain_all_pages

4.11-rc has been giving me hangs after many hours of swapping load: most
kworkers waiting for completion of a flush_work, kthreadd waiting for
completion of flush_work in drain_all_pages (while doing copy_process).
I suspect that kthreadd should not be allowed to drain_all_pages().

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/page_alloc.c |    2 ++
 1 file changed, 2 insertions(+)

--- 4.11-rc5/mm/page_alloc.c	2017-03-13 09:08:37.743209168 -0700
+++ linux/mm/page_alloc.c	2017-04-04 00:33:44.086867413 -0700
@@ -2376,6 +2376,8 @@ void drain_all_pages(struct zone *zone)
 	/* Workqueues cannot recurse */
 	if (current->flags & PF_WQ_WORKER)
 		return;
+	if (current == kthreadd_task)
+		return;
 
 	/*
 	 * Do not drain if one is already in progress unless it's specific to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
