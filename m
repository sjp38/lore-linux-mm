Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40CED6B2EE5
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 05:25:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h40-v6so3394229edb.2
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:25:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m6-v6si359055edd.279.2018.08.24.02.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 02:25:31 -0700 (PDT)
Date: Fri, 24 Aug 2018 11:25:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180824092529.GG29735@dhcp22.suse.cz>
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823205917.16297-2-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Thu 23-08-18 13:59:16, Mike Kravetz wrote:
[...]
> @@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
>  		address = pvmw.address;
>  
> +		if (PageHuge(page)) {
> +			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {
> +				/*
> +				 * huge_pmd_unshare unmapped an entire PMD
> +				 * page.  There is no way of knowing exactly
> +				 * which PMDs may be cached for this mm, so
> +				 * we must flush them all.  start/end were
> +				 * already adjusted above to cover this range.
> +				 */
> +				flush_cache_range(vma, start, end);
> +				flush_tlb_range(vma, start, end);
> +				mmu_notifier_invalidate_range(mm, start, end);
> +
> +				/*
> +				 * The ref count of the PMD page was dropped
> +				 * which is part of the way map counting
> +				 * is done for shared PMDs.  Return 'true'
> +				 * here.  When there is no other sharing,
> +				 * huge_pmd_unshare returns false and we will
> +				 * unmap the actual page and drop map count
> +				 * to zero.
> +				 */
> +				page_vma_mapped_walk_done(&pvmw);
> +				break;
> +			}
> +		}

Wait a second. This is not correct, right? You have to call the
notifiers after page_vma_mapped_walk_done because they might be
sleepable and we are still holding the pte lock. This is btw. a problem
for other users of mmu_notifier_invalidate_range in try_to_unmap_one,
unless I am terribly confused. This would suggest 369ea8242c0fb is
incorrect.
-- 
Michal Hocko
SUSE Labs
