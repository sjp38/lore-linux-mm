Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 86CD66B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 03:31:18 -0400 (EDT)
Subject: [PATCH] oom: skip frozen tasks
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 23 Aug 2011 11:31:01 +0300
Message-ID: <20110823073101.6426.77745.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

All frozen tasks are unkillable, and if one of them has TIF_MEMDIE
we must kill something else to avoid deadlock. After this patch
select_bad_process() will skip frozen task before checking TIF_MEMDIE.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/oom_kill.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 626303b..931ab20 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -138,6 +138,8 @@ static bool oom_unkillable_task(struct task_struct *p,
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
+	if (p->flags & PF_FROZEN)
+		return true;
 
 	/* When mem_cgroup_out_of_memory() and p is not member of the group */
 	if (mem && !task_in_mem_cgroup(p, mem))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
