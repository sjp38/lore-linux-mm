Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7AB6B0038
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 10:34:31 -0400 (EDT)
Received: by wigg3 with SMTP id g3so50689966wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 07:34:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gb5si18423993wjb.21.2015.06.10.07.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 07:34:29 -0700 (PDT)
Message-ID: <55784AF2.2030602@suse.cz>
Date: Wed, 10 Jun 2015 16:34:26 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 27/36] mm: differentiate page_mapped() from page_mapcount()
 for compound pages
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-28-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> Let's define page_mapped() to be true for compound pages if any
> sub-pages of the compound page is mapped (with PMD or PTE).
>
> On other hand page_mapcount() return mapcount for this particular small
> page.
>
> This will make cases like page_get_anon_vma() behave correctly once we
> allow huge pages to be mapped with PTE.
>
> Most users outside core-mm should use page_mapcount() instead of
> page_mapped().
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

[...]

> @@ -917,10 +917,21 @@ static inline pgoff_t page_file_index(struct page *page)
>
>   /*
>    * Return true if this page is mapped into pagetables.
> + * For compound page it returns true if any subpage of compound page is mapped.
>    */
> -static inline int page_mapped(struct page *page)
> +static inline bool page_mapped(struct page *page)
>   {
> -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
> +	int i;
> +	if (likely(!PageCompound(page)))
> +		return atomic_read(&page->_mapcount) >= 0;
> +	page = compound_head(page);
> +	if (compound_mapcount(page))

Same optimization opportunity as I pointed out in previous patch for 
page_mapcount().

> +		return true;
> +	for (i = 0; i < hpage_nr_pages(page); i++) {
> +		if (atomic_read(&page[i]._mapcount) >= 0)
> +			return true;
> +	}
> +	return true;
>   }
>
>   /*
> diff --git a/mm/filemap.c b/mm/filemap.c
> index cb41cf3069d2..c6cf03303ded 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -202,7 +202,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
>   		__dec_zone_page_state(page, NR_FILE_PAGES);
>   	if (PageSwapBacked(page))
>   		__dec_zone_page_state(page, NR_SHMEM);
> -	BUG_ON(page_mapped(page));
> +	VM_BUG_ON_PAGE(page_mapped(page), page);
>
>   	/*
>   	 * At this point page must be either written or cleaned by truncate.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
