Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA25721
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 12:06:48 -0500
Date: Tue, 1 Dec 1998 17:42:08 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <87lnkrn9nb.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.981201173030.2458A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 1 Dec 1998, Zlatko Calusic wrote:
> "Stephen C. Tweedie" <sct@redhat.com> writes:
> > In article <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>,
> > Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> > 
> > > here is a very first primitive version of as swapin
> > > readahead patch. It seems to give much increased
> > > throughput to swap and the desktop switch time has
> > > decreased noticably.
> > 
> > There's a third check needed, I think, which probably accounts for the
> > swap_duplicate errors people have been noting.  You need to skip pages
> > which are marked as locked in the swap_lockmap, or the async page read
> 
> That warnings are probably benign, but the patch in the whole has at
> least one big engineering problem. Unfortunately, I'm trying to
> understand other parts of the MM code, so currently I don't have the
> time needed to play with the swapin readahead more.
> 
> But, what I observed is that memory gets lost in some strange way. It
> is possible that lost pages are in the swap cache, and it looks like
> nothing frees them at all.

I've observed this problem as well, but I haven't figured
out the cause yet...

> I don't understand how Rik doesn't notice this, but I'm able to
> deadlock machine in a matter of minutes, by running simple memory
> mallocing & reading program.

In my experience allocations aren't the big problem but
deallocations. I guess we lose some memory there :(

> Call it hogmem.c, compile it and then run it with two arguments. First
> is how much memory to allocate (make it slightly bigger than size of
> your physical memory in MB, to make system swapping), and second is
> how many times to read the memory (some small number).

> Rik, hopefully this helps you to find a problem with logic in your
> patch.

I'll check it out and report later.

> Also, looking at the patch source, it looks like the comment there is
> completely misleading, as the for() loop is not doing anything, at
> all. The patch can be shortened to do offset++, if() and only ONE
> read_swap_cache_async, if I'm understanding it correctly. Sorry, I'm
> not including it here, have some other things to do fast.

You have to read each entry separately; you want all of
them to have an entry in the swap cache...

[SNIP program]

Hmm, reading and writing huge amounts of memory repeatedly
makes memory dissapear and deadlock the machine... This
means we are losing memory somewhere -- I'll check things
out very carefully...

cheers,

Rik -- now completely used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
