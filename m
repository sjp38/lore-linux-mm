Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id B33556B00C1
	for <linux-mm@kvack.org>; Mon, 18 May 2015 10:32:26 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so72031562wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 07:32:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dj8si11317677wib.80.2015.05.18.07.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 May 2015 07:32:25 -0700 (PDT)
Message-ID: <5559F7F6.7060801@suse.cz>
Date: Mon, 18 May 2015 16:32:22 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 19/28] mm: store mapcount for compound page separately
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-20-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound and
> we need a cheap way to find out how many time the compound page is
> mapped with PMD -- compound_mapcount() does this.
>
> We use the same approach as with compound page destructor and compound
> order: use space in first tail page, ->mapping this time.
>
> page_mapcount() counts both: PTE and PMD mappings of the page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   include/linux/mm.h       | 25 ++++++++++++--
>   include/linux/mm_types.h |  1 +
>   include/linux/rmap.h     |  4 +--
>   mm/debug.c               |  5 ++-
>   mm/huge_memory.c         |  2 +-
>   mm/hugetlb.c             |  4 +--
>   mm/memory.c              |  2 +-
>   mm/migrate.c             |  2 +-
>   mm/page_alloc.c          | 14 ++++++--
>   mm/rmap.c                | 87 +++++++++++++++++++++++++++++++++++++-----------
>   10 files changed, 114 insertions(+), 32 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dad667d99304..33cb3aa647a6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -393,6 +393,19 @@ static inline int is_vmalloc_or_module_addr(const void *x)
>
>   extern void kvfree(const void *addr);
>
> +static inline atomic_t *compound_mapcount_ptr(struct page *page)
> +{
> +	return &page[1].compound_mapcount;
> +}
> +
> +static inline int compound_mapcount(struct page *page)
> +{
> +	if (!PageCompound(page))
> +		return 0;
> +	page = compound_head(page);
> +	return atomic_read(compound_mapcount_ptr(page)) + 1;
> +}
> +
>   /*
>    * The atomic page->_mapcount, starts from -1: so that transitions
>    * both from it and to it can be tracked, using atomic_inc_and_test

What's not shown here is the implementation of page_mapcount_reset() 
that's unchanged... is that correct from all callers?

> @@ -405,8 +418,16 @@ static inline void page_mapcount_reset(struct page *page)
>
>   static inline int page_mapcount(struct page *page)
>   {
> +	int ret;
>   	VM_BUG_ON_PAGE(PageSlab(page), page);
> -	return atomic_read(&page->_mapcount) + 1;
> +	ret = atomic_read(&page->_mapcount) + 1;
> +	/*
> +	 * Positive compound_mapcount() offsets ->_mapcount in every page by
> +	 * one. Let's substract it here.
> +	 */

This could use some more detailed explanation, or at least pointers to 
the relevant rmap functions. Also in commit message.

> +	if (compound_mapcount(page))
> +	       ret += compound_mapcount(page) - 1;

This looks like it could uselessly duplicate-inline the code for 
compound_mapcount(). It has atomics and smp_rmb() so I'm not sure if the 
compiler can just "squash it".

On the other hand, a simple atomic read that was page_mapcount() has 
turned into multiple atomic reads and flag checks. What about the 
stability of the whole result? Are all callers ok? (maybe a later page 
deals with it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
