Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C40606B0098
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 06:12:09 -0400 (EDT)
Date: Tue, 16 Mar 2010 10:11:46 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
Message-ID: <20100316101146.GP18274@csn.ul.ie>
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

Unfortunately, this regression is very poorly understood. I haven't been able
to reproduce it locally and while Christian has provided various debugging
information, it still isn't clear why the problem occurs now.

> 1: Why is direct reclaim calling congestion_wait() at all?  If no
> writes are going on there's lots of clean pagecache around so reclaim
> should trivially succeed.  What's preventing it from doing so?
> 

Memory pressure I think. The workload involves 16 processes (see
http://lkml.org/lkml/2009/12/7/237). I suspect they are all direct reclaimers
and some processes are getting their pages stolen before they have a
chance to allocate them. It's knowing that adding a small amount of
memory "fixes" this problem.

> 2: This is, I think, new behaviour.  A regression.  What caused it?
> 

Short answer, I don't know.

Longer answer. Initially, this was reported as being caused by commit e084b2d:
page-allocator: preserve PFN ordering when __GFP_COLD is set but it was never
established why and reverting it was unpalatable because it fixed another
performance problem. According to Christian, the controller does nothing
with the merging of IO requests and he was very sure about this. As all the
patch does is change the order that pages are returned in and the timing
slightly due to differences in cache hotness, although the fact that such
a small change could make a big difference in reclaim later was surprising.
There were other bugs that might have complicated this such as errors in free
page counters but they were fixed up and the problem still did not go away.

It was after much debugging that it was found that direct reclaim was
returning, the subsequent allocation attempt failed and congestion_wait()
was called but without dirty pages, congestion or writes, it waits for
the full timeout.  congestion_wait() was also being called a lot more
frequently so something was causing reclaim to fail more frequently
(http://lkml.org/lkml/2009/12/18/150). Again, I couldn't figure out why
e084b2d would make a difference.

Later, it got even worse because patches e084b2d and 5f8dcc21 had to be
reverted in 2.6.33 to "resolve" the problem. 5f8dcc21 was more plausible as it
affected how many pages were on the per-cpu lists but making it behave like
2.6.32 did not help the situation. Again, it looked like a very small timing
problem but it could not be isolated exactly why reclaim would fail. Again,
other bugs were found and fixed but made no difference.

What lead to this patch was recognising we could enter congestion_wait()
and wait the entire timeout because no writes were in progress or dirty
pages to be cleaned. As what was really of interest was watermarks in
this path, the patch intended to make the page allocator care about
watermarks instead of congestion. We know it was treating symptoms
rather than understanding the underlying problem but I was somewhat at a
loss to explain why small changes in timing made such a large
difference.

Any new insight is welcome.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
