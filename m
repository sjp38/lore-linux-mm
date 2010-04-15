Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A11D56B01F4
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:31:16 -0400 (EDT)
Date: Thu, 15 Apr 2010 12:30:53 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
Message-ID: <20100415103053.GA5336@cmpxchg.org>
References: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org> <20100415171142.D192.A69D9226@jp.fujitsu.com> <20100415172215.D19B.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415172215.D19B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 05:26:27PM +0900, KOSAKI Motohiro wrote:
> Cc to Johannes
> 
> > > 
> > > On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
> > > 
> > > > Now, vmscan pageout() is one of IO throuput degression source.
> > > > Some IO workload makes very much order-0 allocation and reclaim
> > > > and pageout's 4K IOs are making annoying lots seeks.
> > > >
> > > > At least, kswapd can avoid such pageout() because kswapd don't
> > > > need to consider OOM-Killer situation. that's no risk.
> > > >
> > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > 
> > > What's your opinion on trying to cluster the writes done by pageout,  
> > > instead of not doing any paging out in kswapd?
> > > Something along these lines:
> > 
> > Interesting. 
> > So, I'd like to review your patch carefully. can you please give me one
> > day? :)
> 
> Hannes, if my remember is correct, you tried similar swap-cluster IO
> long time ago. now I can't remember why we didn't merged such patch.
> Do you remember anything?

Oh, quite vividly in fact :)  For a lot of swap loads the LRU order
diverged heavily from swap slot order and readaround was a waste of
time.

Of course, the patch looked good, too, but it did not match reality
that well.

I guess 'how about this patch?' won't get us as far as 'how about
those numbers/graphs of several real-life workloads?  oh and here
is the patch...'.

> > >      Cluster writes to disk due to memory pressure.
> > > 
> > >      Write out logically adjacent pages to the one we're paging out
> > >      so that we may get better IOs in these situations:
> > >      These pages are likely to be contiguous on disk to the one we're
> > >      writing out, so they should get merged into a single disk IO.
> > > 
> > >      Signed-off-by: Suleiman Souhlal <suleiman@google.com>

For random IO, LRU order will have nothing to do with mapping/disk order.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
