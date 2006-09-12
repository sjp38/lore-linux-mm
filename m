Message-ID: <45061F16.202@yahoo.com.au>
Date: Tue, 12 Sep 2006 12:44:38 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: A solution for more GFP_xx flags?
References: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609111920590.7815@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>I wonder if we could pass a pointer to an allocation structure
>to the allocators instead of an unsigned long?
>
>Right now the problem is that we need _node allocators to specify nodes 
>and the memory policies and cpusets are determined by the allocation 
>context of a process. This makes the allocators difficult to handle.
>
>We could define a structure
>
>struct allocation_control {
>	unsigned long flags;	/* Traditional flags */
>	int node;
>	struct cpuset_context *cpuset;
>	struct mempol *mpol;
>};
>
>We could define struct constants called GFP_KERNEL and GFP_ATOMIC.
>const struct allocation_control gfp_kernel {
>	GFP_KERNEL, -1, NULL, NULL
>}
>
>And then do
>
>alloc_pages(n, gfp_kernel)
>
>?
>
>This would also solve the problem of allocations that do not occur in a 
>proper process context. F.e. slab allocations are on behalf of the slab 
>allocator and not on behalf of a process. Thus the cpuset and the memory 
>policies should not influence that allocation. In that case we could have 
>a special allocation_control structure for that context.
>
>It would also get rid off all the xxx_node allocator variations.
>

This seems like a decent approach to make a nice general interface. I guess
existing APIs can be easily implemented by filling in the structure. If you
took this approach I don't think there should be any objections.

A minor point: would we prefer a struct argument to the allocator, or more
function arguments? It is an API that we need to get right...

---

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
