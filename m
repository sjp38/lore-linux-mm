Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EF76E6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 21:28:35 -0500 (EST)
Date: Fri, 19 Nov 2010 13:28:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/13] IO-less dirty throttling
Message-ID: <20101119022824.GB13830@dastard>
References: <20101117035821.000579293@intel.com>
 <20101117072538.GO22876@dastard>
 <20101117100655.GA26501@localhost>
 <20101118014051.GR22876@dastard>
 <20101117175900.0d7878e5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117175900.0d7878e5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 05:59:00PM -0800, Andrew Morton wrote:
> On Thu, 18 Nov 2010 12:40:51 +1100 Dave Chinner <david@fromorbit.com> wrote:
> > Yeah, sorry, should have posted them - I didn't because I snapped
> > the numbers before the run had finished. Without series:
> > 
> > 373.19user 14940.49system 41:42.17elapsed 612%CPU (0avgtext+0avgdata 82560maxresident)k
> > 0inputs+0outputs (403major+2599763minor)pagefaults 0swaps
> > 
> > With your series:
> > 
> > 359.64user 5559.32system 40:53.23elapsed 241%CPU (0avgtext+0avgdata 82496maxresident)k
> > 0inputs+0outputs (312major+2598798minor)pagefaults 0swaps
> > 
> > So the wall time with your series is lower, and system CPU time is
> > way down (as I've already noted) for this workload on XFS.
> 
> How much of that benefit is an accounting artifact, moving work away
> from the calling process's CPU and into kernel threads?

As I spelled out in my original results, the sustained CPU usage for
the unmodified kernel is ~780% - 620% fs_mark, 80% bdi-flusher, 80%
kswapd (i.e. completely CPU bound on the 8p test VM).  With this
series, the sustained CPU usage is about 380% - 250% fs_mark, 80%
bdi-flusher, 50% kswapd.

IOWs, this series _halved_ the total sustained CPU usage even after
taking into account all the kernel threads. With wall time also
being reduced and the number of IOs issued dropping by 25%, I find
it hard to classify the result as anything other than spectacular...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
