Date: Mon, 30 Jul 2007 22:58:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730225809.ed0a95ff.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
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
	<20070730221736.ccf67c86.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 22:33:03 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 30 Jul 2007, Andrew Morton wrote:
> 
> > Nonsense.  The VM used to handle it just fine.  That's what I wrote the
> > all_unreclaimable logic *for*.  It wasn't just added as typing practice.
> 
> That is if the whole zone is unreclaimable. The problems that we want to 
> solve are due to parts of a zone being unreclaimable and due to the VM 
> counters giving an inaccurate picture of the memory situation.

Where is the evidence that this is happening in Kiran's situation?

> > See?  "general".
> 
> Nope. Its a special situation in which the whole zone has become 
> unhandleable by the reclaim logic so it gives up and waits for things 
> somehow to get better.

yes.

> During that time we cannot allocate from a zone 
> which typically makes a vital zone or a node unusuable.

Of course you can't - there are no free pages and none are reclaimable.

> In a NUMA 
> configuration performance degrades in unacceptable ways.

No it won't - you must be referring to something else, or speculating.

> What we want is to remove the unreclaimable pages from the LRU and have 
> reclaim continue on the remainder of the zone.

Well that might be what we want.  afacit we don't know yet.

> > No, let us not.  If the existing crap isn't working as it should (and as it
> > used to) let us first fix (or at least understand) that before adding more
> > crap.
> > 
> > No?
> 
> The all_reclaimable logic is different. It was never been designed to 
> remove the unreclaimable pages.

Of course not.  But I don't know how you can be proposing solutions
without yet knowing what the problem is.

The first thing Kiran should have done was to gather a kernel profile.  If
we're spending a lot (proably half) of time in shrink_active_lsit() then
yeah, that's a plausible theory.

And yes, keeping these pages off the LRU does make sense, and it heaps
easier to handle than mlocked pages.


Sorry, I just go crazy when I see these random pokes at the VM which
are nowhere near being backed by sufficient analysis of the problem
which they allegedly solve.

The _theory_ here is that a large number (but not all) of the pages
in the zone are in ramfs and so page reclaim is making some progress,
but reclaim efficiency is low, hence there is high CPU consumption.

OK, plausible.  But where's the *proof*?  We probably already have 
sufficient statistics to be able to prove this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
