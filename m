Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA18753
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 02:58:00 -0500
Date: Tue, 24 Nov 1998 08:56:57 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux-2.1.129..
In-Reply-To: <m13e79eha7.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.981124084018.14227A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 24 Nov 1998, Eric W. Biederman wrote:
> >>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> RR> On 23 Nov 1998, Eric W. Biederman wrote:
> 
> RR> This waiting is also a good thing if we want to do proper
> RR> I/O clustering. I believe DU has a switch to only write
> RR> dirty data when there's more than XX kB of contiguous data
> RR> at that place on the disk (or the data is old).
> 
> I can tell who has been reading Digital Unix literature latetly.

DU and IRIX scale to much larger machines than Linux does,
so I've been reading the DU bookshelf for quite a while
now. Guess where some of the stuff in /proc/sys/vm comes
from :)

I'd be grateful if anyone can help me to IRIX documentation
(will be bugging our sysadmins later today -- I know they've
got an origin and several indys :).

> >> Ideally/Theoretically I think that is what we should be doing for
> >> swap as well, as it would spread out the swap writes across evenly
> >> across time.  And should leave most of our pages clean. 
> 
> RR> In order to spread out the disk I/O evenly (why would we
> RR> want to do this?
> 
> Imagine a machine with 1 Gigabyte of RAM and 8 Gigabyte of swap, in
> heavy use.  Swapping but not thrashing.  You can't swap out several
> hundred megabytes all at once. 

OK, I see your point now. In your original message I thought
to have read that you wanted to do swap I/O on an individual
basis as opposed to proper I/O clustering. Your second version
of the story is remarkably like what I had in mind :)

> You can handle a suddne flurry of network traffic much better this
> way for example. 

This is the main goal why we should push through the new
VM code ASAP. Gigabit ethernet will be in common use long
before 2.4 hits the street.

> >> The correct ratio (of pages to free from each source) (compuated
> >> dynamically) would be:  (# of process pages)/(# of pages) 
> >> 
> >> Basically for every page kswapd frees shrink_mmap must also free one
> >> page.  Plus however many pages shrink_mmap used to return. 
> 
> RR> This is clearly wrong.  
> 
> No. If for each page we schedule to be swapped, we reclaim a different
> page with shrink_mmap immediately.... so we have free ram.

We only need to have a very small amount of free ram, since
we can easily reclaim memory if we just make sure that we've
got enough unmapped swap cache and page cache laying around.

> As far as fixed percentages.  It's a loose every time, and I won't
> drop a working feature for an older lesser design.  Having tuneable
> fixed percentages is only a win on a 1 application, 1 load pattern
> box. 

The only reason for something like that is that we need to
have some control over the amount of memory that's in the
unmapped/cached state, since:
- we want the pages to undergo somewhat of an aging in order
  to avoid easy thrashing
- we need a large enough amount of unmapped memory which we
  can reclaim fast when we're under heavy (network) pressure
- having a lot of unmapped memory around will give minor page
  faults, decreasing the amount of unmapped memory and requiring
  us to keep scanning memory in a slow but steady pace, this:
  - spreads out swap I/O evenly over time
  - spreads out page aging evenly over space, giving us more
    performance and fair aging than we ever dreamt of

Maybe we want the system to auto-tune the mapped:unmapped
ratio depending on the amount of minor faults and actual
page reclaims going on, with a bottom value of 1/16th of
memory so we always have enough buffer to catch big things.

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
