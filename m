Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 234746B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 23:12:42 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q65so3416804pga.15
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 20:12:42 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id m189si157960pfc.410.2018.03.08.20.12.39
        for <linux-mm@kvack.org>;
        Thu, 08 Mar 2018 20:12:40 -0800 (PST)
Date: Fri, 9 Mar 2018 15:06:50 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Removing GFP_NOFS
Message-ID: <20180309040650.GV7000@dastard>
References: <20180308234618.GE29073@bombadil.infradead.org>
 <20180309013535.GU7000@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180309013535.GU7000@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Mar 09, 2018 at 12:35:35PM +1100, Dave Chinner wrote:
> On Thu, Mar 08, 2018 at 03:46:18PM -0800, Matthew Wilcox wrote:
> > 
> > Do we have a strategy for eliminating GFP_NOFS?
> > 
> > As I understand it, our intent is to mark the areas in individual
> > filesystems that can't be reentered with memalloc_nofs_save()/restore()
> > pairs.  Once they're all done, then we can replace all the GFP_NOFS
> > users with GFP_KERNEL.
> 
> Won't be that easy, I think.  We recently came across user-reported
> allocation deadlocks in XFS where we were doing allocation with
> pages held in the writeback state that lockdep has never triggered
> on.
> 
> https://www.spinics.net/lists/linux-xfs/msg16154.html
> 
> IOWs, GFP_NOFS isn't a solid guide to where
> memalloc_nofs_save/restore need to cover in the filesystems because
> there's a surprising amount of code that isn't covered by existing
> lockdep annotations to warning us about un-intended recursion
> problems.
> 
> I think we need to start with some documentation of all the generic
> rules for where these will need to be set, then the per-filesystem
> rules can be added on top of that...

So thinking a bit further here:

* page writeback state gets set and held:
	->writepage should be under memalloc_nofs_save
	->writepages should be under memalloc_nofs_save
* page cache write path is often under AOP_FLAG_NOFS
	- should probably be under memalloc_nofs_save
* metadata writeback that uses page cache and page writeback flags
  should probably be under memalloc_nofs_save

What other generic code paths are susceptible to allocation
deadlocks?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
