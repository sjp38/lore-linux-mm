Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9574CC742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40F07208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:19:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40F07208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA87B8E0120; Fri, 12 Jul 2019 03:19:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2ED18E00DB; Fri, 12 Jul 2019 03:19:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACF6C8E0120; Fri, 12 Jul 2019 03:19:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 570DC8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:19:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so6987610edu.11
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:19:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OnA4bjBRHH9MS17uXLRt/2IlX+RYZLH7MNnw8SIklPo=;
        b=PVQjAbLsOYjv/G7kvoW0t/uKUtpEwpaWrZPcJqYEbCmGsqhqUDJXKKeGtslk5bdGyG
         E+D3Po3Ppj4YC5UqYG7iLaa2Rpo5iJIkSgfzjj1OKnf2sDTB9RVxA6oZFCT/r4V75Fy5
         gahK4MXnKWnJeXfLPJpkDHOKWX/CB/YZgT/iUmLVHKapt3ThHdvGogJlp+FJupUmdavG
         KY5O0E+YGbi+f6PPcQE0UjLTQ84isBSqBxJkJQcynkXAXVKSXCLO5snSM8LwKDmRfYJA
         rKoXk1hUkajINTCzrGee/4PrcfA3aHiDauQa9kZdBR8UuAOi0uhKB5mx3/cr/ymA+by8
         CDgA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWqwRJhKVm2GCzYNFpvgyjSh5edTV64Dg4XWGJBw9uyD0/brBJv
	JYOY1kMSdmvSMTvgTAUmjUIijYjPaF3hPjNtDqd07Xtcud8XoaK7r+UVwCzb9KCkpGPWB3qbR0H
	LXizw8J4lVu97ZO4FqSszCf7p+LG3wgge64T8OZCFB6cytDi3anlce+zY4UJDEE8=
X-Received: by 2002:a17:906:b211:: with SMTP id p17mr6786554ejz.11.1562915994897;
        Fri, 12 Jul 2019 00:19:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAk9BR8VRPeIwtL/hdMg/S/7sUt1gR7x1OVC6CCpThRF4Wpj6S7wx/T+d1kv4qi0DRz1cN
X-Received: by 2002:a17:906:b211:: with SMTP id p17mr6786510ejz.11.1562915994040;
        Fri, 12 Jul 2019 00:19:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562915994; cv=none;
        d=google.com; s=arc-20160816;
        b=vD7aIHs2m8WKL631uB/ELulbkA3J+SrE9URBMDIATTx4BpkihTjt65+C1Rnh6QvNP3
         UlGkxWFQWVnuERhWuuXSFGx0483vgVBTSuQ+UFA4c8JWcpVzebZSRD7CTHbUPKCDdiIe
         qPCP5ppzCwKOyaEPKhElJwAz+GOiruHoDAtGS4TBy5eJY8eWupO9I8RwpzDh6VjPplbJ
         UiNb/UUNVuoR44CPeLmoJ6Qjn6AfIMRdG6BlB1RLkBEJKUz88htDfC6bfVi2PyU7pW93
         Jils+4dQqeOW9GI/kNoBzDuJpFpAl5EHmE9z0gfRgxZ/lt5uVdLHBYIKCoDAhl9XnDrf
         HUBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OnA4bjBRHH9MS17uXLRt/2IlX+RYZLH7MNnw8SIklPo=;
        b=LEwqYB3tbK7kJfzI29qx+fWJoolkyxTPQqXs+rCqjOujgo+zzGQ+Cl2VtHKdgW44eY
         pquzBjqpkXoDNsvTScH82WDlHcuWStAWLooC2ysXuan2i+0IrPwYHDyA5zoy2ffRt3PS
         yATaH9R3OThip6hxSLQgQqHw9VDpUrSQda5MUMDbLyn00TSlLe1wXzp5v6Ty+26wBNzn
         QvRlOs+w2H1ZnMgojt3sO71TyBNuPCjXr+n2mMjsfbB4PVEffG/kHjel21KdA0gcQQhh
         T/KxVKRDfac0j9TUGOLY5P8NoM3iwKmomKHsxs2N8HRg/J787Rx6b0PR2/MDi1rWorQM
         Pfig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t39si4665561eda.363.2019.07.12.00.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 00:19:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0C9DCAD4E;
	Fri, 12 Jul 2019 07:19:53 +0000 (UTC)
Date: Fri, 12 Jul 2019 09:19:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 4/4] mm: introduce MADV_PAGEOUT
Message-ID: <20190712071951.GO29483@dhcp22.suse.cz>
References: <20190711012528.176050-1-minchan@kernel.org>
 <20190711012528.176050-5-minchan@kernel.org>
 <20190711184223.GD20341@cmpxchg.org>
 <20190712051828.GA128252@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712051828.GA128252@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 14:18:28, Minchan Kim wrote:
[...]
> >From 41592f23e876ec21e49dc3c76dc89538e2bb16be Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 12 Jul 2019 14:05:36 +0900
> Subject: [PATCH] mm: factor out common parts between MADV_COLD and
>  MADV_PAGEOUT
> 
> There are many common parts between MADV_COLD and MADV_PAGEOUT.
> This patch factor them out to save code duplication.

This looks better indeed. I still hope that this can get improved even
further but let's do that in a follow up patch.

> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/madvise.c | 201 +++++++++++++--------------------------------------
>  1 file changed, 52 insertions(+), 149 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index bc2f0138982e..3d3d14517cc8 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -30,6 +30,11 @@
>  
>  #include "internal.h"
>  
> +struct madvise_walk_private {
> +	struct mmu_gather *tlb;
> +	bool pageout;
> +};
> +
>  /*
>   * Any behaviour which results in changes to the vma->vm_flags needs to
>   * take mmap_sem for writing. Others, which simply traverse vmas, need
> @@ -310,16 +315,23 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> -static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> -				unsigned long end, struct mm_walk *walk)
> +static int madvise_cold_or_pageout_pte_range(pmd_t *pmd,
> +				unsigned long addr, unsigned long end,
> +				struct mm_walk *walk)
>  {
> -	struct mmu_gather *tlb = walk->private;
> +	struct madvise_walk_private *private = walk->private;
> +	struct mmu_gather *tlb = private->tlb;
> +	bool pageout = private->pageout;
>  	struct mm_struct *mm = tlb->mm;
>  	struct vm_area_struct *vma = walk->vma;
>  	pte_t *orig_pte, *pte, ptent;
>  	spinlock_t *ptl;
> -	struct page *page;
>  	unsigned long next;
> +	struct page *page = NULL;
> +	LIST_HEAD(page_list);
> +
> +	if (fatal_signal_pending(current))
> +		return -EINTR;
>  
>  	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> @@ -358,6 +370,12 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  			return 0;
>  		}
>  
> +		if (pageout) {
> +			if (isolate_lru_page(page))
> +				goto huge_unlock;
> +			list_add(&page->lru, &page_list);
> +		}
> +
>  		if (pmd_young(orig_pmd)) {
>  			pmdp_invalidate(vma, addr, pmd);
>  			orig_pmd = pmd_mkold(orig_pmd);
> @@ -366,10 +384,14 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>  		}
>  
> +		ClearPageReferenced(page);
>  		test_and_clear_page_young(page);
> -		deactivate_page(page);
>  huge_unlock:
>  		spin_unlock(ptl);
> +		if (pageout)
> +			reclaim_pages(&page_list);
> +		else
> +			deactivate_page(page);
>  		return 0;
>  	}
>  
> @@ -423,6 +445,12 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  		VM_BUG_ON_PAGE(PageTransCompound(page), page);
>  
> +		if (pageout) {
> +			if (isolate_lru_page(page))
> +				continue;
> +			list_add(&page->lru, &page_list);
> +		}
> +
>  		if (pte_young(ptent)) {
>  			ptent = ptep_get_and_clear_full(mm, addr, pte,
>  							tlb->fullmm);
> @@ -437,12 +465,16 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  		 * As a side effect, it makes confuse idle-page tracking
>  		 * because they will miss recent referenced history.
>  		 */
> +		ClearPageReferenced(page);
>  		test_and_clear_page_young(page);
> -		deactivate_page(page);
> +		if (!pageout)
> +			deactivate_page(page);
>  	}
>  
>  	arch_enter_lazy_mmu_mode();
>  	pte_unmap_unlock(orig_pte, ptl);
> +	if (pageout)
> +		reclaim_pages(&page_list);
>  	cond_resched();
>  
>  	return 0;
> @@ -452,10 +484,15 @@ static void madvise_cold_page_range(struct mmu_gather *tlb,
>  			     struct vm_area_struct *vma,
>  			     unsigned long addr, unsigned long end)
>  {
> +	struct madvise_walk_private walk_private = {
> +		.tlb = tlb,
> +		.pageout = false,
> +	};
> +
>  	struct mm_walk cold_walk = {
> -		.pmd_entry = madvise_cold_pte_range,
> +		.pmd_entry = madvise_cold_or_pageout_pte_range,
>  		.mm = vma->vm_mm,
> -		.private = tlb,
> +		.private = &walk_private,
>  	};
>  
>  	tlb_start_vma(tlb, vma);
> @@ -482,153 +519,19 @@ static long madvise_cold(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> -static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> -				unsigned long end, struct mm_walk *walk)
> -{
> -	struct mmu_gather *tlb = walk->private;
> -	struct mm_struct *mm = tlb->mm;
> -	struct vm_area_struct *vma = walk->vma;
> -	pte_t *orig_pte, *pte, ptent;
> -	spinlock_t *ptl;
> -	LIST_HEAD(page_list);
> -	struct page *page;
> -	unsigned long next;
> -
> -	if (fatal_signal_pending(current))
> -		return -EINTR;
> -
> -	next = pmd_addr_end(addr, end);
> -	if (pmd_trans_huge(*pmd)) {
> -		pmd_t orig_pmd;
> -
> -		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
> -		ptl = pmd_trans_huge_lock(pmd, vma);
> -		if (!ptl)
> -			return 0;
> -
> -		orig_pmd = *pmd;
> -		if (is_huge_zero_pmd(orig_pmd))
> -			goto huge_unlock;
> -
> -		if (unlikely(!pmd_present(orig_pmd))) {
> -			VM_BUG_ON(thp_migration_supported() &&
> -					!is_pmd_migration_entry(orig_pmd));
> -			goto huge_unlock;
> -		}
> -
> -		page = pmd_page(orig_pmd);
> -		if (next - addr != HPAGE_PMD_SIZE) {
> -			int err;
> -
> -			if (page_mapcount(page) != 1)
> -				goto huge_unlock;
> -			get_page(page);
> -			spin_unlock(ptl);
> -			lock_page(page);
> -			err = split_huge_page(page);
> -			unlock_page(page);
> -			put_page(page);
> -			if (!err)
> -				goto regular_page;
> -			return 0;
> -		}
> -
> -		if (isolate_lru_page(page))
> -			goto huge_unlock;
> -
> -		if (pmd_young(orig_pmd)) {
> -			pmdp_invalidate(vma, addr, pmd);
> -			orig_pmd = pmd_mkold(orig_pmd);
> -
> -			set_pmd_at(mm, addr, pmd, orig_pmd);
> -			tlb_remove_tlb_entry(tlb, pmd, addr);
> -		}
> -
> -		ClearPageReferenced(page);
> -		test_and_clear_page_young(page);
> -		list_add(&page->lru, &page_list);
> -huge_unlock:
> -		spin_unlock(ptl);
> -		reclaim_pages(&page_list);
> -		return 0;
> -	}
> -
> -	if (pmd_trans_unstable(pmd))
> -		return 0;
> -regular_page:
> -	tlb_change_page_size(tlb, PAGE_SIZE);
> -	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> -	flush_tlb_batched_pending(mm);
> -	arch_enter_lazy_mmu_mode();
> -	for (; addr < end; pte++, addr += PAGE_SIZE) {
> -		ptent = *pte;
> -		if (!pte_present(ptent))
> -			continue;
> -
> -		page = vm_normal_page(vma, addr, ptent);
> -		if (!page)
> -			continue;
> -
> -		/*
> -		 * creating a THP page is expensive so split it only if we
> -		 * are sure it's worth. Split it if we are only owner.
> -		 */
> -		if (PageTransCompound(page)) {
> -			if (page_mapcount(page) != 1)
> -				break;
> -			get_page(page);
> -			if (!trylock_page(page)) {
> -				put_page(page);
> -				break;
> -			}
> -			pte_unmap_unlock(orig_pte, ptl);
> -			if (split_huge_page(page)) {
> -				unlock_page(page);
> -				put_page(page);
> -				pte_offset_map_lock(mm, pmd, addr, &ptl);
> -				break;
> -			}
> -			unlock_page(page);
> -			put_page(page);
> -			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> -			pte--;
> -			addr -= PAGE_SIZE;
> -			continue;
> -		}
> -
> -		VM_BUG_ON_PAGE(PageTransCompound(page), page);
> -
> -		if (isolate_lru_page(page))
> -			continue;
> -
> -		if (pte_young(ptent)) {
> -			ptent = ptep_get_and_clear_full(mm, addr, pte,
> -							tlb->fullmm);
> -			ptent = pte_mkold(ptent);
> -			set_pte_at(mm, addr, pte, ptent);
> -			tlb_remove_tlb_entry(tlb, pte, addr);
> -		}
> -		ClearPageReferenced(page);
> -		test_and_clear_page_young(page);
> -		list_add(&page->lru, &page_list);
> -	}
> -
> -	arch_leave_lazy_mmu_mode();
> -	pte_unmap_unlock(orig_pte, ptl);
> -	reclaim_pages(&page_list);
> -	cond_resched();
> -
> -	return 0;
> -}
> -
>  static void madvise_pageout_page_range(struct mmu_gather *tlb,
>  			     struct vm_area_struct *vma,
>  			     unsigned long addr, unsigned long end)
>  {
> +	struct madvise_walk_private walk_private = {
> +		.pageout = true,
> +		.tlb = tlb,
> +	};
> +
>  	struct mm_walk pageout_walk = {
> -		.pmd_entry = madvise_pageout_pte_range,
> +		.pmd_entry = madvise_cold_or_pageout_pte_range,
>  		.mm = vma->vm_mm,
> -		.private = tlb,
> +		.private = &walk_private,
>  	};
>  
>  	tlb_start_vma(tlb, vma);
> -- 
> 2.22.0.410.gd8fdbe21b5-goog

-- 
Michal Hocko
SUSE Labs

