Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 055A4C742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 18:42:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFE12216C8
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 18:42:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="LczJZj1L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFE12216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F7738E00F4; Thu, 11 Jul 2019 14:42:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A6898E00DB; Thu, 11 Jul 2019 14:42:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16F588E00F4; Thu, 11 Jul 2019 14:42:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D44F18E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 14:42:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so3949439pfj.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:42:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ye/ueaLSHeuUbF2UmwC3qi+L8ppesjqbY1zG1QqAhZE=;
        b=mr+GWVygBrQBamPHK5UtobyvlQj0D95KjPl49bWWcQFSMrtGxZ4hXTjOmOVvjkejeb
         3Pm1btQNvVahPPsWaf/NtCoKmJuwMqvbqIzO02NE3ZcqYDfJPdmBVJaDOFMBL3OjatXp
         XdPAiaNUCChtVnsia47usQ8B/3l5oQymSTNO7oCsDQmAi7up1uBWcSEV/Fsegrn/UN/X
         nJIlqaWIvOolZxGmMERHukBP0Dnj3gxsQiZbAxR9fLHVzOi18bI6UguyRw1xP/nO83OR
         lPfEknSB+/B37cSPgBknHQ4ulXnuSZGXG0zwhIkJOCylpEugkfNQ0L29oGC19dvDUWHU
         782w==
X-Gm-Message-State: APjAAAVFL24ECwvfYAt7fNzBbQVrTNY3Zsh5S5rE6o5cHB3rWk1oOD6Z
	aTHI3Izcq/OkFMGJQo29GjPO3xCi8h/22p4oL0PeZFk4AV6LSXD8fY7EopZN+nwrp9gFhPyxWiP
	PEnwX7X3BtjTwy+PjQtMDuhyuajOzyw26/I7022P+OLYq1rSWMF3Uy68Y8Nu0gx+X+Q==
X-Received: by 2002:a63:9245:: with SMTP id s5mr6024181pgn.123.1562870548151;
        Thu, 11 Jul 2019 11:42:28 -0700 (PDT)
X-Received: by 2002:a63:9245:: with SMTP id s5mr6024110pgn.123.1562870547279;
        Thu, 11 Jul 2019 11:42:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562870547; cv=none;
        d=google.com; s=arc-20160816;
        b=0wSImp9rm6umrVxf/yNCK/cCdlGhov1yaLr9zraO/EtHcujSxrccK6x5HnshNNpuoQ
         1Zb1xjwnw8o00My0R65E9YD5Yo7l9rzKg8VmHTLmY2Qg2DUUgZbtVb/fJvVjlGvNbk1A
         ZNvvYI6cf+zzKrmZbANHKfLx7S6dtFYwv4J7C4tQQ/5JHJ7t8HeciOX3H9Z8BLmEnxMZ
         3FPCsHUTJaLZS+KNVRlKDqw0gr8IqgkBhNIZDstQLtQXQPWY8rg9IjoUmWiuYSiej6Us
         vL64Zin+mGYU3X2zvX6BtAXDclTo3h0zEhk5HCr/YA2GIsrINRbc7gLC/gOSIOtQvY1N
         U7bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ye/ueaLSHeuUbF2UmwC3qi+L8ppesjqbY1zG1QqAhZE=;
        b=VawTrE3uPm9VxaUd7m47/FjNRi7GmgFDFyLc6gVM78hApXm0+X7PSaYxfGKHuVQDfK
         7nULGlecihpa98kjMiXSCP6XqybTOme+mCKR6EWGtRJOpbwh0iAroECK/zeZ3cFTsoon
         2uXlsB8eva6dzl/JvdZH2H1W49bceBWiqWvwyswl2KerBy8EXG5gRgEpNZ8lMSLicnX7
         t3QBKZrhOE6ituBYboLIqpQmWjUwf5dXJ1B7eawhuKfi5ACxc9aJxxaw0jOHYwCSF6Ha
         OCrGP5phndvd9OyaRoh+VmWRPTLY7Whlkp4XPf7JY4Gxl5XU4Nx9Dd/H3sK/Rt/FYu5f
         Zi5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=LczJZj1L;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor7937142plz.40.2019.07.11.11.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 11:42:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=LczJZj1L;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ye/ueaLSHeuUbF2UmwC3qi+L8ppesjqbY1zG1QqAhZE=;
        b=LczJZj1LMI38wtffmfcB6+DCfMF5aokwVwquBj7rOFWJQgRco8bf3jn7Y7DRGU5AKV
         eyjU2kDty+AJg5gmH7znkDUWdSkh2RLvTYYxEUHfUOHIABMuT/zxz26VO2fWPMLpbI42
         Q0nKfVbhqRFEaZHRqg01t1RLn3rSDiadjybENTkR+xzCP5NkdrHC11Iih4QtXXJJEJ+2
         wAnVn52naxG/hzDpgjqUVpVG8nvWNFb9Nm9+54eKFTwbHQZW+h21HGKmNMQL9ThFb9Vb
         wu6ijN+pWhsut8bcnEO8hAL8JYSaTWFrXUY1xJwZBT5S2jLMFydUdVKuRZGN4kxI/tkg
         glJw==
X-Google-Smtp-Source: APXvYqyaXVTrExLmUq7EZsqLnA7MmMx/jzEwrsO/Wn15ERbU1WlzrYFkuyZ9jcRvlFh1JKkaVAl1hw==
X-Received: by 2002:a17:902:aa88:: with SMTP id d8mr5969327plr.274.1562870546389;
        Thu, 11 Jul 2019 11:42:26 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5385])
        by smtp.gmail.com with ESMTPSA id 85sm6717518pfv.130.2019.07.11.11.42.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 11:42:25 -0700 (PDT)
Date: Thu, 11 Jul 2019 14:42:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 4/4] mm: introduce MADV_PAGEOUT
Message-ID: <20190711184223.GD20341@cmpxchg.org>
References: <20190711012528.176050-1-minchan@kernel.org>
 <20190711012528.176050-5-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711012528.176050-5-minchan@kernel.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 10:25:28AM +0900, Minchan Kim wrote:
> @@ -480,6 +482,198 @@ static long madvise_cold(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +{
> +	struct mmu_gather *tlb = walk->private;
> +	struct mm_struct *mm = tlb->mm;
> +	struct vm_area_struct *vma = walk->vma;
> +	pte_t *orig_pte, *pte, ptent;
> +	spinlock_t *ptl;
> +	LIST_HEAD(page_list);
> +	struct page *page;
> +	unsigned long next;
> +
> +	if (fatal_signal_pending(current))
> +		return -EINTR;
> +
> +	next = pmd_addr_end(addr, end);
> +	if (pmd_trans_huge(*pmd)) {
> +		pmd_t orig_pmd;
> +
> +		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
> +		ptl = pmd_trans_huge_lock(pmd, vma);
> +		if (!ptl)
> +			return 0;
> +
> +		orig_pmd = *pmd;
> +		if (is_huge_zero_pmd(orig_pmd))
> +			goto huge_unlock;
> +
> +		if (unlikely(!pmd_present(orig_pmd))) {
> +			VM_BUG_ON(thp_migration_supported() &&
> +					!is_pmd_migration_entry(orig_pmd));
> +			goto huge_unlock;
> +		}
> +
> +		page = pmd_page(orig_pmd);
> +		if (next - addr != HPAGE_PMD_SIZE) {
> +			int err;
> +
> +			if (page_mapcount(page) != 1)
> +				goto huge_unlock;
> +			get_page(page);
> +			spin_unlock(ptl);
> +			lock_page(page);
> +			err = split_huge_page(page);
> +			unlock_page(page);
> +			put_page(page);
> +			if (!err)
> +				goto regular_page;
> +			return 0;
> +		}
> +
> +		if (isolate_lru_page(page))
> +			goto huge_unlock;
> +
> +		if (pmd_young(orig_pmd)) {
> +			pmdp_invalidate(vma, addr, pmd);
> +			orig_pmd = pmd_mkold(orig_pmd);
> +
> +			set_pmd_at(mm, addr, pmd, orig_pmd);
> +			tlb_remove_tlb_entry(tlb, pmd, addr);
> +		}
> +
> +		ClearPageReferenced(page);
> +		test_and_clear_page_young(page);
> +		list_add(&page->lru, &page_list);
> +huge_unlock:
> +		spin_unlock(ptl);
> +		reclaim_pages(&page_list);
> +		return 0;
> +	}
> +
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +regular_page:
> +	tlb_change_page_size(tlb, PAGE_SIZE);
> +	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	flush_tlb_batched_pending(mm);
> +	arch_enter_lazy_mmu_mode();
> +	for (; addr < end; pte++, addr += PAGE_SIZE) {
> +		ptent = *pte;
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, ptent);
> +		if (!page)
> +			continue;
> +
> +		/*
> +		 * creating a THP page is expensive so split it only if we
> +		 * are sure it's worth. Split it if we are only owner.
> +		 */
> +		if (PageTransCompound(page)) {
> +			if (page_mapcount(page) != 1)
> +				break;
> +			get_page(page);
> +			if (!trylock_page(page)) {
> +				put_page(page);
> +				break;
> +			}
> +			pte_unmap_unlock(orig_pte, ptl);
> +			if (split_huge_page(page)) {
> +				unlock_page(page);
> +				put_page(page);
> +				pte_offset_map_lock(mm, pmd, addr, &ptl);
> +				break;
> +			}
> +			unlock_page(page);
> +			put_page(page);
> +			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +			pte--;
> +			addr -= PAGE_SIZE;
> +			continue;
> +		}
> +
> +		VM_BUG_ON_PAGE(PageTransCompound(page), page);
> +
> +		if (isolate_lru_page(page))
> +			continue;
> +
> +		if (pte_young(ptent)) {
> +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> +							tlb->fullmm);
> +			ptent = pte_mkold(ptent);
> +			set_pte_at(mm, addr, pte, ptent);
> +			tlb_remove_tlb_entry(tlb, pte, addr);
> +		}
> +		ClearPageReferenced(page);
> +		test_and_clear_page_young(page);
> +		list_add(&page->lru, &page_list);
> +	}
> +
> +	arch_leave_lazy_mmu_mode();
> +	pte_unmap_unlock(orig_pte, ptl);
> +	reclaim_pages(&page_list);
> +	cond_resched();
> +
> +	return 0;
> +}

I know you have briefly talked about code sharing already.

While I agree that sharing with MADV_FREE is maybe a stretch, I
applied these patches and compared the pageout and the cold page table
functions, and they are line for line the same EXCEPT for 2-3 lines at
the very end, where one reclaims and the other deactivates. It would
be good to share here, it shouldn't be hard or result in fragile code.

Something like int madvise_cold_or_pageout_range(..., bool pageout)?

