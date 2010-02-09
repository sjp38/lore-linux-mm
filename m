Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 047216B0047
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 19:36:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o190agnU006900
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Feb 2010 09:36:42 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 36ECD2E7CD1
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:36:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 09A7445DE4E
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:36:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E00331DB803B
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:36:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C1A41DB803A
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 09:36:41 +0900 (JST)
Date: Tue, 9 Feb 2010 09:32:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup
Message-Id: <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 6 Feb 2010 01:30:49 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame.
> 
> On Fri, Feb 5, 2010 at 9:39 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Please take this patch in different context with recent discussion.
> > This is a quick-fix for a terrible bug.
> >
> > This patch itself is against mmotm but can be easily applied to mainline or
> > stable tree, I think. (But I don't CC stable tree until I get ack.)
> >
> > ==
> > Now, oom-killer kills process's chidlren at first. But this means
> > a child in other cgroup can be killed. But it's not checked now.
> >
> > This patch fixes that.
> >
> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/oom_kill.c | A  A 3 +++
> > A 1 file changed, 3 insertions(+)
> >
> > Index: mmotm-2.6.33-Feb03/mm/oom_kill.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb03.orig/mm/oom_kill.c
> > +++ mmotm-2.6.33-Feb03/mm/oom_kill.c
> > @@ -459,6 +459,9 @@ static int oom_kill_process(struct task_
> > A  A  A  A list_for_each_entry(c, &p->children, sibling) {
> > A  A  A  A  A  A  A  A if (c->mm == p->mm)
> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> > + A  A  A  A  A  A  A  /* Children may be in other cgroup */
> > + A  A  A  A  A  A  A  if (mem && !task_in_mem_cgroup(c, mem))
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > A  A  A  A  A  A  A  A if (!oom_kill_task(c))
> > A  A  A  A  A  A  A  A  A  A  A  A return 0;
> > A  A  A  A }
> >
> > --
> 
> I am worried about latency of OOM at worst case.
> I mean that task_in_mem_cgroup calls task_lock of child.
> We have used task_lock in many place.
> Some place task_lock hold and then other locks.
> For example, exit_fs held task_lock and try to hold write_lock of fs->lock.
> If child already hold task_lock and wait to write_lock of fs->lock, OOM latency
> is dependent of fs->lock.
> 
> I am not sure how many usecase is also dependent of other locks.
> If it is not as is, we can't make sure in future.
> 
> So How about try_task_in_mem_cgroup?
> If we can't hold task_lock, let's continue next child.
> 
It's recommended not to use trylock in unclear case.

Then, I think possible replacement will be not-to-use any lock in
task_in_mem_cgroup. In my short consideration, I don't think task_lock
is necessary if we can add some tricks and memory barrier.

Please let this patch to go as it is because this is an obvious bug fix
and give me time.

Now, I think of following.
This makes use of the fact mm->owner is changed only at _exit() of the owner.
If there is a race with _exit() and mm->owner is racy, the oom selection
itself was racy and bad.
==
int task_in_mem_cgroup_oom(struct task_struct *tsk, struct mem_cgroup *mem)
{
	struct mm_struct *mm;
	struct task_struct *tsk;
	int ret = 0;

	mm = tsk->mm;
	if (!mm)
		return ret;
	/*
	 * we are not interested in tasks other than owner. mm->owner is
	 * updated when the owner task exits. If the owner is exiting now
	 * (and race with us), we may miss.
	 */
	if (rcu_dereference(mm->owner) != tsk)
		return ret;
	rcu_read_lock();
	/* while this task is alive, this task is the owner */
	if (mem == mem_cgroup_from_task(tsk))
		ret = 1;
	rcu_read_unlock();
	return ret;
}
==
Hmm, it seems no memory barrier is necessary.

Does anyone has another idea ?

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
