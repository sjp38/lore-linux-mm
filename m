Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B5F576B0264
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 12:52:14 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 127so66602529wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:52:14 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id v3si844100wjf.31.2016.03.29.09.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 09:52:13 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id p65so148240650wmp.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:52:13 -0700 (PDT)
Date: Tue, 29 Mar 2016 19:51:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Exclude HugeTLB pages from THP page_mapped logic
Message-ID: <20160329165149.GA1102@node.shutemov.name>
References: <1459269581-21190-1-git-send-email-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459269581-21190-1-git-send-email-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dwoods@mellanox.com, mhocko@suse.com, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Mar 29, 2016 at 05:39:41PM +0100, Steve Capper wrote:
> HugeTLB pages cannot be split, thus use the compound_mapcount to
> track rmaps.
> 
> Currently the page_mapped function will check the compound_mapcount, but
> will also go through the constituent pages of a THP compound page and
> query the individual _mapcount's too.
> 
> Unfortunately, the page_mapped function does not distinguish between
> HugeTLB and THP compound pages and assumes that a compound page always
> needs to have HPAGE_PMD_NR pages querying.
> 
> For most cases when dealing with HugeTLB this is just inefficient, but
> for scenarios where the HugeTLB page size is less than the pmd block
> size (e.g. when using contiguous bit on ARM) this can lead to crashes.
> 
> This patch adjusts the page_mapped function such that we skip the
> unnecessary THP reference checks for HugeTLB pages.
> 
> Fixes: e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount() for compound pages")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
> 
> Hi,
> 
> This patch is my approach to fixing a problem that unearthed with
> HugeTLB pages on arm64. We ran with PAGE_SIZE=64KB and placed down 32
> contiguous ptes to create 2MB HugeTLB pages. (We can provide hints to
> the MMU that page table entries are contiguous thus larger TLB entries
> can be used to represent them).
> 
> The PMD_SIZE was 512MB thus the old version of page_mapped would read
> through too many struct pages and lead to BUGs.
> 
> Original problem reported here:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/414657.html
> 
> Having examined the HugeTLB code, I understand that only the
> compound_mapcount_ptr is used to track rmap presence so going through
> the individual _mapcounts for HugeTLB pages is superfluous? Or should I
> instead post a patch that changes hpage_nr_pages to use the compound
> order?

I would not touch hpage_nr_page().

We probably need to introduce compound_nr_pages() or something to replace
(1 << compound_order(page)) to be used independetely from thp/hugetlb
pages.

> Also, for the sake of readability, would it be worth changing the
> definition of PageTransHuge to refer to only THPs (not both HugeTLB
> and THP)?

I don't think so.

That would have overhead, since we wound need to do function call inside
PageTransHuge(). HugeTLB() is not inlinable.

hugetlb deverges from rest of mm pretty early, so thp vs. hugetlb
confusion is not that ofter. We just don't share enough codepath.

> (I misinterpreted PageTransHuge in hpage_nr_pages initially which is one
> reason this problem took me longer than normal to pin down this issue).
> 
> Cheers,
> -- 
> Steve
> 
> ---
>  include/linux/mm.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ed6407d..4b223dc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1031,6 +1031,8 @@ static inline bool page_mapped(struct page *page)
>  	page = compound_head(page);
>  	if (atomic_read(compound_mapcount_ptr(page)) >= 0)
>  		return true;
> +	if (PageHuge(page))
> +		return false;
>  	for (i = 0; i < hpage_nr_pages(page); i++) {
>  		if (atomic_read(&page[i]._mapcount) >= 0)
>  			return true;
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
