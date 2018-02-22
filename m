Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5406B02C9
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:06:31 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x77so938082wmd.0
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:06:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 123si217856wmo.252.2018.02.22.05.06.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 05:06:29 -0800 (PST)
Date: Thu, 22 Feb 2018 14:06:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: wait for oom_lock than back off
Message-ID: <20180221145437.GI2231@dhcp22.suse.cz>
References: <20180123124245.GK1526@dhcp22.suse.cz>
 <201801242228.FAD52671.SFFLQMOVOFHOtJ@I-love.SAKURA.ne.jp>
 <201802132058.HAG51540.QFtSLOJFOOFVMH@I-love.SAKURA.ne.jp>
 <201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp>
 <20180220144920.GB21134@dhcp22.suse.cz>
 <201802212327.CAB51013.FOStFVLHFJMOOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201802212327.CAB51013.FOStFVLHFJMOOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

On Wed 21-02-18 23:27:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 20-02-18 22:32:56, Tetsuo Handa wrote:
> > > >From c3b6616238fcd65d5a0fdabcb4577c7e6f40d35e Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Tue, 20 Feb 2018 11:07:23 +0900
> > > Subject: [PATCH] mm,page_alloc: wait for oom_lock than back off
> > > 
> > > This patch fixes a bug which is essentially same with a bug fixed by
> > > commit 400e22499dd92613 ("mm: don't warn about allocations which stall for
> > > too long").
> > > 
> > > Currently __alloc_pages_may_oom() is using mutex_trylock(&oom_lock) based
> > > on an assumption that the owner of oom_lock is making progress for us. But
> > > it is possible to trigger OOM lockup when many threads concurrently called
> > > __alloc_pages_slowpath() because all CPU resources are wasted for pointless
> > > direct reclaim efforts. That is, schedule_timeout_uninterruptible(1) in
> > > __alloc_pages_may_oom() does not always give enough CPU resource to the
> > > owner of the oom_lock.
> > > 
> > > It is possible that the owner of oom_lock is preempted by other threads.
> > > Preemption makes the OOM situation much worse. But the page allocator is
> > > not responsible about wasting CPU resource for something other than memory
> > > allocation request. Wasting CPU resource for memory allocation request
> > > without allowing the owner of oom_lock to make forward progress is a page
> > > allocator's bug.
> > > 
> > > Therefore, this patch changes to wait for oom_lock in order to guarantee
> > > that no thread waiting for the owner of oom_lock to make forward progress
> > > will not consume CPU resources for pointless direct reclaim efforts.
> > 
> > So instead we will have many tasks sleeping on the lock and prevent the
> > oom reaper to make any forward progress. This is not a solution without
> > further steps. Also I would like to see a real life workload that would
> > benefit from this.
> 
> Of course I will propose follow-up patches.

The patch in its current form will cause a worse behavior than we have
currently, because pending oom waiters simply block the oom reaper. So I
do not really see any reason to push this forward without other changes.

So NAK to this patch in its current form.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
