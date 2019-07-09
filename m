Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F7FCC73C41
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 14:10:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9FC12080C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 14:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9FC12080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79F5A8E0050; Tue,  9 Jul 2019 10:10:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727FC8E0032; Tue,  9 Jul 2019 10:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F0F58E0050; Tue,  9 Jul 2019 10:10:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 054748E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 10:10:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so9418783edr.15
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 07:10:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w0ha5sm2UJZK0newP0Y5GEV9yHab0ATORrcGaVHt8cw=;
        b=SzG2sJKAPBsHrUAwVW7mp6ie6wizGZsmd0hYmiE3V4l/k3sULATCk6aaVlSn1P38Xc
         z3N+pRV1GJeKsEDhngAzpbWhb1aOwb8fvATmFH0INrrILZfGGAFG9et52SFZsFnUgDhk
         K2bahT31L4OJ4S/ptLA5u/skoi8ngUnF/cdJeu5hETEV2lsm8seSTbUZ8z9G2nKDEA/3
         VgaaFlYA4holZuicVwx2DCBuuJesjdI52hjMDwNQXG3P1QGCsHrsnICBr8vuSWCbw+ig
         N/Bwowa0iLWFdExIGe34wz9czOImnLH185KNEhgLkTitTBWLOFGmb6b1K6vykYpfM2DI
         7pMw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWmE0BP4nuB5kqj5vd8JFTAe2an0olrHCxeUAm+ZM5YwBeWWWnu
	4OihdD3CE5skJyoV1zSqW3dI/f1AuW/e0HPRWG6u1uciInbwqCDFKGFqefOoA1eZIvqYusnQFUf
	tIbW/qvZFCON8MkzFUJnKLzDvaVCah9ff05GsM5MO+rgg+hgEwJ57z+5gb0YWDt8=
X-Received: by 2002:a17:906:b301:: with SMTP id n1mr15928774ejz.246.1562681423561;
        Tue, 09 Jul 2019 07:10:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqu35xSjWwuUBfvtcuOvUtYtubXGaeQv4MSi4o5EaaqbZ0DZ/2g9ZCeHsr++zLkzqwAFLb
X-Received: by 2002:a17:906:b301:: with SMTP id n1mr15928646ejz.246.1562681422192;
        Tue, 09 Jul 2019 07:10:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562681422; cv=none;
        d=google.com; s=arc-20160816;
        b=O+ejduBJ9xMqLwKG3BeMocjn2TY7XOtk3s5rNk7Cm7aJwhQ5NeJ3HIrZlQ28Wcb9xc
         lgjIKLutGQi8ERtaBmcBXmZ2Gf81d+y7ZHmVM7eDpHGY8m3qIX8urNya1Sg/F0g+rafE
         CRgoUxSmZh78Q/YvhU2q5e9tP3vttOyVVc9p/BvTKgBkr0WKhe2lJ1HNkph76q6YjcoZ
         qivgA+/W+vc/1YtJchcsMXqCtzBC55FBKNlNnqQQZ0dF219NdUIFh7LtMZsiQBqyb+9L
         t+EM6/yZVUDPSqz73ngR7n7hLqfBxj7fwy96NwtEM/HMJ9o/kf7QU5PTS0biu2mp0BED
         X7ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w0ha5sm2UJZK0newP0Y5GEV9yHab0ATORrcGaVHt8cw=;
        b=bUfIzEhsxekJq3B1JxV3tLo9tBoAToYnz3tBzi94d9IgoByMojcDmkx0zOU8g6GiJ4
         hVAkaRIW9ZYb78eLFreEhugPVeuHlXOxgZRTHq7GbVlYn7AbrFu4aRB7LI/NfsNFVp/F
         Vksv36fbeXVlq7A33pGZ/kHBlg3ub1t3ytjzavSZwFyze+nFGaO+ptqmGWFZTD+Ul98X
         +FljneoDI3p6Siwl/9MkNhO7HqMv1kv/Lzm6jOFlDMKmHH6XfwAAL2f5eRT3oRNIq+aL
         i/7pMyUFP+Ih9mLhVtXpW/MEJNCIR1mwEioN1wiXc678F08lp+ON8BE3BhFaogglFzAk
         0jJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c37si15604735edb.308.2019.07.09.07.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 07:10:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 305F6AB8C;
	Tue,  9 Jul 2019 14:10:21 +0000 (UTC)
Date: Tue, 9 Jul 2019 16:10:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 5/5] mm: factor out pmd young/dirty bit handling and
 THP split
Message-ID: <20190709141019.GN26380@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-6-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627115405.255259-6-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 20:54:05, Minchan Kim wrote:
> Now, there are common part among MADV_COLD|PAGEOUT|FREE to reset
> access/dirty bit resetting or split the THP page to handle part
> of subpages in the THP page. This patch factor out the common part.

While this reduces the code duplication to some degree I suspect it only
goes half way. I haven't tried that myself due to lack of time but I
believe this has a potential to reduce even more. All those madvise
calls are doing the same thing essentially. What page tables and apply
an operation on ptes and/or a page that is mapped. And that suggests
that the specific operation should be good with defining two - pte and
page operations on each entry. All the rest should be a common code.

That being said, I do not feel strongly about this patch. The rest of
the series should be good enough even without it and I wouldn't delay it
just by discussing a potential of the cleanup.

> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/huge_mm.h |   3 -
>  mm/huge_memory.c        |  74 -------------
>  mm/madvise.c            | 234 +++++++++++++++++++++++-----------------
>  3 files changed, 135 insertions(+), 176 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 7cd5c150c21d..2667e1aa3ce5 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -29,9 +29,6 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  					  unsigned long addr,
>  					  pmd_t *pmd,
>  					  unsigned int flags);
> -extern bool madvise_free_huge_pmd(struct mmu_gather *tlb,
> -			struct vm_area_struct *vma,
> -			pmd_t *pmd, unsigned long addr, unsigned long next);
>  extern int zap_huge_pmd(struct mmu_gather *tlb,
>  			struct vm_area_struct *vma,
>  			pmd_t *pmd, unsigned long addr);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 93f531b63a45..e4b9a06788f3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1671,80 +1671,6 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
>  	return 0;
>  }
>  
> -/*
> - * Return true if we do MADV_FREE successfully on entire pmd page.
> - * Otherwise, return false.
> - */
> -bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> -		pmd_t *pmd, unsigned long addr, unsigned long next)
> -{
> -	spinlock_t *ptl;
> -	pmd_t orig_pmd;
> -	struct page *page;
> -	struct mm_struct *mm = tlb->mm;
> -	bool ret = false;
> -
> -	tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
> -
> -	ptl = pmd_trans_huge_lock(pmd, vma);
> -	if (!ptl)
> -		goto out_unlocked;
> -
> -	orig_pmd = *pmd;
> -	if (is_huge_zero_pmd(orig_pmd))
> -		goto out;
> -
> -	if (unlikely(!pmd_present(orig_pmd))) {
> -		VM_BUG_ON(thp_migration_supported() &&
> -				  !is_pmd_migration_entry(orig_pmd));
> -		goto out;
> -	}
> -
> -	page = pmd_page(orig_pmd);
> -	/*
> -	 * If other processes are mapping this page, we couldn't discard
> -	 * the page unless they all do MADV_FREE so let's skip the page.
> -	 */
> -	if (page_mapcount(page) != 1)
> -		goto out;
> -
> -	if (!trylock_page(page))
> -		goto out;
> -
> -	/*
> -	 * If user want to discard part-pages of THP, split it so MADV_FREE
> -	 * will deactivate only them.
> -	 */
> -	if (next - addr != HPAGE_PMD_SIZE) {
> -		get_page(page);
> -		spin_unlock(ptl);
> -		split_huge_page(page);
> -		unlock_page(page);
> -		put_page(page);
> -		goto out_unlocked;
> -	}
> -
> -	if (PageDirty(page))
> -		ClearPageDirty(page);
> -	unlock_page(page);
> -
> -	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> -		pmdp_invalidate(vma, addr, pmd);
> -		orig_pmd = pmd_mkold(orig_pmd);
> -		orig_pmd = pmd_mkclean(orig_pmd);
> -
> -		set_pmd_at(mm, addr, pmd, orig_pmd);
> -		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> -	}
> -
> -	mark_page_lazyfree(page);
> -	ret = true;
> -out:
> -	spin_unlock(ptl);
> -out_unlocked:
> -	return ret;
> -}
> -
>  static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
>  {
>  	pgtable_t pgtable;
> diff --git a/mm/madvise.c b/mm/madvise.c
> index ee210473f639..13b06dc8d402 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -310,6 +310,91 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> +enum madv_pmdp_reset_t {
> +	MADV_PMDP_RESET,	/* pmd was reset successfully */
> +	MADV_PMDP_SPLIT,	/* pmd was split */
> +	MADV_PMDP_ERROR,
> +};
> +
> +static enum madv_pmdp_reset_t madvise_pmdp_reset_or_split(struct mm_walk *walk,
> +				pmd_t *pmd, spinlock_t *ptl,
> +				unsigned long addr, unsigned long end,
> +				bool young, bool dirty)
> +{
> +	pmd_t orig_pmd;
> +	unsigned long next;
> +	struct page *page;
> +	struct mmu_gather *tlb = walk->private;
> +	struct mm_struct *mm = walk->mm;
> +	struct vm_area_struct *vma = walk->vma;
> +	bool reset_young = false;
> +	bool reset_dirty = false;
> +	enum madv_pmdp_reset_t ret = MADV_PMDP_ERROR;
> +
> +	orig_pmd = *pmd;
> +	if (is_huge_zero_pmd(orig_pmd))
> +		return ret;
> +
> +	if (unlikely(!pmd_present(orig_pmd))) {
> +		VM_BUG_ON(thp_migration_supported() &&
> +				!is_pmd_migration_entry(orig_pmd));
> +		return ret;
> +	}
> +
> +	next = pmd_addr_end(addr, end);
> +	page = pmd_page(orig_pmd);
> +	if (next - addr != HPAGE_PMD_SIZE) {
> +		/*
> +		 * THP collapsing is not cheap so only split the page is
> +		 * private to the this process.
> +		 */
> +		if (page_mapcount(page) != 1)
> +			return ret;
> +		get_page(page);
> +		spin_unlock(ptl);
> +		lock_page(page);
> +		if (!split_huge_page(page))
> +			ret = MADV_PMDP_SPLIT;
> +		unlock_page(page);
> +		put_page(page);
> +		return ret;
> +	}
> +
> +	if (young && pmd_young(orig_pmd))
> +		reset_young = true;
> +	if (dirty && pmd_dirty(orig_pmd))
> +		reset_dirty = true;
> +
> +	/*
> +	 * Other process could rely on the PG_dirty for data consistency,
> +	 * not pte_dirty so we could reset PG_dirty only when we are owner
> +	 * of the page.
> +	 */
> +	if (reset_dirty) {
> +		if (page_mapcount(page) != 1)
> +			goto out;
> +		if (!trylock_page(page))
> +			goto out;
> +		if (PageDirty(page))
> +			ClearPageDirty(page);
> +		unlock_page(page);
> +	}
> +
> +	ret = MADV_PMDP_RESET;
> +	if (reset_young || reset_dirty) {
> +		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
> +		pmdp_invalidate(vma, addr, pmd);
> +		if (reset_young)
> +			orig_pmd = pmd_mkold(orig_pmd);
> +		if (reset_dirty)
> +			orig_pmd = pmd_mkclean(orig_pmd);
> +		set_pmd_at(mm, addr, pmd, orig_pmd);
> +		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> +	}
> +out:
> +	return ret;
> +}
> +
>  static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  				unsigned long end, struct mm_walk *walk)
>  {
> @@ -319,64 +404,31 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  	pte_t *orig_pte, *pte, ptent;
>  	spinlock_t *ptl;
>  	struct page *page;
> -	unsigned long next;
>  
> -	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> -		pmd_t orig_pmd;
> -
> -		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
>  		ptl = pmd_trans_huge_lock(pmd, vma);
>  		if (!ptl)
>  			return 0;
>  
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
> -
> -			get_page(page);
> +		switch (madvise_pmdp_reset_or_split(walk, pmd, ptl, addr, end,
> +							true, false)) {
> +		case MADV_PMDP_RESET:
>  			spin_unlock(ptl);
> -			lock_page(page);
> -			err = split_huge_page(page);
> -			unlock_page(page);
> -			put_page(page);
> -			if (!err)
> -				goto regular_page;
> -			return 0;
> -		}
> -
> -		if (pmd_young(orig_pmd)) {
> -			pmdp_invalidate(vma, addr, pmd);
> -			orig_pmd = pmd_mkold(orig_pmd);
> -
> -			set_pmd_at(mm, addr, pmd, orig_pmd);
> -			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> +			page = pmd_page(*pmd);
> +			test_and_clear_page_young(page);
> +			deactivate_page(page);
> +			goto next;
> +		case MADV_PMDP_ERROR:
> +			spin_unlock(ptl);
> +			goto next;
> +		case MADV_PMDP_SPLIT:
> +			; /* go through */
>  		}
> -
> -		test_and_clear_page_young(page);
> -		deactivate_page(page);
> -huge_unlock:
> -		spin_unlock(ptl);
> -		return 0;
>  	}
>  
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
>  
> -regular_page:
>  	tlb_change_page_size(tlb, PAGE_SIZE);
>  	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	flush_tlb_batched_pending(mm);
> @@ -443,6 +495,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  	arch_enter_lazy_mmu_mode();
>  	pte_unmap_unlock(orig_pte, ptl);
> +next:
>  	cond_resched();
>  
>  	return 0;
> @@ -493,70 +546,38 @@ static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
>  	LIST_HEAD(page_list);
>  	struct page *page;
>  	int isolated = 0;
> -	unsigned long next;
>  
>  	if (fatal_signal_pending(current))
>  		return -EINTR;
>  
> -	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> -		pmd_t orig_pmd;
> -
> -		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
>  		ptl = pmd_trans_huge_lock(pmd, vma);
>  		if (!ptl)
>  			return 0;
>  
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
> +		switch (madvise_pmdp_reset_or_split(walk, pmd, ptl, addr, end,
> +							true, false)) {
> +		case MADV_PMDP_RESET:
> +			page = pmd_page(*pmd);
>  			spin_unlock(ptl);
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
> +			if (isolate_lru_page(page))
> +				return 0;
> +			ClearPageReferenced(page);
> +			test_and_clear_page_young(page);
> +			list_add(&page->lru, &page_list);
> +			reclaim_pages(&page_list);
> +			goto next;
> +		case MADV_PMDP_ERROR:
> +			spin_unlock(ptl);
> +			goto next;
> +		case MADV_PMDP_SPLIT:
> +			; /* go through */
>  		}
> -
> -		ClearPageReferenced(page);
> -		test_and_clear_page_young(page);
> -		list_add(&page->lru, &page_list);
> -huge_unlock:
> -		spin_unlock(ptl);
> -		reclaim_pages(&page_list);
> -		return 0;
>  	}
>  
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
> -regular_page:
> +
>  	tlb_change_page_size(tlb, PAGE_SIZE);
>  	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	flush_tlb_batched_pending(mm);
> @@ -631,6 +652,7 @@ static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(orig_pte, ptl);
>  	reclaim_pages(&page_list);
> +next:
>  	cond_resched();
>  
>  	return 0;
> @@ -700,12 +722,26 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	pte_t *orig_pte, *pte, ptent;
>  	struct page *page;
>  	int nr_swap = 0;
> -	unsigned long next;
>  
> -	next = pmd_addr_end(addr, end);
> -	if (pmd_trans_huge(*pmd))
> -		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
> +	if (pmd_trans_huge(*pmd)) {
> +		ptl = pmd_trans_huge_lock(pmd, vma);
> +		if (!ptl)
> +			return 0;
> +
> +		switch (madvise_pmdp_reset_or_split(walk, pmd, ptl, addr, end,
> +							true, true)) {
> +		case MADV_PMDP_RESET:
> +			page = pmd_page(*pmd);
> +			spin_unlock(ptl);
> +			mark_page_lazyfree(page);
>  			goto next;
> +		case MADV_PMDP_ERROR:
> +			spin_unlock(ptl);
> +			goto next;
> +		case MADV_PMDP_SPLIT:
> +			; /* go through */
> +		}
> +	}
>  
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
> @@ -817,8 +853,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	}
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(orig_pte, ptl);
> -	cond_resched();
>  next:
> +	cond_resched();
>  	return 0;
>  }
>  
> -- 
> 2.22.0.410.gd8fdbe21b5-goog

-- 
Michal Hocko
SUSE Labs

