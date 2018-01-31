Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C99466B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:40:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m3so12197858pgd.20
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:40:34 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id p129si320197pga.134.2018.01.31.15.40.32
        for <linux-mm@kvack.org>;
        Wed, 31 Jan 2018 15:40:33 -0800 (PST)
Date: Thu, 1 Feb 2018 10:41:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] few MM topics
Message-ID: <20180131234126.oobqdp6ibcayduu3@destitution>
References: <20180124092649.GC21134@dhcp22.suse.cz>
 <20180131192104.GD4841@magnolia>
 <20180131202438.GA21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131202438.GA21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

On Wed, Jan 31, 2018 at 09:24:38PM +0100, Michal Hocko wrote:
> On Wed 31-01-18 11:21:04, Darrick J. Wong wrote:
> > On Wed, Jan 24, 2018 at 10:26:49AM +0100, Michal Hocko wrote:
> [...]
> > > - I would also love to talk to some FS people and convince them to move
> > >   away from GFP_NOFS in favor of the new scope API. I know this just
> > >   means to send patches but the existing code is quite complex and it
> > >   really requires somebody familiar with the specific FS to do that
> > >   work.
> > 
> > Hm, are you talking about setting PF_MEMALLOC_NOFS instead of passing
> > *_NOFS to allocation functions and whatnot?
> 
> yes memalloc_nofs_{save,restore}
> 
> > Right now XFS will set it
> > on any thread which has a transaction open, but that doesn't help for
> > fs operations that don't have transactions (e.g. reading metadata,
> > opening files).  I suppose we could just set the flag any time someone
> > stumbles into the fs code from userspace, though you're right that seems
> > daunting.
> 
> I would really love to see the code to take the nofs scope
> (memalloc_nofs_save) at the point where the FS "critical" section starts
> (from the reclaim recursion POV).

We already do that - the transaction context in XFS is the critical
context, and we set PF_MEMALLOC_NOFS when we allocate a transaction
handle and remove it when we commit the transaction.

> This would both document the context
> and also limit NOFS allocations to bare minumum.

Yup, most of XFS already uses implicit GFP_NOFS allocation calls via
the transaction context process flag manipulation.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
