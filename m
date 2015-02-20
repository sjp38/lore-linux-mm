Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C43D46B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 04:13:28 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so1492470wiv.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 01:13:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si1546056wiz.74.2015.02.20.01.13.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 01:13:27 -0800 (PST)
Date: Fri, 20 Feb 2015 10:13:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150220091326.GD21248@dhcp22.suse.cz>
References: <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
 <20150219110124.GC15569@phnom.home.cmpxchg.org>
 <20150219122914.GH28427@dhcp22.suse.cz>
 <20150219125844.GI28427@dhcp22.suse.cz>
 <201502200029.DEG78137.QFVLHFFOJMtOOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502200029.DEG78137.QFVLHFFOJMtOOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

On Fri 20-02-15 00:29:29, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 19-02-15 13:29:14, Michal Hocko wrote:
> > [...]
> > > Something like the following.
> > __GFP_HIGH doesn't seem to be sufficient so we would need something
> > slightly else but the idea is still the same:
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8d52ab18fe0d..2d224bbdf8e8 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2599,6 +2599,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> >  	bool deferred_compaction = false;
> >  	int contended_compaction = COMPACT_CONTENDED_NONE;
> > +	int oom = 0;
> >  
> >  	/*
> >  	 * In the slowpath, we sanity check order to avoid ever trying to
> > @@ -2635,6 +2636,15 @@ retry:
> >  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> >  
> >  	/*
> > +	 * __GFP_NOFAIL allocations cannot fail but yet the current context
> > +	 * might be blocking resources needed by the OOM victim to terminate.
> > +	 * Allow the caller to dive into memory reserves to succeed the
> > +	 * allocation and break out from a potential deadlock.
> > +	 */
> 
> We don't know how many callers will pass __GFP_NOFAIL. But if 1000
> threads are doing the same operation which requires __GFP_NOFAIL
> allocation with a lock held, wouldn't memory reserves deplete?

We shouldn't have an unbounded number of GFP_NOFAIL allocations at the
same time. This would be even more broken. If a load is known to use
such allocations excessively then the administrator can enlarge the
memory reserves.

> This heuristic can't continue if memory reserves depleted or
> continuous pages of requested order cannot be found.

Once memory reserves are depleted we are screwed anyway and we might
panic.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
