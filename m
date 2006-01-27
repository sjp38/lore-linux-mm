Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0R0Fpnx010168
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 19:15:51 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0R0E3eQ235122
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:14:03 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0R0Foko014184
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:15:51 -0700
Message-ID: <43D96633.4080900@us.ibm.com>
Date: Thu, 26 Jan 2006 16:15:47 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com> <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com> <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 26 Jan 2006, Matthew Dobson wrote:
> 
> 
>>alloc_pages_node() does not guarantee allocation on a specific node, but
>>calling __alloc_pages() with a specific nodelist would.
> 
> 
> True but you have emergency *_node function that do not take nodelists.

Agreed.


>>>There is no way that you would need this patch.
>>
>>My goal was to not change the behavior of the slab allocator when inserting
>>a mempool-backed allocator "under" it.  Without support for at least
>>*requesting* allocations from a specific node when allocating from a
>>mempool, this would change how the slab allocator works.  That would be
>>bad.  The slab allocator now does not guarantee that, for example, a
>>kmalloc_node() request is satisfied by memory from the requested node, but
>>it does at least TRY.  Without adding mempool_alloc_node() then I would
>>never be able to even TRY to satisfy a mempool-backed kmalloc_node()
>>request from the correct node.  I believe that would constitute an
>>unacceptable breakage from normal, documented behavior.  So, I *do* need
>>this patch.
> 
> 
> If you get to the emergency lists then you are already in a tight memory 
> situation. In that situation it does not make sense to worry about the 
> node number the memory is coming from. kmalloc_node is just a kmalloc with 
> an indication of a preference of where the memory should be coming from. 
> The node locality only influences performance and not correctness.
> 
> There is no change to the way the slab allocator works. Just drop the 
> *_node variants.

If you look more carefully at how the emergency mempools are used, I think
you'll better understand why I did this:

Look at patch 9/9, specficially the changes to kmem_getpages():

-	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
+	/*
+	 * If this allocation request isn't backed by a memory pool, or if that
+	 * memory pool's gfporder is not the same as the cache's gfporder, fall
+	 * back to alloc_pages_node().
+	 */
+	if (!pool || cachep->gfporder != (int)pool->pool_data)
+		page = alloc_pages_node(nodeid, flags, cachep->gfporder);
+	else
+		page = mempool_alloc_node(pool, flags, nodeid);

Allocations backed by a mempool must always be allocated via
mempool_alloc() (or mempool_alloc_node() in this case).  What that means
is, without a mempool_alloc_node() function, NO mempool backed allocations
will be able to request a specific node, even when the system has PLENTY of
memory!  This, IMO, is unacceptable.  Adding more NUMA-awareness to the
mempool system allows us to keep the same slab behavior as before, as well
as leaving us free to ignore the node requests when memory is low.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
