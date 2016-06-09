Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48F396B0276
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 10:20:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 4so22523256wmz.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 07:20:30 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id j9si2745176wjt.128.2016.06.09.07.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 07:20:29 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id m124so11060887wme.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 07:20:28 -0700 (PDT)
Date: Thu, 9 Jun 2016 16:20:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Message-ID: <20160609142026.GF24777@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-8-git-send-email-mhocko@kernel.org>
 <201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 09-06-16 22:18:28, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > @@ -766,15 +797,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	 * If the task is already exiting, don't alarm the sysadmin or kill
> >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> >  	 */
> > -	task_lock(p);
> > -	if (p->mm && task_will_free_mem(p)) {
> > +	if (task_will_free_mem(p)) {
> 
> I think it is possible that p->mm becomes NULL here.

Yes p->mm can become NULL at any time after we drop the task_lock.

> Also, I think setting TIF_MEMDIE on p when find_lock_task_mm(p) != p is
> wrong. While oom_reap_task() will anyway clear TIF_MEMDIE even if we set
> TIF_MEMDIE on p when p->mm == NULL, it is not true for CONFIG_MMU=n case.

Yes this would be racy for !CONFIG_MMU but does it actually matter?
AFAIU !CONFIG_MMU model basically everything is allocated during
the initialization so it is highly unlikely that we would do some
allocations past the exit_mm() which releases the user memory which
should be sufficient to move on and get out of OOM. Also the programming
model is really careful about the memory usage (fork is basically a no
go), large memory mappings are really hard due to memory fragmentation
etc...

So do we really have to nit pick about !CONFIG_MMU to move on here?  I
definitely do not want to break this configuration but I believe that
this particular change has only tiny chance to make any difference.
I might be missing something of course...

[...]

> > @@ -940,14 +968,10 @@ bool out_of_memory(struct oom_control *oc)
> >  	 * If current has a pending SIGKILL or is exiting, then automatically
> >  	 * select it.  The goal is to allow it to allocate so that it may
> >  	 * quickly exit and free its memory.
> > -	 *
> > -	 * But don't select if current has already released its mm and cleared
> > -	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> >  	 */
> > -	if (current->mm &&
> > -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > +	if (task_will_free_mem(current)) {
> 
> Setting TIF_MEMDIE on current when current->mm == NULL and
> find_lock_task_mm(current) != NULL is wrong.

Why? Or is this still about the !CONFIG_MMU?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
