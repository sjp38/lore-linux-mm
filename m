Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0QNOYkV024909
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 18:24:34 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0QNMjeQ235014
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 16:22:45 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0QNOXPp011027
	for <linux-mm@kvack.org>; Thu, 26 Jan 2006 16:24:33 -0700
Message-ID: <43D95A2E.4020002@us.ibm.com>
Date: Thu, 26 Jan 2006 15:24:30 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com> <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com>
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
>>Not all requests for memory from a specific node are performance
>>enhancements, some are for correctness.  With large machines, especially as
> 
> 
> alloc_pages_node and friends do not guarantee allocation on that specific 
> node. That argument for "correctness" is bogus.

alloc_pages_node() does not guarantee allocation on a specific node, but
calling __alloc_pages() with a specific nodelist would.


>>>You do not need this.... 
>>
>>I do not agree...
> 
> 
> There is no way that you would need this patch.

My goal was to not change the behavior of the slab allocator when inserting
a mempool-backed allocator "under" it.  Without support for at least
*requesting* allocations from a specific node when allocating from a
mempool, this would change how the slab allocator works.  That would be
bad.  The slab allocator now does not guarantee that, for example, a
kmalloc_node() request is satisfied by memory from the requested node, but
it does at least TRY.  Without adding mempool_alloc_node() then I would
never be able to even TRY to satisfy a mempool-backed kmalloc_node()
request from the correct node.  I believe that would constitute an
unacceptable breakage from normal, documented behavior.  So, I *do* need
this patch.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
