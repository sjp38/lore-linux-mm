Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D01E36B0034
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 10:27:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 19:51:07 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 7D715E0055
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 19:57:31 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6FERZcr33816808
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 19:57:36 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6FERbe0012665
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 00:27:38 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/9] mm, hugetlb: fix and clean-up node iteration code to alloc or free
In-Reply-To: <1373881967-16153-5-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com> <1373881967-16153-5-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 15 Jul 2013 19:57:37 +0530
Message-ID: <87y597j3ty.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Current node iteration code have a minor problem which do one more
> node rotation if we can't succeed to allocate. For example,
> if we start to allocate at node 0, we stop to iterate at node 0.
> Then we start to allocate at node 1 for next allocation.

Can you explain the problem in a bit more detail

>
> I introduce new macros "for_each_node_mask_to_[alloc|free]" and
> fix and clean-up node iteration code to alloc or free.
> This makes code more understandable.
>

I found the existing code more readable. Obviously I haven't yet figured
out the problem you have observed with the code. 

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 0067cf4..a838e6b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -752,33 +752,6 @@ static int hstate_next_node_to_alloc(struct hstate *h,
>  	return nid;
>  }
>
> -static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
> -{
> -	struct page *page;
> -	int start_nid;
> -	int next_nid;
> -	int ret = 0;
> -
> -	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> -	next_nid = start_nid;
> -
> -	do {
> -		page = alloc_fresh_huge_page_node(h, next_nid);
> -		if (page) {
> -			ret = 1;
> -			break;
> -		}
> -		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> -	} while (next_nid != start_nid);
> -
> -	if (ret)
> -		count_vm_event(HTLB_BUDDY_PGALLOC);
> -	else
> -		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
> -
> -	return ret;
> -}
> -
>  /*
>   * helper for free_pool_huge_page() - return the previously saved
>   * node ["this node"] from which to free a huge page.  Advance the
> @@ -797,6 +770,42 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  	return nid;
>  }
>
> +#define for_each_node_mask_to_alloc(hs, nr_nodes, node, mask)		\
> +	for (nr_nodes = nodes_weight(*mask),				\
> +		node = hstate_next_node_to_alloc(hs, mask);		\
> +		nr_nodes > 0 &&						\
> +		((node = hstate_next_node_to_alloc(hs, mask)) || 1);	\
> +		nr_nodes--)
> +
> +#define for_each_node_mask_to_free(hs, nr_nodes, node, mask)		\
> +	for (nr_nodes = nodes_weight(*mask),				\
> +		node = hstate_next_node_to_free(hs, mask);		\
> +		nr_nodes > 0 &&						\
> +		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
> +		nr_nodes--)
> +
> +static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
> +{
> +	struct page *page;
> +	int nr_nodes, node;
> +	int ret = 0;
> +
> +	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {


This check for nodes_weight and fail right ? (nr_nodes == 0).  That is
not the case with the existing code. It will allocate from 
h->next_nid_to_alloc. Is that ok ?


> +		page = alloc_fresh_huge_page_node(h, node);
> +		if (page) {
> +			ret = 1;
> +			break;
> +		}
> +	}
> +
> +	if (ret)
> +		count_vm_event(HTLB_BUDDY_PGALLOC);
> +	else
> +		count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
> +
> +	return ret;
> +}
> +

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
