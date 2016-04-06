Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF58B6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 05:26:23 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id u206so36919593wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:26:23 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v7si2264906wjy.23.2016.04.06.02.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 02:26:22 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so11421897wma.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 02:26:22 -0700 (PDT)
Date: Wed, 6 Apr 2016 11:26:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-ID: <20160406092620.GD24272@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
 <20160405165826.012236e79db7f396fda546a8@linux-foundation.org>
 <alpine.LSU.2.11.1604051727150.7348@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051727150.7348@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 05-04-16 17:55:39, Hugh Dickins wrote:
> On Tue, 5 Apr 2016, Andrew Morton wrote:
> > On Tue,  5 Apr 2016 13:25:31 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > > -	if (is_thp_gfp_mask(gfp_mask)) {
> > > -		/*
> > > -		 * If compaction is deferred for high-order allocations, it is
> > > -		 * because sync compaction recently failed. If this is the case
> > > -		 * and the caller requested a THP allocation, we do not want
> > > -		 * to heavily disrupt the system, so we fail the allocation
> > > -		 * instead of entering direct reclaim.
> > > -		 */
> > > -		if (compact_result == COMPACT_DEFERRED)
> > > -			goto nopage;
> > > -
> > > -		/*
> > > -		 * Compaction is contended so rather back off than cause
> > > -		 * excessive stalls.
> > > -		 */
> > > -		if(compact_result == COMPACT_CONTENDED)
> > > -			goto nopage;
> > > -	}
> > > +	/*
> > > +	 * Checks for THP-specific high-order allocations and back off
> > > +	 * if the the compaction backed off
> > > +	 */
> > > +	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
> > > +		goto nopage;
> > 
> > This change smashed into Hugh's "huge tmpfs: shmem_huge_gfpmask and
> > shmem_recovery_gfpmask".
> > 
> > I ended up doing this:
> > 
> > 	/* Checks for THP-specific high-order allocations */
> > 	if (!is_thp_allocation(gfp_mask, order))
> > 		migration_mode = MIGRATE_SYNC_LIGHT;
> > 
> > 	/*
> > 	 * Checks for THP-specific high-order allocations and back off
> > 	 * if the the compaction backed off
> > 	 */
> > 	if (is_thp_allocation(gfp_mask) && compaction_withdrawn(compact_result))
> > 		goto nopage;
> 
> You'll already have found that is_thp_allocation() needs the order too.
> But then you had to drop a hunk out of his 10/11 also to fit with mine.
> 
> What you've done may be just right, but I haven't had time to digest
> Michal's changes yet (and not yet seen what happens to the PF_KTHREAD
> distinction), so I think it will probably end up better if you take
> his exactly as he tested and posted them, and drop my 30/31 and 31/31
> for now

I have only briefly checked your patch30 but I guess the above is
not really necessary. If the request is __GFP_REPEAT (I haven't checked
whether that is the case for shmem) then we promote to MIGRATE_SYNC_LIGHT
as soon as we cannot move on with ASYNC. For !__GFP_REPEAT I did
+       if (is_thp_gfp_mask(gfp_mask) && !(current->flags & PF_KTHREAD))
+               migration_mode = MIGRATE_ASYNC;
+       else
+               migration_mode = MIGRATE_SYNC_LIGHT;
        page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
                                            ac, migration_mode,
                                            &compact_result);

so you will end up doing SYNC_LIGHT for !is_thp_allocation as well

> - I can resubmit them (or maybe drop 30 altogether) after I've
> pondered and tested a little on top of Michal's.

I guess this would be safer. If it turns out that we need some special
handling I would prefer if that could be done in should_compact_retry.
 
> Huge tmpfs got along fine for many months without 30/31 and 31/31: 30
> is just for experimentation, and 31 to reduce the compaction stalls we
> saw under some loads.  Maybe I'll find that Michal's rework has changed
> the balance there anyway, and something else or nothing at all needed.
> 
> (The gfp_mask stuff was very confusing, and it's painful for me, how
> ~__GFP_KSWAPD_RECLAIM gets used as a secret password to say "THP" and
> how to angle compaction - or maybe it's all more straightforward now.)
> 
> Many thanks for giving us both this quick exposure!

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
