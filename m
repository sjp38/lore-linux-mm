Message-ID: <3D44F01A.C7AAA1B4@zip.com.au>
Date: Mon, 29 Jul 2002 00:34:50 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] start_aggressive_readahead
References: <3D41A54D.408FA357@zip.com.au> <48F039DC-A282-11D6-A4C0-000393829FA4@cs.amherst.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ snipped poor old Linus.  he doesn't read 'em anyway ]

Scott Kaplan wrote:
> 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On Friday, July 26, 2002, at 03:38 PM, Andrew Morton wrote:
> 
> > readahead was rewritten for 2.5.
> 
> It is just darned difficult to keep up with all of the changes!
> 
> > I think it covers most of the things you discuss there.
> >
> > - It adaptively grows the window size in response to "hits"
> 
> Seems somewhat reasonable, although easy to be fooled.  If I reference
> some of the most recently read-ahead blocks, I'll grow the read-ahead
> window, keeping other unreference, read-ahead blocks for longer, even
> though there's no evidence that keeping them longer will result in more
> hits.  In other words, it's not hits that should necessarily make you grow
> the cache -- it's the evidence that there will be an *increase* in hits if
> you do.

Ah, but if we're not getting hits in the readahead window
then we're getting misses.  And misses shrink the window.

Add two pages for a hit, remove 25% for a miss.  The window size
should stabilise at a size which  is larger if readahead is
being useful.  I hope.

> > - It shrinks the window size in response to "misses"  - if
> >   userspace requests a page which is *not* inside the previously-requested
> >   window, the future window size is shrunk by 25%
> 
> This one seems wierd.  If I reference a page that could have been in a
> larger read-ahead window, shouldn't I make the window *larger* so that
> next time, it *will* be in the window?

That's true.  If the application is walking across a file
touching every fifth page, readahead will stabilise at
its minimum window size, which is less than five pages and
we lose bigtime.   I'm not sure how to fix that while retaining
some sanity in the code.
 
> > - It detects eviction:  if userspace requests a page which *should*
> >   have been inside the readahead window, but it's actually not there,
> >   then we know it was evicted prior to being used.  We shrink the
> >   window by 3 pages.  (This almost never happens, in my testing).
> 
> Again, this seems backwards in the manner mentioned above.  It could have
> been resident, but it was evicted, so if you want it to be a hit, make the
> window *bigger*, no?  What should drive the reduction in the read-ahead
> window is the observation that recent increases have not yielding higher
> hit rates -- more has not been better.

That's the thrashing situation which Rik mentioned.  The application
must be reading the file very slowly.   We try to reduce the window
size to a point at which all the slow readers in the system stabilise
and stop thrashing each other's readahead.

This works up to a point - I had a little artificial test - just a process
which opens a great number of files and reads a page from each one,
cycling around.  The current code reduces the onset of thrashing in
that test, and reduces its severity.  It's significantly better than
the old code.  But there is still a dramatic dropoff in throughput once it
happens.

> > - It behaves differently for page faults:  for read(2), readahead is
> >   strictly ahead of the requested page.  For mmap pagefaults,
> >   the readaround window is positioned 25% behind the requested page and
> >   75% ahead of it.
> 
> That seems sensible enough...
> 
> The entire adaptive mechanism you've described seems only to consider one
> of the two competing pools, though, namely the read-ahead pool of pages.
> What about its competition -- The references to pages that are near
> eviction at the end of the inactive list?  Adapting to one without
> consideration of the other is working half-blind.  Why would you ever want
> to shrink the read-ahead window if very, very few pages at the end of the
> inactive list are being hit?

hmm.  The default max window size is 128kbytes at present.  For some
but not many tests, increasing it does help.  But mainly because of the
merging artifact which I mentioned earlier.

>  Similarly, you would want to be very
> cautious about increasing the size of the read-ahead window of many pages
> at the end of the inactive list are being re-used.

I tend to think that if pages at the tail of the LRU are being
referenced with any frequency we've goofed anyway.  There are
many things apart from readahead which will allocate pages, yes?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
