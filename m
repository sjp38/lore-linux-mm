Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E11FC6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 20:36:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h193so791749pfe.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 17:36:28 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b33-v6si15634606plb.184.2018.03.08.17.36.26
        for <linux-mm@kvack.org>;
        Thu, 08 Mar 2018 17:36:27 -0800 (PST)
Date: Fri, 9 Mar 2018 12:35:35 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Removing GFP_NOFS
Message-ID: <20180309013535.GU7000@dastard>
References: <20180308234618.GE29073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180308234618.GE29073@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Mar 08, 2018 at 03:46:18PM -0800, Matthew Wilcox wrote:
> 
> Do we have a strategy for eliminating GFP_NOFS?
> 
> As I understand it, our intent is to mark the areas in individual
> filesystems that can't be reentered with memalloc_nofs_save()/restore()
> pairs.  Once they're all done, then we can replace all the GFP_NOFS
> users with GFP_KERNEL.

Won't be that easy, I think.  We recently came across user-reported
allocation deadlocks in XFS where we were doing allocation with
pages held in the writeback state that lockdep has never triggered
on.

https://www.spinics.net/lists/linux-xfs/msg16154.html

IOWs, GFP_NOFS isn't a solid guide to where
memalloc_nofs_save/restore need to cover in the filesystems because
there's a surprising amount of code that isn't covered by existing
lockdep annotations to warning us about un-intended recursion
problems.

I think we need to start with some documentation of all the generic
rules for where these will need to be set, then the per-filesystem
rules can be added on top of that...

> How will we know when we're done and can kill GFP_NOFS?  I was thinking
> that we could put a warning in slab/page_alloc that fires when __GFP_IO
> is set, __GFP_FS is clear and PF_MEMALLOC_NOFS is clear.  That would
> catch every place that uses GFP_NOFS without using memalloc_nofs_save().
> 
> Unfortunately (and this is sort of the point), there's a lot of places
> which use GFP_NOFS as a precaution; that is, they can be called from
> places which both are and aren't in a nofs path.  So we'd have to pass
> in GFP flags.  Which would be a lot of stupid churn.

Yup, GFP_NOFS has been used as a "go away, lockdep, your drunk" flag
for handling false positives for quite a long time because some
calls are already under memalloc_nofs_save/restore protection paths.
THese would need to be converted to GFP_NOLOCKDEP instead of
memalloc_nofs_save/restore() which they are already covered by in
the cases taht matter...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
