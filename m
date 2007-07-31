Date: Mon, 30 Jul 2007 19:27:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730192721.eb220a9d.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
	<20070730172007.ddf7bdee.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
	<20070731015647.GC32468@localdomain>
	<Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 19:01:07 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 30 Jul 2007, Ravikiran G Thirumalai wrote:
> 
> > On Mon, Jul 30, 2007 at 05:27:41PM -0700, Christoph Lameter wrote:
> > >On Mon, 30 Jul 2007, Andrew Morton wrote:
> > >
> > >> The problem is that __zone_reclaim() doesn't use all_unreclaimable at all.
> > >> You'll note that all the other callers of shrink_zone() do take avoiding
> > >> action if the zone is in all_unreclaimable state, but __zone_reclaim() forgot
> > >> to.
> > >
> > >zone reclaim only runs if there are unmapped file backed pages that can be 
> > >reclaimed. 
> > 
> > Yes, and in this case, without the patch, VM considers RAMFS pages to be
> > file backed, thus being fooled into entering reclaim.  The process entering
> > into reclaim in our tests gets in through zone_reclaim.

Oh.. So this:

	/*
	 * Zone reclaim reclaims unmapped file backed pages and
	 * slab pages if we are over the defined limits.
	 *
	 * A small portion of unmapped file backed pages is needed for
	 * file I/O otherwise pages read by file I/O will be immediately
	 * thrown out if the zone is overallocated. So we do not reclaim
	 * if less than a specified percentage of the zone is used by
	 * unmapped file backed pages.
	 */
	if (zone_page_state(zone, NR_FILE_PAGES) -
	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_pages
	    && zone_page_state(zone, NR_SLAB_RECLAIMABLE)
			<= zone->min_slab_pages)
		return 0;

is being fooled.

That makes sense, but any fix we do here won't fix things for regular
reclaim.

Sigh, I should have spotted that bug on day one - it's pretty gross.  Too
many patches, too little akpm.

> That means RAMFS pages are accounted as NR_FILE_PAGES but not as 
> NR_FILE_MAPPED..... So we have unmapped pages that are not reclaimable.
> 
> But they are not really file backed pages. They are backed by memory. Can 
> we just not increment NR_FILE_MAPPED? Should they not be accounted for an 
> NR_ANON_PAGES or so?

Or we change NR_FILE_MAPPED accounting so that it doesn't account
BDI_CAP_foo pages, where foo is, I guess, NO_WRITEBACK.

We're going to create a mess here, I can feel it.  Please, ignore "what works".
What is _right_ here?  What is our design?  Our guiding principle?  Because we
already have a mess.

Straw man proposal:

- account file-backed pages, BDI_CAP_NO_ACCT_DIRTY pages and
  BDI_CAP_NO_WRITEBACK separately.  ie: zone accounting pretty
  much follows the BDI_CAP_ selectors.

- work out, then document what those BDI_CAP_* things actually _mean_.  ie:
  which sorts of callers should set them, and why.

- do the appropriate arith at reclaim-time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
