Message-ID: <46EEB7C1.70806@kolumbus.fi>
Date: Mon, 17 Sep 2007 20:22:09 +0300
From: =?UTF-8?B?TWlrYSBQZW50dGlsw6Q=?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] hugetlb: Try to grow hugetlb pool for MAP_SHARED
 mappings
References: <20070917163935.32557.50840.stgit@kernel> <20070917164009.32557.4348.stgit@kernel>
In-Reply-To: <20070917164009.32557.4348.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

> +void return_unused_surplus_pages(void)
> +{
> +	static int nid = -1;
> +	int delta;
> +	struct page *page;
> +
> +	delta = unused_surplus_pages - resv_huge_pages;
> +
> +	while (delta) {
>   
Shouldn't this be while (delta >= 0) ?
> +		nid = next_node(nid, node_online_map);
> +		if (nid == MAX_NUMNODES)
> +			nid = first_node(node_online_map);
> +
> +		if (!surplus_huge_pages_node[nid])
> +			continue;
> +
> +		if (!list_empty(&hugepage_freelists[nid])) {
> +			page = list_entry(hugepage_freelists[nid].next,
> +					  struct page, lru);
> +			list_del(&page->lru);
> +			update_and_free_page(page);
> +			free_huge_pages--;
> +			free_huge_pages_node[nid]--;
> +			surplus_huge_pages_node[nid]--;
> +			unused_surplus_pages--;
> +			delta--;
> +		}
> +	}
> +}
> +

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
