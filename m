Date: Tue, 19 Aug 2008 12:25:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: page allocator minor speedup
Message-ID: <20080819102510.GD16446@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de> <20080818122957.GE9062@wotan.suse.de> <84144f020808180657v2bdd5f76l4b0f1897c73ec0c0@mail.gmail.com> <20080819074911.GA10447@wotan.suse.de> <1219132301.7813.358.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1219132301.7813.358.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 10:51:41AM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Mon, Aug 18, 2008 at 3:29 PM, Nick Piggin <npiggin@suse.de> wrote:
> > > > Now that we don't put a ZERO_PAGE in the pagetables any more, and the
> > > > "remove PageReserved from core mm" patch has had a long time to mature,
> > > > let's remove the page reserved logic from the allocator.
> > > >
> > > > This saves several branches and about 100 bytes in some important paths.
> ???
> On Mon, Aug 18, 2008 at 04:57:00PM +0300, Pekka Enberg wrote:
> > > Cool. Any numbers for this?
> 
> ???On Tue, 2008-08-19 at 09:49 +0200, Nick Piggin wrote:
> > No, no numbers. I expect it would be very difficult to measure because
> > it probably only starts saving cycles when the workload exceeds L1I and/or
> > the branch caches.
> 
> OK, I am asking this because any improvements in the page allocator fast
> paths are going to be a gain for SLUB intensive workloads as well.

Right. "OLTP" is *very* cache and branch sensitive... but I doubt this
would stand out from the noise.

BTW. I have a patch somewhere that adds a new interface to the page
allocator which avoids setting the page refcount. This way if you're
careful you can free the page after use without the expensive
atomic_dec_and_test & branch.

I didn't quite get it into a form that I like (would have required some
more extensive page allocator rework). But if you're interested in
numbers, then what I had should be enough to get an idea...

Remember to give SLAB the same advantage too ;)!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
