Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 06FCB6B01EF
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:45:41 -0400 (EDT)
Date: Tue, 30 Mar 2010 19:43:37 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
Message-ID: <20100330174337.GA21663@redhat.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100330163909.GA16884@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

->siglock is no longer needed to access task->signal, change
oom_adjust_read() and oom_adjust_write() to read/write oom_adj
lockless.

Yes, this means that "echo 2 >oom_adj" and "echo 1 >oom_adj"
can race and the second write can win, but I hope this is OK.

Also, cleanup the EACCES case a bit.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/proc/base.c |   28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

--- 34-rc1/fs/proc/base.c~PROC_5_OOM_ADJ	2010-03-30 18:23:50.000000000 +0200
+++ 34-rc1/fs/proc/base.c	2010-03-30 19:14:43.000000000 +0200
@@ -981,22 +981,16 @@ static ssize_t oom_adjust_read(struct fi
 {
 	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
 	char buffer[PROC_NUMBUF];
+	int oom_adjust;
 	size_t len;
-	int oom_adjust = OOM_DISABLE;
-	unsigned long flags;
 
 	if (!task)
 		return -ESRCH;
 
-	if (lock_task_sighand(task, &flags)) {
-		oom_adjust = task->signal->oom_adj;
-		unlock_task_sighand(task, &flags);
-	}
-
+	oom_adjust = task->signal->oom_adj;
 	put_task_struct(task);
 
 	len = snprintf(buffer, sizeof(buffer), "%i\n", oom_adjust);
-
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
 }
 
@@ -1006,7 +1000,6 @@ static ssize_t oom_adjust_write(struct f
 	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	long oom_adjust;
-	unsigned long flags;
 	int err;
 
 	memset(buffer, 0, sizeof(buffer));
@@ -1025,20 +1018,11 @@ static ssize_t oom_adjust_write(struct f
 	task = get_proc_task(file->f_path.dentry->d_inode);
 	if (!task)
 		return -ESRCH;
-	if (!lock_task_sighand(task, &flags)) {
-		put_task_struct(task);
-		return -ESRCH;
-	}
-
-	if (oom_adjust < task->signal->oom_adj && !capable(CAP_SYS_RESOURCE)) {
-		unlock_task_sighand(task, &flags);
-		put_task_struct(task);
-		return -EACCES;
-	}
 
-	task->signal->oom_adj = oom_adjust;
-
-	unlock_task_sighand(task, &flags);
+	if (task->signal->oom_adj <= oom_adjust || capable(CAP_SYS_RESOURCE))
+		task->signal->oom_adj = oom_adjust;
+	else
+		count = -EACCES;
 	put_task_struct(task);
 
 	return count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
