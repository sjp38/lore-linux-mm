Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BD0E86B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:08:19 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so169585057pad.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:08:19 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id gj8si15168183pac.118.2015.03.30.08.08.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 08:08:18 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 20:38:14 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 21AE4125805C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:39:51 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2UF898v60424328
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:38:09 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2UF88nm028917
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:38:08 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 19/24] thp, mm: use migration entries to freeze page counts on split
In-Reply-To: <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
Date: Mon, 30 Mar 2015 20:38:08 +0530
Message-ID: <87h9t2le07.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

....
....
 +static void freeze_page(struct anon_vma *anon_vma, struct page *page)
> +{
> +	struct anon_vma_chain *avc;
> +	struct vm_area_struct *vma;
> +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);

So this get called only with head page, We also do
BUG_ON(PageTail(page)) in the caller.  But


> +	unsigned long addr, haddr;
> +	unsigned long mmun_start, mmun_end;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *start_pte, *pte;
> +	spinlock_t *ptl;
......


> +
> +static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
> +{
> +	struct anon_vma_chain *avc;
> +	pgoff_t pgoff = page_to_pgoff(page);

Why ? Can this get called for tail pages ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
