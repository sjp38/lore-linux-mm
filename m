Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 247EA6B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 11:04:23 -0400 (EDT)
Message-ID: <503797F0.1050805@redhat.com>
Date: Fri, 24 Aug 2012 11:04:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: support MIGRATE_DISCARD
References: <1345782330-23234-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1345782330-23234-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>

On 08/24/2012 12:25 AM, Minchan Kim wrote:
> This patch introudes MIGRATE_DISCARD mode in migration.
> It drops *unmapped clean cache pages* instead of migration so that

Am I confused, or does the code not match the changelog?

It looks like it is still trying to discard mapped page cache pages:

> +	file = page_is_file_cache(page);
> +	ttu_flags = TTU_IGNORE_ACCESS;
> +retry:
> +	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
> +		ttu_flags |= (TTU_MIGRATION | TTU_IGNORE_MLOCK);
> +	else
> +		discard_mode = true;
> +
>   	/* Establish migration ptes or remove ptes */
> -	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	rc = try_to_unmap(page, ttu_flags);
>
>   skip_unmap:
> -	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
> +	if (rc == SWAP_SUCCESS) {
> +		if (!discard_mode)
> +			rc = move_to_new_page(newpage, page,
> +					remap_swapcache, mode);
> +		else {
> +
> +			rc = discard_page(page);
> +			goto uncharge;
> +		}



-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
