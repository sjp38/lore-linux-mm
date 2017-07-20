Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 493D96B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 17:47:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l28so40269823pfj.12
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 14:47:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u5si2168173pgc.766.2017.07.20.14.47.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 14:47:23 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1500386810-4881-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170718141602.GB19133@dhcp22.suse.cz>
	<201707190551.GJE30718.OFHOQMFJtVSFOL@I-love.SAKURA.ne.jp>
	<20170720141138.GJ9058@dhcp22.suse.cz>
In-Reply-To: <20170720141138.GJ9058@dhcp22.suse.cz>
Message-Id: <201707210647.BDH57894.MQOtFFOJHLSOFV@I-love.SAKURA.ne.jp>
Date: Fri, 21 Jul 2017 06:47:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 19-07-17 05:51:03, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 18-07-17 23:06:50, Tetsuo Handa wrote:
> > > > Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> > > > guarded whole OOM reaping operations using oom_lock. But there was no
> > > > need to guard whole operations. We needed to guard only setting of
> > > > MMF_OOM_REAPED flag because get_page_from_freelist() in
> > > > __alloc_pages_may_oom() is called with oom_lock held.
> > > > 
> > > > If we change to guard only setting of MMF_OOM_SKIP flag, the OOM reaper
> > > > can start reaping operations as soon as wake_oom_reaper() is called.
> > > > But since setting of MMF_OOM_SKIP flag at __mmput() is not guarded with
> > > > oom_lock, guarding only the OOM reaper side is not sufficient.
> > > > 
> > > > If we change the OOM killer side to ignore MMF_OOM_SKIP flag once,
> > > > there is no need to guard setting of MMF_OOM_SKIP flag, and we can
> > > > guarantee a chance to call get_page_from_freelist() in
> > > > __alloc_pages_may_oom() without depending on oom_lock serialization.
> > > > 
> > > > This patch makes MMF_OOM_SKIP act as if MMF_OOM_REAPED, and adds a new
> > > > flag which acts as if MMF_OOM_SKIP, in order to close both race window
> > > > (the OOM reaper side and __mmput() side) without using oom_lock.
> > > 
> > > Why do we need this patch when
> > > http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org
> > > already removes the lock and solves another problem at once?
> > 
> > We haven't got an answer from Hugh and/or Andrea whether that patch is safe.
> 
> So what? I haven't see anybody disputing the correctness. And to be
> honest I really dislike your patch. Yet another round kind of solutions
> are just very ugly hacks usually because they are highly timing
> sensitive.

Yes, OOM killer is highly timing sensitive.

> 
> > Even if that patch is safe, this patch still helps with CONFIG_MMU=n case.
> 
> Could you explain how?

Nothing prevents sequence below.

    Process-1              Process-2

    Takes oom_lock.
    Fails get_page_from_freelist().
    Enters out_of_memory().
    Gets SIGKILL.
    Gets TIF_MEMDIE.
    Leaves out_of_memory().
    Releases oom_lock.
    Enters do_exit().
    Calls __mmput().
                           Takes oom_lock.
                           Fails get_page_from_freelist().
    Releases some memory.
    Sets MMF_OOM_SKIP.
                           Enters out_of_memory().
                           Selects next victim because there is no !MMF_OOM_SKIP mm.
                           Sends SIGKILL needlessly.

If we ignore MMF_OOM_SKIP once, we can avoid sequence above.

    Process-1              Process-2

    Takes oom_lock.
    Fails get_page_from_freelist().
    Enters out_of_memory().
    Get SIGKILL.
    Get TIF_MEMDIE.
    Leaves out_of_memory().
    Releases oom_lock.
    Enters do_exit().
    Calls __mmput().
                           Takes oom_lock.
                           Fails get_page_from_freelist().
    Releases some memory.
    Sets MMF_OOM_SKIP.
                           Enters out_of_memory().
                           Ignores MMF_OOM_SKIP mm once.
                           Leaves out_of_memory().
                           Releases oom_lock.
                           Succeeds get_page_from_freelist().

Strictly speaking, this patch is independent with OOM reaper.
This patch increases possibility of succeeding get_page_from_freelist()
without sending SIGKILL. Your patch is trying to drop it silently.

Serializing setting of MMF_OOM_SKIP with oom_lock is one approach,
and ignoring MMF_OOM_SKIP once without oom_lock is another approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
