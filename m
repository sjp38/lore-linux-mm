Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5Q9OAqW010897
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:24:10 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5Q9SwlB176982
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 03:28:58 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5Q9Svsu021865
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 03:28:57 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 14:58:55 +0530
Message-Id: <20080626092855.16841.52723.sendpatchset@balbir-laptop>
In-Reply-To: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
References: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
Subject: [3/5] memrlimit fix sleep inside sleeplock in mm_update_next_owner()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


We have a sleep inside a spinlock (read side locking of tasklist_lock). We
try to acquire mmap_sem without releasing the read_lock. Since we have
the task_struct of the new process, we can release the read_lock, before
acquiring the task_lock of the chosen one.

Reported-by: Hugh Dickins <hugh@veritas.com>



Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 kernel/exit.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff -puN kernel/exit.c~memrlimit-fix-sleep-in-spinlock-bug kernel/exit.c
--- linux-2.6.26-rc5/kernel/exit.c~memrlimit-fix-sleep-in-spinlock-bug	2008-06-26 14:48:21.000000000 +0530
+++ linux-2.6.26-rc5-balbir/kernel/exit.c	2008-06-26 14:48:21.000000000 +0530
@@ -636,28 +636,24 @@ retry:
 assign_new_owner:
 	BUG_ON(c == p);
 	get_task_struct(c);
+	read_unlock(&tasklist_lock);
 	down_write(&mm->mmap_sem);
 	/*
 	 * The task_lock protects c->mm from changing.
 	 * We always want mm->owner->mm == mm
 	 */
 	task_lock(c);
-	/*
-	 * Delay read_unlock() till we have the task_lock()
-	 * to ensure that c does not slip away underneath us
-	 */
-	read_unlock(&tasklist_lock);
 	if (c->mm != mm) {
 		task_unlock(c);
-		put_task_struct(c);
 		up_write(&mm->mmap_sem);
+		put_task_struct(c);
 		goto retry;
 	}
 	cgroup_mm_owner_callbacks(mm->owner, c);
 	mm->owner = c;
 	task_unlock(c);
-	put_task_struct(c);
 	up_write(&mm->mmap_sem);
+	put_task_struct(c);
 }
 #endif /* CONFIG_MM_OWNER */
 
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
