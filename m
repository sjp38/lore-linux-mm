Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AABBB6B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 05:03:23 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o5S93KWL030677
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 02:03:20 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by hpaq6.eem.corp.google.com with ESMTP id o5S92lPe028682
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 02:03:19 -0700
Received: by pxi1 with SMTP id 1so2949284pxi.1
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 02:03:18 -0700 (PDT)
Date: Mon, 28 Jun 2010 02:03:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: kmem_cache_destroy() badness with SLUB
In-Reply-To: <1277688701.4200.159.camel@pasglop>
Message-ID: <alpine.DEB.2.00.1006280159010.28072@chino.kir.corp.google.com>
References: <1277688701.4200.159.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, Benjamin Herrenschmidt wrote:

> Hi folks !
> 
> Internally, I'm hitting a little "nit"...
> 
> sysfs_slab_add() has this check:
> 
> 	if (slab_state < SYSFS)
> 		/* Defer until later */
> 		return 0;
> 
> But sysfs_slab_remove() doesn't.
> 
> So if the slab is created -and- destroyed at, for example, arch_initcall
> time, then we hit a WARN in the kobject code, trying to dispose of a
> non-existing kobject.
> 

Indeed, but shouldn't we be appropriately handling the return value of 
sysfs_slab_add() so that it fails cache creation?  We wouldn't be calling 
sysfs_slab_remove() on a cache that was never created.

> Now, at first sight, just adding the same test to sysfs_slab_remove()
> would do the job... but it all seems very racy to me.
> 
> I don't understand in fact how this slab_state deals with races at all. 
> 

All modifiers of slab_state are intended to be run only on the boot cpu so 
the only concern is the ordering.  We need slab_state to indicate how far 
slab has been initialized since we can't otherwise enforce how code uses 
slab in between things like kmem_cache_init(), kmem_cache_init_late(), and 
initcalls on the boot cpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
