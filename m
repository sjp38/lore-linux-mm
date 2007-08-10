Date: Fri, 10 Aug 2007 11:40:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
Message-Id: <20070810114033.f655c905.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708101037290.12758@schroedinger.engr.sgi.com>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
	<20070810004059.8aa2aadb.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708101037290.12758@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007 10:40:15 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 10 Aug 2007, Andrew Morton wrote:
> 
> > Well that was fairly foul.  What was wrong wih turning slub_lock into a
> > spinlock?
> 
> It would make things even worse because we would have always to do atomic 
> allocs when holding the lock.

That would be dumb.

> Or allocate before and then take the 
> lock to check if someone else has created it.

Obviously better.

> If so we would need to fall 
> back meaning we cannot avoid kmem_cache_destroy() from dynamic cache 
> creation.

I think you meant kmem_cache_close().  There's nothing wrong with running
kmem_cache_close() synchronously, inside spinlock.

> The trylock avoids the kmem_cache_destroy() and is minimally 
> invasive.

I see no need for a kmem_cache_destroy() call.  The sysfs stuff hasn't
been created yet.

The trylock is *revolting*.  They always are.  They introduce
rarely-occurring special cases which get little runtime testing and they
introduce special-cases which often only get exercised with certain
configs.

As an example, look at what this patch did.  There are crufty old drivers
out there which do GFP_ATOMIC allocations at init-time because they got
themselves in a locking mess.  Old scsi drivers come to mind.  Old scsi
drivers often use GFP_DMA too.  We've now gone and increased the
probability of those allocations failing.

Contrary to the assertions in the changelog, those allocations will not be
retried.  Generally if an allocation fails at initialisation time a crufty
old driver will either a) fail the initialisation (ie: boot failure), b)
panic or c) oops the kernel.

> > > +	schedule_work(&sysfs_add_work);
> > 
> > sysfs_add_work could be already pending, or running.  boom.
> 
> sysfs_add_work takes the slub_lock. It cannot be running.

It _can_ be running and it _can_ be pending.  But yes, given
schedule_work()'s behaviour when an already-pending work is rescheduled and
given the locking which you have in there, that part of the code appears to
be reliable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
