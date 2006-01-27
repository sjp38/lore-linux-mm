Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0R0YWu3025604
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 19:34:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0R0WieQ182988
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:32:44 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0R0YVOK010238
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 17:34:31 -0700
Message-ID: <43D96A93.9000600@us.ibm.com>
Date: Thu, 26 Jan 2006 16:34:27 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com> <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com> <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com> <43D96633.4080900@us.ibm.com> <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com>
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
>>Allocations backed by a mempool must always be allocated via
>>mempool_alloc() (or mempool_alloc_node() in this case).  What that means
>>is, without a mempool_alloc_node() function, NO mempool backed allocations
>>will be able to request a specific node, even when the system has PLENTY of
>>memory!  This, IMO, is unacceptable.  Adding more NUMA-awareness to the
>>mempool system allows us to keep the same slab behavior as before, as well
>>as leaving us free to ignore the node requests when memory is low.
> 
> 
> Ok. That makes sense. I thought the mempool_xxx functions were only for 
> emergencies. But nevertheless you still duplicate all memory allocation 
> functions. I already was a bit concerned when I added the _node stuff.

I'm glad we're on the same page now. :)  And yes, adding four "duplicate"
*_mempool allocators was not my first choice, but I couldn't easily see a
better way.


> What may be better is to add some kind of "allocation policy" to an 
> allocation. That allocation policy could require the allocation on a node, 
> distribution over a series of nodes, require allocation on a particular 
> node, or allow the use of emergency pools etc.
> 
> Maybe unify all the different page allocations to one call and do the 
> same with the slab allocator.

Hmmm...  I kinda like that.  Some sort of

struct allocation_policy
{
	enum       policy_type;
	nodemask_t nodes;
	mempool_t  critical_pool;
}

that could be passed to __alloc_pages()?

That seems a bit beyond the scope of what I'd hoped for this patch series,
but if an approach like this is believed to be generally useful, it's
something I'm more than willing to work on...

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
