Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0A23F6B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 08:41:37 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id f198so71662135wme.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 05:41:36 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id lh1si3048935wjc.78.2016.04.06.05.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 05:41:35 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i204so12833753wmd.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 05:41:35 -0700 (PDT)
Date: Wed, 6 Apr 2016 14:41:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
Message-ID: <20160406124134.GH24272@dhcp22.suse.cz>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
 <201604052012.IGJ69231.VFtMSHFJOOLOFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604052012.IGJ69231.VFtMSHFJOOLOFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 05-04-16 20:12:51, Tetsuo Handa wrote:
[...]
> What I can observe under OOM livelock condition is a three-way dependency loop.
> 
>   (1) An OOM victim (which has TIF_MEMDIE) is unable to make forward progress
>       due to blocked at unkillable lock waiting for other thread's memory
>       allocation.
> 
>   (2) A filesystem writeback work item is unable to make forward progress
>       due to waiting for GFP_NOFS memory allocation to be satisfied because
>       storage I/O is stalling.
> 
>   (3) A disk I/O work item is unable to make forward progress due to
>       waiting for GFP_NOIO memory allocation to be satisfied because
>       an OOM victim does not release memory but the OOM reaper does not
>       unlock TIF_MEMDIE.

It is true that find_lock_task_mm might have returned NULL and so
we cannot reap anything. I guess we want to clear TIF_MEMDIE for such a
task because it wouldn't have been selected in the next oom victim
selection round, so we can argue this would be acceptable. After more
thinking about this we can clear it for tasks which block oom_reaper
because of mmap_sem contention because those would be sitting on the
memory and we can retry to select them later so we cannot end up in the
worse state we are now. I will prepare a patch for that.

[...]

>   (A) We use the same watermark for GFP_KERNEL / GFP_NOFS / GFP_NOIO
>       allocation requests.
> 
>   (B) We allow GFP_KERNEL allocation requests to consume memory to
>       min: watermark.
> 
>   (C) GFP_KERNEL allocation requests might depend on GFP_NOFS
>       allocation requests, and GFP_NOFS allocation requests
>       might depend on GFP_NOIO allocation requests.
> 
>   (D) TIF_MEMDIE thread might wait forever for other thread's
>       GFP_NOFS / GFP_NOIO allocation requests.
> 
> There is no gfp flag that prevents GFP_KERNEL from consuming memory to min:
> watermark. Thus, it is inevitable that GFP_KERNEL allocations consume
> memory to min: watermark and invokes the OOM killer. But if we change
> memory allocations which might block writeback operations to utilize
> memory reserves, it is likely that allocations from workqueue items
> will no longer stall, even without depending on mmap_sem which is a
> weakness of the OOM reaper.

Depending on memory reserves just shifts the issue to a later moment.
Heavy GFP_NOFS loads would deplete this reserve very easily and we are
back to square one.

> Of course, there is no guarantee that allowing such GFP_NOFS / GFP_NOIO
> allocations to utilize memory reserves always avoids OOM livelock. But
> at least we don't need to give up GFP_NOFS / GFP_NOIO allocations
> immediately without trying to utilize memory reserves.
> Therefore, I object this comment
> 
> Michal Hocko wrote:
> > +		/*
> > +		 * XXX: GFP_NOFS allocations should rather fail than rely on
> > +		 * other request to make a forward progress.
> > +		 * We are in an unfortunate situation where out_of_memory cannot
> > +		 * do much for this context but let's try it to at least get
> > +		 * access to memory reserved if the current task is killed (see
> > +		 * out_of_memory). Once filesystems are ready to handle allocation
> > +		 * failures more gracefully we should just bail out here.
> > +		 */
> > +
> 
> that try to make !__GFP_FS allocations fail.

I do not get what do you abject to. The comment is clear that we are not
yet there to make this happen. The primary purpose of the comment is to
make it clear where we should back off and fail if we _ever_ consider
this safe to do.

> It is possible that such GFP_NOFS / GFP_NOIO allocations need to select
> next OOM victim. If we add a guaranteed unlocking mechanism (the simplest
> way is timeout), such GFP_NOFS / GFP_NOIO allocations will succeed, and
> we can avoid loss of reliability of async write operations.

this still relies on somebody else for making a forward progress, which
is not good. I can imagine a highly theoretical situation where even
selecting other task doesn't lead to any relief because most of the
memory might be pinned for some reason.

> (By the way, can swap in/out work even if GFP_NOIO fails?)

The page would be redirtied and kept around if get_swap_bio failed the
GFP_NOIO allocation

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
