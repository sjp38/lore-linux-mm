Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 142206B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:45:39 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q8-v6so17705297ioh.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:45:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m129-v6si17854359iof.174.2018.05.23.06.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 06:45:37 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180518122045.GG21711@dhcp22.suse.cz>
	<201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
	<20180522061850.GB20020@dhcp22.suse.cz>
	<201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
	<20180523115726.GP20441@dhcp22.suse.cz>
In-Reply-To: <20180523115726.GP20441@dhcp22.suse.cz>
Message-Id: <201805232245.IGI00539.HLtMFOQSJFFOOV@I-love.SAKURA.ne.jp>
Date: Wed, 23 May 2018 22:45:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Wed 23-05-18 19:24:48, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > I don't understand why you are talking about PF_WQ_WORKER case.
> > > 
> > > Because that seems to be the reason to have it there as per your
> > > comment.
> > 
> > OK. Then, I will fold below change into my patch.
> > 
> >         if (did_some_progress) {
> >                 no_progress_loops = 0;
> >  +              /*
> > -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> > -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > ++               * Try to give the OOM killer/reaper/victims some time for
> > ++               * releasing memory.
> >  +               */
> >  +              if (!tsk_is_oom_victim(current))
> >  +                      schedule_timeout_uninterruptible(1);
> 
> Do you really need this? You are still fiddling with this path at all? I
> see how removing the timeout might be reasonable after recent changes
> but why do you insist in adding it outside of the lock.

Sigh... We can't remove this sleep without further changes. That's why I added

 * This schedule_timeout_*() serves as a guaranteed sleep for
 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.

so that we won't by error remove this sleep without further changes.

This sleep is not only for waiting for OOM victims. Any thread who is holding
oom_lock needs CPU resources in order to make forward progress.

If oom_notify_list callbacks are registered, this sleep helps the owner of
oom_lock to reclaim memory by processing the callbacks.

If oom_notify_list callbacks did not release memory, this sleep still helps
the owner of oom_lock to check whether there is inflight OOM victims.

If there is no inflight OOM victims, this sleep still helps the owner of
oom_lock to select a new OOM victim and call printk().

If there are already inflight OOM victims, this sleep still helps the OOM
reaper and the OOM victims to release memory.

Printing messages to consoles and reclaiming memory need CPU resources.
More reliable way is to use mutex_lock_killable(&oom_lock) instead of
mutex_trylock(&oom_lock) in __alloc_pages_may_oom(), but I'm giving way
for now. There is no valid reason for removing this sleep now.
