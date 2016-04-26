Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 592146B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:00:25 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y69so28454333oif.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:00:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t32si9840671ota.108.2016.04.26.07.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 07:00:24 -0700 (PDT)
Subject: Re: [PATCH v2] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp>
	<20160419200752.GA10437@dhcp22.suse.cz>
	<201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
	<201604201937.AGB86467.MOFFOOQJVFHLtS@I-love.SAKURA.ne.jp>
	<20160425114733.GF23933@dhcp22.suse.cz>
In-Reply-To: <20160425114733.GF23933@dhcp22.suse.cz>
Message-Id: <201604262300.IFD43745.FMOLFJFQOVStHO@I-love.SAKURA.ne.jp>
Date: Tue, 26 Apr 2016 23:00:15 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> Hmm, I guess we have already discussed that in the past but I might
> misremember. The above relies on oom killer to be triggered after the
> previous victim was selected. There is no guarantee this will happen.

Why there is no guarantee this will happen?

This OOM livelock is caused by waiting for TIF_MEMDIE threads forever
unconditionally. If oom_unkillable_task() is not called, it is not
the OOM killer's problem.

Are you talking about doing did_some_progress = 1 for !__GFP_FS && !__GFP_NOFAIL
allocations without calling oom_unkillable_task() ? Then, I insist that this is
the page allocator's problem. GFP_NOIO and GFP_NOFS allocations wake up kswapd,
and kswapd does __GFP_FS reclaim. If the kswapd is unable to make forward
progress (an example is
http://I-love.SAKURA.ne.jp/tmp/serial-20160314-too-many-isolated2.txt.xz

----------
[  485.216878] Out of memory: Kill process 1356 (a.out) score 999 or sacrifice child
[  485.219170] Killed process 1356 (a.out) total-vm:4176kB, anon-rss:80kB, file-rss:0kB, shmem-rss:0kB
[  514.255929] MemAlloc-Info: stalling=146 dying=0 exiting=0 victim=0 oom_count=1/226
(...snipped...)
[  540.998623] MemAlloc-Info: stalling=146 dying=0 exiting=0 victim=0 oom_count=1/226
[  571.003817] MemAlloc-Info: stalling=152 dying=0 exiting=0 victim=0 oom_count=1/226
(...snipped...)
[  585.888300] MemAlloc-Info: stalling=152 dying=0 exiting=0 victim=0 oom_count=1/226
----------
), we are already OOM and we need to hear from administrator's decision (i.e.
either fail !__GFP_FS && !__GFP_NOFAIL allocations or select an OOM victim).
This OOM livelock is caused by waiting for somebody else forever unconditionally.

These OOM livelocks are caused by lack of mechanism for hearing administrator's
policy. We are missing rescue mechanisms which are needed for recovering from
situations your model did not expect.

I'm talking about corner cases where your deterministic approach fail. What we
need is "stop waiting for something forever unconditionally" and "hear what the
administrator wants to do". You can deprecate and then remove sysctl knobs for
hearing what the administrator wants to do when you developed perfect model and
mechanism.

> Why cannot we get back to the timer based solution at least for the
> panic timeout?

Use of global timer can cause false positive panic() calls.
Timeout should be calculated for per task_struct or signal_struct basis.

Also, although a different problem, global timer based solution does not
work for OOM livelock without any TIF_MEMDIE thread case (an example
shown above).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
