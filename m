Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] modified segq for 2.5
Date: Tue, 10 Sep 2002 03:50:43 +0200
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <E17oXIx-0006vb-00@starship> <3D7D277E.7E179FA0@digeo.com>
In-Reply-To: <3D7D277E.7E179FA0@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oaAt-0006x4-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 September 2002 00:58, Andrew Morton wrote:
> Daniel Phillips wrote:
> > 
> > On Monday 09 September 2002 11:38, Andrew Morton wrote:
> > > One thing this patch did do was to speed up the initial untar of
> > > the kernel source - 50 seconds down to 25.  That'll be due to not
> > > having so much dirt on the inactive list.  The "nonblocking page
> > > reclaim" code (needs a better name...)
> > 
> > Nonblocking kswapd, no?  Perhaps 'kscand' would be a better name, now.
> 
> Well, it blocks still.  But it doesn't block on "this particular
> request queue" or on "that particular page ending IO".  It
> blocks on "any queue putting back a write request".   Which is
> basically equivalent to blocking on "a bunch of pages came clean".

It's not that far from being truly nonblocking, which would be a useful 
property.  Instead of calling ->writepage, just bump the page to the front of 
the pdlist (getting deja vu here).  Move locked pages off to a locked list 
and let them rehabilitate themselves asynchronously (since we can now do lru 
list moves inside interrupts).  If necessary, fall back to scanning the 
locked list for pages that slipped through the cracks, though it may be 
possible to make things airtight so that never happens.

What other ways for kswapd to block are there?  Buffers may be locked; a 
similar strategy applies, which is one reason why buffer state should not be 
opaque to the vfs.  ->releasepage is a can of worms, at which I'm looking 
suspiciously.

> Skipping is dumb.  It shouldn't have been on that list in the
> first place.

Sure, it's not the only way to skin the cat.  Anyway, skipping isn't so dumb 
that we haven't been doing it for years.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
