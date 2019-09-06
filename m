Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59F93C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:59:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDDE2082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:59:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="pY7zk/w8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDDE2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFE456B0003; Fri,  6 Sep 2019 08:59:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB0806B0006; Fri,  6 Sep 2019 08:59:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 976556B0007; Fri,  6 Sep 2019 08:59:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 7125C6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:59:31 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1C443D19
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:59:31 +0000 (UTC)
X-FDA: 75904502142.23.kick79_702031ad71215
X-HE-Tag: kick79_702031ad71215
X-Filterd-Recvd-Size: 9650
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:59:30 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id o9so6269205edq.0
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 05:59:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ziEdRLsXO40ln6MLqiGodbd9Jh5bSPIFcy/rNK9Q7Ww=;
        b=pY7zk/w8TKLJb6+4uHUls3O2RTMWA4y90jjFogFYSGbnC8kHwBqF4z6DO/QXdoW6E0
         YsRh0jq+m4bgl1o3zsg9/NasXl8gLvgOcLQDim2rH5D7UiSG7YnE6X9GM8TB25X//kwD
         +SSF2b4wnQxvm3Utnh9Z7HT3dwS2wSeo1b46bYUyk/y1+NUl0yV0Y+uds6NernVoc6Yn
         8+BoWumqAbJSd3ZtzZ7D5zNvaB34HIoxAghzP85f84Xf5Wm3iTktI74MIr9DvzGcDMSH
         TBQRLtPRGk7kBF+tPeda6CcovF0XfzVGVeuJ1LBxN6w5jHJkQVV1rTsujOlSa75rktb/
         k+dQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=ziEdRLsXO40ln6MLqiGodbd9Jh5bSPIFcy/rNK9Q7Ww=;
        b=QGZyT5wWht6LUsXn/E2P9QCGNLrDfhuGP0iL017t9hjwcjRRHLjEfpUgLlIEEsC3Wd
         h1ooosTz3C0EYgrfebBrNCJ4aPIADy6+swVUdY0X/XsPC38eCQCbaAmiUjzH5n/3g9RV
         NZE0n1ucKBtJkgbpTE1zmumLRNnOo0px4whR+VBWxoV1sip0g6Z2ZwfIqdMUD3FFueHo
         bA2m++5Vxl+vHXDJ369l17OYtpU+wx0BOMxaSczhOgzJGwCtPX48d+rVkiUUCnSGyYws
         U31qCa9CGY/3AWcFOBLNfYMKpZUKfF9OH+qJctA4zqqF0N7FKrnyEZ9K9oY2z0OESsoK
         yvmw==
X-Gm-Message-State: APjAAAXjkeypatI37R0E0UNZqzZ85mL99ba0ESFEVPDE8qo7yZSZl9eI
	LWy/dYTT/1Bp1KdwUlc2zhs6Wg==
X-Google-Smtp-Source: APXvYqyM60s24Ukh0h3LJMSfouaIHNvU1YMuRs0W9Y4zW6Ppmqnt6NhfeH5WdCs329ssEK+X7vonxA==
X-Received: by 2002:a50:981b:: with SMTP id g27mr9406727edb.105.1567774769088;
        Fri, 06 Sep 2019 05:59:29 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id p4sm815871edc.38.2019.09.06.05.59.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 05:59:28 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 7E46B1049F1; Fri,  6 Sep 2019 15:59:28 +0300 (+03)
Date: Fri, 6 Sep 2019 15:59:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 3/3] mm: Allow find_get_page to be used for large pages
Message-ID: <20190906125928.urwopgpd66qibbil@box>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-4-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905182348.5319-4-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 11:23:48AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> Add FGP_PMD to indicate that we're trying to find-or-create a page that
> is at least PMD_ORDER in size.  The internal 'conflict' entry usage
> is modelled after that in DAX, but the implementations are different
> due to DAX using multi-order entries and the page cache using multiple
> order-0 entries.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  include/linux/pagemap.h |  9 +++++
>  mm/filemap.c            | 82 +++++++++++++++++++++++++++++++++++++----
>  2 files changed, 84 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index d2147215d415..72101811524c 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -248,6 +248,15 @@ pgoff_t page_cache_prev_miss(struct address_space *mapping,
>  #define FGP_NOFS		0x00000010
>  #define FGP_NOWAIT		0x00000020
>  #define FGP_FOR_MMAP		0x00000040
> +/*
> + * If you add more flags, increment FGP_ORDER_SHIFT (no further than 25).

Maybe some BUILD_BUG_ON()s to ensure FGP_ORDER_SHIFT is sane?

> + * Do not insert flags above the FGP order bits.
> + */
> +#define FGP_ORDER_SHIFT		7
> +#define FGP_PMD			((PMD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
> +#define FGP_PUD			((PUD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
> +
> +#define fgp_order(fgp)		((fgp) >> FGP_ORDER_SHIFT)
>  
>  struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>  		int fgp_flags, gfp_t cache_gfp_mask);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ae3c0a70a8e9..904dfabbea52 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1572,7 +1572,71 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
>  
>  	return page;
>  }
> -EXPORT_SYMBOL(find_get_entry);
> +
> +static bool pagecache_is_conflict(struct page *page)
> +{
> +	return page == XA_RETRY_ENTRY;
> +}
> +
> +/**
> + * __find_get_page - Find and get a page cache entry.
> + * @mapping: The address_space to search.
> + * @offset: The page cache index.
> + * @order: The minimum order of the entry to return.
> + *
> + * Looks up the page cache entries at @mapping between @offset and
> + * @offset + 2^@order.  If there is a page cache page, it is returned with

Off by one? :P

> + * an increased refcount unless it is smaller than @order.
> + *
> + * If the slot holds a shadow entry of a previously evicted page, or a
> + * swap entry from shmem/tmpfs, it is returned.
> + *
> + * Return: the found page, a value indicating a conflicting page or %NULL if
> + * there are no pages in this range.
> + */
> +static struct page *__find_get_page(struct address_space *mapping,
> +		unsigned long offset, unsigned int order)
> +{
> +	XA_STATE(xas, &mapping->i_pages, offset);
> +	struct page *page;
> +
> +	rcu_read_lock();
> +repeat:
> +	xas_reset(&xas);
> +	page = xas_find(&xas, offset | ((1UL << order) - 1));

Hm. '|' is confusing. What is expectation about offset?
Is round_down(offset, 1UL << order) expected to be equal offset?
If yes, please use '+' instead of '|'.

> +	if (xas_retry(&xas, page))
> +		goto repeat;
> +	/*
> +	 * A shadow entry of a recently evicted page, or a swap entry from
> +	 * shmem/tmpfs.  Skip it; keep looking for pages.
> +	 */
> +	if (xa_is_value(page))
> +		goto repeat;
> +	if (!page)
> +		goto out;
> +	if (compound_order(page) < order) {
> +		page = XA_RETRY_ENTRY;
> +		goto out;
> +	}

compound_order() is not stable if you don't have pin on the page.
Check it after page_cache_get_speculative().

> +
> +	if (!page_cache_get_speculative(page))
> +		goto repeat;
> +
> +	/*
> +	 * Has the page moved or been split?
> +	 * This is part of the lockless pagecache protocol. See
> +	 * include/linux/pagemap.h for details.
> +	 */
> +	if (unlikely(page != xas_reload(&xas))) {
> +		put_page(page);
> +		goto repeat;
> +	}
> +	page = find_subpage(page, offset);
> +out:
> +	rcu_read_unlock();
> +
> +	return page;
> +}
>  
>  /**
>   * find_lock_entry - locate, pin and lock a page cache entry
> @@ -1614,12 +1678,12 @@ EXPORT_SYMBOL(find_lock_entry);
>   * pagecache_get_page - find and get a page reference
>   * @mapping: the address_space to search
>   * @offset: the page index
> - * @fgp_flags: PCG flags
> + * @fgp_flags: FGP flags
>   * @gfp_mask: gfp mask to use for the page cache data page allocation
>   *
>   * Looks up the page cache slot at @mapping & @offset.
>   *
> - * PCG flags modify how the page is returned.
> + * FGP flags modify how the page is returned.
>   *
>   * @fgp_flags can be:
>   *
> @@ -1632,6 +1696,10 @@ EXPORT_SYMBOL(find_lock_entry);
>   * - FGP_FOR_MMAP: Similar to FGP_CREAT, only we want to allow the caller to do
>   *   its own locking dance if the page is already in cache, or unlock the page
>   *   before returning if we had to add the page to pagecache.
> + * - FGP_PMD: We're only interested in pages at PMD granularity.  If there
> + *   is no page here (and FGP_CREATE is set), we'll create one large enough.
> + *   If there is a smaller page in the cache that overlaps the PMD page, we
> + *   return %NULL and do not attempt to create a page.

Is it really the best inteface?

Maybe allow user to ask bitmask of allowed orders? For THP order-0 is fine
if order-9 has failed.

>   *
>   * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
>   * if the GFP flags specified for FGP_CREAT are atomic.
> @@ -1646,9 +1714,9 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>  	struct page *page;
>  
>  repeat:
> -	page = find_get_entry(mapping, offset);
> -	if (xa_is_value(page))
> -		page = NULL;
> +	page = __find_get_page(mapping, offset, fgp_order(fgp_flags));
> +	if (pagecache_is_conflict(page))
> +		return NULL;
>  	if (!page)
>  		goto no_page;
>  
> @@ -1682,7 +1750,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>  		if (fgp_flags & FGP_NOFS)
>  			gfp_mask &= ~__GFP_FS;
>  
> -		page = __page_cache_alloc(gfp_mask);
> +		page = __page_cache_alloc_order(gfp_mask, fgp_order(fgp_flags));
>  		if (!page)
>  			return NULL;
>  
> -- 
> 2.23.0.rc1
> 

-- 
 Kirill A. Shutemov

