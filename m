Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 88AE06B0078
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 06:17:12 -0400 (EDT)
Date: Wed, 29 Sep 2010 12:17:04 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
Message-ID: <20100929101704.GB2618@cmpxchg.org>
References: <1285729060.27440.14.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1285729060.27440.14.camel@sli10-conroe.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, riel@redhat.com, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 29, 2010 at 10:57:40AM +0800, Shaohua Li wrote:
> With commit 645747462435, pte referenced file page isn't activated in inactive
> list scan. For VM_EXEC page, if it can't get a chance to active list, the
> executable page protect loses its effect. We protect such page in inactive scan
> here, now such page will be guaranteed cached in a full scan of active and
> inactive list, which restores previous behavior.

This change was in the back of my head since the used-once detection
was merged but there were never any regressions reported that would
indicate a requirement for it.

Does this patch fix a problem you observed?

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
>  		 * quickly recovered.
>  		 */
>  		SetPageReferenced(page);
> -
> -		if (referenced_page)
> +		/*
> +		 * Identify pte referenced and file-backed pages and give them
> +		 * one trip around the active list. So that executable code get
> +		 * better chances to stay in memory under moderate memory
> +		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
> +		 * ignore them here.

PTE-referenced PageAnon() pages are activated unconditionally a few
lines further up, so the page_is_file_cache() check filters only shmem
pages.  I doubt this was your intention...?

> +		 */
> +		if (referenced_page || ((vm_flags & VM_EXEC) &&
> +		    page_is_file_cache(page)))
>  			return PAGEREF_ACTIVATE;
>  
>  		return PAGEREF_KEEP;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
