Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C52v19015338
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 22:02:57 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k8C2SE8s39342506
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 19:28:14 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k8C2SEnB56256190
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 19:28:14 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GMy0T-000229-00
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 19:28:13 -0700
Date: Mon, 11 Sep 2006 19:28:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: A solution for more GFP_xx flags?
Message-ID: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I wonder if we could pass a pointer to an allocation structure
to the allocators instead of an unsigned long?

Right now the problem is that we need _node allocators to specify nodes 
and the memory policies and cpusets are determined by the allocation 
context of a process. This makes the allocators difficult to handle.

We could define a structure

struct allocation_control {
	unsigned long flags;	/* Traditional flags */
	int node;
	struct cpuset_context *cpuset;
	struct mempol *mpol;
};

We could define struct constants called GFP_KERNEL and GFP_ATOMIC.
const struct allocation_control gfp_kernel {
	GFP_KERNEL, -1, NULL, NULL
}

And then do

alloc_pages(n, gfp_kernel)

?

This would also solve the problem of allocations that do not occur in a 
proper process context. F.e. slab allocations are on behalf of the slab 
allocator and not on behalf of a process. Thus the cpuset and the memory 
policies should not influence that allocation. In that case we could have 
a special allocation_control structure for that context.

It would also get rid off all the xxx_node allocator variations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
