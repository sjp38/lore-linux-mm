Date: Wed, 7 Jun 2000 11:27:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <20000607144102.F30951@redhat.com>
Message-ID: <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Stephen C. Tweedie wrote:
> On Wed, Jun 07, 2000 at 10:23:35AM -0300, Rik van Riel wrote:
> > > 
> > > There is no need for subcaches at all if all of the pages can be
> > > represented on the page cache LRU lists.  That would certainly
> > > make balancing between caches easier.
> > 
> > Wouldn't this mean we could end up with an LRU cache full of
> > unfreeable pages?
> 
> Rik, we need the VM to track dirty pages anyway, precisely so
> that we can obtain some degree of write throttling to avoid
> having the whole of memory full of dirty pages.

*nod*

> If we get short of memory, we really need to start flushing dirty
> pages to disk independently of the task of finding free pages.  

Indeed, page replacement and page flushing need to be
pretty much independant of each other, with the only
gotcha that page replacement is able to trigger page
flushing...

> > This could get particularly nasty when we have a VM with
> > active / inactive / scavenge lists... (like what I'm working
> > on now)
> 
> Right, we definitely need a better distinction between different
> lists and different types of page activity before we can do this.

I think we'll want something like what FreeBSD has, mainly
because their feedback loop is really simple and has proven
to be robust.

1) active list
	This list contains the pages which are active, we
	age the pages, they can be mapped in processes
2) inactive list
	All pages here are ready to be reclaimed. We are
	free to reclaim the clean inactive page before the
	dirty ones (to delay/minimise IO) because no page
	ends up here unless we want to reclaim it anyway.
3) scavenge list   (BSD calls this cache list, -EOVERLOADEDWORD)
	All pages here are clean and can be reclaimed for
	all page allocations which have __GFP_WAIT set. We
	keep only a minimal amount of free pages and most
	times __alloc_pages() is called we'll take a scavenge
	page instead.
4) free list
	Not much of a list, the current free page structure.
	We use the pages here for atomic allocations and, when
	we have too many free pages, for normal allocations.

The filesystem callbacks would be made for pages on the
inactive list, the filesystem (or shm, or swap subsystem)
is free to cluster any "eligable" pages with the page we
requested to be freed.

So if, eg., we request ext3 to flush page X, the filesystem
can make its own decision on if it wants to also flush some
other inactive (or even active) pages which are contiguous
on disk with the block page X is written to.

> > Question is, are the filesystems ready to play this game?
> 
> With an address_space callback, yes --- ext3 can certainly find
> a transaction covering a given page. 

This is what we need...

> I'd imagine reiserfs can do something similar, but even if not,
> it's not important if the filesystem can't do its lookup by
> page.

I don't necessarily agree on this point. What if our
inactive list is filled with pages the filesystem somehow
regards as new, and the filesystem will be busy flushing
the "wrong" (in the eyes of the page stealer) pages?

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
