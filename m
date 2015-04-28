Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADEA6B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:55:39 -0400 (EDT)
Received: by wiun10 with SMTP id n10so30127763wiu.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 06:55:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si13878925wjf.92.2015.04.28.06.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 06:55:37 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:55:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150428135535.GE2659@dhcp22.suse.cz>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, aarcange@redhat.com, david@fromorbit.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 28-04-15 19:34:47, Tetsuo Handa wrote:
[...]
> [PATCH 8/9] makes the speed of allocating __GFP_FS pages extremely slow (5
> seconds / page) because out_of_memory() serialized by the oom_lock sleeps for
> 5 seconds before returning true when the OOM victim got stuck. This throttling
> also slows down !__GFP_FS allocations when there is a thread doing a __GFP_FS
> allocation, for __alloc_pages_may_oom() is serialized by the oom_lock
> regardless of gfp_mask.

This is indeed unnecessary.

> How long will the OOM victim is blocked when the
> allocating task needs to allocate e.g. 1000 !__GFP_FS pages before allowing
> the OOM victim waiting at mutex_lock(&inode->i_mutex) to continue? It will be
> a too-long-to-wait stall which is effectively a deadlock for users. I think
> we should not sleep with the oom_lock held.

I do not see why sleeping with oom_lock would be a problem. It simply
doesn't make much sense to try to trigger OOM killer when there is/are
OOM victims still exiting.

> Also, allowing any !fatal_signal_pending() threads doing __GFP_FS allocations
> (e.g. malloc() + memset()) to dip into the reserves will deplete them when the
> OOM victim is blocked for a thread doing a !__GFP_FS allocation, for
> [PATCH 9/9] does not allow !test_thread_flag(TIF_MEMDIE) threads doing
> !__GFP_FS allocations to access the reserves. Of course, updating [PATCH 9/9]
> like
> 
> -+     if (*did_some_progress)
> -+          alloc_flags |= ALLOC_NO_WATERMARKS;
>   out:
> ++     if (*did_some_progress)
> ++          alloc_flags |= ALLOC_NO_WATERMARKS;
>        mutex_unlock(&oom_lock);
> 
> (which means use of "no watermark" without invoking the OOM killer) is
> obviously wrong. I think we should not allow __GFP_FS allocations to
> access to the reserves when the OOM victim is blocked.
> 
> By the way, I came up with an idea (incomplete patch on top of patches up to
> 7/9 is shown below) while trying to avoid sleeping with the oom_lock held.
> This patch is meant for
> 
>   (1) blocking_notifier_call_chain(&oom_notify_list) is called after
>       the OOM killer is disabled in order to increase possibility of
>       memory allocation to succeed.

How do you guarantee that the notifier doesn't wake up any process and
break the oom_disable guarantee?

>   (2) oom_kill_process() can determine when to kill next OOM victim.
> 
>   (3) oom_scan_process_thread() can take TIF_MEMDIE timeout into
>       account when choosing an OOM victim.

You have heard my opinions about this and I do not plan to repeat them
here again.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
