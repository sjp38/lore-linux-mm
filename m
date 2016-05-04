Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 107616B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:56:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so42356927wme.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:56:31 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id cb2si3571895wjc.188.2016.05.04.01.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 01:56:30 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so8992439wmw.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:56:29 -0700 (PDT)
Date: Wed, 4 May 2016 10:56:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 12/14] mm, oom: protect !costly allocations some more
Message-ID: <20160504085628.GE29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-13-git-send-email-mhocko@kernel.org>
 <20160504060123.GB10899@js1304-P5Q-DELUXE>
 <20160504063112.GD10899@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504063112.GD10899@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 15:31:12, Joonsoo Kim wrote:
> On Wed, May 04, 2016 at 03:01:24PM +0900, Joonsoo Kim wrote:
> > On Wed, Apr 20, 2016 at 03:47:25PM -0400, Michal Hocko wrote:
[...]
> > > @@ -3408,6 +3456,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  				 no_progress_loops))
> > >  		goto retry;
> > >  
> > > +	/*
> > > +	 * It doesn't make any sense to retry for the compaction if the order-0
> > > +	 * reclaim is not able to make any progress because the current
> > > +	 * implementation of the compaction depends on the sufficient amount
> > > +	 * of free memory (see __compaction_suitable)
> > > +	 */
> > > +	if (did_some_progress > 0 &&
> > > +			should_compact_retry(order, compact_result,
> > > +				&migration_mode, compaction_retries))
> > 
> > Checking did_some_progress on each round have subtle corner case. Think
> > about following situation.
> > 
> > round, compaction, did_some_progress, compaction
> > 0, defer, 1
> > 0, defer, 1
> > 0, defer, 1
> > 0, defer, 1
> > 0, defer, 0
> 
> Oops...Example should be below one.
> 
> 0, defer, 1
> 1, defer, 1
> 2, defer, 1
> 3, defer, 1
> 4, defer, 0

I am not sure I understand. The point of the check is that if the
reclaim doesn't make _any_ progress then checking the result of the
compaction after it didn't lead to a successful allocation just doesn't
make any sense. If the compaction deferred all the time then we have a
bug in the compaction. Vlastimil is already working on a code which
should make the compaction more ready for !costly requests but that is a
separate topic IMO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
