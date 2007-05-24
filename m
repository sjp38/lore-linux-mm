Date: Thu, 24 May 2007 01:11:53 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524061153.GP11115@waste.org>
References: <20070523071200.GB9449@wotan.suse.de> <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com> <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com> <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com> <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 03:48:18PM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Matt Mackall wrote:
> 
> > On Wed, May 23, 2007 at 03:26:05PM -0700, Christoph Lameter wrote:
> > > On Wed, 23 May 2007, Matt Mackall wrote:
> > > 
> > > > On Wed, May 23, 2007 at 01:02:53PM -0700, Christoph Lameter wrote:
> > > > > On Wed, 23 May 2007, Matt Mackall wrote:
> > > > > 
> > > > > > Meanwhile this function is only called from swsusp.c.
> > > > > 
> > > > > NR_SLAB_UNRECLAIMABLE is also used in  __vm_enough_memory and 
> > > > > in zone reclaim (well ok thats only NUMA).
> > > > 
> > > > It's NR_SLAB_RECLAIMABLE in __vm_enough_memory. And that is always
> > > > zero with SLOB. There aren't any reclaimable slab pages.
> > > 
> > > All dentries and inodes are reclaimable via the shrinkers in vmscan.c. So 
> > > you are saying that SLOB does not allow dentry and inode reclaim?
> > 
> > No. I've already pointed out the EXACT CALL CHAIN that leads to dentry
> > reclaim. And it's independent of NR_SLAB_RECLAIMABLE and independent
> > of allocator.
> 
> So we have an allocator which is not following the rules... You are 
> arguing that dysfunctional behavior of SLOB does not have bad effects.
> 
> 1. We have allocated reclaimable objects via SLOB (dentry & inodes)
> 
> 2. We can reclaim them
> 
> 3. The allocator lies about it telling the VM that there is nothing 
> reclaimable because NR_SLAB_UNRECLAIMABLE is always 0.

4. The VM calls shrink_slabs anyway so the implied "rules" don't
actually exist (yet).

Because there's no guarantee that dcache or icache can actually be
shrunk _at all_, the VM can't do much of anything with
NR_SLAB_RECLAIMABLE. It could skip shrinking slabs if RECLAIMABLE=0
but as that never happens in practice with SLAB, the check's pretty
pointless. Nor can users glean any information from it, in fact
they'll probably be mislead!

So, here's three possible approaches to this issue:

A) Continue to ignore it. Doing something about it would add
complexity and it's not clear that it's a win.

B) Set NR_SLAB_RECLAIMABLE to 1. If the VM starts checking that to
decide whether it should call shrinkers, things will continue to work.
Increment and decrement NR_SLAB_UNRECLAIMABLE when we grow/shrink the
SLOB pool. This is probably 3 lines of code total.

C) Fake NR_SLAB_RECLAIMABLE/NR_SLAB_UNRECLAIMABLE based on actual
allocs and slab flags such that they sum to the total pages in the
SLOB pool. This would need a third global counter in bytes of how many
allocs we had in the "reclaimable" slabs. Probably 10-20 lines of
code of marginal utility. 

So, nothing insurmountable here. Just not convinced we should bother.
But the cost of B is so low, perhaps I might as well.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
