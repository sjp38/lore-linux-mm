Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E78166B0038
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 20:11:27 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so7251938pab.41
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 17:11:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id td1si25321190pbc.140.2014.09.09.17.11.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 17:11:27 -0700 (PDT)
Date: Tue, 9 Sep 2014 17:11:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] slub: fallback to node_to_mem_node() node if
 allocating on memoryless node
Message-Id: <20140909171125.de9844579d55599c59260afb@linux-foundation.org>
In-Reply-To: <20140909190514.GE22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
	<20140909190326.GD22906@linux.vnet.ibm.com>
	<20140909190514.GE22906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Tue, 9 Sep 2014 12:05:14 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Update the SLUB code to search for partial slabs on the nearest node
> with memory in the presence of memoryless nodes. Additionally, do not
> consider it to be an ALLOC_NODE_MISMATCH (and deactivate the slab) when
> a memoryless-node specified allocation goes off-node.
> 
> ...
>
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1699,7 +1699,12 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
>  		struct kmem_cache_cpu *c)
>  {
>  	void *object;
> -	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> +	int searchnode = node;
> +
> +	if (node == NUMA_NO_NODE)
> +		searchnode = numa_mem_id();
> +	else if (!node_present_pages(node))
> +		searchnode = node_to_mem_node(node);

I expect a call to node_to_mem_node() will always be preceded by a test
of node_present_pages().  Perhaps node_to_mem_node() should just do the
node_present_pages() call itself?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
