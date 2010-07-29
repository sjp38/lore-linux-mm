Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 84A0A6B02AB
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 06:00:41 -0400 (EDT)
Message-ID: <4C515137.707@cs.helsinki.fi>
Date: Thu, 29 Jul 2010 13:00:23 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: slub numa: Fix rare allocation from unexpected node
References: <alpine.DEB.2.00.1007261040430.5438@router.home>
In-Reply-To: <alpine.DEB.2.00.1007261040430.5438@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, jamal <hadi@cyberus.ca>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Subject: slub numa: Fix rare allocation from unexpected node
> 
> The network developers have seen sporadic allocations resulting in objects
> coming from unexpected NUMA nodes despite asking for objects from a
> specific node.
> 
> This is due to get_partial() calling get_any_partial() if partial
> slabs are exhausted for a node even if a node was specified and therefore
> one would expect allocations only from the specified node.
> 
> get_any_partial() sporadically may return a slab from a foreign
> node to gradually reduce the size of partial lists on remote nodes
> and thereby reduce total memory use for a slab cache.
> 
> The behavior is controlled by the remote_defrag_ratio of each cache.
> 
> Strictly speaking this is permitted behavior since __GFP_THISNODE was
> not specified for the allocation but it is certain surprising.
> 
> This patch makes sure that the remote defrag behavior only occurs
> if no node was specified.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-07-23 09:24:11.000000000 -0500
> +++ linux-2.6/mm/slub.c	2010-07-23 09:25:15.000000000 -0500
> @@ -1390,7 +1390,7 @@ static struct page *get_partial(struct k
>  	int searchnode = (node == -1) ? numa_node_id() : node;
> 
>  	page = get_partial_node(get_node(s, searchnode));
> -	if (page || (flags & __GFP_THISNODE))
> +	if (page || node != -1)
>  		return page;
> 
>  	return get_any_partial(s, flags);

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
