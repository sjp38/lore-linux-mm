Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 41A126B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 11:22:49 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id f206so29146168wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 08:22:49 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id u128si6292322wmd.39.2016.01.05.08.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 08:22:48 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id f206so29145511wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 08:22:47 -0800 (PST)
Date: Tue, 5 Jan 2016 17:22:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killer
 under OOM livelock
Message-ID: <20160105162246.GH15324@dhcp22.suse.cz>
References: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 30-12-15 15:33:47, Tetsuo Handa wrote:
> >From 7fcac2054b33dc3df6c5915a58f232b9b80bb1e6 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 30 Dec 2015 15:24:40 +0900
> Subject: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killer under OOM livelock
> 
> This patch is similar to what commit 373ccbe5927034b5 ("mm, vmstat:
> allow WQ concurrency to discover memory reclaim doesn't make any
> progress") does, but this patch is for SysRq-f.
>
> SysRq-f is a method for reclaiming memory by manually invoking the OOM
> killer. Therefore, it needs to be invokable even when the system is
> looping under OOM livelock condition.

Yes this makes a lot of sense and thanks for doing it. I have it on my
todo list but didn't get to it yet. I guess this is not only sysrq+f
specific though. What about emergency reboot or manual crash invocation?

I think all of them deserve an immediate action and so they should share
the same wq.
 
> While making sure that we give workqueue items a chance to run is
> done by "mm,oom: Always sleep before retrying." patch, allocating
> a dedicated workqueue only for SysRq-f might be too wasteful when
> there is the OOM reaper kernel thread which will be idle when
> we need to use SysRq-f due to OOM livelock condition.
> 
> I wish for a kernel thread that does OOM-kill operation.
> Maybe we can change the OOM reaper kernel thread to do it.
> What do you think?

I do no think a separate kernel thread would help much if the
allocations have to keep looping in the allocator. oom_reaper is a
separate kernel thread only due to locking required for the exit_mmap
path.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
