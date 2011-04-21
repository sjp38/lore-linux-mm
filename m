Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7698D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 04:01:15 -0400 (EDT)
Date: Thu, 21 Apr 2011 04:00:39 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110421080038.GA4959@infradead.org>
References: <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
 <20110420152211.GC4991@quack.suse.cz>
 <20110421033325.GA13764@localhost>
 <20110421070947.GA12436@dastard>
 <20110421071426.GA24790@infradead.org>
 <20110421075258.GB12436@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421075258.GB12436@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 05:52:58PM +1000, Dave Chinner wrote:
> > We shouldn't have I_DIRTY_PAGES set for that case, as we only redirty
> > metadata.  But we're actually doing a xfs_mark_inode_dirty, which
> > dirties all of I_DIRTY, which includes I_DIRTY_PAGES.  I guess it
> > should change to
> > 
> > 	__mark_inode_dirty(inode, I_DIRTY_SYNC | I_DIRTY_DATASYNC);
> 
> Probably should. Using xfs_mark_inode_dirty_sync() might be the best
> thing to do.

That's not correct either - we need to set I_DIRTY_DATASYNC so that it
gets caught by fsync and not just fdatasync.

But thinking about it I'm actually not sure we need it at all.  We already
wait for the i_iocount to go to zero both in fsync and ->sync_fs, which will
catch pending I/O completions even without any VFS dirty state.  So just
marking the inode dirty (as I_DIRTY_SYNC | I_DIRTY_DATASYNC) on I/O
completion should be enough these days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
