Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 308316B0044
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 23:02:31 -0500 (EST)
Date: Tue, 30 Dec 2008 05:02:25 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
Message-ID: <20081230040225.GB27679@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de> <1229669697.17206.602.camel@nimitz> <20081219070311.GA26419@wotan.suse.de> <1229700721.17206.634.camel@nimitz> <20081222043526.GC13406@wotan.suse.de> <1230591637.19452.129.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1230591637.19452.129.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 29, 2008 at 03:00:37PM -0800, Dave Hansen wrote:
> On Mon, 2008-12-22 at 05:35 +0100, Nick Piggin wrote:
> > > Is there a real good reason to allocate the percpu counters dynamically?
> > > Might as well stick them in the vfsmount and let the one
> > > kmem_cache_zalloc() in alloc_vfsmnt() do a bit larger of an allocation.
> > > Did you think that was going to bloat it to a compound allocation or
> > > something?  I hate the #ifdefs. :)
> > 
> > Distros want to ship big NR_CPUS kernels and have them run reasonably on
> > small num_possible_cpus() systems. But also, it would help to avoid
> > cacheline bouncing from false sharing (allocpercpu.c code can also mess
> > this bug for small objects like these counters, but that's a problem
> > with the allocpercpu code which should be fixed anyway).
> 
> I guess we could also play the old trick:
> 
> struct vfsmount
> {
> 	...
> 	int mnt_writers[0];
> };
> 
> And just 
> 
> void __init mnt_init(void)
> {
> ...
> 	int size = sizeof(struct vfsmount) + num_possible_cpus() * sizeof(int)
> 
> -       mnt_cache = kmem_cache_create("mnt_cache", sizeof(struct vfsmount),
> +       mnt_cache = kmem_cache_create("mnt_cache", size,
>                         0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> 
> That should save us the dereference from the pointer and still let it be
> pretty flexible.  

Still results in cacheline contention, however...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
