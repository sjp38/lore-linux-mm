Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6786B01F1
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:44:43 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o31Jiffu014451
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:44:41 -0700
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by kpbe11.cbf.corp.google.com with ESMTP id o31JiX2F002703
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 14:44:40 -0500
Received: by pwi2 with SMTP id 2so1716875pwi.0
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:44:33 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:44:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/5 v2] oom: give current access to memory reserves if
 it has been killed
In-Reply-To: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004011243020.13247@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004011240370.13247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's possible to livelock the page allocator if a thread has mm->mmap_sem and 
fails to make forward progress because the oom killer selects another thread 
sharing the same ->mm to kill that cannot exit until the semaphore is dropped.

The oom killer will not kill multiple tasks at the same time; each oom killed 
task must exit before another task may be killed.  Thus, if one thread is 
holding mm->mmap_sem and cannot allocate memory, all threads sharing the same 
->mm are blocked from exiting as well.  In the oom kill case, that means the
thread holding mm->mmap_sem will never free additional memory since it cannot
get access to memory reserves and the thread that depends on it with access to
memory reserves cannot exit because it cannot acquire the semaphore.  Thus,
the page allocators livelocks.

When the oom killer is called and current happens to have a pending SIGKILL,
this patch automatically gives it access to memory reserves and returns.  Upon
returning to the page allocator, its allocation will hopefully succeed so it
can quickly exit and free its memory.  If not, the page allocator will fail
the allocation if it is not __GFP_NOFAIL.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -679,6 +679,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		return;
 
 	/*
+	 * If current has a pending SIGKILL, then automatically select it.  The
+	 * goal is to allow it to allocate so that it may quickly exit and free
+	 * its memory.
+	 */
+	if (fatal_signal_pending(current)) {
+		set_tsk_thread_flag(current, TIF_MEMDIE);
+		return;
+	}
+
+	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
