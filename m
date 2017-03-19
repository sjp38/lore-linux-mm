Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C01B6B0395
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:09:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y51so23354191wry.6
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:09:19 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id c18si20040545wrb.156.2017.03.19.13.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 13:09:18 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id C5FE61C3186
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:09:17 +0000 (GMT)
Date: Sun, 19 Mar 2017 20:09:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 06/16] mm/migrate: add new boolean copy flag to
 migratepage() callback
Message-ID: <20170319200912.GF2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-7-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489680335-6594-7-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On Thu, Mar 16, 2017 at 12:05:25PM -0400, J?r?me Glisse wrote:
> Allow migration without copy in case destination page already have
> source page content. This is usefull for new dma capable migration
> where use device dma engine to copy pages.
> 
> This feature need carefull audit of filesystem code to make sure
> that no one can write to the source page while it is unmapped and
> locked. It should be safe for most filesystem but as precaution
> return error until support for device migration is added to them.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>

I really dislike the amount of boilerplace code this creates and the fact
that additional headers are needed for that boilerplate. As it's only of
relevance to DMA capable migration, why not simply infer from that if it's
an option instead of updating all supporters of migration?

If that is unsuitable, create a new migreate_mode for a no-copy
migration. You'll need to alter some sites that check the migrate_mode
and it *may* be easier to convert migrate_mode to a bitmask but overall
it would be less boilerplate and confined to just the migration code.

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 9a0897a..cb911ce 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -596,18 +596,10 @@ static void copy_huge_page(struct page *dst, struct page *src)
>  	}
>  }
>  
> -/*
> - * Copy the page to its new location
> - */
> -void migrate_page_copy(struct page *newpage, struct page *page)
> +static void migrate_page_states(struct page *newpage, struct page *page)
>  {
>  	int cpupid;
>  
> -	if (PageHuge(page) || PageTransHuge(page))
> -		copy_huge_page(newpage, page);
> -	else
> -		copy_highpage(newpage, page);
> -
>  	if (PageError(page))
>  		SetPageError(newpage);
>  	if (PageReferenced(page))

> @@ -661,6 +653,19 @@ void migrate_page_copy(struct page *newpage, struct page *page)
>  
>  	mem_cgroup_migrate(page, newpage);
>  }
> +
> +/*
> + * Copy the page to its new location
> + */
> +void migrate_page_copy(struct page *newpage, struct page *page)
> +{
> +	if (PageHuge(page) || PageTransHuge(page))
> +		copy_huge_page(newpage, page);
> +	else
> +		copy_highpage(newpage, page);
> +
> +	migrate_page_states(newpage, page);
> +}
>  EXPORT_SYMBOL(migrate_page_copy);
>  
>  /************************************************************
> @@ -674,8 +679,8 @@ EXPORT_SYMBOL(migrate_page_copy);
>   * Pages are locked upon entry and exit.
>   */
>  int migrate_page(struct address_space *mapping,
> -		struct page *newpage, struct page *page,
> -		enum migrate_mode mode)
> +		 struct page *newpage, struct page *page,
> +		 enum migrate_mode mode, bool copy)
>  {
>  	int rc;
>  
> @@ -686,7 +691,11 @@ int migrate_page(struct address_space *mapping,
>  	if (rc != MIGRATEPAGE_SUCCESS)
>  		return rc;
>  
> -	migrate_page_copy(newpage, page);
> +	if (copy)
> +		migrate_page_copy(newpage, page);
> +	else
> +		migrate_page_states(newpage, page);
> +
>  	return MIGRATEPAGE_SUCCESS;
>  }
>  EXPORT_SYMBOL(migrate_page);

Other than some reshuffling, this is the place where the new copy
parameters it used and it has the mode parameter. At worst you end up
creating a helper to check two potential migrate modes to have either
ASYNC, SYNC or SYNC_LIGHT semantics. I expect you want SYNC symantics.

This patch is huge relative to the small thing it acatually requires.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
