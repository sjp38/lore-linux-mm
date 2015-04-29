Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8ED6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 14:31:39 -0400 (EDT)
Received: by wgin8 with SMTP id n8so37863989wgi.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:31:38 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id wc10si303481wic.59.2015.04.29.11.31.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 11:31:37 -0700 (PDT)
Received: by wgyo15 with SMTP id o15so37861406wgy.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:31:37 -0700 (PDT)
Date: Wed, 29 Apr 2015 20:31:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150429183135.GH31341@dhcp22.suse.cz>
References: <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
 <20150428135535.GE2659@dhcp22.suse.cz>
 <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
 <20150429125506.GB7148@cmpxchg.org>
 <20150429144031.GB31341@dhcp22.suse.cz>
 <201504300227.JCJ81217.FHOLSQVOFFJtMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201504300227.JCJ81217.FHOLSQVOFFJtMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, aarcange@redhat.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 30-04-15 02:27:44, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 29-04-15 08:55:06, Johannes Weiner wrote:
> > > What we can do to mitigate this is tie the timeout to the setting of
> > > TIF_MEMDIE so that the wait is not 5s from the point of calling
> > > out_of_memory() but from the point of where TIF_MEMDIE was set.
> > > Subsequent allocations will then go straight to the reserves.
> > 
> > That would deplete the reserves very easily. Shouldn't we rather
> > go other way around? Allow OOM killer context to dive into memory
> > reserves some more (ALLOC_OOM on top of current ALLOC flags and
> > __zone_watermark_ok would allow an additional 1/4 of the reserves) and
> > start waiting for the victim after that reserve is depleted. We would
> > still have some room for TIF_MEMDIE to allocate, the reserves consumption
> > would be throttled somehow and the holders of resources would have some
> > chance to release them and allow the victim to die.
> 
> Does OOM killer context mean memory allocations which can call out_of_memory()?

Yes, that was the idea, because others will not reclaim any memory. Even
all those which invoke out_of_memory will not kill a new task but one
killed task should compensate for the ALLOC_OOM part of the memory
reserves.

> If yes, there is no guarantee that such memory reserve is used by threads which
> the OOM victim is waiting for, for they might do only !__GFP_FS allocations.

OK, so we are back to GFP_NOFS. Right, those are your main pain point
because you can see i_mutex deadlocks. But really, those allocations
should simply fail because looping in the allocator and rely on others
to make a progress is simply retarded.

I thought that Dave was quite explicit that they do not strictly
need nofail behavior of GFP_NOFS but rather a GFP flag which
would allow to dive into reserves some more for specific contexts
(http://marc.info/?l=linux-mm&m=142897087230385&w=2). I also do not
remember him or anybody else saying that _every_ GFP_NOFS should get the
access to reserves automatically.

Dave, could you clarify/confirm, please?

Because we are going back and forth about GFP_NOFS without any progress
for a very long time already and it seems one class of issues could be
handled by this change already.

I mean we should eventually fail all the allocation types but GFP_NOFS
is coming from _carefully_ handled code paths which is an easier starting
point than a random code path in the kernel/drivers. So can we finally
move at least in this direction?

> Likewise, there is possibility that such memory reserve is used by threads
> which the OOM victim is not waiting for, for malloc() + memset() causes
> __GFP_FS allocations.

We cannot be certain without complete dependency tracking. This is
just a heuristic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
