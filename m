Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7472E6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:25:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so354201549pfb.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:25:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id su5si46017281pab.230.2016.05.16.06.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 06:25:45 -0700 (PDT)
Date: Mon, 16 May 2016 15:25:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160516132541.GP3193@twins.programming.kicks-ass.net>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516130519.GJ23146@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org

On Mon, May 16, 2016 at 03:05:19PM +0200, Michal Hocko wrote:
> On Mon 16-05-16 12:41:30, Peter Zijlstra wrote:
> > On Fri, May 13, 2016 at 06:03:41PM +0200, Michal Hocko wrote:

> > How would you like to see it done? The interrupt model works well for
> > reclaim because how is direct reclaim from a !GFP_NOWAIT allocation not
> > an 'interrupt' like thing?
> 
> Unfortunately I do not have any good ideas. It would basically require
> to allow marking the lockdep context transaction specific AFAIU somehow
> and tell that there is no real dependency between !GFP_NOWAIT and
> 'interrupt' context.

But here is; direct reclaim is very much an 'interrupt' in the normal
program flow.

But the problem here appears to be that at some points we 'know' things
cannot get reclaimed because stuff we didn't tell lockdep about (its got
references), and sure then it don't work right.

But that doesn't mean that the 'interrupt' model is wrong.

> IIRC Dave's emails they have tried that by using lockdep classes and
> that turned out to be an overly complex maze which still doesn't work
> 100% reliably.

So that would be the: 

> >  but we can't tell lockdep that easily in any way
> > without going back to the bad old ways of creating a new lockdep
> > class for inode ilocks the moment they enter ->evict. This then
> > disables "entire lifecycle" lockdep checking on the xfs inode ilock,
> > which is why we got rid of it in the first place."
> > 
> > But fails to explain the problems with the 'old' approach.
> > 
> > So clearly this is a 'problem' that has existed for quite a while, so I
> > don't see any need to rush half baked solutions either.
> 
> Well, at least my motivation for _some_ solution here is that xfs has
> worked around this deficiency by forcing GFP_NOFS also for contexts which
> are perfectly OK to do __GFP_FS allocation. And that in turn leads to
> other issues which I would really like to sort out. So the idea was to
> give xfs another way to express that workaround that would be a noop
> without lockdep configured.

Right, that's unfortunate. But I would really like to understand the
problem with the classes vs lifecycle thing.

Is there an email explaining that somewhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
