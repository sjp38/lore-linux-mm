Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57130C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:09:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0085A208C3
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:09:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="1gxHiQjK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0085A208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EC446B0003; Fri,  6 Sep 2019 08:09:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99DE46B0006; Fri,  6 Sep 2019 08:09:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 865636B0007; Fri,  6 Sep 2019 08:09:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 670EB6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:09:47 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DCB49181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:09:46 +0000 (UTC)
X-FDA: 75904376772.08.shoes30_726b634bca54a
X-HE-Tag: shoes30_726b634bca54a
X-Filterd-Recvd-Size: 6468
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:09:46 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id o9so6137683edq.0
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 05:09:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/ZpOOYR+HZWQeyP2e1hldkbWyYIuYUrXJjhNyL08Hq8=;
        b=1gxHiQjKdOMyYiGzE5VW4GFk2+DGLsS8p512DlwXy29ptXKbSTxwpPVaBpZ1OwYzrS
         iNS3KHSS9jXjIQ+sUHeZZ9SEREISWmfb1ze0PNii5OcBKGxRubHhsMXap2slQfeghNCE
         E0p3aVriXPsjvaZlDj3krxH2NPEjfTGXCK5RptnMHNg2ycrRsJ+w7cFxLS6Mp2aIX6+6
         5QXL+r/wNaFsrn0yeAzhcJVg1lDEQYaXqGN1g3QrkgQJxox+6gQ+01A5CRWd0wbb7Ie4
         hfjVnoD4qOkIlwdZmQuoIW2hA+WZ/zAhKjctVLDpQvRmf4x2ndokxfa2L9yq5Kir9BMW
         1jwg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=/ZpOOYR+HZWQeyP2e1hldkbWyYIuYUrXJjhNyL08Hq8=;
        b=bmgXHWruIP9wtcCVDw8v/GpO/AXQnJnw6wBUqolvU6Xg00nEKrwgVLFEm9vgljGAcj
         SnieTDX3cqqzjFFJBOyk59epRn/MomyxHKVdA/FG+Tgxq7ruPl3/69+bcIeCsGVYG2en
         1Bq5x9BSsA0q5Cr5AyL5BoXCK90HFGdYhMP9z1qkj1at4iKjtR+GXh8HZyVj9WbgbtRl
         UmlUSFLu2A8rHbTtPS1zkH+O3O7X2mmu+UEhW1j2ZtH0eEu7J0srB8lUeczP7fvzTeSZ
         f1siaKOzoLycdas8O4+XaGsrJli9B3j9gSpAPBw7LVeeF+dSUdJ88FXEXNw/TBGPi1E7
         RjsA==
X-Gm-Message-State: APjAAAXpeTb51nxd/Sjs+WYvbOSa/gsEgxj457+ToYJtqs+LyO+CT+8C
	4SrY+Lt4OUBWBVWCpoq7owinUw==
X-Google-Smtp-Source: APXvYqzc3hH3oh715W7IxEi0aqKaryx+UF7bbnCEMkE8mzS+Qle/uOPGXcP6SUwwvaatUlZBYPeZIA==
X-Received: by 2002:a50:d55e:: with SMTP id f30mr9274055edj.35.1567771784925;
        Fri, 06 Sep 2019 05:09:44 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c21sm912039ede.45.2019.09.06.05.09.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 05:09:44 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 251D01049F1; Fri,  6 Sep 2019 15:09:44 +0300 (+03)
Date: Fri, 6 Sep 2019 15:09:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 2/3] mm: Allow large pages to be added to the page cache
Message-ID: <20190906120944.gm6lncxmkkz6kgjx@box>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905182348.5319-3-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 11:23:47AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> We return -EEXIST if there are any non-shadow entries in the page
> cache in the range covered by the large page.  If there are multiple
> shadow entries in the range, we set *shadowp to one of them (currently
> the one at the highest index).  If that turns out to be the wrong
> answer, we can implement something more complex.  This is mostly
> modelled after the equivalent function in the shmem code.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> ---
>  mm/filemap.c | 39 ++++++++++++++++++++++++++++-----------
>  1 file changed, 28 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 041c77c4ca56..ae3c0a70a8e9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -850,6 +850,7 @@ static int __add_to_page_cache_locked(struct page *page,
>  	int huge = PageHuge(page);
>  	struct mem_cgroup *memcg;
>  	int error;
> +	unsigned int nr = 1;
>  	void *old;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> @@ -861,31 +862,47 @@ static int __add_to_page_cache_locked(struct page *page,
>  					      gfp_mask, &memcg, false);
>  		if (error)
>  			return error;
> +		xas_set_order(&xas, offset, compound_order(page));
> +		nr = compound_nr(page);
>  	}
>  
> -	get_page(page);
> +	page_ref_add(page, nr);
>  	page->mapping = mapping;
>  	page->index = offset;
>  
>  	do {
> +		unsigned long exceptional = 0;
> +		unsigned int i = 0;
> +
>  		xas_lock_irq(&xas);
> -		old = xas_load(&xas);
> -		if (old && !xa_is_value(old))
> +		xas_for_each_conflict(&xas, old) {
> +			if (!xa_is_value(old))
> +				break;
> +			exceptional++;
> +			if (shadowp)
> +				*shadowp = old;
> +		}
> +		if (old) {
>  			xas_set_err(&xas, -EEXIST);
> -		xas_store(&xas, page);
> +			break;
> +		}
> +		xas_create_range(&xas);
>  		if (xas_error(&xas))
>  			goto unlock;
>  
> -		if (xa_is_value(old)) {
> -			mapping->nrexceptional--;
> -			if (shadowp)
> -				*shadowp = old;
> +next:
> +		xas_store(&xas, page);
> +		if (++i < nr) {
> +			xas_next(&xas);
> +			goto next;
>  		}

Can we have a proper loop here instead of goto?

		do {
			xas_store(&xas, page);
			/* Do not move xas ouside the range */
			if (++i != nr)
				xas_next(&xas);
		} while (i < nr);

> -		mapping->nrpages++;
> +		mapping->nrexceptional -= exceptional;
> +		mapping->nrpages += nr;
>  
>  		/* hugetlb pages do not participate in page cache accounting */
>  		if (!huge)
> -			__inc_node_page_state(page, NR_FILE_PAGES);
> +			__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES,
> +						nr);
>  unlock:
>  		xas_unlock_irq(&xas);
>  	} while (xas_nomem(&xas, gfp_mask & GFP_RECLAIM_MASK));
> @@ -902,7 +919,7 @@ static int __add_to_page_cache_locked(struct page *page,
>  	/* Leave page->index set: truncation relies upon it */
>  	if (!huge)
>  		mem_cgroup_cancel_charge(page, memcg, false);
> -	put_page(page);
> +	page_ref_sub(page, nr);
>  	return xas_error(&xas);
>  }
>  ALLOW_ERROR_INJECTION(__add_to_page_cache_locked, ERRNO);
> -- 
> 2.23.0.rc1
> 

-- 
 Kirill A. Shutemov

