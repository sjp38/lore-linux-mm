Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA20655
	for <linux-mm@kvack.org>; Tue, 17 Mar 1998 14:10:01 -0500
Date: Tue, 17 Mar 1998 11:09:52 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] pre3 corrections!
In-Reply-To: <Pine.LNX.3.91.980317105548.385B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980317104435.5051E-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


[ Cc'd to Stephen and the mm-list because I'm explaining what I really
  think should happen and why I've rejected some patches: sorry for the
  lack of explanations but I was fairly busy last week.. ]

On Tue, 17 Mar 1998, Rik van Riel wrote:
> 
> apparently friday 13th has struck you very badly,
> since some _important_ pieces of kswapd got lost...
> (and page_alloc.c had an obvious bug).

page_alloc.c had an obvious bug, but no, the changes did not "get lost". 

I decided that it was time to stop with the band-aid patches, and just
wait for the problem to be fixed _correctly_, which I didn't think this
patch does:

> --- vmscan.c.pre3	Tue Mar 17 10:47:44 1998
> +++ vmscan.c	Tue Mar 17 10:52:05 1998
> @@ -568,8 +568,13 @@
>  		while (tries--) {
>  			int gfp_mask;
>  
> -			if (free_memory_available())
> -				break;
> +			if (BUFFER_MEM < buffer_mem.max * num_physpages / 100) {
> +				if (free_memory_available() && nr_free_pages +
> +					atomic_read(&nr_async_pages) > freepages.high)
> +					break;
> +				if( nr_free_pages > freepages.high * 4)
> +					break;
> +			}
>  			gfp_mask = __GFP_IO;
>  			try_to_free_page(gfp_mask);
>  			/*

Basically, I consider any patch that adds another "nr_free_pages" 
occurrence to be buggy. 

Why? Because I have 512 MB (yes, that's half a gig) of memory, and I don't
think it is valid to compare the number of free pages against anything,
because they have so little relevance when they may not be the basic
reason for why an allocation failed. I may have 8MB worth of free memory
(aka "a lot"), but if all those twothousand pages are single pages (or
even dual pages) then NFS won't work correctly because NFS needs to
allocate about 9000 bytes for incoming full-sized packets. 

That is why I want to have the "free_memory_available()" approach of
checking that there are free large-page areas still, and continuing to
swap out IN THE BACKGROUND when this isn't true. 

What I _think_ the patch should look like is roughly something like

	do {
		if (free_memory_available())
			break;
		gfp_mask = __GFP_IO;
		if (!try_to_free_page(gfp_mask))
			break;
		run_task_queue(&tq_disk); /* or whatever */
	} while (--tries);

AND then "swap_tick()" should also be changed to not look at nr_free_pages
at all, but only at whether we can easily allocate new memory (ie
"free_memory_available()") 

The plan would be that
 - kswapd should wake up every so often until we have large areas
   (swap_tick())
 - kswapd would never /ever/ run for too long ("tries"), even when low on
   memory. So the solution would be to make "tries" have a low enough
   value that kswapd never hogs the machine, and "swap_tick()" would make
   sure that while we don't hog the machine we do keep running
   occasionally until everything is dandy again.. 
 - "nr_free_pages" should go away: we end up just spending time
   maintaining it, yet it doesn't really ever tell us enough about the
   actul state of the machine due to fragmentation. 

I could do this myself, but I also know that my particular machine usage
isn't interesting enough to guarantee that I get the tweaking anywhere
close to reasonable, which is why I've been so happy that others (ie you)
have been looking into this - you probably have more real-world usage than
I do.

At the same time I _really_ hate the "arbitrary" kinds of tests that you
cannot actually explain _why_ they are there, and the only explanation for
them is that they hide some basic problem. This is why I want to have
"free_memory_available()" be important: because that function very clearly
states whether we can allocate things atomically or not. It's not a case
of "somebody feels that this is the right thing", but a case of "when the
free_memory_available() function returns true, we can _prove_ that some
specific condition is fine (ie the ability to allocate memory)". 

(Btw, I think my original "free_memory_available()" function that only
tested the highest memory order was probably a better one: the only reason
it was downgraded was due to the interactive issues due to swap_tick() and
the pageout loop disagreeing about when things should be done). 

One other thing that should probably be more aggressively looked into: the
buffer cache. It used to be that the buffer cache was of supreme
importance for performance, and we needed to keep the buffer cache big
because it was also our source of shared pages. That is no longer true.

These days we should penalize the buffer cache _heavily_: _especially_
dirty data pages that have been written out should generally be thrown
away as quickly as possible instead of leaving them in memory. Not
immediately, because re-writing parts of some file is fairly common, but
they should be aged much more aggressively (but we should not age the
metadata pages all that quickly - only the pages we have used for
write-outs). 

I've too often seen my machine with 200MB worth of ex-dirty buffers (ie
they are clean now and have been synched, but they still lay around just
in case) when I've written out a large file, and I just know that that is
just all wasted memory. 

Again, this is something that needs to be tested on more "normal" machines
than my particular machine is - I doubt my use is even close to what most
people tend to do..

		Linus
