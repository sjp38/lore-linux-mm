Message-ID: <392AE273.D24CBC10@norran.net>
Date: Tue, 23 May 2000 21:56:35 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH--] Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)
References: <Pine.BSO.4.20.0005231244060.1176-100000@naughty.monkey.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yes, I know - that is why I do _fewer_ memory writes than the standard
pre9-3 kernel!

The standard kernel deletes and reinserts every linked page.

I do only move referenced pages once a second (trim able) in age_mmap or
when
hit by a search in shrink_mmap (not that likely due to age_mmap).

Other pages are not modified!

Since all pages is not in the lru (or phys page array) you have to
maintain
a list. That can be fixed in 2.5 ...

/RogerL


Chuck Lever wrote:
> 
> hi roger-
> 
> list manipulations are probably more expensive than maintaining a "load
> average" value associated with a page.  usually a list manipulation will
> require several memory writes into areas shared across CPUs; maintaining a
> weighted load average requires a single write.
> 
> this was an issue with andrea's original LRU implementation, IIRC.
> 
> On Tue, 23 May 2000, Roger Larsson wrote:
> 
> > From: Matthew Dillon <dillon@apollo.backplane.com>
> > >     The algorithm is a *modified* LRU.  Lets say you decide on a weighting
> > >     betweeen 0 and 10.  When a page is first allocated (either to the
> > >     buffer cache or for anonymous memory) its statistical weight is
> > >     set to the middle (5).  If the page is used often the statistical
> > >     weight slowly rises to its maximum (10).  If the page remains idle
> > >     (or was just used once) the statistical weight slowly drops to its
> > >     minimum (0).
> >
> > My patches has been approaching this a while... [slowly...]
> > The currently included patch adds has divided lru in four lists [0..3].
> > New pages are added at level 1.
> > Scan is performed - and referenced pages are moved up.
> >
> > Pages are moved down due to list balancing, but I have been playing with
> > other ideas.
> >
> > These patches should be a good continuation point.
> > Patches are against pre9-3 with Quintela applied.
> 
>         - Chuck Lever
> --
> corporate:      <chuckl@netscape.com>
> personal:       <chucklever@bigfoot.com>
> 
> The Linux Scalability project:
>         http://www.citi.umich.edu/projects/linux-scalability/
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
