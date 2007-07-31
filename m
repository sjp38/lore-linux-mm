Date: Mon, 30 Jul 2007 23:09:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070730225809.ed0a95ff.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707302300090.874@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
 <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
 <20070730192721.eb220a9d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
 <20070730214756.c4211678.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
 <20070730221736.ccf67c86.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
 <20070730225809.ed0a95ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Andrew Morton wrote:

> > That is if the whole zone is unreclaimable. The problems that we want to 
> > solve are due to parts of a zone being unreclaimable and due to the VM 
> > counters giving an inaccurate picture of the memory situation.
> 
> Where is the evidence that this is happening in Kiran's situation?

He used ramfs for some of this memory. As a result some memory became
unreclaimable but it was put on the LRU. Zone reclaim understood that
as reclaimable memory since unmapped file backed pages were on the LRU and 
scanned for them.

> > During that time we cannot allocate from a zone 
> > which typically makes a vital zone or a node unusuable.
> 
> Of course you can't - there are no free pages and none are reclaimable.

There may be free pages that we cannot get to because too many 
unreclaimable pages have to be scanned until we get there.

> > In a NUMA 
> > configuration performance degrades in unacceptable ways.
> 
> No it won't - you must be referring to something else, or speculating.

Sorry that occurs at SGI. Typically if a customers uses XPMEM to pin too 
many pages on a zone.

> > The all_reclaimable logic is different. It was never been designed to 
> > remove the unreclaimable pages.
> 
> Of course not.  But I don't know how you can be proposing solutions
> without yet knowing what the problem is.

We know the problem and have seen it repeatedly.
 
> The first thing Kiran should have done was to gather a kernel profile.  If
> we're spending a lot (proably half) of time in shrink_active_lsit() then
> yeah, that's a plausible theory.

Well that is what the traces show here in these scenarios. I have never
seen it in zone_reclaim (guess we do not use ramfs that warps the 
counters)
 
> And yes, keeping these pages off the LRU does make sense, and it heaps
> easier to handle than mlocked pages.

I think this is pretty straighforward.

> The _theory_ here is that a large number (but not all) of the pages
> in the zone are in ramfs and so page reclaim is making some progress,
> but reclaim efficiency is low, hence there is high CPU consumption.

No theory. The problem here is that the VM counters are off. RAMFS puts 
pages unmapped pages on the LRU that are not reclaimable and zone reclaim 
will continually run to get rid of these pages counting on the ability to 
throw out unmapped pages. 

What are these pages doing on the LRU if they cannot be reclaimed anyways? 
There is no point on putting them on it in the first place.

> OK, plausible.  But where's the *proof*?  We probably already have 
> sufficient statistics to be able to prove this.

Rik has shown this repeatedly. You want metaphysical certainty?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
