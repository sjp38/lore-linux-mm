Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 175556B01D0
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:18 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o593xCDg016103
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:13 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by wpaz29.hot.corp.google.com with ESMTP id o593xBrA012106
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:11 -0700
Received: by pxi2 with SMTP id 2so2116249pxi.4
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:10 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/6] oom: dump_tasks use find_lock_task_mm too fix
In-Reply-To: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082057300.6219@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


When find_lock_task_mm() returns a thread other than p in dump_tasks(),
its name should be displayed instead.  This is the thread that will be
targeted by the oom killer, not its mm-less parent.

This also allows us to safely dereference task->comm without needing
get_task_comm().

While we're here, remove the cast on task_cpu(task) as Andrew suggested.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -376,10 +376,10 @@ static void dump_tasks(const struct mem_cgroup *mem)
 			continue;
 		}
 
-		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
+		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3u     %3d %s\n",
 		       task->pid, __task_cred(task)->uid, task->tgid,
 		       task->mm->total_vm, get_mm_rss(task->mm),
-		       (int)task_cpu(task), task->signal->oom_adj, p->comm);
+		       task_cpu(task), task->signal->oom_adj, task->comm);
 		task_unlock(task);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
