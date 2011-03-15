Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BA8448D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 10:42:45 -0400 (EDT)
Date: Tue, 15 Mar 2011 15:33:57 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH] fork bomb killer
Message-ID: <20110315143357.GA9025@redhat.com>
References: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com, Andrey Vagin <avagin@openvz.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On 03/15, KAMEZAWA Hiroyuki wrote:
>
> I wonder it's better to have a fork-bomb killer

I am not going do discuss the idea, I never know when it comes to the
new features. Although personally I think this makes sense.

Just a couple of nits about the patch itself. Which I didn't read carefully
yet ;)

> +extern struct pid *fork_bomb_session;
> +static inline bool in_fork_bomb(void)
> +{
> +	return task_session(current) == fork_bomb_session;
> +}

Well, at first glance it is easy to write the fork-bomb which does setsid()...

> --- mmotm-temp.orig/kernel/fork.c
> +++ mmotm-temp/kernel/fork.c
> @@ -1417,6 +1417,8 @@ long do_fork(unsigned long clone_flags,
>  			return -EPERM;
>  	}
>
> +	if (in_fork_bomb())
> +		return -ENOMEM;

This is not clear to me. fork_bomb_detection() does do_each_pid_task(SID)
and sends SIGKILL to the hostile processes. After that none of the killed
processes can fork. Assuming the "bomb_task" was detected correctly, why
do we punish the whole session?

Once again, I didn't read the patch. This is the question, not the comment.

> +static bool is_ancestor(struct task_struct *t, struct task_struct *p)
> +{
> +	while (t != &init_task) {
> +		if (t == p)
> +			return true;
> +		t = t->real_parent;
> +	}
> +	return false;
> +}

No, this is not right. In fact, in theory this can crash if /sbin/init is
multithreaded. This needs same_thread_group() istead of "==" or "!=". Or
it should use t->real_parent->group_leader, assuming that both t and p
are the group-leaders (this seems to be true).

IOW. If a main thream M does pthread_create() and creates the thread T,
and T forks the child C after that, then C->real_parent == T, not M.

> +static bool fork_bomb_detection(unsigned long totalpages, struct mem_cgroup *mem,
> +		const nodemask_t *nodemask)
> +{
> ...
> +
> +	fork_bomb_session = task_session(bomb_task);

Hmm. In theory this needs fork_bomb_session = get_pid(task_session()).
Otherwise, all tasks in this session can be killed or can exit before
forkbomb_timeout runs. In this case this pid's memory can be reused
and in in_fork_bomb() can be false positive.

> +	INIT_DELAYED_WORK(&forkbomb_timeout, clear_fork_bomb);

OK, we already checked that fork_bomb_session == NULL. But isn't it
possible that multiple threads call fork_bomb_detection() at the same
time? We have sysrq_handle_moom, and __alloc_pages_may_oom() can lock
different zonelist's. No?

> +	 * Now, we found a bomb task. kill all children of bomb_task.

Again, this is not clear to me. We could literally kill all children,
why do we scan the session instead?

> +	do_each_pid_task(bomb_session, PIDTYPE_SID, p) {
> +
> +		start_time = timespec_to_jiffies(&p->start_time);
> +		start_time += fork_bomb_thresh;
> +
> +		if (!thread_group_leader(p))
> +			continue;

This is unneded, it must be thread_group_leader().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
