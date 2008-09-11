Date: Thu, 11 Sep 2008 11:47:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH] discarding swap
In-Reply-To: <20080911085816.GP20055@kernel.dk>
Message-ID: <Pine.LNX.4.64.0809111128170.16065@blonde.site>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site>
 <20080910173518.GD20055@kernel.dk> <Pine.LNX.4.64.0809102015230.16131@blonde.site>
 <20080911085816.GP20055@kernel.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Sep 2008, Jens Axboe wrote:
> On Wed, Sep 10 2008, Hugh Dickins wrote:
> > 
> > 3. Add an occasional cond_resched() into the loop, to avoid risking bad
> >    latencies when discarding a large area in small max_hw_sectors steps.
> 
> Hugh, I applied this - but on 2nd though, I killed the cond_resched()
> for two reasons:

Thanks.  Yes, that was definitely the most dubious part of the patch.

> 
> - We should only add stuff like that if it's known problematic

Fair enough.  I tend to be more proactive than that with mm loops,
and perhaps had it overmuch on my mind because the swap allocation
loop itself used to be such a prime offender.

(There's also the argument that those most worried about such latencies
will be setting CONFIG_PREEMPT=y, in which case no cond_resched() needed:
I like to give that argument some respect, but not take it too far.)

> - We'll be throttling on the request allocation eventually, once we get
>   128 of these in flight.

Yes, my worry was that if the device completes these requests quickly
enough (as we hope it, or many of them, will), blkdev_issue_discard()
may never reach that throttling, despite doing lots more than 128.

> 
> So if this turns out to be a problem, we can revisit the cond_resched()
> solution.

Indeed - and it doesn't affect the blkdev_issue_discard() interface,
just its implementation.

(I'm still mulling over, in between unrelated work,
David's point on the barriers: will reply to that later.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
