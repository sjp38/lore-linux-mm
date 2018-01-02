Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 306756B02A6
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 06:40:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so14391585wmd.0
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 03:40:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d200si21901414wmd.238.2018.01.02.03.40.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Jan 2018 03:40:19 -0800 (PST)
Date: Tue, 2 Jan 2018 12:40:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Is GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) &
 ~__GFP_DIRECT_RECLAIM supported?
Message-ID: <20180102114017.GB25397@dhcp22.suse.cz>
References: <201801021108.BCC17635.FQtOHMOLJSVFFO@I-love.SAKURA.ne.jp>
 <20180102091457.GA25397@dhcp22.suse.cz>
 <201801021856.CBE48424.HFSOMFLJFOOVtQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201801021856.CBE48424.HFSOMFLJFOOVtQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, wei.w.wang@intel.com, willy@infradead.org, mst@redhat.com

On Tue 02-01-18 18:56:56, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 02-01-18 11:08:47, Tetsuo Handa wrote:
> > > virtio-balloon wants to try allocation only when that allocation does not cause
> > > OOM situation. Since there is no gfp flag which succeeds allocations only if
> > > there is plenty of free memory (i.e. higher watermark than other requests),
> > > virtio-balloon needs to watch for OOM notifier and release just allocated memory
> > > when OOM notifier is invoked.
> > 
> > I do not understand the last part mentioning OOM notifier.
> > 
> > > Currently virtio-balloon is using
> > > 
> > >   GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY
> > > 
> > > for allocation, but is
> > > 
> > >   GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) & ~__GFP_DIRECT_RECLAIM
> > > 
> > > supported (from MM subsystem's point of view) ?
> > 
> > Semantically I do not see any reason why we shouldn't support
> > non-sleeping user allocation with an explicit nomemalloc flag.
> 
> I see. Then, allocating with balloon_lock held can become a choice.
> 
> The virtio-balloon driver is trying to allocate many pages using
> GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY for inflating the
> balloon, and then hold the balloon_lock, and then is trying to allocate some
> more pages using GFP_NOWAIT for faster communication using scatter-gather API.
> 
> Unfortunately, since the former memory is not visible to OOM notifier path until
> the latter memory is allocated, when someone hit OOM notifier path before the
> driver holds the balloon_lock, the driver fails to release the former memory
> (i.e. premature OOM killer invocation).
> 
> While it would be possible to make the former memory visible to OOM notifier path,
> allocating (GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC) & ~__GFP_DIRECT_RECLAIM and
> GFP_NOWAIT with the balloon_lock held would simplify the code.
> 
> >                                                                Btw. why
> > is __GFP_NOMEMALLOC needed at all?
> 
> Because there is no need to use memory reserves for memory allocations for
> inflating the balloon. If we use memory reserves for inflating the balloon,
> some allocation request will immediately hit OOM notifier path, and we will
> after all release memory allocated from memory reserves.

Well, the primary reason to use __GFP_NOMEMALLOC is to override either
PF_MEMALLOC or an explicit use of __GFP_MEMALLOC from the above layer.
Normally you shouldn't really care. So the question is whether this
allocation is called from a context which uses the above...

> Although there will be no need to specify __GFP_NOMEMALLOC because it is
> a workqueue context

... so the above doesn't seem to be the case.

> which does this allocation (which will never cause
> __gfp_pfmemalloc_flags() to return ALLOC_OOM), I think there will be
> no harm with shortcutting __gfp_pfmemalloc_flags() by specifying
> __GFP_NOMEMALLOC.

I do not see a reason why. Moreover I think the usage of
__GFP_NOMEMALLOC should be reduced because it tends to be wrong in many
cases. People just tend to add it without a deeper understanding why.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
