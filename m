Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 24FBD6B01D2
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:27:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o536RWYY010432
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 15:27:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C573345DE51
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:27:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 954CA45DE50
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:27:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78EF61DB8050
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:27:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FFE61DB8044
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:27:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 12/12] oom: give current access to memory reserves if it has been killed
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603152653.726B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 15:27:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: David Rientjes <rientjes@google.com>

It's possible to livelock the page allocator if a thread has
mm->mmap_sem and fails to make forward progress because the
oom killer selects another thread sharing the same ->mm to
kill that cannot exit until the semaphore is dropped.

The oom killer will not kill multiple tasks at the same time; each oom
killed task must exit before another task may be killed.  Thus, if one
thread is holding mm->mmap_sem and cannot allocate memory, all threads
sharing the same ->mm are blocked from exiting as well.  In the oom kill
case, that means the thread holding mm->mmap_sem will never free
additional memory since it cannot get access to memory reserves and the
thread that depends on it with access to memory reserves cannot exit
because it cannot acquire the semaphore.  Thus, the page allocators
livelocks.

When the oom killer is called and current happens to have a pending
SIGKILL, this patch automatically gives it access to memory reserves and
returns.  Upon returning to the page allocator, its allocation will
hopefully succeed so it can quickly exit and free its memory.  If not,
the page allocator will fail the allocation if it is not __GFP_NOFAIL.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 67b5fa5..ad85e1b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -638,6 +638,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	}
 
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
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
