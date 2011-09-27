Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC6E89000C4
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:10:57 -0400 (EDT)
Message-Id: <65d9dff7ff78fad1f146e71d32f9f92741281b46.1317110948.git.mhocko@suse.cz>
In-Reply-To: <cover.1317110948.git.mhocko@suse.cz>
References: <cover.1317110948.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Tue, 27 Sep 2011 10:01:47 +0200
Subject: [PATCH 2/2] oom: do not live lock on frozen tasks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Konstantin Khlebnikov has reported (https://lkml.org/lkml/2011/8/23/45)
that OOM can end up in a live lock if select_bad_process picks up a frozen
task.
Unfortunately we cannot mark such processes as unkillable to ignore them
because we could panic the system even though there is a chance that
somebody could thaw the process so we can make a forward process (e.g. a
process from another cpuset or with a different nodemask).

Let's thaw an OOM selected frozen process right after we've sent fatal
signal from oom_kill_task.
Thawing is safe if the frozen task doesn't access any suspended device
(e.g. by ioctl) on the way out to the userspace where we handle the
signal and die. Note, we are not interested in the kernel threads because
they are not oom killable.

Accessing suspended devices by a userspace processes shouldn't be an
issue because devices are suspended only after userspace is already
frozen and oom is disabled at that time.

Other than that userspace accesses the fridge only from the
signal handling routines so we are able to handle SIGKILL without any
negative side effects or we always check for pending signals after
we return from try_to_freeze (e.g. in lguest).

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 626303b..c419a7e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,6 +32,7 @@
 #include <linux/mempolicy.h>
 #include <linux/security.h>
 #include <linux/ptrace.h>
+#include <linux/freezer.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -451,10 +452,15 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 				task_pid_nr(q), q->comm);
 			task_unlock(q);
 			force_sig(SIGKILL, q);
+
+			if (frozen(q))
+				thaw_process(q);
 		}
 
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 	force_sig(SIGKILL, p);
+	if (frozen(p))
+		thaw_process(p);
 
 	return 0;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
