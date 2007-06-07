Date: Thu, 7 Jun 2007 11:11:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] gfp.h: GFP_THISNODE can go to other nodes if some are
 unpopulated
In-Reply-To: <20070607150425.GA15776@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee.Schermerhorn@hp.com, anton@samba.org, apw@shadowen.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007, Nishanth Aravamudan wrote:

> While testing my sysfs per-node hugepage allocator
> (http://marc.info/?l=linux-mm&m=117935849517122&w=2), I found that an
> alloc_pages_node(nid, GFP_THISNODE) request would sometimes return a
> struct page such that page_to_nid(page) != nid. This was because, on
> that particular machine, nodes 0 and 1 are populated and nodes 2 and 3
> are not. When a page is requested get_page_from_freelist() relies on
> zonelist->zones[0]->zone_pgdat indicating when THISNODE stops. But,
> because, say, node 2 has no memory, the first zone_pgdat in the fallback
> list points to a different node. Add a comment indicating that THISNODE
> may not return pages on THISNODE if the node is unpopulated.

Hmmm.... Bad semantics are developing as a result of allowing empty nodes 
with no zones. This is not correct and can have bad consequences. 

As I expected: We may need more hacks to deal with it. Sigh.

> Am working on testing Lee/Anton's patch to add a node_populated_mask and
> use that in the hugepage allocator path. But I think this may be a
> problem anywhere THISNODE is used and memory is expected to come from
> the requested node and nowhere else.

What GFP_THISNODE effectively does now is to require the allocation on the 
nearest available zone to the indicated node because it does not allow 
access outside of the first encountered pgdat. But the first pgdat is not 
the node we selected if the node has no memory.

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 0d2ef0b..ed826e9 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -67,6 +67,10 @@ struct vm_area_struct;
>  			 __GFP_HIGHMEM)
>  
>  #ifdef CONFIG_NUMA
> +/*
> + * NOTE: if the requested node is unpopulated (no memory), a THISNODE
> + * request can go to other nodes due to the fallback list

Change to

Note: GFP_THISNODE allocates from the first available pgdat (== node 
structure) from the zonelist of a given node. The first pgdat may be the 
pgdat of another node if the node has no memory on its own.

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
