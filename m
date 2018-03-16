Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99ED86B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:51:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f3-v6so5514797plf.1
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:51:35 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o18si5550362pfa.401.2018.03.16.06.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 06:51:34 -0700 (PDT)
Date: Fri, 16 Mar 2018 16:51:30 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2 1/1] mm/ksm: fix interaction with THP
Message-ID: <20180316135130.dlyn6patvgvwaf4r@black.fi.intel.com>
References: <1521207755-28381-1-git-send-email-imbrenda@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521207755-28381-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@kernel.org, linux-mm@kvack.org, hughd@google.com, borntraeger@de.ibm.com, gerald.schaefer@de.ibm.com

On Fri, Mar 16, 2018 at 01:42:35PM +0000, Claudio Imbrenda wrote:
> This patch fixes a corner case for KSM. When two pages belong or
> belonged to the same transparent hugepage, and they should be merged,
> KSM fails to split the page, and therefore no merging happens.
> 
> This bug can be reproduced by:
> * making sure ksm is running (in case disabling ksmtuned)
> * enabling transparent hugepages
> * allocating a THP-aligned 1-THP-sized buffer
>   e.g. on amd64: posix_memalign(&p, 1<<21, 1<<21)
> * filling it with the same values
>   e.g. memset(p, 42, 1<<21)
> * performing madvise to make it mergeable
>   e.g. madvise(p, 1<<21, MADV_MERGEABLE)
> * waiting for KSM to perform a few scans
> 
> The expected outcome is that the all the pages get merged (1 shared and
> the rest sharing); the actual outcome is that no pages get merged (1
> unshared and the rest volatile)
> 
> The reason of this behaviour is that we increase the reference count
> once for both pages we want to merge, but if they belong to the same
> hugepage (or compound page), the reference counter used in both cases
> is the one of the head of the compound page.
> This means that split_huge_page will find a value of the reference
> counter too high and will fail.
> 
> This patch solves this problem by testing if the two pages to merge
> belong to the same hugepage when attempting to merge them. If so, the
> hugepage is split safely. This means that the hugepage is not split if
> not necessary.
> 
> Co-authored-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> ---
>  mm/ksm.c | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 293721f..882d6ec 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -2082,8 +2082,22 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  	tree_rmap_item =
>  		unstable_tree_search_insert(rmap_item, page, &tree_page);
>  	if (tree_rmap_item) {
> +		bool split;
> +
>  		kpage = try_to_merge_two_pages(rmap_item, page,
>  						tree_rmap_item, tree_page);
> +		/*
> +		 * If both pages we tried to merge belong to the same compound
> +		 * page, then we actually ended up increasing the reference
> +		 * count of the same compound page twice, and split_huge_page
> +		 * failed.
> +		 * Here we set a flag if that happened, and we use it later to
> +		 * try split_huge_page again. Since we call put_page right
> +		 * afterwards, the reference count will be correct and
> +		 * split_huge_page should succeed.
> +		 */
> +		split = PageTransCompound(page) && PageTransCompound(tree_page)
> +			&& compound_head(page) == compound_head(tree_page);

You don't need to check *both* pages if they are compound if they share
compound_head(). One check is enough.

-- 
 Kirill A. Shutemov
