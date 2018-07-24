Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A64786B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:51:17 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 90-v6so1675999pla.18
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 15:51:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f18-v6sor2859664pgd.94.2018.07.24.15.51.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 15:51:16 -0700 (PDT)
Date: Tue, 24 Jul 2018 15:51:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v4] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <05dbc69a-1c26-adec-15c6-f7192f8d2ae0@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807241549420.215249@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com> <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com> <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com> <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807201505550.38399@chino.kir.corp.google.com>
 <f8d24892-b05e-73a8-36d5-4fe278f84c44@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807241444370.206335@chino.kir.corp.google.com> <05dbc69a-1c26-adec-15c6-f7192f8d2ae0@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Jul 2018, Tetsuo Handa wrote:

> >> You might worry about situations where __oom_reap_task_mm() is a no-op.
> >> But that is not always true. There is no point with emitting
> >>
> >>   pr_info("oom_reaper: unable to reap pid:%d (%s)\n", ...);
> >>   debug_show_all_locks();
> >>
> >> noise and doing
> >>
> >>   set_bit(MMF_OOM_SKIP, &mm->flags);
> >>
> >> because exit_mmap() will not release oom_lock until __oom_reap_task_mm()
> >> completes. That is, except extra noise, there is no difference with
> >> current behavior which sets set_bit(MMF_OOM_SKIP, &mm->flags) after
> >> returning from __oom_reap_task_mm().
> >>
> > 
> > v5 has restructured how exit_mmap() serializes its unmapping with the oom 
> > reaper.  It sets MMF_OOM_SKIP while holding mm->mmap_sem.
> > 
> 
> I think that v5 is still wrong. exit_mmap() keeps mmap_sem held for write does
> not prevent oom_reap_task() from emitting the noise and setting MMF_OOM_SKIP
> after timeout. Since your purpose is to wait for release of memory which could
> not be reclaimed by __oom_reap_task_mm(), what if __oom_reap_task_mm() was no-op and
> exit_mmap() was preempted immediately after returning from __oom_reap_task_mm() ?
> 

If exit_mmap() gets preempted indefinitely before it can free any memory, 
we are better off oom killing another process.  The purpose of the timeout 
is to give an oom victim an amount of time to free its memory and exit 
before selecting another victim.
