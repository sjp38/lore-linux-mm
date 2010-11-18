Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 469F46B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 22:19:17 -0500 (EST)
Date: Thu, 18 Nov 2010 11:19:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/13] IO-less dirty throttling
Message-ID: <20101118031905.GA16498@localhost>
References: <20101117035821.000579293@intel.com>
 <20101117072538.GO22876@dastard>
 <20101117100655.GA26501@localhost>
 <20101118014051.GR22876@dastard>
 <20101117175900.0d7878e5.akpm@linux-foundation.org>
 <20101118025039.GA15479@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118025039.GA15479@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 10:50:39AM +0800, Wu Fengguang wrote:
> On Thu, Nov 18, 2010 at 09:59:00AM +0800, Andrew Morton wrote:
> > On Thu, 18 Nov 2010 12:40:51 +1100 Dave Chinner <david@fromorbit.com> wrote:
> > 
> > > 
> > > There's no point
> > > waking a dirtier if all they can do is write a single page before
> > > they are throttled again - IO is most efficient when done in larger
> > > batches...
> > 
> > That assumes the process was about to do another write.  That's
> > reasonable on average, but a bit sad for interactive/rtprio tasks.  At
> > some stage those scheduler things should be brought into the equation.
> 
> The interactive/rtprio tasks are given 1/4 bonus in
> global_dirty_limits(). So when there are lots of heavy dirtiers,
> the interactive/rtprio tasks will get soft throttled at
> (6~8)*bdi_bandwidth. We can increase that to (12~16)*bdi_bandwidth
> or whatever.

Even better :) It seems that this break in balance_dirty_pages() will
make them throttle free, unless they themselves generate dirty data
faster than the disk can write:

        if (nr_dirty <= (background_thresh + dirty_thresh) / 2)
                break;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
