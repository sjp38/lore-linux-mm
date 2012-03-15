Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 0A4B56B0044
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 22:15:12 -0400 (EDT)
Received: by dakn40 with SMTP id n40so4056297dak.9
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 19:15:12 -0700 (PDT)
Date: Wed, 14 Mar 2012 19:15:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, coredump: fail allocations when coredumping instead of
 oom killing
Message-ID: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

The size of coredump files is limited by RLIMIT_CORE, however, allocating
large amounts of memory results in three negative consequences:

 - the coredumping process may be chosen for oom kill and quickly deplete
   all memory reserves in oom conditions preventing further progress from
   being made or tasks from exiting,

 - the coredumping process may cause other processes to be oom killed
   without fault of their own as the result of a SIGSEGV, for example, in
   the coredumping process, or

 - the coredumping process may result in a livelock while writing to the
   dump file if it needs memory to allocate while other threads are in
   the exit path waiting on the coredumper to complete.

This is fixed by implying __GFP_NORETRY in the page allocator for
coredumping processes when reclaim has failed so the allocations fail and
the process continues to exit.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2306,6 +2306,10 @@ rebalance:
 		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
 			if (oom_killer_disabled)
 				goto nopage;
+			/* Coredumps can quickly deplete all memory reserves */
+			if ((current->flags & PF_DUMPCORE) &&
+			    !(gfp_mask & __GFP_NOFAIL))
+				goto nopage;
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask, preferred_zone,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
