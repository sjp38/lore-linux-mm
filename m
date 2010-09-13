Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 265B96B00FE
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 05:57:14 -0400 (EDT)
Date: Mon, 13 Sep 2010 17:57:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/17] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100913095708.GA31310@localhost>
References: <20100912154945.758129106@intel.com>
 <20100912155202.733389420@intel.com>
 <20100913095130.GD23508@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100913095130.GD23508@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 05:51:30PM +0800, Mel Gorman wrote:
> On Sun, Sep 12, 2010 at 11:49:46PM +0800, Wu Fengguang wrote:
> > The dirty_ratio was siliently limited in global_dirty_limits() to >= 5%.
> > This is not a user expected behavior. And it's inconsistent with
> > calc_period_shift(), which uses the plain vm_dirty_ratio value.
> > 
> > Let's rip the arbitrary internal bound. It may impact some very weird
> > user space applications. However we are going to dynamicly sizing the
> > dirty limits anyway, which may well break such applications, too.
> > 
> > At the same time, fix balance_dirty_pages() to work with the
> > dirty_thresh=0 case. This allows applications to proceed when
> > dirty+writeback pages are all cleaned.
> > 
> > And ">" fits with the name "exceeded" better than ">=" does. Neil
> > think it is an aesthetic improvement as well as a functional one :)
> > 
> > CC: Jan Kara <jack@suse.cz>
> > Proposed-by: Con Kolivas <kernel@kolivas.org>
> > Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> > Reviewed-by: Neil Brown <neilb@suse.de>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/fs-writeback.c   |    2 +-
> >  mm/page-writeback.c |   16 +++++-----------
> >  2 files changed, 6 insertions(+), 12 deletions(-)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2010-08-29 08:10:30.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2010-08-29 08:12:08.000000000 +0800
> > @@ -415,14 +415,8 @@ void global_dirty_limits(unsigned long *
> >  
> >  	if (vm_dirty_bytes)
> >  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > -	else {
> > -		int dirty_ratio;
> > -
> > -		dirty_ratio = vm_dirty_ratio;
> > -		if (dirty_ratio < 5)
> > -			dirty_ratio = 5;
> > -		dirty = (dirty_ratio * available_memory) / 100;
> > -	}
> > +	else
> > +		dirty = (vm_dirty_ratio * available_memory) / 100;
> >  
> 
> What kernel is this? In a recent mainline kernel and on linux-next, this
> is

It applies to linux-next 20100903.

> dirty = (dirty_ratio * available_memory) / 100;
> 
> i.e. * instead of +. With +, the value for dirty is almost always going
> to be simply 1%.

Where's the "+" come from?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
