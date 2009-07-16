Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0D3EF6B005D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:26:26 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 769BD82C3F8
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:45:47 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zunJ+AVa+GEl for <linux-mm@kvack.org>;
	Thu, 16 Jul 2009 10:45:47 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 531F882C400
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:45:39 -0400 (EDT)
Date: Thu, 16 Jul 2009 10:26:25 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <20090716095344.9D10.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907161024120.32382@gentwo.org>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com> <20090716095344.9D10.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009, KOSAKI Motohiro wrote:

> Index: b/mm/migrate.c
> ===================================================================
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -67,6 +67,8 @@ int putback_lru_pages(struct list_head *
>
>  	list_for_each_entry_safe(page, page2, l, lru) {
>  		list_del(&page->lru);
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				    !!page_is_file_cache(page));
>  		putback_lru_page(page);
>  		count++;
>  	}

ok.

> @@ -696,6 +698,8 @@ unlock:
>   		 * restored.
>   		 */
>   		list_del(&page->lru);
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				    !!page_is_file_cache(page));
>  		putback_lru_page(page);
>  	}
>

ok.

> @@ -740,6 +744,13 @@ int migrate_pages(struct list_head *from
>  	struct page *page2;
>  	int swapwrite = current->flags & PF_SWAPWRITE;
>  	int rc;
> +	int flags;
> +
> +	local_irq_save(flags);
> +	list_for_each_entry(page, from, lru)
> +		__inc_zone_page_state(page, NR_ISOLATED_ANON +
> +				      !!page_is_file_cache(page));
> +	local_irq_restore(flags);
>

Why do a separate pass over all the migrates pages? Can you add the
_inc_xx  somewhere after the page was isolated from the lru by calling
try_to_unmap()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
