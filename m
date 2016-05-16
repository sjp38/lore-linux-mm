Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id B98A36B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 06:41:36 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id kj7so168201064igb.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 03:41:36 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id l4si24268062iof.91.2016.05.16.03.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 03:41:36 -0700 (PDT)
Date: Mon, 16 May 2016 12:41:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160516104130.GK3193@twins.programming.kicks-ass.net>
References: <94cea603-2782-1c5a-e2df-42db4459a8ce@cn.fujitsu.com>
 <20160512055756.GE6648@birch.djwong.org>
 <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160513160341.GW20141@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org

On Fri, May 13, 2016 at 06:03:41PM +0200, Michal Hocko wrote:

> To quote Dave:
> "
> Ignoring whether reflink should be doing anything or not, that's a
> "xfs_refcountbt_init_cursor() gets called both outside and inside
> transactions" lockdep false positive case. The problem here is
> lockdep has seen this allocation from within a transaction, hence a
> GFP_NOFS allocation, and now it's seeing it in a GFP_KERNEL context.
> Also note that we have an active reference to this inode.

So the only thing that distinguishes the good from the bad case is that
reference; how should that then not do anything?

> So, because the reclaim annotations overload the interrupt level
> detections and it's seen the inode ilock been taken in reclaim
> ("interrupt") context, this triggers a reclaim context warning where
> it thinks it is unsafe to do this allocation in GFP_KERNEL context
> holding the inode ilock...
> "
> 
> This sounds like a fundamental problem of the reclaim lock detection.
> It is really impossible to annotate such a special usecase IMHO unless
> the reclaim lockup detection is reworked completely.

How would you like to see it done? The interrupt model works well for
reclaim because how is direct reclaim from a !GFP_NOWAIT allocation not
an 'interrupt' like thing?

> Until then it
> is much better to provide a way to add "I know what I am doing flag"
> and mark problematic places. This would prevent from abusing GFP_NOFS
> flag which has a runtime effect even on configurations which have
> lockdep disabled.

So without more context; no. The mail you referenced mentions:

"The reclaim -> lock context that it's complaining about here is on
an inode being reclaimed - it has no active references and so, by
definition, cannot deadlock with a context holding an active
reference to an inode ilock. Hence there cannot possibly be a
deadlock here, but we can't tell lockdep that easily in any way
without going back to the bad old ways of creating a new lockdep
class for inode ilocks the moment they enter ->evict. This then
disables "entire lifecycle" lockdep checking on the xfs inode ilock,
which is why we got rid of it in the first place."

But fails to explain the problems with the 'old' approach.

So clearly this is a 'problem' that has existed for quite a while, so I
don't see any need to rush half baked solutions either.

Please better explain things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
