Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA21049
	for <linux-mm@kvack.org>; Tue, 17 Mar 1998 15:25:35 -0500
Date: Tue, 17 Mar 1998 21:20:27 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: [PATCH] pre3 corrections!
In-Reply-To: <Pine.LNX.3.95.980317104435.5051E-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980317205032.289K@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 1998, Linus Torvalds wrote:

> On Tue, 17 Mar 1998, Rik van Riel wrote:
> > 
> > apparently friday 13th has struck you very badly,
> > since some _important_ pieces of kswapd got lost...
> > (and page_alloc.c had an obvious bug).
> 
> page_alloc.c had an obvious bug, but no, the changes did not "get lost". 
> 
> I decided that it was time to stop with the band-aid patches, and just
> wait for the problem to be fixed _correctly_, which I didn't think this
> patch does:

OK, you're right about that. But your free_memory_available()
function is just too easily overwhelmed on normal systems.
Also, on your system, you should have noticed an extra 200
context switches a second, since swap_tick() wakes up kswapd
even when free_memory_available() is satisfied ;-)

!!! The BUFFER_MEM test however needs to stay. It is the way
    we implement the maximum quota for buffermem+page_cache_size !!!

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

1. You can tune the amount of pages you want free
2. On small-memory machines, kswapd swaps out up to half of total
   memory when free_memory_available() can't be satisfied. We should
   place some upper limit to the amount of memory that can be
   freed at once.
3. When you only look at free_memory_available() and a huge amount
   of memory is allocated at once, the large area's all 'dissappear'
   at once, and the system enters swapping madness (has happened to
   me and other people too!).
4. Large-mem machines usually have more allocations/second too...

For me, point 3 is the most important one.

> That is why I want to have the "free_memory_available()" approach of
> checking that there are free large-page areas still, and continuing to
> swap out IN THE BACKGROUND when this isn't true. 
> 
> AND then "swap_tick()" should also be changed to not look at nr_free_pages
> at all, but only at whether we can easily allocate new memory (ie
> "free_memory_available()") 

We'll also want a lot of 'extra' free memory around, as it takes
a _long_ time to 'create' new large free areas...
I almost swapped my machine to death when the free-mem limitation
wasn't built into kswapd... And with less memory it's even worse!

> What I _think_ the patch should look like is roughly something like
> 
> 	do {
> 		if (free_memory_available())
> 			break;
> 		gfp_mask = __GFP_IO;
> 		if (!try_to_free_page(gfp_mask))
> 			break;

??? Why break when one try_to_free_page() fails ???

> 		run_task_queue(&tq_disk); /* or whatever */
> 	} while (--tries);
> 
> The plan would be that
>  - kswapd should wake up every so often until we have large areas
>    (swap_tick())
>  - kswapd would never /ever/ run for too long ("tries"), even when low on
>    memory. So the solution would be to make "tries" have a low enough
>    value that kswapd never hogs the machine, and "swap_tick()" would make
>    sure that while we don't hog the machine we do keep running
>    occasionally until everything is dandy again..

This was a _serious_ bug in the 1.2 days. Then kswapd
couldn't keep up with the amount of memory allocations,
since there was an upper limit on it's memory freeing rate.
 
>  - "nr_free_pages" should go away: we end up just spending time
>    maintaining it, yet it doesn't really ever tell us enough about the
>    actul state of the machine due to fragmentation. 

I agree that freepages.[min,low,high] could go away, but I'd
like to keep nr_free_pages so we can free on a somewhat more
intelligent rate.
It would be nice to keep enough free pages around for the
allocations that happen until kswapd is woken up again.

> At the same time I _really_ hate the "arbitrary" kinds of tests that you
> cannot actually explain _why_ they are there, and the only explanation for
> them is that they hide some basic problem. This is why I want to have
> "free_memory_available()" be important: because that function very clearly
> states whether we can allocate things atomically or not. It's not a case
> of "somebody feels that this is the right thing", but a case of "when the
> free_memory_available() function returns true, we can _prove_ that some
> specific condition is fine (ie the ability to allocate memory)". 
>
> (Btw, I think my original "free_memory_available()" function that only
> tested the highest memory order was probably a better one: the only reason
> it was downgraded was due to the interactive issues due to swap_tick() and
> the pageout loop disagreeing about when things should be done). 

Your free_memory_available() test is almost as arbitrary
as the nr_free_pages tests...
Your free_memory_available() test tests whether the system
can do one or two really big allocations.
The nr_free_pages test tests whether the system can do loads
of small allocations.

Since the systems I see usually do a lot of small allocations,
the second test seems quite useful to me...
I can't grasp why it should be eradicated and never used again...
Please enlighten me... :-)

> These days we should penalize the buffer cache _heavily_: _especially_

It is penalized a lot more heavily than the page cache, because:
- the page cache memory gets properly aged
- the buffer cache doesn't grow fast when buffer+page > max, while
  the page cache just grows on until kswapd trims 'em both

> dirty data pages that have been written out should generally be thrown
> away as quickly as possible instead of leaving them in memory. Not
> immediately, because re-writing parts of some file is fairly common, but
> they should be aged much more aggressively (but we should not age the
> metadata pages all that quickly - only the pages we have used for
> write-outs). 
> 
> I've too often seen my machine with 200MB worth of ex-dirty buffers (ie
> they are clean now and have been synched, but they still lay around just
> in case) when I've written out a large file, and I just know that that is
> just all wasted memory. 

When it's wasted memory, the system will free it very soon
because:
- the pages aren't touched
- there's a quota for buffer+pagecache now
(there's been a lot of activity lately, so you might have
missed out on some of the subtle stuff. If you haven't, sorry
for the newbie-like speech)

> Again, this is something that needs to be tested on more "normal" machines
> than my particular machine is - I doubt my use is even close to what most
> people tend to do..

It is nothing like the way we mere mortals use our computers.
For example, your original free_memory_available() test might
have worked perfectly when you tested it, but it nearly
killed my box :-)
(and it _did_ kill the boxes of people with only 8 or 12 MB)

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
