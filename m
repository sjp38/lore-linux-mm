Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 59E596006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 08:39:37 -0400 (EDT)
Date: Mon, 26 Jul 2010 14:39:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20100726123907.GG3280@quack.suse.cz>
References: <20100722050928.653312535@intel.com>
 <20100722061822.906037624@intel.com>
 <20100726105736.GM5300@csn.ul.ie>
 <20100726120011.GG6284@localhost>
 <20100726122054.GF3280@quack.suse.cz>
 <20100726123141.GA13146@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100726123141.GA13146@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon 26-07-10 20:31:41, Wu Fengguang wrote:
> On Mon, Jul 26, 2010 at 08:20:54PM +0800, Jan Kara wrote:
> > On Mon 26-07-10 20:00:11, Wu Fengguang wrote:
> > > On Mon, Jul 26, 2010 at 06:57:37PM +0800, Mel Gorman wrote:
> > > > On Thu, Jul 22, 2010 at 01:09:32PM +0800, Wu Fengguang wrote:
> > > > > A background flush work may run for ever. So it's reasonable for it to
> > > > > mimic the kupdate behavior of syncing old/expired inodes first.
> > > > > 
> > > > > The policy is
> > > > > - enqueue all newly expired inodes at each queue_io() time
> > > > > - retry with halfed expire interval until get some inodes to sync
> > > > > 
> > > > > CC: Jan Kara <jack@suse.cz>
> > > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > 
> > > > Ok, intuitively this would appear to tie into pageout where we want
> > > > older inodes to be cleaned first by background flushers to limit the
> > > > number of dirty pages encountered by page reclaim. If this is accurate,
> > > > it should be detailed in the changelog.
> > > 
> > > Good suggestion. I'll add these lines:
> > > 
> > > This is to help reduce the number of dirty pages encountered by page
> > > reclaim, eg. the pageout() calls. Normally older inodes contain older
> > > dirty pages, which are more close to the end of the LRU lists. So
> >   Well, this kind of implicitely assumes that once page is written, it
> > doesn't get accessed anymore, right?
> 
> No, this patch is not evicting the page :)
  Sorry, I probably wasn't clear enough :) I meant: The claim that "older
inodes contain older dirty pages, which are more close to the end of the
LRU lists" assumes that once page is written it doesn't get accessed
again. For example files which get continual random access (like DB files)
can have rather old dirtied_when but some of their pages are accessed quite
often...

> > Which I imagine is often true but
> > not for all workloads... Anyway I think this behavior is a good start
> > also because it is kind of natural to users to see "old" files written
> > first.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
