Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBF36B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 14:19:19 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so49119275lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 11:19:19 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id jk1si6531010wjb.0.2016.05.04.11.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 11:19:18 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so12259557wmn.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 11:19:18 -0700 (PDT)
Date: Wed, 4 May 2016 20:19:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 12/14] mm, oom: protect !costly allocations some more
Message-ID: <20160504181916.GB21490@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-13-git-send-email-mhocko@kernel.org>
 <20160504060123.GB10899@js1304-P5Q-DELUXE>
 <20160504063112.GD10899@js1304-P5Q-DELUXE>
 <20160504085628.GE29978@dhcp22.suse.cz>
 <CAAmzW4O_mAQP0UkCbZ6bk8G+W1-3PCwqrPbRGTpZ78ZKXc25hw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4O_mAQP0UkCbZ6bk8G+W1-3PCwqrPbRGTpZ78ZKXc25hw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 23:57:50, Joonsoo Kim wrote:
> 2016-05-04 17:56 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 04-05-16 15:31:12, Joonsoo Kim wrote:
> >> On Wed, May 04, 2016 at 03:01:24PM +0900, Joonsoo Kim wrote:
> >> > On Wed, Apr 20, 2016 at 03:47:25PM -0400, Michal Hocko wrote:
> > [...]
> >> > > @@ -3408,6 +3456,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >> > >                            no_progress_loops))
> >> > >           goto retry;
> >> > >
> >> > > + /*
> >> > > +  * It doesn't make any sense to retry for the compaction if the order-0
> >> > > +  * reclaim is not able to make any progress because the current
> >> > > +  * implementation of the compaction depends on the sufficient amount
> >> > > +  * of free memory (see __compaction_suitable)
> >> > > +  */
> >> > > + if (did_some_progress > 0 &&
> >> > > +                 should_compact_retry(order, compact_result,
> >> > > +                         &migration_mode, compaction_retries))
> >> >
> >> > Checking did_some_progress on each round have subtle corner case. Think
> >> > about following situation.
> >> >
> >> > round, compaction, did_some_progress, compaction
> >> > 0, defer, 1
> >> > 0, defer, 1
> >> > 0, defer, 1
> >> > 0, defer, 1
> >> > 0, defer, 0
> >>
> >> Oops...Example should be below one.
> >>
> >> 0, defer, 1
> >> 1, defer, 1
> >> 2, defer, 1
> >> 3, defer, 1
> >> 4, defer, 0
> >
> > I am not sure I understand. The point of the check is that if the
> > reclaim doesn't make _any_ progress then checking the result of the
> > compaction after it didn't lead to a successful allocation just doesn't
> > make any sense.
> 
> Even if this round (#4) doesn't reclaim any pages, previous rounds
> (#0, #1, #2, #3) would reclaim enough pages to succeed future
> compaction attempt.

Then the compaction shouldn't back off and I would consider it a
compaction bug. I haven't see this happening though. Vlastimil is
already working on patches which would simply guarantee that really
important allocations will not defer.

So unless I can see an example of a real issue with this I think it is
just a theoretical issue which shouldn't block the patch as is.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
