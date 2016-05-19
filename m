Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7E6C6B0253
	for <linux-mm@kvack.org>; Thu, 19 May 2016 13:20:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a17so39680671wme.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 10:20:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jo9si19272213wjc.10.2016.05.19.10.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 10:20:58 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so22677475wmw.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 10:20:58 -0700 (PDT)
Date: Thu, 19 May 2016 19:20:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom_reaper: do not mmput synchronously from the
 oom reaper context
Message-ID: <20160519172056.GA5290@dhcp22.suse.cz>
References: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
 <1461679470-8364-3-git-send-email-mhocko@kernel.org>
 <201605192329.ABB17132.LFHOFJMVtOSFQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605192329.ABB17132.LFHOFJMVtOSFQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

On Thu 19-05-16 23:29:38, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Tetsuo has properly noted that mmput slow path might get blocked waiting
> > for another party (e.g. exit_aio waits for an IO). If that happens the
> > oom_reaper would be put out of the way and will not be able to process
> > next oom victim. We should strive for making this context as reliable
> > and independent on other subsystems as much as possible.
> > 
> > Introduce mmput_async which will perform the slow path from an async
> > (WQ) context. This will delay the operation but that shouldn't be a
> > problem because the oom_reaper has reclaimed the victim's address space
> > for most cases as much as possible and the remaining context shouldn't
> > bind too much memory anymore. The only exception is when mmap_sem
> > trylock has failed which shouldn't happen too often.
> > 
> > The issue is only theoretical but not impossible.
> 
> Just a random thought, but after this patch is applied, do we still need to use
> a dedicated kernel thread for OOM-reap operation? If I recall correctly, the
> reason we decided to use a dedicated kernel thread was that calling
> down_read(&mm->mmap_sem) / mmput() from the OOM killer context is unsafe due to
> dependency. By replacing mmput() with mmput_async(), since __oom_reap_task() will
> no longer do operations that might block, can't we try OOM-reap operation from
> current thread which called mark_oom_victim() or oom_scan_process_thread() ?

I was already thinking about that. It is true that the main blocker
was the mmput, as you say, but the dedicated kernel thread seems to be
more robust locking and stack wise. So I would prefer staying with the
current approach until we see that it is somehow limitting. One pid and
kernel stack doesn't seem to be a terrible price to me. But as I've said
I am not bound to the kernel thread approach...

> I want to start waking up the OOM reaper whenever TIF_MEMDIE is set or found.
> 
> Using a dedicated kernel thread is still better because memory allocation path
> already consumed a lot of kernel stack? But we don't need to give up OOM-reaping
> when kthread_run() failed.

Is kthread_run failure during early boot even an option? Isn't such a
system screwed up by definition?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
