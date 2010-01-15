Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 167056B0047
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 15:35:44 -0500 (EST)
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.1001151358110.6590@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com>
	 <alpine.DEB.2.00.1001151358110.6590@router.home>
Content-Type: text/plain
Date: Fri, 15 Jan 2010 15:35:21 -0500
Message-Id: <1263587721.20615.255.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Alex Chiang <achiang@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-15 at 14:07 -0600, Christoph Lameter wrote:
> Another stab at the problem:
> 
> We have the following code in init_kmem_cache_nodes()
> 
>   if (slab_state >= UP)
>                 local_node = page_to_nid(virt_to_page(s));
>         else
>                 local_node = 0;
> 
> 
> If the slab bootstrap is complete (UP) (which is the case here) then
> the structure pointing to by s was allocated using kmalloc itself. So
> virt_to_page() works for the typical.
> 
> The changeset results in the use of a statically allocated structure
> after boot is complete. Now page_to_nid(virt_to_page(s)) runs on a
> global data address.
> 
> Could this be problematic for some reasons on IA64?

Dunno.  Alex or I will check and get back to you.

> 
> The following patch makes init_kmem_cache_nodes assume 0
> for statically allocated kmem_cache structures even after
> boot is complete.

I believe that on Alex's platform, the kernel will get loaded into "node
2", the hardware interleaved pseudo-node, because it's located at phys
0..., and has sufficient space.  So, this might not work here.

> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-01-15 14:02:54.000000000 -0600
> +++ linux-2.6/mm/slub.c	2010-01-15 14:04:47.000000000 -0600
> @@ -2176,7 +2176,8 @@ static int init_kmem_cache_nodes(struct
>  	int node;
>  	int local_node;
> 
> -	if (slab_state >= UP)
> +	if (slab_state >= UP &&


>  s < kmalloc_caches &&
> +			s > kmalloc_caches + KMALLOC_CACHES)

??? can this ever be so?  for positive KMALLOC_CACHES, I mean...


>  		local_node = page_to_nid(virt_to_page(s));
>  	else
>  		local_node = 0;
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
