Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2566B0087
	for <linux-mm@kvack.org>; Tue, 26 May 2015 17:39:43 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so99775643pdb.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 14:39:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xf4si22630313pbc.157.2015.05.26.14.39.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 May 2015 14:39:42 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
	<20150526170213.GB14955@dhcp22.suse.cz>
In-Reply-To: <20150526170213.GB14955@dhcp22.suse.cz>
Message-Id: <201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
Date: Wed, 27 May 2015 06:39:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Mon 25-05-15 23:33:31, Tetsuo Handa wrote:
> > >From 3728807fe66ebc24a8a28455593754b9532bbe74 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Mon, 25 May 2015 22:26:07 +0900
> > Subject: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
> > 
> > If the mm struct which the OOM victim is using is shared by e.g. 1000
> > threads, and the lock dependency prevents all threads except the OOM
> > victim thread from terminating until they get TIF_MEMDIE flag, the OOM
> > killer will be invoked for 1000 times on this mm struct. As a result,
> > the kernel would emit
> > 
> >   "Kill process %d (%s) sharing same memory\n"
> > 
> > line for 1000 * 1000 / 2 times. But once these threads got pending SIGKILL,
> > emitting this information is nothing but noise. This patch filters them.
> 
> OK, I can see this might be really annoying. But reducing this message
> will not help much because it is the dump_header which generates a lot
> of output. And there is clearly no reason to treat the selected victim
> any differently than the current so why not simply do the following
> instead?
> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5cfda39b3268..a67ce18b4b35 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -505,7 +505,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
>  	task_lock(p);
> -	if (p->mm && task_will_free_mem(p)) {
> +	if (p->mm && (fatal_signal_pending(p) || task_will_free_mem(p))) {
>  		mark_oom_victim(p);
>  		task_unlock(p);
>  		put_task_struct(p);
> 

I don't think this is good, for this will omit sending SIGKILL to threads
sharing p->mm ("Kill all user processes sharing victim->mm in other thread
groups, if any.") when p already has pending SIGKILL.

By the way, if p with p->mm && task_will_free_mem(p) can get stuck due to
memory allocation deadlock, is it OK that currently we are not sending SIGKILL
to threads sharing p->mm ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
