Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4AE7A6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 22:31:40 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9580149dak.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 19:31:39 -0700 (PDT)
Date: Mon, 18 Jun 2012 19:31:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, oom: do not schedule if current has been killed
In-Reply-To: <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

The oom killer currently schedules away from current in an
uninterruptible sleep if it does not have access to memory reserves.
It's possible that current was killed because it shares memory with the
oom killed thread or because it was killed by the user in the interim,
however.

This patch only schedules away from current if it does not have a pending
kill, i.e. if it does not share memory with the oom killed thread, or is
already exiting.  It's possible that it will immediately retry its memory
allocation and fail, but it will immediately be given access to memory
reserves if it calls the oom killer again.

This prevents the delay of memory freeing when threads that share memory
with the oom killed thread get unnecessarily scheduled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -746,10 +746,11 @@ out:
 	read_unlock(&tasklist_lock);
 
 	/*
-	 * Give "p" a good chance of killing itself before we
+	 * Give "p" a good chance of exiting before we
 	 * retry to allocate memory unless "p" is current
 	 */
-	if (killed && !test_thread_flag(TIF_MEMDIE))
+	if (killed && !fatal_signal_pending(current) &&
+		      !(current->flags & PF_EXITING))
 		schedule_timeout_uninterruptible(1);
 }
 
@@ -765,6 +766,6 @@ void pagefault_out_of_memory(void)
 		out_of_memory(NULL, 0, 0, NULL, false);
 		clear_system_oom();
 	}
-	if (!test_thread_flag(TIF_MEMDIE))
+	if (!fatal_signal_pending(current) && !(current->flags & PF_EXITING))
 		schedule_timeout_uninterruptible(1);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
