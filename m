Date: Mon, 30 Aug 2004 12:20:25 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040830152025.GA2901@logos.cnet>
References: <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de> <20040829141718.GD10955@suse.de> <20040829131824.1b39f2e8.akpm@osdl.org> <20040829203011.GA11878@suse.de> <20040829135917.3e8ffed8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040829135917.3e8ffed8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Jens Axboe <axboe@suse.de>, wli@holomorphy.com, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 29, 2004 at 01:59:17PM -0700, Andrew Morton wrote:
> Jens Axboe <axboe@suse.de> wrote:
> >
> > > That was my point.
> > 
> >  I didn't understand your message at all, maybe that wasn't clear enough
> >  in my email :-). You state that the main effect of that particular patch
> >  is to bump nr_requests to 8192, which is definitely not true. The main
> >  effect of the patch is to make sure that ->nr_requests was valid, so
> >  that cfqd->max_queued is valid. ->nr_requests was always overwritten
> >  with 8192 for quite some time, irregardless of that patch. So this
> >  particular change has nothing to do with that, and other io schedulers
> >  will experience exactly this very problem with 8192 requests.
> > 
> >  Why you do see a difference is that when ->max_queued isn't valid, you
> >  end up block a lot more in get_request_wait() because cfq_may_queue will
> >  disallow you to queue a lot more than with the patch. Since other io
> >  schedulers don't have these sort of checks, they behave like CFQ does
> >  with the bug in blk_init_queue() fixed.
> 
> The changlog wasn't that detailed ;)
> 
> But yes, it's the large nr_requests which is tripping up swapout.  I'm
> assuming that when a process exits with its anonymous memory still under
> swap I/O we're forgetting to actually free the pages when the I/O
> completes.  So we end up with a ton of zero-ref swapcache pages on the LRU.

What nr_requests would have to do with swapcache not being freed after 
the owner of it exits?

I can't reproduce the behaviour which swapcache is not freed after
the memory hog exited (I'm using fillmem, dont think that matters). Where
can I find usemem?

The filesystem dirty writeback (page-writeback.c) code effectively throttles tasks 
on the size of the queue. blk_congestion_wait() is not enough to avoid the
queueing get full. 

Same with swap IO. 

So, Andrew, you say you fixed that in the dirty writeback code. Where is that? 

What Jens seems to argue is that VM needs limiting IO in flight - it
doesnt do that at all, it relies on the IO scheduler to do such limiting.
That is how Linux always worked.

I'm I missing something? 

> I assume.   Something odd's happening, that's for sure.

What is the problem Karl is seeing again? There seem to be several, lets
separate them

- OOM killer triggering (if there's swap space available and 
"enough" anonymous memory to be swapped out this should not happen). 
One of his complaint on the initial report (about the OOM killer).

- Swap cache not freed after test app exists. Should not be a
problem because such memory will be freed as soon as theres 
pressure, I think.

How can you reproduce that?

I can't see any big difference between using cfq/as with either 8192 or 128. 
Both make the box trash completly (ie very unresponsive) as soon as intensive
swap IO starts.

---

"I can bring down my box by running a program that does a calloc() of 512Mb
(which is the size of my RAM). The box starts to heavily swap and never
recovers from it. The process that calloc's the memory gets OOM killed (which
is also strange as I have 1Gb free swap).

After the OOM kill, the shell where I started the calloc() program is alive
but very slow. The box continues to swap and the other processes remain dead. "
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
