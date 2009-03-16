Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E1AC6B004F
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:50:08 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 64E81304892
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:56:47 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bxThe4nozD3B for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:56:47 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C86C230488D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:38:34 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:30:02 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 29/35] Do not store the PCP high and batch watermarks in
 the per-cpu structure
In-Reply-To: <1237196790-7268-30-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161228120.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-30-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -166,8 +166,6 @@ static inline int is_unevictable_lru(enum lru_list l)
>
>  struct per_cpu_pages {
>  	int count;		/* number of pages in the list */
> -	int high;		/* high watermark, emptying needed */
> -	int batch;		/* chunk size for buddy add/remove */


There is a hole here on 64 bit systems.

>
>  	/* Lists of pages, one per migrate type stored on the pcp-lists */
>  	struct list_head lists[MIGRATE_PCPTYPES];
> @@ -285,6 +283,12 @@ struct zone {
>  		unsigned long pages_mark[3];
>  	};
>
> +	/* high watermark for per-cpu lists, emptying needed */
> +	u16 pcp_high;
> +
> +	/* chunk size for buddy add/remove to per-cpu lists*/
> +	u16 pcp_batch;
> +

Move this up to fill the hole?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
