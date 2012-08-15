Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 656986B006C
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 14:59:58 -0400 (EDT)
Message-ID: <502BF139.3040403@redhat.com>
Date: Wed, 15 Aug 2012 14:58:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] cma: support MIGRATE_DISCARD
References: <1344934627-8473-1-git-send-email-minchan@kernel.org> <1344934627-8473-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1344934627-8473-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2012 04:57 AM, Minchan Kim wrote:
> This patch introudes MIGRATE_DISCARD mode in migration.
> It drop clean cache pages instead of migration so that
> migration latency could be reduced. Of course, it could
> evict code pages but latency of big contiguous memory
> is more important than some background application's slow down
> in mobile embedded enviroment.

Would it be an idea to only drop clean UNMAPPED
page cache pages?

> Signed-off-by: Minchan Kim <minchan@kernel.org>

> @@ -799,12 +802,39 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>   		goto skip_unmap;
>   	}
>
> +	file = page_is_file_cache(page);
> +	ttu_flags = TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS;
> +
> +	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
> +		ttu_flags |= TTU_MIGRATION;
> +	else
> +		discard_mode = true;
> +
>   	/* Establish migration ptes or remove ptes */
> -	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	try_to_unmap(page, ttu_flags);

This bit looks wrong, because you end up ignoring
mlock and then discarding the page.

Only dropping clean page cache pages that are not
mapped would avoid that problem, without introducing
much complexity in the code.

That would turn the test above into:

	if (!page_mapped(page))
		discard_mode = true;

>   skip_unmap:
> -	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
> +	if (!page_mapped(page)) {
> +		if (!discard_mode)
> +			rc = move_to_new_page(newpage, page, remap_swapcache, mode);
> +		else {
> +			struct address_space *mapping;
> +			mapping = page_mapping(page);
> +
> +			if (page_has_private(page)) {
> +				if (!try_to_release_page(page, GFP_KERNEL)) {
> +					rc = -EAGAIN;
> +					goto uncharge;
> +				}
> +			}
> +
> +			if (remove_mapping(mapping, page))
> +				rc = 0;
> +			else
> +				rc = -EAGAIN;
> +			goto uncharge;
> +		}
> +	}

This big piece of code could probably be split out
into its own function.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
