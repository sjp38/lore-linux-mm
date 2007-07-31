Date: Mon, 30 Jul 2007 22:17:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730221736.ccf67c86.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
	<20070730172007.ddf7bdee.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
	<20070731015647.GC32468@localdomain>
	<Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
	<20070730192721.eb220a9d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
	<20070730214756.c4211678.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 22:00:15 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 30 Jul 2007, Andrew Morton wrote:
> 
> > On Mon, 30 Jul 2007 19:36:04 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > On Mon, 30 Jul 2007, Andrew Morton wrote:
> > > 
> > > > That makes sense, but any fix we do here won't fix things for regular
> > > > reclaim.
> > > 
> > > Standard reclaim has the same issues. It uselessly keeps 
> > > scanning the unreclaimable file backed pages.
> > 
> > Well it shouldn't.  That's what all_unreclaimable is for.  And it does
> > work.  Or used to, five years ago.  Stuff like this has a habit of breaking
> > because we don't have a test suite.
> 
> The current VM has never been able to handle it since we have never had 
> logic to remove unreclaimable pages from the LRU.

Nonsense.  The VM used to handle it just fine.  That's what I wrote the
all_unreclaimable logic *for*.  It wasn't just added as typing practice.

Here's the changelog, from 22 Nov 2002:

	[PATCH] handle zones which are full of unreclaimable pages
	
	This patch is a general solution to the situation where a zone is full
	of pinned pages.
	
	This can come about if:
	
	a) Someone has allocated all of ZONE_DMA for IO buffers
	
	b) Some application is mlocking some memory and a zone ends up full
	   of mlocked pages (can happen on a 1G ia32 system)
	
	c) All of ZONE_HIGHMEM is pinned in hugetlb pages (can happen on 1G
	   machines)
	
	We'll currently burn 10% of CPU in kswapd when this happens, although
	it is quite hard to trigger.
	
	The algorithm is:
	
	- If page reclaim has scanned 2 * the total number of pages in the
	  zone and there have been no pages freed in that zone then mark the
	  zone as "all unreclaimable".
	
	- When a zone is "all unreclaimable" page reclaim almost ignores it.
	  We will perform a "light" scan at DEF_PRIORITY (typically 1/4096'th of
	  the zone, or 64 pages) and then forget about the zone.
	
	- When a batch of pages are freed into the zone, clear its "all
	  unreclaimable" state and start full scanning again.  The assumption
	  being that some state change has come about which will make reclaim
	  successful again.
	
	  So if a "light scan" actually frees some pages, the zone will revert to
	  normal state immediately.
	
	So we're effectively putting the zone into "low power" mode, and lightly
	polling it to see if something has changed.
	
	The code works OK, but is quite hard to test - I mainly tested it by
	pinning all highmem in hugetlb pages.


See?  "general".

Now it may be that someone broke it since then, sure.  But I haven't seen a
cogent bug report or test case for all the things you're waving hands at me
over.  Where's the git-bisect result?

> Lets bring up the patchsets for the handling of unreclaimable pages up 
> again (mlocked and anonymous/no swap) again and make sure that it also 
> addresses the issue issue here so that we have a comprehensive solution.

No, let us not.  If the existing crap isn't working as it should (and as it
used to) let us first fix (or at least understand) that before adding more
crap.

No?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
