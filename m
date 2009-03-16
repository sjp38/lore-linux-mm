Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B0B896B004D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:43:42 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 586CD3047FB
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:50:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id osmNtKKpye1H for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:50:20 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 48DF882D3A7
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:42:09 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:33:44 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 31/35] Optimistically check the first page on the PCP
 free list is suitable
In-Reply-To: <1237196790-7268-32-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161232130.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-32-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bb5bd5e..8568284 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1212,6 +1212,12 @@ again:
>  				if (pcp_page_suit(page, order))
>  					break;
>  		} else {
> +			/* Optimistic before we start a list search */
> +			page = list_entry(list->next, struct page, lru);
> +			if (pcp_page_suit(page, order))
> +				goto found;
> +
> +			/* Do the search */
>  			list_for_each_entry(page, list, lru)
>  				if (pcp_page_suit(page, order))
>  					break;

I am not convinced that this is beneficial. If it would then the compiler
would unroll the loop.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
