Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBD176B0005
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 04:10:12 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id q18so23796138igr.2
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 01:10:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q31si7499144otq.213.2016.06.11.01.10.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 11 Jun 2016 01:10:12 -0700 (PDT)
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
	<1465473137-22531-8-git-send-email-mhocko@kernel.org>
	<201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
	<20160609142026.GF24777@dhcp22.suse.cz>
In-Reply-To: <20160609142026.GF24777@dhcp22.suse.cz>
Message-Id: <201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
Date: Sat, 11 Jun 2016 17:10:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > Also, I think setting TIF_MEMDIE on p when find_lock_task_mm(p) != p is
> > wrong. While oom_reap_task() will anyway clear TIF_MEMDIE even if we set
> > TIF_MEMDIE on p when p->mm == NULL, it is not true for CONFIG_MMU=n case.
> 
> Yes this would be racy for !CONFIG_MMU but does it actually matter?

I don't know because I've never used CONFIG_MMU=n kernels. But I think it
actually matters. You fixed this race by commit 83363b917a2982dd ("oom:
make sure that TIF_MEMDIE is set under task_lock").

> > > @@ -940,14 +968,10 @@ bool out_of_memory(struct oom_control *oc)
> > >  	 * If current has a pending SIGKILL or is exiting, then automatically
> > >  	 * select it.  The goal is to allow it to allocate so that it may
> > >  	 * quickly exit and free its memory.
> > > -	 *
> > > -	 * But don't select if current has already released its mm and cleared
> > > -	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> > >  	 */
> > > -	if (current->mm &&
> > > -	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> > > +	if (task_will_free_mem(current)) {
> > 
> > Setting TIF_MEMDIE on current when current->mm == NULL and
> > find_lock_task_mm(current) != NULL is wrong.
> 
> Why? Or is this still about the !CONFIG_MMU?

Yes, mainly about CONFIG_MMU=n kernels. This change reintroduces possibility
of failing to clear TIF_MEMDIE which was fixed by commit d7a94e7e11badf84
("oom: don't count on mm-less current process").

I was also thinking about possibility of the OOM reaper failing to clear
TIF_MEMDIE due to race with PM/freezing. That is, TIF_MEMDIE is set on a
thread which already released mm, then try_to_freeze_tasks(true) from
freeze_processes() freezes such thread, then oom_reap_task() fails to
clear TIF_MEMDIE from such thread due to oom_killer_disabled == true, then
subsequent memory allocation fails and hibernation aborts, then all threads
are thawed, but TIF_MEMDIE thread won't clear TIF_MEMDIE, and finally the
system locks up because nobody will clear TIF_MEMDIE.

But as I posted in other thread, we can use an approach which does not
introduce possibility of failing to clear TIF_MEMDIE due to race with
PM/freezing. So, this is purely about CONFIG_MMU=n kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
