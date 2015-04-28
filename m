Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 84F176B007D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:23:21 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so22242656ieb.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:23:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id mu7si8847125igb.29.2015.04.28.09.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 09:23:20 -0700 (PDT)
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
	<201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
	<20150428135535.GE2659@dhcp22.suse.cz>
In-Reply-To: <20150428135535.GE2659@dhcp22.suse.cz>
Message-Id: <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
Date: Wed, 29 Apr 2015 00:50:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, aarcange@redhat.com, david@fromorbit.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 28-04-15 19:34:47, Tetsuo Handa wrote:
> [...]
> > [PATCH 8/9] makes the speed of allocating __GFP_FS pages extremely slow (5
> > seconds / page) because out_of_memory() serialized by the oom_lock sleeps for
> > 5 seconds before returning true when the OOM victim got stuck. This throttling
> > also slows down !__GFP_FS allocations when there is a thread doing a __GFP_FS
> > allocation, for __alloc_pages_may_oom() is serialized by the oom_lock
> > regardless of gfp_mask.
> 
> This is indeed unnecessary.
> 
> > How long will the OOM victim is blocked when the
> > allocating task needs to allocate e.g. 1000 !__GFP_FS pages before allowing
> > the OOM victim waiting at mutex_lock(&inode->i_mutex) to continue? It will be
> > a too-long-to-wait stall which is effectively a deadlock for users. I think
> > we should not sleep with the oom_lock held.
> 
> I do not see why sleeping with oom_lock would be a problem. It simply
> doesn't make much sense to try to trigger OOM killer when there is/are
> OOM victims still exiting.

Because thread A's memory allocation is deferred by threads B, C, D...'s memory
allocation which are holding (or waiting for) the oom_lock when the OOM victim
is waiting for thread A's allocation. I think that a memory allocator which
allocates at average 5 seconds is considered as unusable. If we sleep without
the oom_lock held, the memory allocator can allocate at average
(5 / number_of_allocating_threads) seconds. Sleeping with the oom_lock held
can effectively prevent thread A from making progress.

> > By the way, I came up with an idea (incomplete patch on top of patches up to
> > 7/9 is shown below) while trying to avoid sleeping with the oom_lock held.
> > This patch is meant for
> > 
> >   (1) blocking_notifier_call_chain(&oom_notify_list) is called after
> >       the OOM killer is disabled in order to increase possibility of
> >       memory allocation to succeed.
> 
> How do you guarantee that the notifier doesn't wake up any process and
> break the oom_disable guarantee?

I thought oom_notify_list wakes up only kernel threads. OK, that's the reason
we don't call oom_notify_list after the OOM killer is disabled?

> 
> >   (2) oom_kill_process() can determine when to kill next OOM victim.
> > 
> >   (3) oom_scan_process_thread() can take TIF_MEMDIE timeout into
> >       account when choosing an OOM victim.
> 
> You have heard my opinions about this and I do not plan to repeat them
> here again.

Yes, I've heard your opinions. But neither ALLOC_NO_WATERMARKS nor WMARK_OOM
is a perfect measure for avoiding deadlock. We want to solve "Without any
extra measures the above situation will result in a deadlock" problem.
When WMARK_OOM failed to avoid the deadlock, and we don't want to go to
ALLOC_NO_WATERMARKS, I think somehow choosing and killing more victims is
the only possible measure. Maybe choosing next OOM victim upon reaching
WMARK_OOM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
