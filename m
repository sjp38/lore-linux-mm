Date: Mon, 18 Aug 2008 11:59:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] __GFP_THISNODE is not always honored
Message-ID: <20080818105918.GD32113@csn.ul.ie>
References: <1218837685.12953.11.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1218837685.12953.11.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On (15/08/08 17:01), Adam Litke didst pronounce:
> While running the libhugetlbfs test suite on a NUMA machine with 2.6.27-rc3, I
> discovered some strange behavior with __GFP_THISNODE.  The hugetlb function
> alloc_fresh_huge_page_node() calls alloc_pages_node() with __GFP_THISNODE but
> occasionally a page that is not on the requested node is returned. 

That's bad in itself and has wider reaching consequences than hugetlb
getting its counters wrong. I believe SLUB depends on __GFP_THISNODE
being obeyed for example. Can you boot the machine in question with
mminit_loglevel=4 and loglevel=8 set on the command line and send me the
dmesg please? It should output the zonelists and I might be able to
figure out what's going wrong. Thanks

> Since the
> hugetlb code assumes that the page will be on the requested node, badness follows
> when the page is added to the wrong node's free_list.
> 
> There is clearly something wrong with the buddy allocator since __GFP_THISNODE
> cannot be trusted.  Until that is fixed, the hugetlb code should not assume
> that the newly allocated page is on the node asked for.  This patch prevents
> the hugetlb pool counters from being corrupted and allows the code to cope with
> unbalanced numa allocations.
> 
> So far my debugging has led me to get_page_from_freelist() inside the
> for_each_zone_zonelist() loop.  When buffered_rmqueue() returns a page I
> compare the value of page_to_nid(page), zone->node and the node that the
> hugetlb code requested with __GFP_THISNODE.  These all match -- except when the
> problem triggers.  In that case, zone->node matches the node we asked for but
> page_to_nid() does not.
> 

Feels like the wrong zonelist is being used. The dmesg with
mminit_loglevel may tell.

> Workaround patch:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 67a7119..7a30a61 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -568,7 +568,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>  			__free_pages(page, huge_page_order(h));
>  			return NULL;
>  		}
> -		prep_new_huge_page(h, page, nid);
> +		prep_new_huge_page(h, page, page_to_nid(page));
>  	}

This will mask the bug for hugetlb but I wonder if this should be a
VM_BUG_ON(page_to_nid(page) != nid) ?

>  
>  	return page;
> 
> -- 
> Adam Litke - (agl at us.ibm.com)
> IBM Linux Technology Center
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
