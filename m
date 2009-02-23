Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id ECD286B00B7
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:10:25 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0312182C17C
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:14:57 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uGMAaC1AZIgn for <linux-mm@kvack.org>;
	Mon, 23 Feb 2009 10:14:52 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0898482C26C
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:14:27 -0500 (EST)
Date: Mon, 23 Feb 2009 10:01:35 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 03/20] Do not check NUMA node ID when the caller knows
 the node is valid
In-Reply-To: <1235344649-18265-4-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902230958440.7298@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Feb 2009, Mel Gorman wrote:

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 75f49d3..6566c9e 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1318,11 +1318,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	for (i = 0; i < area->nr_pages; i++) {
>  		struct page *page;
>
> -		if (node < 0)
> -			page = alloc_page(gfp_mask);
> -		else
> -			page = alloc_pages_node(node, gfp_mask, 0);
> -
> +		page = alloc_pages_node(node, gfp_mask, 0);
>  		if (unlikely(!page)) {
>  			/* Successfully allocated i pages, free them in __vunmap() */
>  			area->nr_pages = i;
>

That wont work. alloc_pages() obeys memory policies. alloc_pages_node()
does not.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
