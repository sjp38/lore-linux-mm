Date: Fri, 10 Aug 2007 11:52:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
In-Reply-To: <20070810114033.f655c905.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708101143270.17426@schroedinger.engr.sgi.com>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
 <20070810004059.8aa2aadb.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708101037290.12758@schroedinger.engr.sgi.com>
 <20070810114033.f655c905.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007, Andrew Morton wrote:

> > back meaning we cannot avoid kmem_cache_destroy() from dynamic cache 
> > creation.
> 
> I think you meant kmem_cache_close().  There's nothing wrong with running
> kmem_cache_close() synchronously, inside spinlock.

Using kmem_cache_close would be possible if we defer the sysfs_add as  
in the existing patch and keep the unrolling of the 
create_kmalloc_cache function.

> > The trylock avoids the kmem_cache_destroy() and is minimally 
> > invasive.
> 
> I see no need for a kmem_cache_destroy() call.  The sysfs stuff hasn't
> been created yet.

Yes after my patch that is true. Its not true before the patch. Before we 
called create_kmalloc_path.

> The trylock is *revolting*.  They always are.  They introduce
> rarely-occurring special cases which get little runtime testing and they
> introduce special-cases which often only get exercised with certain
> configs.

This is an extremely rare condition for rarely used functionality that we 
are dealing with here. The acquisition is only needed for a very few 
numbers of times.

Changing to spinlock is a signficant change in slub certainly not fit for 
2.6.23. Spinlocks will make later allocations of per node and per 
cpu structures (cpu hotplug node hotplug) while looping over the list of all 
slabs very difficult.

> As an example, look at what this patch did.  There are crufty old drivers
> out there which do GFP_ATOMIC allocations at init-time because they got
> themselves in a locking mess.  Old scsi drivers come to mind.  Old scsi
> drivers often use GFP_DMA too.  We've now gone and increased the
> probability of those allocations failing.

Given that SLUB has been out there for 6 months with this issue and we 
have not heard from them I think that is very unlikely. The issue only 
surfaced when someone started tinkering with a new driver that needed 
GFP_DMA for allocs < 1GB.

> > sysfs_add_work takes the slub_lock. It cannot be running.
> 
> It _can_ be running and it _can_ be pending.  But yes, given
> schedule_work()'s behaviour when an already-pending work is rescheduled and
> given the locking which you have in there, that part of the code appears to
> be reliable.

Well we both reversed position on that one. See the other 
message.

After the changes for SLUB (page allocator pass through) in mm we have 
reduced the number of kmalloc slabs to PAGE_SHIFT. We could create all 
kmalloc dma slabs at init time without wasting too much memory for the mm 
version of SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
