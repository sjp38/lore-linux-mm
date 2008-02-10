Date: Sun, 10 Feb 2008 03:45:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080210024517.GA32721@wotan.suse.de>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080209143518.ced71a48.akpm@linux-foundation.org> <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 09, 2008 at 04:19:39PM -0800, Christoph Lameter wrote:
> On Sat, 9 Feb 2008, Andrew Morton wrote:
> 
> > On Sat, 9 Feb 2008 13:45:11 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > Isnt there a way that we can make the page allocator handle PAGE_SIZEd 
> > > allocations in such a way that is competitive with the slab allocators? 
> > > The cycle count for an allocation needs to be <100 not just below 1000 as 
> > > it is now.
> > Well.  Where are the cycles spent?
> 
> No idea. This is from some measurements I took with my page allocator 
> benchmarks. For the tests see the code at
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git tests
> 
> We do a gazillion of tests before doing anything. Most of that is NUMA 
> stuff it seems but even in SMP this is still signficant.
> 
> > We are notorious for sucking but I don't think even we suck enough to have
> > left a 10x optimisation opportunity in the core page allocator ;)
> 
> The regression only occurs if there is intensive allocation and freeing of 
> pages. If there is a contiguous stream of allocations then there will be 
> no regression since the slab allocators will have to go to the page 
> allocator to get new pages. So the suckiness gets pushed under the carpet.
> 
> The SLUB fastpath takes around 40-50 cycles if things align right.
> SLAB takes around 80-100 cycles.
> The page allocator fastpath takes 342 cycles(!) at its best (Note kernel 
> compiled for SMP no NUMA!)

What kind of allocating and freeing of pages are you talking about? Are
you just measuring single threaded performance?

I haven't looked at the page allocator for a while, but last time I did
there are quirks in the pcp lists where say if the freed page is
considered cold but the allocation wants a hot page, then it always
goes to the page zone.

Other things you can do like not looking at the watermarks if the zone
has pcp pages avoids cacheline bouncing on SMP. 

I had a set of patches do to various little optimisations like that, but
I don't actually know if they would help you significantly or not.

I could try a bit of profiling if you tell me what specific test you
are interested in?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
