Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7D3496B01EF
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 10:33:32 -0400 (EDT)
Date: Wed, 21 Apr 2010 09:30:20 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
 pages
In-Reply-To: <1271797276-31358-5-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1004210927550.4959@router.home>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Apr 2010, Mel Gorman wrote:

> @@ -520,10 +521,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
>  	else
>  		rc = fallback_migrate_page(mapping, newpage, page);
>
> -	if (!rc)
> -		remove_migration_ptes(page, newpage);
> -	else
> +	if (rc) {
>  		newpage->mapping = NULL;
> +	} else {
> +		if (remap_swapcache)
> +			remove_migration_ptes(page, newpage);
> +	}

You are going to keep the migration ptes after the page has been unlocked?
Or is remap_swapcache true if its not a swapcache page?

Maybe you meant

if (!remap_swapcache)

?

>  	unlock_page(newpage);
>

>
>  skip_unmap:
>  	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page);
> +		rc = move_to_new_page(newpage, page, remap_swapcache);
>
> -	if (rc)
> +	if (rc && remap_swapcache)
>  		remove_migration_ptes(page, page);
>  rcu_unlock:
>

Looks like you meant !remap_swapcache

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
