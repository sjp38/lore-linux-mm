Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29DC56B002C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 22:56:21 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p982uIE3030547
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 19:56:18 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by hpaq12.eem.corp.google.com with ESMTP id p982uFS0015065
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 7 Oct 2011 19:56:16 -0700
Received: by pzk33 with SMTP id 33so16918213pzk.8
        for <linux-mm@kvack.org>; Fri, 07 Oct 2011 19:56:15 -0700 (PDT)
Date: Fri, 7 Oct 2011 19:56:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch resend] oom: thaw threads if oom killed thread is frozen
 before deferring
Message-ID: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
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
 mm/oom_kill.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -318,8 +318,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
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
