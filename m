Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F5AA6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 07:32:16 -0400 (EDT)
Date: Wed, 4 May 2011 19:32:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/6] writeback: introduce
 writeback_control.inodes_cleaned
Message-ID: <20110504113211.GA5853@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080917.890756812@intel.com>
 <20110504110500.GB4646@infradead.org>
 <20110504111130.GA5191@localhost>
 <20110504111647.GA19261@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504111647.GA19261@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 04, 2011 at 07:16:47PM +0800, Christoph Hellwig wrote:
> On Wed, May 04, 2011 at 07:11:30PM +0800, Wu Fengguang wrote:
> > On Wed, May 04, 2011 at 07:05:00PM +0800, Christoph Hellwig wrote:
> > > Same here - this has nothing to do with actual page writeback and really
> > > should stay internal to fs/fs-writeback.c
> > 
> > OK, I'll check how to constrain writeback_control to the minimal scope.
> 
> The basic idea would be to pass the struct wb_writeback_work all the
> way down to writeback_sb_inodes, and initialize the struct writeback_control
> there.

OK.

> This requires adding a few more fields like more_io and

We can in fact just kill more_io and test list_empty(b_more_io)
instead.

> older_than_this to struct wb_writeback_work, and redoing a lot of the
> tracing,

Yeah, older_than_this must still be set in wb_writeback().
The two trace points could be removed for now.

> but it immediately clean things up, e.g. suddently
> wbc.nr_to_write vs work->nr_pages starts to make sense, and instead
> of saving and restoring pages_skipped in writeback_sb_inodes it can
> always start with a clean zero value.

That's right.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
