Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2GIsRRS023965
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 13:54:27 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2GIsQwE175108
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 13:54:26 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2GIsQKD004386
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 13:54:26 -0500
Date: Wed, 16 Mar 2005 10:54:09 -0800
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Fw: [PATCH] NUMA Slab Allocator
Message-ID: <273220000.1110999247@[10.10.2.4]>
In-Reply-To: <42387C2E.4040106@colorfullife.com>
References: <20050315204110.6664771d.akpm@osdl.org> <42387C2E.4040106@colorfullife.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Christoph Lameter <christoph@lameter.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Do you have profile data from your modification? Which percentage of the allocations is node-local, which percentage is from foreign nodes? Preferably per-cache. It shouldn't be difficult to add statistics counters to your patch.
> And: Can you estaimate which percentage is really accessed node-local and which percentage are long-living structures that are accessed from all cpus in the system?
> I had discussions with guys from IBM and SGI regarding a numa allocator, and we decided that we need profile data before we can decide if we need one:
> - A node-local allocator reduces the inter-node traffic, because the callers get node-local memory
> - A node-local allocator increases the inter-node traffic, because objects that are kfree'd on the wrong node must be returned to their home node.

One of the big problems is that much of the slab data really is more global
(ie dentry, inodes, etc). Some of it is more localized (typically the 
kmalloc style stuff). I can't really generate any data easily, as most
of my NUMA boxes are either small Opterons / midsized PPC64, which have 
a fairly low NUMA factor, or large ia32, which only has kernel mem on 
node 0 ;-(

> IIRC the conclusion from our discussion was, that there are at least four possible implementations:
> - your version
> - Add a second per-cpu array for off-node allocations. __cache_free batches, free_block then returns. Global spinlock or per-node spinlock. A patch with a global spinlock is in
> http://www.colorfullife.com/~manfred/Linux-kernel/slab/patch-slab-numa-2.5.66
> per-node spinlocks would require a restructuring of free_block.
> - Add per-node array for each cpu for wrong node allocations. Allows very fast batch return: each array contains memory just from one node, usefull if per-node spinlocks are used.
> - do nothing. Least overhead within slab.
> 
> I'm fairly certains that "do nothing" is the right answer for some caches. 
> For example the dentry-cache: The object lifetime is seconds to minutes, 
> the objects are stored in a global hashtable. They will be touched from 
> all cpus in the system, thus guaranteeing that kmem_cache_alloc returns 
> node-local memory won't help. But the added overhead within slab.c will hurt.

That'd be my inclination .... but OTOH, we do that for pagecache OK. Dunno, 
I'm torn. Depends if there's locality on the file access or not, I guess.
Is there any *harm* in doing it node local .... perhaps creating a node
mem pressure imbalance (OTOH, there's loads of stuff that does that anyway ;-))

The other thing that needs serious thought is how we balance reclaim pressure.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
