Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE5B6B00B6
	for <linux-mm@kvack.org>; Wed, 27 May 2015 12:45:09 -0400 (EDT)
Received: by wizk4 with SMTP id k4so118386350wiz.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:45:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j18si29438865wjr.158.2015.05.27.09.45.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 May 2015 09:45:07 -0700 (PDT)
Date: Wed, 27 May 2015 18:45:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150527164505.GD27348@dhcp22.suse.cz>
References: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
 <20150526170213.GB14955@dhcp22.suse.cz>
 <201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Wed 27-05-15 06:39:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 25-05-15 23:33:31, Tetsuo Handa wrote:
> > > >From 3728807fe66ebc24a8a28455593754b9532bbe74 Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Mon, 25 May 2015 22:26:07 +0900
> > > Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
> > > 
> > > If the mm struct which the OOM victim is using is shared by e.g. 1000
> > > threads, and the lock dependency prevents all threads except the OOM
> > > victim thread from terminating until they get TIF_MEMDIE flag, the OOM
> > > killer will be invoked for 1000 times on this mm struct. As a result,
> > > the kernel would emit
> > > 
> > >   "Kill process %d (%s) sharing same memory\n"
> > > 
> > > line for 1000 * 1000 / 2 times. But once these threads got pending SIGKILL,
> > > emitting this information is nothing but noise. This patch filters them.
> > 
> > OK, I can see this might be really annoying. But reducing this message
> > will not help much because it is the dump_header which generates a lot
> > of output. And there is clearly no reason to treat the selected victim
> > any differently than the current so why not simply do the following
> > instead?
> > ---
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 5cfda39b3268..a67ce18b4b35 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -505,7 +505,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> >  	 */
> >  	task_lock(p);
> > -	if (p->mm && task_will_free_mem(p)) {
> > +	if (p->mm && (fatal_signal_pending(p) || task_will_free_mem(p))) {
> >  		mark_oom_victim(p);
> >  		task_unlock(p);
> >  		put_task_struct(p);
> > 
> 
> I don't think this is good, for this will omit sending SIGKILL to threads
> sharing p->mm ("Kill all user processes sharing victim->mm in other thread
> groups, if any.")

threads? The whole thread group will die when the fatal signal is
send to the group leader no? This mm sharing handling is about
processes which are sharing mm but they are not in the same thread group
(aka CLONE_VM without CLONE_SIGHAND resp. CLONE_THREAD).

> when p already has pending SIGKILL.

yes we can select a task which has SIGKILL already pending and then
we wouldn't kill other processes which share the same mm but does it
matter?  I do not think so. Because if this is really the case and the
OOM condition continues even after p exits (which is very probable but
p alone might release some resources and free memory) we will find a
process with the same mm in the next round.

> By the way, if p with p->mm && task_will_free_mem(p) can get stuck due to
> memory allocation deadlock, is it OK that currently we are not sending SIGKILL
> to threads sharing p->mm ?

I am not sure I understand the question. Threads will die automatically
because we are sending group signal.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
