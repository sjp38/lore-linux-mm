Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 24A2D6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 17:14:39 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o2VLEZfG006809
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:14:36 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz33.hot.corp.google.com with ESMTP id o2VLEGbJ022190
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:14:34 -0700
Received: by pwj10 with SMTP id 10so536959pwj.26
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:14:34 -0700 (PDT)
Date: Wed, 31 Mar 2010 14:14:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
In-Reply-To: <20100331185950.GB11635@redhat.com>
Message-ID: <alpine.DEB.2.00.1003311408520.31252@chino.kir.corp.google.com>
References: <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com>
 <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com> <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com> <20100331185950.GB11635@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Oleg Nesterov wrote:

> David, I just can't understand why
> 	oom-badness-heuristic-rewrite.patch
> duplicates the related code in fs/proc/base.c and why it preserves
> the deprecated signal->oom_adj.
> 

You could combine the two write functions together and then two read 
functions together if you'd like.

> OK. Please forget about lock_task_sighand/signal issues. Can't we kill
> signal->oom_adj and create a single helper for both
> /proc/pid/{oom_adj,oom_score_adj} ?
> 
> 	static ssize_t oom_any_adj_write(struct file *file, const char __user *buf,
> 						size_t count, bool deprecated_mode)
> 	{
> 		struct task_struct *task;
> 		char buffer[PROC_NUMBUF];
> 		unsigned long flags;
> 		long oom_score_adj;
> 		int err;
> 
> 		memset(buffer, 0, sizeof(buffer));
> 		if (count > sizeof(buffer) - 1)
> 			count = sizeof(buffer) - 1;
> 		if (copy_from_user(buffer, buf, count))
> 			return -EFAULT;
> 
> 		err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
> 		if (err)
> 			return -EINVAL;
> 
> 		if (depraceted_mode) {
> 			 if (oom_score_adj == OOM_ADJUST_MAX)
> 				oom_score_adj = OOM_SCORE_ADJ_MAX;

???

> 			 else
> 				oom_score_adj = (oom_score_adj * OOM_SCORE_ADJ_MAX) /
> 						-OOM_DISABLE;
> 		}
> 
> 		if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
> 				oom_score_adj > OOM_SCORE_ADJ_MAX)

That doesn't work for depraceted_mode (sic), you'd need to test for 
OOM_ADJUST_MIN and OOM_ADJUST_MAX in that case.

> 			return -EINVAL;
> 
> 		task = get_proc_task(file->f_path.dentry->d_inode);
> 		if (!task)
> 			return -ESRCH;
> 		if (!lock_task_sighand(task, &flags)) {
> 			put_task_struct(task);
> 			return -ESRCH;
> 		}
> 		if (oom_score_adj < task->signal->oom_score_adj &&
> 				!capable(CAP_SYS_RESOURCE)) {
> 			unlock_task_sighand(task, &flags);
> 			put_task_struct(task);
> 			return -EACCES;
> 		}
> 
> 		task->signal->oom_score_adj = oom_score_adj;
> 
> 		unlock_task_sighand(task, &flags);
> 		put_task_struct(task);
> 		return count;
> 	}
> 

There have been efforts to reuse as much of this code as possible for 
other sysctl handlers as well, you might be better off looking for other 
users of the common read and write code and then merging them first 
(comm_write, proc_coredump_filter_write, etc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
