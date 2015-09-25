Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id D09E36B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:15:03 -0400 (EDT)
Received: by igxx6 with SMTP id x6so12724697igx.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 09:15:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qf1si2906213igb.68.2015.09.25.09.15.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 09:15:02 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150921161203.GD19811@dhcp22.suse.cz>
	<20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
In-Reply-To: <20150925093556.GF16497@dhcp22.suse.cz>
Message-Id: <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
Date: Sat, 26 Sep 2015 01:14:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> On Thu 24-09-15 14:15:34, David Rientjes wrote:
> > > > Finally. Whatever we do, we need to change oom_kill_process() first,
> > > > and I think we should do this regardless. The "Kill all user processes
> > > > sharing victim->mm" logic looks wrong and suboptimal/overcomplicated.
> > > > I'll try to make some patches tomorrow if I have time...
> > > 
> > > That would be appreciated. I do not like that part either. At least we
> > > shouldn't go over the whole list when we have a good chance that the mm
> > > is not shared with other processes.
> > > 
> > 
> > Heh, it's actually imperative to avoid livelocking based on mm->mmap_sem, 
> > it's the reason the code exists.  Any optimizations to that is certainly 
> > welcome, but we definitely need to send SIGKILL to all threads sharing the 
> > mm to make forward progress, otherwise we are going back to pre-2008 
> > livelocks.
> 
> Yes but mm is not shared between processes most of the time. CLONE_VM
> without CLONE_THREAD is more a corner case yet we have to crawl all the
> task_structs for _each_ OOM killer invocation. Yes this is an extreme
> slow path but still might take quite some unnecessarily time.

Excuse me, but thinking about CLONE_VM without CLONE_THREAD case...
Isn't there possibility of hitting livelocks at

        /*
         * If current has a pending SIGKILL or is exiting, then automatically
         * select it.  The goal is to allow it to allocate so that it may
         * quickly exit and free its memory.
         *
         * But don't select if current has already released its mm and cleared
         * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
         */
        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

if current thread receives SIGKILL just before reaching here, for we don't
send SIGKILL to all threads sharing the mm?

Hopefully current thread is not holding inode->i_mutex because reaching here
(i.e. calling out_of_memory()) suggests that we are doing GFP_KERNEL
allocation. But it could be !__GFP_NOFS && __GFP_NOFAIL allocation, or
different locks contended by another thread sharing the mm?

I don't like "That thread will now get access to memory reserves since it
has a pending fatal signal." line in comments for the "Kill all user
processes sharing victim->mm" logic. That thread won't get access to memory
reserves unless that thread can call out_of_memory() (i.e. doing __GFP_FS or
__GFP_NOFAIL allocations). Since I can observe that that thread may be doing
!__GFP_NOFS allocation, I think that this comment needs to be updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
