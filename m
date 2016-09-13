Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38E246B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 13:32:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so25292496pab.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 10:32:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d63si28506560pfk.42.2016.09.13.10.32.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Sep 2016 10:32:18 -0700 (PDT)
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57D83821.4090804@linux.intel.com>
Date: Tue, 13 Sep 2016 10:32:17 -0700
MIME-Version: 1.0
In-Reply-To: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/13/2016 01:39 AM, Rui Teng wrote:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 87e11d8..64b5f81 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1442,7 +1442,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
>  static void dissolve_free_huge_page(struct page *page)
>  {
>  	spin_lock(&hugetlb_lock);
> -	if (PageHuge(page) && !page_count(page)) {
> +	if (PageHuge(page) && !page_count(page) && PageHead(page)) {
>  		struct hstate *h = page_hstate(page);
>  		int nid = page_to_nid(page);
>  		list_del(&page->lru);

This is goofy.  What is calling dissolve_free_huge_page() on a tail page?

Hmm:

>         for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
>                 dissolve_free_huge_page(pfn_to_page(pfn));

So, skip through the area being offlined at the smallest huge page size,
and try to dissolve a huge page in each place one might appear.  But,
after we dissolve a 16GB huge page, we continue looking through the
remaining 15.98GB tail area for huge pages in the area we just
dissolved.  The tail pages are still PageHuge() (how??), and we call
page_hstate() on the tail page whose head was just dissolved.

Note, even with the fix, this taking a (global) spinlock 1023 more times
that it doesn't have to.

This seems inefficient, and fails to fully explain what is going on, and
how tail pages still _look_ like PageHuge(), which seems pretty wrong.

I guess the patch _works_.  But, sheesh, it leaves a lot of room for
improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
