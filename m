Date: Wed, 10 Dec 1997 13:38:49 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: how mm could work
In-Reply-To: <Pine.LNX.3.91.971210124512.7823D-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.971210131331.5452B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Albert D. Cahalan" <acahalan@cs.uml.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 1997, Rik van Riel wrote:

> On Wed, 10 Dec 1997, Albert D. Cahalan wrote:

> [ the quoted part is from a _forwarded_ message, not from Albert!!!]
> 
> > FreeBSD's paging system is both simple and complex.  The basic premis,
> > though, is that a page must go through several states before it is 
> > actually unrecoverably freed.
> > 
> > In FreeBSD a page can be:
> > 
> > 	wired		most active state
> > 	active		nominally active state
> > 	inactive	dirty & inactive (can be reclaimed to active/wired)
> > 	cache		clean & inactive (can be reclaimed to active/wired)
> > 	free		truely free

That's pretty close to how Linux is set up, except pages cannot be dirty
and unmapped - so we lose out on some write-behind with shared mmappings
right now - the last user triggers the write.  The model I'm slowly
working towards is the above, plus an 'almost-free' state.  Almost free
could essentially be the bottom X% of the cache pages - which could be
reclaimed within interrupts if nescessary.

Another idea lurking in the back of my head is to use a slab-like scheme
for pages overall.  This idea is completely undeveloped, but the core to
it is that unswappable kernel-used pages should sit together, and not
spread around memory, resulting in fragmentation.

> > paging against cache maintenance.  The larger the minimum 'cache' size,
> > the more aggressive FreeBSD pages in order to maintain the larger
> > 'cache'.  A smaller minimum 'cache' size results in less aggressive
> > paging, but a higher chance of paging an active page out in a heavily
> > loaded system.
> 
> This is 'wrong' IMO, the system should balance between swaps
> and FS-pages... It keeps statistics of both of them, so it
> could just adjust the minimum-size so swapping and FS-reads
> are balanced (when in heavy load).

One mechanism suggested for attacking this problem is to get rid of the
buffer cache completely, and rely solely on the page cache.  This is
something for 2.3, though.  My current development plans for the
pte-linking and assorted stuff is to work on it from now though 2.2 and
have something to submit for 2.3...

		-ben
