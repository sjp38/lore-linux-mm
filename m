Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D04D86B006E
	for <linux-mm@kvack.org>; Wed, 27 May 2015 17:59:33 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so26420897pdb.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 14:59:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id cm6si387110pdb.94.2015.05.27.14.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 May 2015 14:59:32 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
	<20150526170213.GB14955@dhcp22.suse.cz>
	<201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
	<20150527164505.GD27348@dhcp22.suse.cz>
In-Reply-To: <20150527164505.GD27348@dhcp22.suse.cz>
Message-Id: <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
Date: Thu, 28 May 2015 06:59:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Wed 27-05-15 06:39:42, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 25-05-15 23:33:31, Tetsuo Handa wrote:
> > > > >From 3728807fe66ebc24a8a28455593754b9532bbe74 Mon Sep 17 00:00:00 2001
> > > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Date: Mon, 25 May 2015 22:26:07 +0900
> > > > Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
> > > > 
> > > > If the mm struct which the OOM victim is using is shared by e.g. 1000
> > > > threads, and the lock dependency prevents all threads except the OOM
> > > > victim thread from terminating until they get TIF_MEMDIE flag, the OOM
> > > > killer will be invoked for 1000 times on this mm struct. As a result,
> > > > the kernel would emit
> > > > 
> > > >   "Kill process %d (%s) sharing same memory\n"
> > > > 
> > > > line for 1000 * 1000 / 2 times. But once these threads got pending SIGKILL,
> > > > emitting this information is nothing but noise. This patch filters them.
> > > 
> > > OK, I can see this might be really annoying. But reducing this message
> > > will not help much because it is the dump_header which generates a lot
> > > of output. And there is clearly no reason to treat the selected victim
> > > any differently than the current so why not simply do the following
> > > instead?
> > > ---
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 5cfda39b3268..a67ce18b4b35 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -505,7 +505,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> > >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> > >  	 */
> > >  	task_lock(p);
> > > -	if (p->mm && task_will_free_mem(p)) {
> > > +	if (p->mm && (fatal_signal_pending(p) || task_will_free_mem(p))) {
> > >  		mark_oom_victim(p);
> > >  		task_unlock(p);
> > >  		put_task_struct(p);
> > > 
> > 
> > I don't think this is good, for this will omit sending SIGKILL to threads
> > sharing p->mm ("Kill all user processes sharing victim->mm in other thread
> > groups, if any.")
> 
> threads? The whole thread group will die when the fatal signal is
> send to the group leader no? This mm sharing handling is about
> processes which are sharing mm but they are not in the same thread group

OK. I should say "omit sending SIGKILL to processes which are sharing mm
but they are not in the same thread group".

> (aka CLONE_VM without CLONE_SIGHAND resp. CLONE_THREAD).

clone(CLONE_SIGHAND | CLONE_VM) ?

> 
> > when p already has pending SIGKILL.
> 
> yes we can select a task which has SIGKILL already pending and then
> we wouldn't kill other processes which share the same mm but does it
> matter?  I do not think so. Because if this is really the case and the
> OOM condition continues even after p exits (which is very probable but
> p alone might release some resources and free memory) we will find a
> process with the same mm in the next round.

I think it matters because p cannot call do_exit() when p is blocked by
processes which are sharing mm but they are not in the same thread group.

> 
> > By the way, if p with p->mm && task_will_free_mem(p) can get stuck due to
> > memory allocation deadlock, is it OK that currently we are not sending SIGKILL
> > to threads sharing p->mm ?
> 
> I am not sure I understand the question. Threads will die automatically
> because we are sending group signal.

I just imagined a case where p is blocked at down_read() in acct_collect() from
do_exit() when p is sharing mm with other processes, and other process is doing
blocking operation with mm->mmap_sem held for writing. Is such case impossible?

do_exit() {
  exit_signals(tsk);  /* sets PF_EXITING */
  acct_collect(code, group_dead) {
    if (group_dead && current->mm) {
      down_read(&current->mm->mmap_sem);
      up_read(&current->mm->mmap_sem);
    }
  }
  exit_mm(tsk) {
     down_read(&mm->mmap_sem);
     tsk->mm = NULL;
     up_read(&mm->mmap_sem);
  }
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
