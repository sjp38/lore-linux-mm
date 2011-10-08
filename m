Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2A06B002C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 22:59:57 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p982xrGH001591
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 19:59:53 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz29.hot.corp.google.com with ESMTP id p982xFEw031104
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 19:59:51 -0700
Received: by pzk5 with SMTP id 5so15682190pzk.1
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 19:59:51 -0700 (PDT)
Date: Fri, 7 Oct 2011 19:59:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] oom: thaw threads if oom killed thread is frozen before
 deferring
In-Reply-To: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

If a thread has been oom killed and is frozen, thaw it before returning
to the page allocator.  Otherwise, it can stay frozen indefinitely and
no memory will be freed.

Reported-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: adds the missing header file include, the resend patch was based on a 
     previous patch from Michal that is no longer needed if this is 
     applied.

 mm/oom_kill.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 626303b..d897262 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,6 +32,7 @@
 #include <linux/mempolicy.h>
 #include <linux/security.h>
 #include <linux/ptrace.h>
+#include <linux/freezer.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -317,8 +318,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * blocked waiting for another task which itself is waiting
 		 * for memory. Is there a better alternative?
 		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			if (unlikely(frozen(p)))
+				thaw_process(p);
 			return ERR_PTR(-1UL);
+		}
 		if (!p->mm)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
