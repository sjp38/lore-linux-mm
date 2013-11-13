Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 102146B00AA
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 21:02:23 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so169452pbc.40
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:02:23 -0800 (PST)
Received: from psmtp.com ([74.125.245.117])
        by mx.google.com with SMTP id ws5si1585337pab.35.2013.11.12.18.02.21
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 18:02:22 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id ld10so3173000pab.20
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 18:02:20 -0800 (PST)
Date: Tue, 12 Nov 2013 18:02:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, vmscan: abort futile reclaim if we've been oom killed
Message-ID: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The oom killer is only invoked when reclaim has already failed and it
only kills processes if the victim is also oom.  In other words, the oom
killer does not select victims when a process tries to allocate from a
disjoint cpuset or allocate DMA memory, for example.

Therefore, it's pointless for an oom killed process to continue
attempting to reclaim memory in a loop when it has been granted access to
memory reserves.  It can simply return to the page allocator and allocate
memory.

If there is a very large number of processes trying to reclaim memory,
the cond_resched() in shrink_slab() becomes troublesome since it always
forces a schedule to other processes also trying to reclaim memory.
Compounded by many reclaim loops, it is possible for a process to sit in
do_try_to_free_pages() for a very long time when reclaim is pointless and
it could allocate if it just returned to the page allocator.

This patch checks if current has been oom killed and, if so, aborts
futile reclaim immediately.  We're not concerned with complete depletion
of memory reserves since there's nothing else we can do.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/vmscan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2428,6 +2428,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			goto out;
 
 		/*
+		 * If we've been oom killed, reclaim has already failed.  We've
+		 * been given access to memory reserves so that we can allocate
+		 * and quickly die, so just abort futile efforts.
+		 */
+		if (unlikely(test_thread_flag(TIF_MEMDIE)))
+			aborted_reclaim = true;
+
+		/*
 		 * If we're getting trouble reclaiming, start doing
 		 * writepage even in laptop mode.
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
