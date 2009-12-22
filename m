Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2D784620003
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 10:47:50 -0500 (EST)
Date: Tue, 22 Dec 2009 09:47:39 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
In-Reply-To: <4B30BDA8.1070904@linux.intel.com>
Message-ID: <alpine.DEB.2.00.0912220945250.12048@router.home>
References: <4B30BDA8.1070904@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Dec 2009, Haicheng Li wrote:

>  	struct array_cache **ac_ptr;
> -	int memsize = sizeof(void *) * nr_node_ids;
> +	int memsize = sizeof(void *) * MAX_NUMNODES;
>  	int i;

Why does the alien cache pointer array size have to be increased? node ids
beyond nr_node_ids cannot be used.


>
>  	if (limit > 1)
>  		limit = 12;
>  	ac_ptr = kmalloc_node(memsize, gfp, node);

Use kzalloc to ensure zeroed memory.

>  	if (ac_ptr) {
> +		memset(ac_ptr, 0, memsize);
>  		for_each_node(i) {
> -			if (i == node || !node_online(i)) {
> -				ac_ptr[i] = NULL;
> +			if (i == node || !node_online(i))
>  				continue;
> -			}
>  			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d,
> gfp);
>  			if (!ac_ptr[i]) {
>  				for (i--; i >= 0; i--)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
