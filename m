Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5316A6B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 20:48:35 -0400 (EDT)
Date: Sun, 18 Apr 2010 17:49:44 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100418174944.7b9716ad@infradead.org>
In-Reply-To: <20100419003556.GC2520@dastard>
References: <20100413202021.GZ13327@think>
	<20100414014041.GD2493@dastard>
	<20100414155233.D153.A69D9226@jp.fujitsu.com>
	<20100414072830.GK2493@dastard>
	<20100414085132.GJ25756@csn.ul.ie>
	<20100415013436.GO2493@dastard>
	<20100415102837.GB10966@csn.ul.ie>
	<20100416041412.GY2493@dastard>
	<20100416151403.GM19264@csn.ul.ie>
	<20100417203239.dda79e88.akpm@linux-foundation.org>
	<20100419003556.GC2520@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Apr 2010 10:35:56 +1000
Dave Chinner <david@fromorbit.com> wrote:

> On Sat, Apr 17, 2010 at 08:32:39PM -0400, Andrew Morton wrote:
> > 
> > There are two issues here: stack utilisation and poor IO patterns in
> > direct reclaim.  They are different.
> > 
> > The poor IO patterns thing is a regression.  Some time several years
> > ago (around 2.6.16, perhaps), page reclaim started to do a LOT more
> > dirty-page writeback than it used to.  AFAIK nobody attempted to
> > work out why, nor attempted to try to fix it.
> 
> I think that part of the problem is that at roughly the same time
> writeback started on a long down hill slide as well, and we've
> really only fixed that in the last couple of kernel releases. Also,
> it tends to take more that just writing a few large files to invoke
> the LRU-based writeback code is it is generally not invoked in
> filesystem "performance" testing. Hence my bet is on the fact that
> the effects of LRU-based writeback are rarely noticed in common
> testing.
> 


Would this also be the time where we started real dirty accounting, and
started playing with the dirty page thresholds?

Background writeback is that interesting tradeoff between writing out
to make the VM easier (and the data safe) and the chance of someone
either rewriting the same data (as benchmarks do regularly... not sure
about real workloads) or deleting the temporary file.


Maybe we need to do the background dirty writes a bit more aggressive...
or play with heuristics where we get an adaptive timeout (say, if the
file got closed by the last opener, then do a shorter timeout)


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
