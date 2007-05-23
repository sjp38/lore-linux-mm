Date: Wed, 23 May 2007 14:35:47 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523193547.GE11115@waste.org>
References: <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com> <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com> <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de> <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 10:07:33AM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Nick Piggin wrote:
> 
> > Oh, and just out of interest, SLOB before my patches winds up with
> > 1068K free, so it is good to know the patches were able to save a bit
> > on this setup.
> 
> Ahhh.. Its you who did the evil deed. By copying SLUB ideas SLOB became 
> better than SLUB.

Uh, what? SLOB's memory usage was already better.

Quoting Nick:
> After booting and mounting /proc, SLOB has 1140K free, SLUB has 748K
> free.

So that's:

 748K SLUB
1068K SLOB    (old SLOB saves 320K)
1140K SLOB++  (Nick's improvements save an additional 72K for 392K total)

(It'd be nice to have a SLAB number in there for completeness.)

Nick's patches also make SLOB reasonably performant on larger machines
(and can be a bit faster with a little tweaking). But it'll never be
as fast as SLAB or SLUB - it has to walk lists. Similarly, I think
it's basically impossible for a SLAB-like system that segregates
objects of different sizes onto different pages to compete with a
linked-list allocator on size. Especially now that Nick's reduced the
kmalloc overhead to 2 bytes!

So as long as there are machines where 100K or so makes a difference,
there'll be a use for a SLOB-like allocator.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
