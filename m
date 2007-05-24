Date: Thu, 24 May 2007 04:05:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524020530.GA13694@wotan.suse.de>
References: <20070523071200.GB9449@wotan.suse.de> <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com> <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com> <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com> <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
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


SLOB doesn't keep track of what pages might be reclaimable, so yes
it reports zero to the VM. That doesn't make it non functional or
even prevent slab reclaim from working.

Doesn't SLUB "lie" to the VM telling it that unreclaimable dentries
are reclaimable? That doesn't make it broken...

If you were to come up with a system that gets the accounting right
while also being as space efficient, then sure that is preferable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
