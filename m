Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 818026B0044
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 18:00:41 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBTMxJ7Y010176
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 15:59:19 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBTN0dCH202794
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 16:00:39 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBTN0dDx014325
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 16:00:39 -0700
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081222043526.GC13406@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de>
	 <1229669697.17206.602.camel@nimitz> <20081219070311.GA26419@wotan.suse.de>
	 <1229700721.17206.634.camel@nimitz>  <20081222043526.GC13406@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 29 Dec 2008 15:00:37 -0800
Message-Id: <1230591637.19452.129.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-22 at 05:35 +0100, Nick Piggin wrote:
> > Is there a real good reason to allocate the percpu counters dynamically?
> > Might as well stick them in the vfsmount and let the one
> > kmem_cache_zalloc() in alloc_vfsmnt() do a bit larger of an allocation.
> > Did you think that was going to bloat it to a compound allocation or
> > something?  I hate the #ifdefs. :)
> 
> Distros want to ship big NR_CPUS kernels and have them run reasonably on
> small num_possible_cpus() systems. But also, it would help to avoid
> cacheline bouncing from false sharing (allocpercpu.c code can also mess
> this bug for small objects like these counters, but that's a problem
> with the allocpercpu code which should be fixed anyway).

I guess we could also play the old trick:

struct vfsmount
{
	...
	int mnt_writers[0];
};

And just 

void __init mnt_init(void)
{
...
	int size = sizeof(struct vfsmount) + num_possible_cpus() * sizeof(int)

-       mnt_cache = kmem_cache_create("mnt_cache", sizeof(struct vfsmount),
+       mnt_cache = kmem_cache_create("mnt_cache", size,
                        0, SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);

That should save us the dereference from the pointer and still let it be
pretty flexible.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
