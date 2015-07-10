Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id D725C6B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 03:35:38 -0400 (EDT)
Received: by ietj16 with SMTP id j16so18431719iet.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:35:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k10si862488igx.32.2015.07.10.00.35.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 00:35:38 -0700 (PDT)
Date: Fri, 10 Jul 2015 00:35:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page: refine the calculation of highest possible
 node id
Message-Id: <20150710003555.4398c8ad.akpm@linux-foundation.org>
In-Reply-To: <1436509581-9370-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1436509581-9370-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: tj@kernel.org, linux-mm@kvack.org

On Fri, 10 Jul 2015 14:26:21 +0800 Wei Yang <weiyang@linux.vnet.ibm.com> wrote:

> nr_node_ids records the highest possible node id, which is calculated by
> scanning the bitmap node_states[N_POSSIBLE]. Current implementation scan
> the bitmap from the beginning, which will scan the whole bitmap.
> 
> This patch reverse the order by scanning from the end. By doing so, this
> will save some time whose worst case is the best case of current
> implementation.

It hardly matters - setup_nr_node_ids() is called a single time, at boot.

> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -253,6 +253,12 @@ static inline int __first_node(const nodemask_t *srcp)
>  	return min_t(int, MAX_NUMNODES, find_first_bit(srcp->bits, MAX_NUMNODES));
>  }
>  
> +#define last_node(src) __last_node(&(src))
> +static inline int __last_node(const nodemask_t *srcp)
> +{
> +	return min_t(int, MAX_NUMNODES, find_last_bit(srcp->bits, MAX_NUMNODES));
> +}

hm.  Why isn't this just

	return find_last_bit(srcp->bits, MAX_NUMNODES);

?

> @@ -360,10 +366,20 @@ static inline void __nodes_fold(nodemask_t *dstp, const nodemask_t *origp,
>  	for ((node) = first_node(mask);			\
>  		(node) < MAX_NUMNODES;			\
>  		(node) = next_node((node), (mask)))
> +
> +static inline int highest_node_id(const nodemask_t possible)
> +{
> +	return last_node(possible);
> +}

`possible' isn't a good identifier.  This function doesn't *know* that
its caller passed node_possible_map.  Another caller could pass some
other nodemask.

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5453,8 +5453,7 @@ void __init setup_nr_node_ids(void)
>  	unsigned int node;
>  	unsigned int highest = 0;

The "= 0" can now be removed.

> -	for_each_node_mask(node, node_possible_map)
> -		highest = node;
> +	highest = highest_node_id(node_possible_map);

I suspect we can just open-code a find_last_bit() here and all the
infrastructure isn't needed.

>  	nr_node_ids = highest + 1;
>  }


And I suspect the "#if MAX_NUMNODES > 1" around setup_nr_node_ids() can
be removed.  Because if MAX_NUMNODES is ever <= 1 when
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y, the kernel won't compile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
