Date: Thu, 18 Oct 2007 02:13:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch](memory hotplug) Make kmem_cache_node for SLUB on memory
 online to avoid panic(take 3)
In-Reply-To: <20071018000004.cf4727e7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710180203500.13576@schroedinger.engr.sgi.com>
References: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
 <20071017204651.aefcece7.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0710172321550.11401@schroedinger.engr.sgi.com>
 <20071018000004.cf4727e7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Oct 2007, Andrew Morton wrote:

> > Slab brings up a per node structure when the corresponding cpu is brought 
> > up. That was sufficient as long as we did not have any memoryless nodes. 
> > Now we may have to fix some things over there as well.
> 
> Is there amy point?  Our time would be better spent in making
> slab.c go away.  How close are we to being able to do that anwyay?

Well the problem right now is the regression in slab_free() on SMP. 
AFAICT UP and NUMA is fine and also most loads under SMP. Concurrent 
allocation / frees on multiple processors are several times faster (I see 
up to 10 fold improvements on an 8p).

However, long sequences of free operations from a single processor under 
SMP require too many atomic operations compared with SLAB. If I only do 
frees on a single processor on SMP then I can produce a 30% regression for 
slabs between 128 and 1024 byte in size. I have a patchset in the works 
that reduces the atomic operations for those.

SLAB currently has an advantage since it uses coarser grained locking. 
SLAB can take a global lock and then perform queue operations on 
multiple objects. SLUB has fine grained locking which increases 
concurrency but also the overhead of atomic operations.

The regression does not surface under UP since we do not need to do 
locking. And it does not surface under NUMA since the alien cache stuff in 
SLAB is reducing slab_free performance compared to SMP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
