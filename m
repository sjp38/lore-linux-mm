Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE046B009A
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 13:42:44 -0400 (EDT)
Date: Thu, 18 Mar 2010 17:42:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100318174220.GP12388@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <20100311154124.e1e23900.akpm@linux-foundation.org> <4B99E19E.6070301@linux.vnet.ibm.com> <20100312020526.d424f2a8.akpm@linux-foundation.org> <20100312104712.GB18274@csn.ul.ie> <4B9A3049.7010602@linux.vnet.ibm.com> <20100312093755.b2393b33.akpm@linux-foundation.org> <4B9E296A.2010605@linux.vnet.ibm.com> <20100315130935.f8b0a2d7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100315130935.f8b0a2d7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 01:09:35PM -0700, Andrew Morton wrote:
> On Mon, 15 Mar 2010 13:34:50 +0100
> Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
> 
> > c) If direct reclaim did reasonable progress in try_to_free but did not
> > get a page, AND there is no write in flight at all then let it try again
> > to free up something.
> > This could be extended by some kind of max retry to avoid some weird
> > looping cases as well.
> > 
> > d) Another way might be as easy as letting congestion_wait return
> > immediately if there are no outstanding writes - this would keep the 
> > behavior for cases with write and avoid the "running always in full 
> > timeout" issue without writes.
> 
> They're pretty much equivalent and would work.  But there are two
> things I still don't understand:
> 
> 1: Why is direct reclaim calling congestion_wait() at all?  If no
> writes are going on there's lots of clean pagecache around so reclaim
> should trivially succeed.  What's preventing it from doing so?
> 
> 2: This is, I think, new behaviour.  A regression.  What caused it?
> 

I looked at this a bit closer using an iozone test very similar to
Christian's. Despite buying a number of disks, I still can't reproduce his
problem but I instrumented congestion_wait counts and times similar to
what he did.

2.6.29-instrument:congestion_waittime 990
2.6.30-instrument:congestion_waittime 2823
2.6.31-instrument:congestion_waittime 193169
2.6.32-instrument:congestion_waittime 228890
2.6.33-instrument:congestion_waittime 785529
2.6.34-rc1-instrument:congestion_waittime 797178

So in the problem window, there was *definite* increases in the time spent
in congestion_wait and the number of times it was called. I'll look
closer at this tomorrow and Monday and see can I pin down what is
happening.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
