Date: Wed, 7 Jun 2000 12:41:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <20000607163519.S30951@redhat.com>
Message-ID: <Pine.LNX.4.21.0006071239120.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Stephen C. Tweedie wrote:
> On Wed, Jun 07, 2000 at 05:20:41PM +0200, Quintela Carreira Juan J. wrote:
> > 
> > stephen> It doesn't matter.  *If* the filesystem knows better than the 
> > stephen> page cleaner what progress can be made, then let the filesystem
> > stephen> make progress where it can.  There are likely to be transaction
> > stephen> dependencies which mean we have to clean some pages in a specific
> > stephen> order.  As soon as the page cleaner starts exerting back pressure
> > stephen> on the filesystem, the filesystem needs to start clearing stuff,
> > stephen> and if that means we have to start cleaning things that shrink_
> > stephen> mmap didn't expect us to, then that's fine.
> > 
> > I don't like that, if you put some page in the LRU cache, that means
> > that you think that _this_ page is freeable.
> 
> Remember that Rik is talking about multiple LRUs.  Pages can
> only be on the inactive LRU if they are clean and unpinned, yes,
> but we still need a way of tracking pages which are in a more
> difficult state.

That's the scavenge list ;)

The inactive list contains unmapped pages with age 0, from
the inactive list I want to clean the pages whenever there's
demand for memory.

This could potentially mean that the pinned buffers from one
fs would be spread over both the active and the inactive list.

> > If you need pages in the LRU cache only for getting notifications,
> > then change the system to send notifications each time that we are
> > short of memory.
> 
> It's a matter of pressure.  The filesystem with most pages in
> the LRU cache, or with the oldest pages there, should stand the
> greatest chance of being the first one told to clean up its act.

Indeed, the more I think of it the more I think any other
approach than shared-lru is the right one.

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
