Subject: Re: [PATCH] reduce fragmentation due to kmem_cache_alloc_node
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <41684BF3.5070108@colorfullife.com>
References: <41684BF3.5070108@colorfullife.com>
Content-Type: text/plain
Message-Id: <1097514734.12861.366.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 11 Oct 2004 10:12:24 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Manfred,

This patch seems to work fine on my AMD machine.
I tested your patch on 2.6.9-rc2-mm3. 

It seemed to have fixed fragmentation problem I was
observing, but I don't think it fixed the problem
completely. I still see some fragmentation, with
repeated tests of scsi-debug, but it could be due
to the test. I will collect more numbers..

Thanks,
Badari

On Sat, 2004-10-09 at 13:37, Manfred Spraul wrote:
> Hi Andrew,
> 
> attached is a patch that fixes the fragmentation that Badri noticed with 
> kmem_cache_alloc_node. Could you add it to the mm tree? The patch is 
> against 2.6.9-rc3-mm3.
> 
> Description:
> kmem_cache_alloc_node tries to allocate memory from a given node. The 
> current implementation contains two bugs:
> - the node aware code was used even for !CONFIG_NUMA systems. Fix: 
> inline function that redefines kmem_cache_alloc_node as kmem_cache_alloc 
> for !CONFIG_NUMA.
> - the code always allocated a new slab for each new allocation. This 
> caused severe fragmentation. Fix: walk the slabp lists and search for a 
> matching page instead of allocating a new page.
> - the patch also adds a new statistics field for node-local allocs. They 
> should be rare - the codepath is quite slow, especially compared to the 
> normal kmem_cache_alloc.
> 
> Badri: Could you test it?
> Andrew, could you add the patch to the next -mm kernel? I'm running it 
> right now, no obvious problems.
> 
> Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>
> 
> 
> ______________________________________________________________________


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
