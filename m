Received: from atlas.infra.CARNet.hr (zcalusic@atlas.infra.CARNet.hr [161.53.160.131])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA20981
	for <linux-mm@kvack.org>; Tue, 17 Mar 1998 15:19:52 -0500
Subject: Re: [PATCH] pre3 corrections!
References: <Pine.LNX.3.95.980317104435.5051E-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 17 Mar 1998 21:20:03 +0100
In-Reply-To: Linus Torvalds's message of "Tue, 17 Mar 1998 11:09:52 -0800 (PST)"
Message-ID: <87iupdcbnw.fsf@atlas.infra.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

[snip]
> I decided that it was time to stop with the band-aid patches, and just
> wait for the problem to be fixed _correctly_, which I didn't think this
> patch does:
> 
> > --- vmscan.c.pre3	Tue Mar 17 10:47:44 1998
> > +++ vmscan.c	Tue Mar 17 10:52:05 1998
> > @@ -568,8 +568,13 @@
> >  		while (tries--) {
> >  			int gfp_mask;
> >  
> > -			if (free_memory_available())
> > -				break;
> > +			if (BUFFER_MEM < buffer_mem.max * num_physpages / 100) {
> > +				if (free_memory_available() && nr_free_pages +
> > +					atomic_read(&nr_async_pages) > freepages.high)
> > +					break;
> > +				if( nr_free_pages > freepages.high * 4)
> > +					break;
> > +			}
> >  			gfp_mask = __GFP_IO;
> >  			try_to_free_page(gfp_mask);
> >  			/*
> 
> Basically, I consider any patch that adds another "nr_free_pages" 
> occurrence to be buggy. 
> 
> Why? Because I have 512 MB (yes, that's half a gig) of memory, and I don't
> think it is valid to compare the number of free pages against anything,
> because they have so little relevance when they may not be the basic
> reason for why an allocation failed. I may have 8MB worth of free memory
> (aka "a lot"), but if all those twothousand pages are single pages (or
> even dual pages) then NFS won't work correctly because NFS needs to
> allocate about 9000 bytes for incoming full-sized packets. 
> 
> That is why I want to have the "free_memory_available()" approach of
> checking that there are free large-page areas still, and continuing to
> swap out IN THE BACKGROUND when this isn't true.
           ^^^^^^^^^^^^^^^^^

Agreed!!!

> 
> What I _think_ the patch should look like is roughly something like
> 
> 	do {
> 		if (free_memory_available())
> 			break;
> 		gfp_mask = __GFP_IO;
> 		if (!try_to_free_page(gfp_mask))
> 			break;
> 		run_task_queue(&tq_disk); /* or whatever */
> 	} while (--tries);
> 
> AND then "swap_tick()" should also be changed to not look at nr_free_pages
> at all, but only at whether we can easily allocate new memory (ie
> "free_memory_available()") 
> 
> The plan would be that
>  - kswapd should wake up every so often until we have large areas
>    (swap_tick())
>  - kswapd would never /ever/ run for too long ("tries"), even when low on
>    memory. So the solution would be to make "tries" have a low enough
>    value that kswapd never hogs the machine, and "swap_tick()" would make
>    sure that while we don't hog the machine we do keep running
>    occasionally until everything is dandy again..

I could not agree more. Few latest kernel revisions were too much
aggresive swapping things out. Of course, we need a way to assure we
have big enough chunks free, but I believe that's tough to accomplish
without deep thinking.

What I don't like is excessive swapout, under which I lose control
over machine for a few seconds, in .89 processes got killed randomly,
sound stops playing (Sound: DMA (output) timed out - IRQ/DRQ config
error?), and eventually I have machine with lots of free (unused!) RAM
and tens of MB's worth of data swapped out that is now slowly paging
in. I wouldn't call that a "performance improvement". :(

Benjamin's patch (rev-ptes) could be a big win in kernel
functionality, if you decide it's good enough to be included in the
mainstream. Reverse page tables is the only thing, _I_ can think of,
that could help in freeing of big areas of memory.

Blindly throwing pages out leads to heavy swapouts. If my machine
swaps out 50MB to get one 128KB free chunk, that's overkill.

>  - "nr_free_pages" should go away: we end up just spending time
>    maintaining it, yet it doesn't really ever tell us enough about the
>    actul state of the machine due to fragmentation. 
> 
> I could do this myself, but I also know that my particular machine usage
> isn't interesting enough to guarantee that I get the tweaking anywhere
> close to reasonable, which is why I've been so happy that others (ie you)
> have been looking into this - you probably have more real-world usage than
> I do.
> 
> At the same time I _really_ hate the "arbitrary" kinds of tests that you
> cannot actually explain _why_ they are there, and the only explanation for
> them is that they hide some basic problem. This is why I want to have
> "free_memory_available()" be important: because that function very clearly
> states whether we can allocate things atomically or not. It's not a case
> of "somebody feels that this is the right thing", but a case of "when the
> free_memory_available() function returns true, we can _prove_ that some
> specific condition is fine (ie the ability to allocate memory)".

Again agreed. I like simple things more than anything and it looks
like kswapd and others are becaming progressively less and less
readable. That leads to bugs that are harder to track.

> 
> (Btw, I think my original "free_memory_available()" function that only
> tested the highest memory order was probably a better one: the only reason
> it was downgraded was due to the interactive issues due to swap_tick() and
> the pageout loop disagreeing about when things should be done). 
> 
> One other thing that should probably be more aggressively looked into: the
> buffer cache. It used to be that the buffer cache was of supreme
> importance for performance, and we needed to keep the buffer cache big
> because it was also our source of shared pages. That is no longer true.

On this one I don't agree. My opinion is that buffer cache gets shrunk
slightly too fast. I don't like unused pages around, too, but it looks
to me that buffer cache pages dissapear five or ten times faster than
pages from page cache. Maybe that is intended behaviour, but nobody
actually profiled caches to see what is really happening.

At one occasion, I did put some code in kernel to calculate hit rate
of the caches, but didn't know how to interpret values I got. :)

But some benchmarking and profiling could be very helpful, definitely.

> 
> These days we should penalize the buffer cache _heavily_: _especially_
> dirty data pages that have been written out should generally be thrown
> away as quickly as possible instead of leaving them in memory. Not
> immediately, because re-writing parts of some file is fairly common, but
> they should be aged much more aggressively (but we should not age the
> metadata pages all that quickly - only the pages we have used for
> write-outs).

I believe all your wishes about buffer cache are already fulfilled in
recent kernels. At least on the machines with "normal" amount of
RAM. :)

> 
> I've too often seen my machine with 200MB worth of ex-dirty buffers (ie
> they are clean now and have been synched, but they still lay around just
> in case) when I've written out a large file, and I just know that that is
> just all wasted memory. 
> 
> Again, this is something that needs to be tested on more "normal" machines
> than my particular machine is - I doubt my use is even close to what most
> people tend to do..
> 
> 		Linus
> 
> 

Hmm... godzilla type of machine. :)

Everything I said applies to 64MB (and 32MB) machines that are, I
presume, "slightly" more common these days. :)

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	   Sign here please:_______________________Thanks.
