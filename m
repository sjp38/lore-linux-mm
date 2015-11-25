Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id DF4F06B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 04:33:28 -0500 (EST)
Received: by wmec201 with SMTP id c201so61745810wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 01:33:28 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id k18si33318837wjw.112.2015.11.25.01.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 01:33:27 -0800 (PST)
Received: by wmww144 with SMTP id w144so61036571wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 01:33:27 -0800 (PST)
Date: Wed, 25 Nov 2015 10:33:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151125093325.GA27283@dhcp22.suse.cz>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
 <20151123092925.GB21050@dhcp22.suse.cz>
 <5652DFCE.3010201@suse.cz>
 <20151123101345.GF21050@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
 <20151124094708.GA29472@dhcp22.suse.cz>
 <20151124162604.GB9598@cmpxchg.org>
 <20151124170239.GA13492@dhcp22.suse.cz>
 <20151124195710.GA12923@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124195710.GA12923@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-11-15 14:57:10, Johannes Weiner wrote:
> On Tue, Nov 24, 2015 at 06:02:39PM +0100, Michal Hocko wrote:
> > On Tue 24-11-15 11:26:04, Johannes Weiner wrote:
> > > On Tue, Nov 24, 2015 at 10:47:09AM +0100, Michal Hocko wrote:
> > > > Besides that there is no other reliable warning that we are getting
> > > > _really_ short on memory unlike when the allocation failure is
> > > > allowed. OOM killer report might be missing because there was no actual
> > > > killing happening.
> > > 
> > > This is why I would like to see that warning generalized, and not just
> > > for __GFP_NOFAIL. We have allocations other than explicit __GFP_NOFAIL
> > > that will loop forever in the allocator,
> > 
> > Yes but does it make sense to warn for all of them? Wouldn't it be
> > sufficient to warn about those which cannot allocate anything even
> > though they are doing ALLOC_NO_WATERMARKS?
> 
> Why is it important whether they can do ALLOC_NO_WATERMARKS or not?

Well, the idea was that ALLOC_NO_WATERMARKS failures mean that memory
reserves are not sufficient to handle given workload. min_free_kbytes
is auto-tuned and it might be not sufficient - especially now that we
are adding a new class of consumers of the reserves. I find a warning
as an appropriate way to tell administrator that the auto-tuning was
too optimistic for the particular load.

> I'm worried about all those that can loop forever with locks held.

I can see your point here but I think that looping endlessly without
any progress is a different class of issue. It is hard to tune for it.
You can change tunning and still can end up looping because the lock
vs. reclaim dependencies will be still there.

> > > and when this deadlocks the
> > > machine all we see is other tasks hanging, but not the culprit. If we
> > > were to get a backtrace of some task in the allocator that is known to
> > > hold locks, suddenly all the other hung tasks will make sense, and it
> > > will clearly distinguish such an allocator deadlock from other issues.
> > 
> > Tetsuo was suggesting a more sophisticated infrastructure for tracking
> > allocations [1] which take too long without making progress. I haven't
> > seen his patch because I was too busy with other stuff but maybe this is
> > what you would like to see?
> 
> That seems a bit excessive. I was thinking something more like this:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 05ef7fb..fbfc581 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3004,6 +3004,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>  	bool deferred_compaction = false;
>  	int contended_compaction = COMPACT_CONTENDED_NONE;
> +	unsigned int nr_tries = 0;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3033,6 +3034,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto nopage;
>  
>  retry:
> +	if (++nr_retries % 100 == 0)
> +		warn_alloc_failed(gfp_mask, order, "Potential GFP deadlock\n");
> +

I am not against this in principle. It might be too noisy but
warn_alloc_failed is throttled already so it should handle too many
parallel requests already. I still think that ALLOC_NO_WATERMARKS
failures deserve a special treatment because we can tune for that.
Care to send a patch?

>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
>  
> > Anyway I would like to make some progress on this patch. Do you think
> > that it would be acceptable in the current form without the warning or
> > you preffer a different way?
> 
> Oh, I have nothing against your patch, please go ahead with it. I just
> wondered out loud when you proposed a warning about deadlocking NOFAIL
> allocations but limited it to explicit __GFP_NOFAIL allocations, when
> those obviously aren't the only ones that can deadlock in that way.

As mentioned above I have added it merely because this would be a new
consumer of the reserves which might lead to its depletion without
an explicit warning. But the more I think about that the more I am
convinced that this should be generalized to ALLOC_NO_WATERMARKS.

I will remove the warning from the patch and prepare a separate one
which will warn ALLOC_NO_WATERMARKS so that we can discuss that
separately.

Thanks

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
