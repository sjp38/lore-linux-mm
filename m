Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EBB116B01EF
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 15:01:53 -0400 (EDT)
Date: Wed, 31 Mar 2010 20:59:50 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
Message-ID: <20100331185950.GB11635@redhat.com>
References: <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com> <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/30, David Rientjes wrote:
>
> On Tue, 30 Mar 2010, Oleg Nesterov wrote:
>
> > ->siglock is no longer needed to access task->signal, change
> > oom_adjust_read() and oom_adjust_write() to read/write oom_adj
> > lockless.
> >
> > Yes, this means that "echo 2 >oom_adj" and "echo 1 >oom_adj"
> > can race and the second write can win, but I hope this is OK.
>
> Ok, but could you base this on -mm at
> http://userweb.kernel.org/~akpm/mmotm/ since an additional tunable has
> been added (oom_score_adj), which does the same thing?

David, I just can't understand why
	oom-badness-heuristic-rewrite.patch
duplicates the related code in fs/proc/base.c and why it preserves
the deprecated signal->oom_adj.

OK. Please forget about lock_task_sighand/signal issues. Can't we kill
signal->oom_adj and create a single helper for both
/proc/pid/{oom_adj,oom_score_adj} ?

	static ssize_t oom_any_adj_write(struct file *file, const char __user *buf,
						size_t count, bool deprecated_mode)
	{
		struct task_struct *task;
		char buffer[PROC_NUMBUF];
		unsigned long flags;
		long oom_score_adj;
		int err;

		memset(buffer, 0, sizeof(buffer));
		if (count > sizeof(buffer) - 1)
			count = sizeof(buffer) - 1;
		if (copy_from_user(buffer, buf, count))
			return -EFAULT;

		err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
		if (err)
			return -EINVAL;

		if (depraceted_mode) {
			 if (oom_score_adj == OOM_ADJUST_MAX)
				oom_score_adj = OOM_SCORE_ADJ_MAX;
			 else
				oom_score_adj = (oom_score_adj * OOM_SCORE_ADJ_MAX) /
						-OOM_DISABLE;
		}

		if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
				oom_score_adj > OOM_SCORE_ADJ_MAX)
			return -EINVAL;

		task = get_proc_task(file->f_path.dentry->d_inode);
		if (!task)
			return -ESRCH;
		if (!lock_task_sighand(task, &flags)) {
			put_task_struct(task);
			return -ESRCH;
		}
		if (oom_score_adj < task->signal->oom_score_adj &&
				!capable(CAP_SYS_RESOURCE)) {
			unlock_task_sighand(task, &flags);
			put_task_struct(task);
			return -EACCES;
		}

		task->signal->oom_score_adj = oom_score_adj;

		unlock_task_sighand(task, &flags);
		put_task_struct(task);
		return count;
	}

This is just the current oom_score_adj_read() + "if (depraceted_mode)"
which does oom_adj -> oom_score_adj conversion.

Now,

	static ssize_t oom_adjust_write(...)
	{
		printk_once(KERN_WARNING "... deprecated ...\n");

		return oom_any_adj_write(..., true);
	}

	static ssize_t oom_score_adj_write(...)
	{
		return oom_any_adj_write(..., false);
	}

The same for oom_xxx_read().

What is the point to keep signal->oom_adj ?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
