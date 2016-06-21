Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCB36B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 09:27:40 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id c1so13911900lbw.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 06:27:39 -0700 (PDT)
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com. [209.85.215.52])
        by mx.google.com with ESMTPS id k199si29984852lfb.146.2016.06.21.06.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 06:27:38 -0700 (PDT)
Received: by mail-lf0-f52.google.com with SMTP id h129so24009476lfh.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 06:27:38 -0700 (PDT)
Date: Tue, 21 Jun 2016 15:27:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, oom_reaper: How to handle race with oom_killer_disable() ?
Message-ID: <20160621132736.GF30848@dhcp22.suse.cz>
References: <201606102323.BCC73478.FtOJHFQMSVFLOO@I-love.SAKURA.ne.jp>
 <20160613111943.GB6518@dhcp22.suse.cz>
 <20160621083154.GA30848@dhcp22.suse.cz>
 <201606212003.FFB35429.QtMOJFFFOLSHVO@I-love.SAKURA.ne.jp>
 <20160621114643.GE30848@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160621114643.GE30848@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, mgorman@techsingularity.net, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 21-06-16 13:46:43, Michal Hocko wrote:
> On Tue 21-06-16 20:03:17, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Mon 13-06-16 13:19:43, Michal Hocko wrote:
> > > [...]
> > > > I am trying to remember why we are disabling oom killer before kernel
> > > > threads are frozen but not really sure about that right away.
> > > 
> > > OK, I guess I remember now. Say that a task would depend on a freezable
> > > kernel thread to get to do_exit (stuck in wait_event etc...). We would
> > > simply get stuck in oom_killer_disable for ever. So we need to address
> > > it a different way.
> > > 
> > > One way would be what you are proposing but I guess it would be more
> > > systematic to never call exit_oom_victim on a remote task.  After [1] we
> > > have a solid foundation to rely only on MMF_REAPED even when TIF_MEMDIE
> > > is set. It is more code than your patch so I can see a reason to go with
> > > yours if the following one seems too large or ugly.
> > > 
> > > [1] http://lkml.kernel.org/r/1466426628-15074-1-git-send-email-mhocko@kernel.org
> > > 
> > > What do you think about the following?
> > 
> > I'm OK with not clearing TIF_MEMDIE from a remote task. But this patch is racy.
> > 
> > > @@ -567,40 +612,23 @@ static void oom_reap_task(struct task_struct *tsk)
> > >  	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
> > >  		schedule_timeout_idle(HZ/10);
> > >  
> > > -	if (attempts > MAX_OOM_REAP_RETRIES) {
> > > -		struct task_struct *p;
> > > +	tsk->oom_reaper_list = NULL;
> > >  
> > > +	if (attempts > MAX_OOM_REAP_RETRIES) {
> > 
> > attempts > MAX_OOM_REAP_RETRIES would mean that down_read_trylock()
> > continuously failed. But it does not guarantee that the offending task
> > shall not call up_write(&mm->mmap_sem) and arrives at mmput() from exit_mm()
> > (as well as other threads which are blocked at down_read(&mm->mmap_sem) in
> > exit_mm() by the offending task arrive at mmput() from exit_mm()) when the
> > OOM reaper was preempted at this point.
> > 
> > Therefore, find_lock_task_mm() in requeue_oom_victim() could return NULL and
> > the OOM reaper could fail to set MMF_OOM_REAPED (and find_lock_task_mm() in
> > oom_scan_process_thread() could return NULL and the OOM killer could fail to
> > select next OOM victim as well) when __mmput() got stuck.
> 
> Fair enough. As this would break no-lockup requirement we cannot go that
> way. Let me think about it more.

Hmm, what about the following instead. It is rather a workaround than a
full flaged fix but it seems much more easier and shouldn't introduce
new issues.
---
