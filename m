Message-ID: <393E9C58.9FE2A0E0@reiser.to>
Date: Wed, 07 Jun 2000 12:02:48 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:it'snot
 just the code)
References: <Pine.LNX.4.21.0006071018320.14304-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 7 Jun 2000, Stephen C. Tweedie wrote:
> > On Tue, Jun 06, 2000 at 08:45:08PM -0700, Hans Reiser wrote:
> > > >
> > > > This is the reason because of what I think that one operation in the
> > > > address space makes no sense.  No sense because it can't be called
> > > > from the page.
> > >
> > > What do you think of my argument that each of the subcaches should register
> > > currently_consuming counters which are the number of pages that subcache
> > > currently takes up in memory,
> >
> > There is no need for subcaches at all if all of the pages can be
> > represented on the page cache LRU lists.  That would certainly
> > make balancing between caches easier.
> 
> Wouldn't this mean we could end up with an LRU cache full of
> unfreeable pages?
> 
> Then we would scan the LRU cache and apply pressure on all of
> the filesystems, but then the filesystem could decide it wants
> to flush *other* pages from the ones we have on the LRU queue.

And we intend to do exactly that with allocate on flush.  Eventually we will
even repack on flush.

> 
> This could get particularly nasty when we have a VM with
> active / inactive / scavenge lists... (like what I'm working
> on now)
> 
> Then again, if the filesystem knows which pages we want to
> push, it could base the order in which it is going to flush
> its blocks on that memory pressure. Then your scheme will
> undoubtedly be the more robust one.
> 
> Question is, are the filesystems ready to play this game? 

Yes, we are eager to play, but you do intend that the filesystem will be
pressured to age not flush, yes?

That is, if aging causes something to get flushed, it gets flushed, but if not
then not.
The filesystems should get passed some notion of how much of their cache to age
so that you MM guys can have fun varying this.

You might want us to return how much got scheduled for flushing as a result of
the aging, that way you know when to stop pressuring caches.

> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
