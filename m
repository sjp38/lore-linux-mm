Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1D7618D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 03:53:08 -0400 (EDT)
Date: Thu, 21 Apr 2011 17:52:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110421075258.GB12436@dastard>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
 <20110420152211.GC4991@quack.suse.cz>
 <20110421033325.GA13764@localhost>
 <20110421070947.GA12436@dastard>
 <20110421071426.GA24790@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421071426.GA24790@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 03:14:26AM -0400, Christoph Hellwig wrote:
> On Thu, Apr 21, 2011 at 05:09:47PM +1000, Dave Chinner wrote:
> > Likely just timing. When IO completes and updates the inode IO size,
> > XFS calls mark_inode_dirty() again to ensure that the metadata that
> > was changed gets written out at a later point in time.
> > Hence every single file that is created by the test will be marked
> > dirty again after the first write has returned and disappeared.
> > 
> > Why you see different numbers? it's timing dependent based on Io
> > completion rates - if you have a fast disk the IO completion can
> > occur before write_inode() is called and so the inode can be written
> > and the dirty page state removed in the one writeback_single_inode()
> > call...
> > 
> > That's my initial guess without looking at it in any real detail,
> > anyway.
> 
> We shouldn't have I_DIRTY_PAGES set for that case, as we only redirty
> metadata.  But we're actually doing a xfs_mark_inode_dirty, which
> dirties all of I_DIRTY, which includes I_DIRTY_PAGES.  I guess it
> should change to
> 
> 	__mark_inode_dirty(inode, I_DIRTY_SYNC | I_DIRTY_DATASYNC);

Probably should. Using xfs_mark_inode_dirty_sync() might be the best
thing to do.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
