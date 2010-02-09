Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 339BD6B0078
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 20:00:05 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o190xxFK002269
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Feb 2010 09:59:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F373C45DE53
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:59:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C528745DE4E
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:59:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A72E61DB803C
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:59:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A0671DB8040
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:59:58 +0900 (JST)
Date: Tue, 9 Feb 2010 09:56:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup
Message-Id: <20100209095635.b8a0fdac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	<20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 9 Feb 2010 09:32:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Sat, 6 Feb 2010 01:30:49 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:

> > I am not sure how many usecase is also dependent of other locks.
> > If it is not as is, we can't make sure in future.
> > 
> > So How about try_task_in_mem_cgroup?
> > If we can't hold task_lock, let's continue next child.
> > 
> It's recommended not to use trylock in unclear case.
> 
> Then, I think possible replacement will be not-to-use any lock in
> task_in_mem_cgroup. In my short consideration, I don't think task_lock
> is necessary if we can add some tricks and memory barrier.
> 
> Please let this patch to go as it is because this is an obvious bug fix
> and give me time.
> 
I'll try some today. please wait. 
(but I wonder the patch will be not good for stable tree.)

Thanks,
-Kame

> Now, I think of following.
> This makes use of the fact mm->owner is changed only at _exit() of the owner.
> If there is a race with _exit() and mm->owner is racy, the oom selection
> itself was racy and bad.
> ==
> int task_in_mem_cgroup_oom(struct task_struct *tsk, struct mem_cgroup *mem)
> {
> 	struct mm_struct *mm;
> 	struct task_struct *tsk;
> 	int ret = 0;
> 
> 	mm = tsk->mm;
> 	if (!mm)
> 		return ret;
> 	/*
> 	 * we are not interested in tasks other than owner. mm->owner is
> 	 * updated when the owner task exits. If the owner is exiting now
> 	 * (and race with us), we may miss.
> 	 */
> 	if (rcu_dereference(mm->owner) != tsk)
> 		return ret;
> 	rcu_read_lock();
> 	/* while this task is alive, this task is the owner */
> 	if (mem == mem_cgroup_from_task(tsk))
> 		ret = 1;
> 	rcu_read_unlock();
> 	return ret;
> }
> ==
> Hmm, it seems no memory barrier is necessary.
> 
> Does anyone has another idea ?
> 
> Thanks,
> -Kame
> 
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
