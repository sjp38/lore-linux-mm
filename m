Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id F179B6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 10:40:35 -0400 (EDT)
Received: by wizk4 with SMTP id k4so182989495wiz.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 07:40:35 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id h8si44193724wjs.46.2015.04.29.07.40.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 07:40:34 -0700 (PDT)
Received: by widdi4 with SMTP id di4so182609424wid.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 07:40:33 -0700 (PDT)
Date: Wed, 29 Apr 2015 16:40:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150429144031.GB31341@dhcp22.suse.cz>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
 <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
 <20150428135535.GE2659@dhcp22.suse.cz>
 <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
 <20150429125506.GB7148@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150429125506.GB7148@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, aarcange@redhat.com, david@fromorbit.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 29-04-15 08:55:06, Johannes Weiner wrote:
> On Wed, Apr 29, 2015 at 12:50:37AM +0900, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 28-04-15 19:34:47, Tetsuo Handa wrote:
> > > [...]
> > > > [PATCH 8/9] makes the speed of allocating __GFP_FS pages extremely slow (5
> > > > seconds / page) because out_of_memory() serialized by the oom_lock sleeps for
> > > > 5 seconds before returning true when the OOM victim got stuck. This throttling
> > > > also slows down !__GFP_FS allocations when there is a thread doing a __GFP_FS
> > > > allocation, for __alloc_pages_may_oom() is serialized by the oom_lock
> > > > regardless of gfp_mask.
> > > 
> > > This is indeed unnecessary.
> > > 
> > > > How long will the OOM victim is blocked when the
> > > > allocating task needs to allocate e.g. 1000 !__GFP_FS pages before allowing
> > > > the OOM victim waiting at mutex_lock(&inode->i_mutex) to continue? It will be
> > > > a too-long-to-wait stall which is effectively a deadlock for users. I think
> > > > we should not sleep with the oom_lock held.
> > > 
> > > I do not see why sleeping with oom_lock would be a problem. It simply
> > > doesn't make much sense to try to trigger OOM killer when there is/are
> > > OOM victims still exiting.
> > 
> > Because thread A's memory allocation is deferred by threads B, C, D...'s memory
> > allocation which are holding (or waiting for) the oom_lock when the OOM victim
> > is waiting for thread A's allocation. I think that a memory allocator which
> > allocates at average 5 seconds is considered as unusable. If we sleep without
> > the oom_lock held, the memory allocator can allocate at average
> > (5 / number_of_allocating_threads) seconds. Sleeping with the oom_lock held
> > can effectively prevent thread A from making progress.
> 
> I agree with that.  The problem with the sleeping is that it has to be
> long enough to give the OOM victim a fair chance to exit, but short
> enough to not make the page allocator unusable in case there is a
> genuine deadlock.  And you are right, the context blocking the OOM
> victim from exiting might do a whole string of allocations, not just
> one, before releasing any locks.
> 
> What we can do to mitigate this is tie the timeout to the setting of
> TIF_MEMDIE so that the wait is not 5s from the point of calling
> out_of_memory() but from the point of where TIF_MEMDIE was set.
> Subsequent allocations will then go straight to the reserves.

That would deplete the reserves very easily. Shouldn't we rather
go other way around? Allow OOM killer context to dive into memory
reserves some more (ALLOC_OOM on top of current ALLOC flags and
__zone_watermark_ok would allow an additional 1/4 of the reserves) and
start waiting for the victim after that reserve is depleted. We would
still have some room for TIF_MEMDIE to allocate, the reserves consumption
would be throttled somehow and the holders of resources would have some
chance to release them and allow the victim to die.

If the allocation still fails after the timeout then we should consider
failing the allocation as the next step or give NO_WATERMARK to
GFP_NOFAIL.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
