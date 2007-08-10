Date: Fri, 10 Aug 2007 10:40:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
In-Reply-To: <20070810004059.8aa2aadb.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708101037290.12758@schroedinger.engr.sgi.com>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
 <20070810004059.8aa2aadb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Aug 2007, Andrew Morton wrote:

> Well that was fairly foul.  What was wrong wih turning slub_lock into a
> spinlock?

It would make things even worse because we would have always to do atomic 
allocs when holding the lock. Or allocate before and then take the 
lock to check if someone else has created it. If so we would need to fall 
back meaning we cannot avoid kmem_cache_destroy() from dynamic cache 
creation. The trylock avoids the kmem_cache_destroy() and is minimally 
invasive.

> > +	schedule_work(&sysfs_add_work);
> 
> sysfs_add_work could be already pending, or running.  boom.

sysfs_add_work takes the slub_lock. It cannot be running.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
