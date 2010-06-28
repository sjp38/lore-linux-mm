Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C92D46B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 17:44:39 -0400 (EDT)
Subject: Re: kmem_cache_destroy() badness with SLUB
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.DEB.2.00.1006280159010.28072@chino.kir.corp.google.com>
References: <1277688701.4200.159.camel@pasglop>
	 <alpine.DEB.2.00.1006280159010.28072@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 29 Jun 2010 07:44:29 +1000
Message-ID: <1277761469.4200.194.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-28 at 02:03 -0700, David Rientjes wrote:
> On Mon, 28 Jun 2010, Benjamin Herrenschmidt wrote:
> 
> > Hi folks !
> > 
> > Internally, I'm hitting a little "nit"...
> > 
> > sysfs_slab_add() has this check:
> > 
> > 	if (slab_state < SYSFS)
> > 		/* Defer until later */
> > 		return 0;
> > 
> > But sysfs_slab_remove() doesn't.
> > 
> > So if the slab is created -and- destroyed at, for example, arch_initcall
> > time, then we hit a WARN in the kobject code, trying to dispose of a
> > non-existing kobject.
> > 
> Indeed, but shouldn't we be appropriately handling the return value of 
> sysfs_slab_add() so that it fails cache creation?  We wouldn't be calling 
> sysfs_slab_remove() on a cache that was never created.

It's eventually created, but yes, we should probably store a state,
unless we have a clean way to know the kobject in there is uninitialized
and test for that.

> > Now, at first sight, just adding the same test to sysfs_slab_remove()
> > would do the job... but it all seems very racy to me.
> > 
> > I don't understand in fact how this slab_state deals with races at all. 
> > 
> All modifiers of slab_state are intended to be run only on the boot cpu so 
> the only concern is the ordering.  We need slab_state to indicate how far 
> slab has been initialized since we can't otherwise enforce how code uses 
> slab in between things like kmem_cache_init(), kmem_cache_init_late(), and 
> initcalls on the boot cpu.

But initcalls aren't pinned to the boot CPU... IE. I don't see how the
sysfs creation avoids racing with SLAB creation, or am I missing
something ?

Cheers,
Ben.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
