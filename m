Message-ID: <3D2F2DE2.93D327F8@zip.com.au>
Date: Fri, 12 Jul 2002 12:28:34 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <3D2E08DE.3C0D619@zip.com.au> <Pine.LNX.4.44L.0207112011150.14432-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 11 Jul 2002, Andrew Morton wrote:
> 
> > > generic_file_write() calls deactivate_page() if it crosses
> > > the page boundary (ie. if it is done writing this page)
> >
> > Ah, OK.  I tried lots of those sorts of things.  But fact is
> > that moving the unwanted pages to the far of the inactive list
> > just isn't effective: pagecache which will be used at some time
> > in the future always ends up getting evicted.
> 
> There's no way around that, unless you know your application
> workload well enough to be able to predict the future.

Well, we do know that.  In fact probably most applications know
their buffering requirements better than the kernel does.
(soapbox: default open() mode should be unbuffered, and the
application developer should be forced to specify what caching
behaviour [s]he wants.  Ah well).

> ...
> > mm.  Well we do want processes to go in and reclaim their own
> > pages normally, to avoid a context switch (I guess.  No numbers
> > to back this up).
> 
> Falling from __alloc_pages into the pageout path shouldn't be
> part of the fast path.  If it is we have bigger problems...

Oh, direct reclaim is the common case when the system is working
hard (and when it's not, we don't care about anything).

It's the common case because, yup, kswapd is asleep on request
queues all the time.
 
> > But I think killing batch_requests may make all this rather better.
> 
> Probably.

It does.  Still testing what ended up being a pretty broad
patch.  Frankly, I'd rather not finish the patch - it's
a workaround for a basic design mistake.  This is one of the
biggest performance bugs in linux.  The biggest, actually.  Don't
underestimate it.  In 2.4 it is halving our multi-spindle
writeback throughput.  It makes machines unusable during heavy
writeback loads.

Anyway.  I've uploaded my current patchset to
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.25/

What I tend to do is to keep a FIFO of patches.  Every now and
then I flush out the code which is 1-2 weeks old.  This way it has
had a good amount of testing by the time I submit it.

So anytime anyone has anything else which is reasonably close to
ready and which needs stability testing,  I'd be happy to add
it to the mix.

Not much of that code is ready to go at present.  kmap stuff needs
confirmation against more hardware and I still have many filesystems
to hack away at.  O_DIRECT rework is awaiting Ben's kvecs.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
