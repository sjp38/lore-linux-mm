Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA05210
	for <linux-mm@kvack.org>; Wed, 10 Dec 1997 12:08:32 -0500
Date: Wed, 10 Dec 1997 13:11:53 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: how mm could work
In-Reply-To: <199712100745.CAA11790@jupiter.cs.uml.edu>
Message-ID: <Pine.LNX.3.91.971210124512.7823D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 1997, Albert D. Cahalan wrote:

> Below is a nice explanation of how FreeBSD paging works.
> It appears that Digital Unix does something similar.
> (the Digital Unix man pages use the strange term "wired")

AFAIK, 'wired' stands for locked in memory... not for 'active'

> Since we should soundly whip FreeBSD :-) instead of just

That's not the point. We should get the _maximum_ out of 
our hardware... 

[ the quoted part is from a _forwarded_ message, not from Albert!!!]

> FreeBSD's paging system is both simple and complex.  The basic premis,
> though, is that a page must go through several states before it is 
> actually unrecoverably freed.
> 
> In FreeBSD a page can be:
> 
> 	wired		most active state
> 	active		nominally active state
> 	inactive	dirty & inactive (can be reclaimed to active/wired)
> 	cache		clean & inactive (can be reclaimed to active/wired)
> 	free		truely free
> 
> FreeBSD attempts to move wired/active pages to either inactive or cache
> depending on whether they are dirty or not.  When pages are needed, 
> FreeBSD will do a combination of paging of inactive pages (which cleans 
> them and moves them to cache), and movement of pages from cache to free.
> Actual page allocation always comes out of free.  Sysctl parameters
> handle low and high water marks allowing one to control the burstiness
> and aggressiveness of the page movement.

Digital unix has the following (tunable) parameters:
- low + high watermark (start/end _paging_)
- nr_inactive_pages >= nr_active_pages * 2
- if the number of free pages stays below nr_swap_pages (somewhere
  between low/high water mark) for a certain number of seconds, 
  the system starts _swapping_ out tasks

> In a nominal paging situation, an active process may see a page get
> moved to inactive/cache, but if the process references the page relatively
> quickly the page will be 'reclaimed' (see vmstat, systat -vm) and moved
> back to active/wired without requiring a buffer copy or disk I/O.
> 
> In a nominal paging situation, a dirty page in inactive is written to swap 
> and turned into a clean page in cache, but still not immediately freed.
> It is still possible to reclaim the page from cache and move it back to 
> active even if it has been paged out.

Second-chance fifo replacement is a good thing with inactive
and cache list. For active pages we should use normal aging.

> A very heavy paging situation occurs when FreeBSD is unable to maintain
> the minimum cache+free paramater.  When this occurs, FreeBSD begins to
> *swap* whole processes.  This is an area where work has been needed 
> for a while because certain programs such as 'ps' tend to force all 
> swapped (IW) processes back to idle (I) and the swap-trigger is just
> too sensitive... it's trivial to fix and -current already has the 
> better swapping code, with -stable soon to follow.  The new code is 
> going to have the capability to swap idle processes out based on how long
> they've been sleeping (SUNish style swapping).  In a heavily loaded 
> time-share system such as BEST's shell machines, this results in a 
> constant, slow movement of processes both into and out of the swapped 
> state and better balances new allocations against frees.  In fact, even
> swapping out a process does not immediately free its pages... it's still
> possible for the process to be swapped in without incuring disk I/O though,
> usually, the pages are lost because the swapping only occurs in a heavily
> loaded situation anyway.
> 
> It should be noted that the disk cache in FreeBSD is comprised of ALL the
> paging pools, not just the 'cache' paging pool, but FreeBSD has various

Of course, a heavily used cache page shouldn't be paged out :)

> sysctl VM parameters that allow you to separate a true 'disk cache' from
> active pages used by processes.  A true 'disk cache' infers the caching
> of blocks not currently in use.  Thus sysctl allows you to specify a 
> minimum size for the 'cache' queue which in turn allows you to balance

>From the Digital Unix system tuning guide:

ubc-maxpercent		maximum % of memory the buffer cache can use
ubc-minpercent		minimum % of memory the buffer cache has
ubc-borrowpercent	if the buffer cache uses more than this %
			of memory, and memory is tight, the system
			will steal pages from the UBC only until this
			number is reached again. If cache mem is
			below this number, memory is stolen from
			normal memory and buffer cache in round-robin
			fashion.

note:
DU uses LRU aging on the buffer cache, and some multilevel
(active, inactive, etc.) scheme on program pages.

> paging against cache maintenance.  The larger the minimum 'cache' size,
> the more aggressive FreeBSD pages in order to maintain the larger
> 'cache'.  A smaller minimum 'cache' size results in less aggressive
> paging, but a higher chance of paging an active page out in a heavily
> loaded system.

This is 'wrong' IMO, the system should balance between swaps
and FS-pages... It keeps statistics of both of them, so it
could just adjust the minimum-size so swapping and FS-reads
are balanced (when in heavy load).

Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
