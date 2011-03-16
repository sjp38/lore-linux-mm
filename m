Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7908D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 20:41:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 741213EE0C1
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:41:07 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 522B445DE5E
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:41:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2373945DE56
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:41:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10F0FE08003
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:41:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD7F3E18003
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:41:06 +0900 (JST)
Date: Wed, 16 Mar 2011 09:34:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fork bomb killer
Message-Id: <20110316093443.a37d64f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110315143357.GA9025@redhat.com>
References: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110315143357.GA9025@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com, Andrey Vagin <avagin@openvz.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Tue, 15 Mar 2011 15:33:57 +0100
Oleg Nesterov <oleg@redhat.com> wrote:

> On 03/15, KAMEZAWA Hiroyuki wrote:
> >
> > I wonder it's better to have a fork-bomb killer
> 
> I am not going do discuss the idea, I never know when it comes to the
> new features. Although personally I think this makes sense.
> 
> Just a couple of nits about the patch itself. Which I didn't read carefully
> yet ;)
> 

Thank you for review. 

> > +extern struct pid *fork_bomb_session;
> > +static inline bool in_fork_bomb(void)
> > +{
> > +	return task_session(current) == fork_bomb_session;
> > +}
> 
> Well, at first glance it is easy to write the fork-bomb which does setsid()...
> 
This is for disallowing new fork() in guilty session.

But yes, setsid script can kill the system. I'll leave this check (with improvement)
but will try to remove session check in killing loop.

I never think 'a carefully programmed fork-bomb to crash system' can be 
catched. But...

I'd like to catch all cases in wikipedia, finally ;)
http://en.wikipedia.org/wiki/Fork_bomb
Now, I can't.



> > --- mmotm-temp.orig/kernel/fork.c
> > +++ mmotm-temp/kernel/fork.c
> > @@ -1417,6 +1417,8 @@ long do_fork(unsigned long clone_flags,
> >  			return -EPERM;
> >  	}
> >
> > +	if (in_fork_bomb())
> > +		return -ENOMEM;
> 
> This is not clear to me. fork_bomb_detection() does do_each_pid_task(SID)
> and sends SIGKILL to the hostile processes. After that none of the killed
> processes can fork. Assuming the "bomb_task" was detected correctly, why
> do we punish the whole session?
> 
> Once again, I didn't read the patch. This is the question, not the comment.
> 

This killer kills only young tasks. So, we can't guarantee we removed all
bombs. I'd like to stop new bomb for a while.




> > +static bool is_ancestor(struct task_struct *t, struct task_struct *p)
> > +{
> > +	while (t != &init_task) {
> > +		if (t == p)
> > +			return true;
> > +		t = t->real_parent;
> > +	}
> > +	return false;
> > +}
> 
> No, this is not right. In fact, in theory this can crash if /sbin/init is
> multithreaded. This needs same_thread_group() istead of "==" or "!=". Or
> it should use t->real_parent->group_leader, assuming that both t and p
> are the group-leaders (this seems to be true).
> 
> IOW. If a main thream M does pthread_create() and creates the thread T,
> and T forks the child C after that, then C->real_parent == T, not M.
> 

I'll fix this.


> > +static bool fork_bomb_detection(unsigned long totalpages, struct mem_cgroup *mem,
> > +		const nodemask_t *nodemask)
> > +{
> > ...
> > +
> > +	fork_bomb_session = task_session(bomb_task);
> 
> Hmm. In theory this needs fork_bomb_session = get_pid(task_session()).
> Otherwise, all tasks in this session can be killed or can exit before
> forkbomb_timeout runs. In this case this pid's memory can be reused
> and in in_fork_bomb() can be false positive.
> 

ok, will fix.


> > +	INIT_DELAYED_WORK(&forkbomb_timeout, clear_fork_bomb);
> 
> OK, we already checked that fork_bomb_session == NULL. But isn't it
> possible that multiple threads call fork_bomb_detection() at the same
> time? We have sysrq_handle_moom, and __alloc_pages_may_oom() can lock
> different zonelist's. No?
> 

Hmm, yes. I'll add some lock. (I really forgot sysrq...thank you.)


> > +	 * Now, we found a bomb task. kill all children of bomb_task.
> 
> Again, this is not clear to me. We could literally kill all children,
> why do we scan the session instead?
> 

I'll write a process tree walk code and remove session scan.



> > +	do_each_pid_task(bomb_session, PIDTYPE_SID, p) {
> > +
> > +		start_time = timespec_to_jiffies(&p->start_time);
> > +		start_time += fork_bomb_thresh;
> > +
> > +		if (!thread_group_leader(p))
> > +			continue;
> 
> This is unneded, it must be thread_group_leader().
> 
Ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
