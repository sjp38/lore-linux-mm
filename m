Message-ID: <424A3FA0.9030403@colorfullife.com>
Date: Wed, 30 Mar 2005 07:56:48 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: API changes to the slab allocator for NUMA memory allocation
References: <20050315204110.6664771d.akpm@osdl.org> <42387C2E.4040106@colorfullife.com> <273220000.1110999247@[10.10.2.4]> <4238845E.5060304@colorfullife.com> <Pine.LNX.4.58.0503292126050.32140@server.graphe.net>
In-Reply-To: <Pine.LNX.4.58.0503292126050.32140@server.graphe.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>The patch makes the following function calls available to allocate memory on
>a specific node without changing the basic operation of the slab
>allocator:
>
> kmem_cache_alloc_node(kmem_cache_t *cachep, unsigned int flags, int node);
> kmalloc_node(size_t size, unsigned int flags, int node);
>
>  
>
I intentionally didn't add a kmalloc_node() function:
kmalloc is just a wrapper around 
kmem_find_general_cachep+kmem_cache_alloc. It exists only for 
efficiency. The _node functions are slow, thus a wrapper is IMHO not 
required. kmalloc_node(size,flags,node) is identical to 
kmem_cache_alloc(kmem_find_general_cachep(size,flags),flags,node). What 
about making kmem_find_general_cachep() public again and removing 
kmalloc_node()?

And I don't know if it's a good idea to make kmalloc() a special case of 
kmalloc_node(): It adds one parameter to every kmalloc call and 
kmem_cache_alloc call, virtually everyone passes -1. Does it increase 
the .text size?

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
