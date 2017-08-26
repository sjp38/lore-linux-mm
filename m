Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3156810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 21:28:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v123so2209027oif.11
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:28:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a62si6232188oif.90.2017.08.25.18.28.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 18:28:28 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,page_alloc: Don't call __node_reclaim() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170825134714.844d9fb169e5b1883c3dd6eb@linux-foundation.org>
In-Reply-To: <20170825134714.844d9fb169e5b1883c3dd6eb@linux-foundation.org>
Message-Id: <201708261028.HBH81733.HOtQJLMVFOFFOS@I-love.SAKURA.ne.jp>
Date: Sat, 26 Aug 2017 10:28:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mgorman@suse.de, mhocko@suse.com, vbabka@suse.cz

Andrew Morton wrote:
> On Thu, 24 Aug 2017 21:18:25 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > We are doing last second memory allocation attempt before calling
> > out_of_memory(). But since slab shrinker functions might indirectly
> > wait for other thread's __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> > allocations via sleeping locks, calling slab shrinker functions from
> > node_reclaim() from get_page_from_freelist() with oom_lock held has
> > possibility of deadlock. Therefore, make sure that last second memory
> > allocation attempt does not call slab shrinker functions.
> 
> I wonder if there's any way we could gert lockdep to detect this sort
> of thing.

That is hopeless regarding MM subsystem.

The root problem is that MM subsystem assumes that somebody else shall make
progress for me. And direct reclaim does not check for other thread's progress
(e.g. too_many_isolated() looping forever waiting for kswapd) and continue
consuming CPU resource (e.g. deprive a thread doing schedule_timeout_killable()
with oom_lock held of all CPU time for doing pointless get_page_from_freelist()
etc.).

Since the page allocator chooses retry the attempt rather than wait for locks,
lockdep won't help. The dependency is spreaded to all threads with timing and
threshold checks, preventing threads from calling operations which lockdep
will detect.

I do wish we can get rid of __GFP_DIRECT_RECLAIM and offload memory reclaim
operation to some kswapd-like kernel threads. Then, we would be able to check
progress of relevant threads and invoke the OOM killer as needed (rather than
doing __GFP_FS check in out_of_memory()), as well as implementing __GFP_KILLABLE.

> 
> Has the deadlock been observed in testing?  Do we think this fix
> should be backported into -stable?

I have never observed this deadlock, but it is hard for everybody to know
if he/she hit this deadlock. The only clue which is available since 4.9+
(though still unreliable) is warn_alloc() complaining memory allocation is
stalling for some reason. For users using 2.6.18/2.6.32/3.10 kernels, they
have absolutely no clue to know it (other than using SysRq-t etc. which is
generating too much messages and asking for too much efforts).

Judging from my experience at a support center, it is too difficult for users
to report memory allocation hangs. It requires users to stand by in front of
the console twenty-four seven so that we get SysRq-t etc. whenever a memory
allocation related problem is suspected. We can't ask users for such effort.
There is no report does not mean memory allocation hang is not occurring in
the real life. But nobody (other than me) is interested in adding asynchronous
watchdog like kmallocwd. Thus, I'm spending much effort for finding potential
lockup bugs using stress tests, and Michal do not care bugs which are found by
stress tests, and nobody else are responding, and users do not have a reliable
mean to report lockup bugs caused by memory allocation (e.g. kmallocwd).

Sigh.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
