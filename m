Date: Wed, 7 Jun 2000 18:14:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <ytt1z29dxce.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0006071808300.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On 7 Jun 2000, Juan J. Quintela wrote:
> >>>>> "sct" == Stephen C Tweedie <sct@redhat.com> writes:
> 
> >> I'd like to be able to keep stuff simple in the shrink_mmap
> >> "equivalent" I'm working on. Something like:
> >> 
> >> if (PageDirty(page) && page->mapping && page->mapping->flush)
> >> maxlaunder -= page->mapping->flush();
> 
> sct> That looks ideal.
> 
> But this is supposed to flush that _page_, at least in the
> normal case.

But not *just* that page ...

In the ideal case the flush() function will search around
memory for objects to cluster and write out together with
this page.

I'll probably write an example page->mapping->flush()
function for swap. The function will do the following:
- find other swap pages to cluster with this page,
  those must be:
	- contiguous with this page
	- inactive or seldomly used active pages
	- dirty (duh)
- flush out the collection of pages
- return the number of INACTIVE pages we flushed,
  ignoring the number of active pages

That last point is very important because:
- if we mainly flushed active pages, we should not give
  shrink_mmap (or similar) the illusion that we cleared
  up the inactive list ... don't pretend we made a lot
  of progress cleaning inactive pages if we didn't
- since we wrote the pages in the same disk seek, writing
  the active pages was essentially for free so it doesn't
  matter that we don't report having written them ...
  (having written that page and potentially saving some IO
  later, otoh, definately does matter)

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
