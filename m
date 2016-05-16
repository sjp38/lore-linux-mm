Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2156B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:05:22 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id tb5so59319524lbb.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:05:22 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id h62si20031174wma.124.2016.05.16.06.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 06:05:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so18014923wme.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:05:20 -0700 (PDT)
Date: Mon, 16 May 2016 15:05:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160516130519.GJ23146@dhcp22.suse.cz>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516104130.GK3193@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org

On Mon 16-05-16 12:41:30, Peter Zijlstra wrote:
> On Fri, May 13, 2016 at 06:03:41PM +0200, Michal Hocko wrote:
[...]
> > So, because the reclaim annotations overload the interrupt level
> > detections and it's seen the inode ilock been taken in reclaim
> > ("interrupt") context, this triggers a reclaim context warning where
> > it thinks it is unsafe to do this allocation in GFP_KERNEL context
> > holding the inode ilock...
> > "
> > 
> > This sounds like a fundamental problem of the reclaim lock detection.
> > It is really impossible to annotate such a special usecase IMHO unless
> > the reclaim lockup detection is reworked completely.
> 
> How would you like to see it done? The interrupt model works well for
> reclaim because how is direct reclaim from a !GFP_NOWAIT allocation not
> an 'interrupt' like thing?

Unfortunately I do not have any good ideas. It would basically require
to allow marking the lockdep context transaction specific AFAIU somehow
and tell that there is no real dependency between !GFP_NOWAIT and
'interrupt' context.
IIRC Dave's emails they have tried that by using lockdep classes and
that turned out to be an overly complex maze which still doesn't work
100% reliably.

> > Until then it
> > is much better to provide a way to add "I know what I am doing flag"
> > and mark problematic places. This would prevent from abusing GFP_NOFS
> > flag which has a runtime effect even on configurations which have
> > lockdep disabled.
> 
> So without more context; no. The mail you referenced mentions:
> 
> "The reclaim -> lock context that it's complaining about here is on
> an inode being reclaimed - it has no active references and so, by
> definition, cannot deadlock with a context holding an active
> reference to an inode ilock. Hence there cannot possibly be a
> deadlock here, but we can't tell lockdep that easily in any way
> without going back to the bad old ways of creating a new lockdep
> class for inode ilocks the moment they enter ->evict. This then
> disables "entire lifecycle" lockdep checking on the xfs inode ilock,
> which is why we got rid of it in the first place."
> 
> But fails to explain the problems with the 'old' approach.
> 
> So clearly this is a 'problem' that has existed for quite a while, so I
> don't see any need to rush half baked solutions either.

Well, at least my motivation for _some_ solution here is that xfs has
worked around this deficiency by forcing GFP_NOFS also for contexts which
are perfectly OK to do __GFP_FS allocation. And that in turn leads to
other issues which I would really like to sort out. So the idea was to
give xfs another way to express that workaround that would be a noop
without lockdep configured.
 
> Please better explain things.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
