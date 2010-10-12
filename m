Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5A03B6B0096
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 21:01:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C11AZ8001506
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Oct 2010 10:01:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 126BF45DE4E
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:01:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C426845DE58
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:01:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 824501DB8060
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:01:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 202F91DB8067
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 10:01:09 +0900 (JST)
Date: Tue, 12 Oct 2010 09:55:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 07/10] memcg: add dirty limits to mem_cgroup
Message-Id: <20101012095546.f23bb950.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93bp70febu.fsf@ninji.mtv.corp.google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-8-git-send-email-gthelen@google.com>
	<20101005094302.GA4314@linux.develer.com>
	<xr93eic4wjlq.fsf@ninji.mtv.corp.google.com>
	<20101007091343.82ca9f7d.kamezawa.hiroyu@jp.fujitsu.com>
	<xr937hhuj19a.fsf@ninji.mtv.corp.google.com>
	<20101007094845.9e6a1b0f.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93bp70febu.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrea Righi <arighi@develer.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Oct 2010 17:24:21 -0700
Greg Thelen <gthelen@google.com> wrote:

> >> Is your motivation to increase performance with the same functionality?
> >> If so, then would a 'static inline' be performance equivalent to a
> >> preprocessor macro yet be safer to use?
> >> 
> > Ah, if lockdep finds this as bug, I think other parts will hit this,
> > too.  like this.
> >> static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> >> {
> >>         struct mem_cgroup *mem = NULL;
> >> 
> >>         if (!mm)
> >>                 return NULL;
> >>         /*
> >>          * Because we have no locks, mm->owner's may be being moved to other
> >>          * cgroup. We use css_tryget() here even if this looks
> >>          * pessimistic (rather than adding locks here).
> >>          */
> >>         rcu_read_lock();
> >>         do {
> >>                 mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> >>                 if (unlikely(!mem))
> >>                         break;
> >>         } while (!css_tryget(&mem->css));
> >>         rcu_read_unlock();
> >>         return mem;
> >> }
> 
> mem_cgroup_from_task() calls task_subsys_state() calls
> task_subsys_state_check().  task_subsys_state_check() will be happy if
> rcu_read_lock is held.
> 
yes.

> I don't think that this will fail lockdep, because rcu_read_lock_held()
> is true when calling mem_cgroup_from_task() within
> try_get_mem_cgroup_from_mm()..
> 
agreed.

> > mem_cgroup_from_task() is designed to be used as this.
> > If dqefined as macro, I think it will not be catched.
> 
> I do not understand how making mem_cgroup_from_task() a macro will
> change its behavior wrt. to lockdep assertion checking.  I assume that
> as a macro mem_cgroup_from_task() would still call task_subsys_state(),
> which requires either:
> a) rcu read lock held
> b) task->alloc_lock held
> c) cgroup lock held
> 

Hmm. Maybe I was wrong.

> 
> >> Maybe it makes more sense to find a way to perform this check in
> >> mem_cgroup_has_dirty_limit() without needing to grab the rcu lock.  I
> >> think this lock grab is unneeded.  I am still collecting performance
> >> data, but suspect that this may be making the code slower than it needs
> >> to be.
> >> 
> >
> > Hmm. css_set[] itself is freed by RCU..what idea to remove rcu_read_lock() do
> > you have ? Adding some flags ?
> 
> It seems like a shame to need a lock to determine if current is in the
> root cgroup.  Especially given that as soon as
> mem_cgroup_has_dirty_limit() returns, the task could be moved
> in-to/out-of the root cgroup thereby invaliding the answer.  So the
> answer is just a sample that may be wrong. 

Yes. But it's not a bug but a specification.

> But I think you are correct.
> We will need the rcu read lock in mem_cgroup_has_dirty_limit().
> 

yes.


> > Ah...I noticed that you should do
> >
> >  mem = mem_cgroup_from_task(current->mm->owner);
> >
> > to check has_dirty_limit...
> 
> What are the cases where current->mm->owner->cgroups !=
> current->cgroups?
> 
In that case, assume group A and B.

   thread(1) -> belongs to cgroup A  (thread(1) is mm->owner)
   thread(2) -> belongs to cgroup B
and
   a page    -> charnged to cgroup A

Then, thread(2) make the page dirty which is under cgroup A.

In this case, if page's dirty_pages accounting is added to cgroup B, cgroup B'
statistics may show "dirty_pages > all_lru_pages". This is bug.


> I was hoping to avoid having add even more logic into
> mem_cgroup_has_dirty_limit() to handle the case where current->mm is
> NULL.
> 

Blease check current->mm. We can't limit works of kernel-thread by this, let's
consider it later if necessary.

> Presumably the newly proposed vm_dirty_param(),
> mem_cgroup_has_dirty_limit(), and mem_cgroup_page_stat() routines all
> need to use the same logic.  I assume they should all be consistently
> using current->mm->owner or current.
> 

please.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
