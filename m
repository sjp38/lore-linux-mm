Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3261682F66
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 07:17:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l65so33597731wmf.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:17:56 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id o21si1877513lfo.228.2016.09.08.04.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 04:17:55 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id s29so1087720lfg.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:17:54 -0700 (PDT)
Date: Thu, 8 Sep 2016 14:17:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -v3 08/10] mm, THP: Add can_split_huge_page()
Message-ID: <20160908111752.GE17331@node>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <1473266769-2155-9-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473266769-2155-9-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

On Wed, Sep 07, 2016 at 09:46:07AM -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Separates checking whether we can split the huge page from
> split_huge_page_to_list() into a function.  This will help to check that
> before splitting the THP (Transparent Huge Page) really.
> 
> This will be used for delaying splitting THP during swapping out.  Where
> for a THP, we will allocate a swap cluster, add the THP into the swap
> cache, then split the THP.  To avoid the unnecessary operations for the
> un-splittable THP, we will check that firstly.
> 
> There is no functionality change in this patch.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  include/linux/huge_mm.h |  6 ++++++
>  mm/huge_memory.c        | 13 ++++++++++++-
>  2 files changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 9b9f65d..a0073e7 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -94,6 +94,7 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
>  extern void prep_transhuge_page(struct page *page);
>  extern void free_transhuge_page(struct page *page);
>  
> +bool can_split_huge_page(struct page *page);
>  int split_huge_page_to_list(struct page *page, struct list_head *list);
>  static inline int split_huge_page(struct page *page)
>  {
> @@ -176,6 +177,11 @@ static inline void prep_transhuge_page(struct page *page) {}
>  
>  #define thp_get_unmapped_area	NULL
>  
> +static inline bool
> +can_split_huge_page(struct page *page)
> +{

BUILD_BUG() should be appropriate here.

> +	return false;
> +}
>  static inline int
>  split_huge_page_to_list(struct page *page, struct list_head *list)
>  {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fc0d37e..3be5abe 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2016,6 +2016,17 @@ int page_trans_huge_mapcount(struct page *page, int *total_mapcount)
>  	return ret;
>  }
>  
> +/* Racy check whether the huge page can be split */
> +bool can_split_huge_page(struct page *page)
> +{
> +	int extra_pins = 0;
> +
> +	/* Additional pins from radix tree */
> +	if (!PageAnon(page))
> +		extra_pins = HPAGE_PMD_NR;
> +	return total_mapcount(page) == page_count(page) - extra_pins - 1;
> +}
> +
>  /*
>   * This function splits huge page into normal pages. @page can point to any
>   * subpage of huge page to split. Split doesn't change the position of @page.
> @@ -2086,7 +2097,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	 * Racy check if we can split the page, before freeze_page() will
>  	 * split PMDs
>  	 */
> -	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
> +	if (!can_split_huge_page(head)) {
>  		ret = -EBUSY;
>  		goto out_unlock;
>  	}
> -- 
> 2.8.1
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
