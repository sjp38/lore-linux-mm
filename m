Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF3906B003A
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 23:42:04 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so397002pbc.24
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 20:42:04 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id s8si262690pas.180.2014.04.07.19.03.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 19:03:46 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6D00C3EE189
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:03:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6094845DF10
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:03:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.nic.fujitsu.com [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4566945DF56
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:03:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32CF41DB8052
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:03:45 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA5AA1DB804A
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 11:03:44 +0900 (JST)
Message-ID: <53435892.8070607@jp.fujitsu.com>
Date: Tue, 8 Apr 2014 11:01:54 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] hugetlb: move helpers up in the file
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com> <1396462128-32626-4-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1396462128-32626-4-git-send-email-lcapitulino@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, yinghai@kernel.org, riel@redhat.com

(2014/04/03 3:08), Luiz Capitulino wrote:
> Next commit will add new code which will want to call the
> for_each_node_mask_to_alloc() macro. Move it, its buddy
> for_each_node_mask_to_free() and their dependencies up in the file so
> the new code can use them. This is just code movement, no logic change.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   mm/hugetlb.c | 146 +++++++++++++++++++++++++++++------------------------------
>   1 file changed, 73 insertions(+), 73 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7e07e47..2c7a44a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -570,6 +570,79 @@ err:
>   	return NULL;
>   }
>   
> +/*
> + * common helper functions for hstate_next_node_to_{alloc|free}.
> + * We may have allocated or freed a huge page based on a different
> + * nodes_allowed previously, so h->next_node_to_{alloc|free} might
> + * be outside of *nodes_allowed.  Ensure that we use an allowed
> + * node for alloc or free.
> + */
> +static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
> +{
> +	nid = next_node(nid, *nodes_allowed);
> +	if (nid == MAX_NUMNODES)
> +		nid = first_node(*nodes_allowed);
> +	VM_BUG_ON(nid >= MAX_NUMNODES);
> +
> +	return nid;
> +}
> +
> +static int get_valid_node_allowed(int nid, nodemask_t *nodes_allowed)
> +{
> +	if (!node_isset(nid, *nodes_allowed))
> +		nid = next_node_allowed(nid, nodes_allowed);
> +	return nid;
> +}
> +
> +/*
> + * returns the previously saved node ["this node"] from which to
> + * allocate a persistent huge page for the pool and advance the
> + * next node from which to allocate, handling wrap at end of node
> + * mask.
> + */
> +static int hstate_next_node_to_alloc(struct hstate *h,
> +					nodemask_t *nodes_allowed)
> +{
> +	int nid;
> +
> +	VM_BUG_ON(!nodes_allowed);
> +
> +	nid = get_valid_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> +	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
> +
> +	return nid;
> +}
> +
> +/*
> + * helper for free_pool_huge_page() - return the previously saved
> + * node ["this node"] from which to free a huge page.  Advance the
> + * next node id whether or not we find a free huge page to free so
> + * that the next attempt to free addresses the next node.
> + */
> +static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
> +{
> +	int nid;
> +
> +	VM_BUG_ON(!nodes_allowed);
> +
> +	nid = get_valid_node_allowed(h->next_nid_to_free, nodes_allowed);
> +	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
> +
> +	return nid;
> +}
> +
> +#define for_each_node_mask_to_alloc(hs, nr_nodes, node, mask)		\
> +	for (nr_nodes = nodes_weight(*mask);				\
> +		nr_nodes > 0 &&						\
> +		((node = hstate_next_node_to_alloc(hs, mask)) || 1);	\
> +		nr_nodes--)
> +
> +#define for_each_node_mask_to_free(hs, nr_nodes, node, mask)		\
> +	for (nr_nodes = nodes_weight(*mask);				\
> +		nr_nodes > 0 &&						\
> +		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
> +		nr_nodes--)
> +
>   static void update_and_free_page(struct hstate *h, struct page *page)
>   {
>   	int i;
> @@ -750,79 +823,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
>   	return page;
>   }
>   
> -/*
> - * common helper functions for hstate_next_node_to_{alloc|free}.
> - * We may have allocated or freed a huge page based on a different
> - * nodes_allowed previously, so h->next_node_to_{alloc|free} might
> - * be outside of *nodes_allowed.  Ensure that we use an allowed
> - * node for alloc or free.
> - */
> -static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
> -{
> -	nid = next_node(nid, *nodes_allowed);
> -	if (nid == MAX_NUMNODES)
> -		nid = first_node(*nodes_allowed);
> -	VM_BUG_ON(nid >= MAX_NUMNODES);
> -
> -	return nid;
> -}
> -
> -static int get_valid_node_allowed(int nid, nodemask_t *nodes_allowed)
> -{
> -	if (!node_isset(nid, *nodes_allowed))
> -		nid = next_node_allowed(nid, nodes_allowed);
> -	return nid;
> -}
> -
> -/*
> - * returns the previously saved node ["this node"] from which to
> - * allocate a persistent huge page for the pool and advance the
> - * next node from which to allocate, handling wrap at end of node
> - * mask.
> - */
> -static int hstate_next_node_to_alloc(struct hstate *h,
> -					nodemask_t *nodes_allowed)
> -{
> -	int nid;
> -
> -	VM_BUG_ON(!nodes_allowed);
> -
> -	nid = get_valid_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> -	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
> -
> -	return nid;
> -}
> -
> -/*
> - * helper for free_pool_huge_page() - return the previously saved
> - * node ["this node"] from which to free a huge page.  Advance the
> - * next node id whether or not we find a free huge page to free so
> - * that the next attempt to free addresses the next node.
> - */
> -static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
> -{
> -	int nid;
> -
> -	VM_BUG_ON(!nodes_allowed);
> -
> -	nid = get_valid_node_allowed(h->next_nid_to_free, nodes_allowed);
> -	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
> -
> -	return nid;
> -}
> -
> -#define for_each_node_mask_to_alloc(hs, nr_nodes, node, mask)		\
> -	for (nr_nodes = nodes_weight(*mask);				\
> -		nr_nodes > 0 &&						\
> -		((node = hstate_next_node_to_alloc(hs, mask)) || 1);	\
> -		nr_nodes--)
> -
> -#define for_each_node_mask_to_free(hs, nr_nodes, node, mask)		\
> -	for (nr_nodes = nodes_weight(*mask);				\
> -		nr_nodes > 0 &&						\
> -		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
> -		nr_nodes--)
> -
>   static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
>   {
>   	struct page *page;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
