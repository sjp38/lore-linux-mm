Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 603EE6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 10:11:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so13171845wrc.15
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 07:11:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10si6061875wrc.20.2017.07.20.07.11.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 07:11:40 -0700 (PDT)
Date: Thu, 20 Jul 2017 16:11:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: close race without using oom_lock
Message-ID: <20170720141138.GJ9058@dhcp22.suse.cz>
References: <1500386810-4881-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170718141602.GB19133@dhcp22.suse.cz>
 <201707190551.GJE30718.OFHOQMFJtVSFOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707190551.GJE30718.OFHOQMFJtVSFOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Wed 19-07-17 05:51:03, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 18-07-17 23:06:50, Tetsuo Handa wrote:
> > > Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> > > guarded whole OOM reaping operations using oom_lock. But there was no
> > > need to guard whole operations. We needed to guard only setting of
> > > MMF_OOM_REAPED flag because get_page_from_freelist() in
> > > __alloc_pages_may_oom() is called with oom_lock held.
> > > 
> > > If we change to guard only setting of MMF_OOM_SKIP flag, the OOM reaper
> > > can start reaping operations as soon as wake_oom_reaper() is called.
> > > But since setting of MMF_OOM_SKIP flag at __mmput() is not guarded with
> > > oom_lock, guarding only the OOM reaper side is not sufficient.
> > > 
> > > If we change the OOM killer side to ignore MMF_OOM_SKIP flag once,
> > > there is no need to guard setting of MMF_OOM_SKIP flag, and we can
> > > guarantee a chance to call get_page_from_freelist() in
> > > __alloc_pages_may_oom() without depending on oom_lock serialization.
> > > 
> > > This patch makes MMF_OOM_SKIP act as if MMF_OOM_REAPED, and adds a new
> > > flag which acts as if MMF_OOM_SKIP, in order to close both race window
> > > (the OOM reaper side and __mmput() side) without using oom_lock.
> > 
> > Why do we need this patch when
> > http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org
> > already removes the lock and solves another problem at once?
> 
> We haven't got an answer from Hugh and/or Andrea whether that patch is safe.

So what? I haven't see anybody disputing the correctness. And to be
honest I really dislike your patch. Yet another round kind of solutions
are just very ugly hacks usually because they are highly timing
sensitive.

> Even if that patch is safe, this patch still helps with CONFIG_MMU=n case.

Could you explain how?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
