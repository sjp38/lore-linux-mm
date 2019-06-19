Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6246C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:56:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66086214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:56:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66086214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27326B0003; Wed, 19 Jun 2019 08:56:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB13A8E0002; Wed, 19 Jun 2019 08:56:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D52058E0001; Wed, 19 Jun 2019 08:56:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81E106B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:56:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so26019622edp.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:56:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8om5Q9BL7tqW0w4aGZsSxpfoaa9D/ddDtXIlDfmm+rw=;
        b=LbffMXYHUYNsHaivrnhhSjMufeBhcFHYa/SOPY35MHgSWwGEbq7R/aAnZsAkzzMGBr
         6GOaaE5y/JdXh6Zbnrlr4Z0nqjTyiW5B/3/Q75nVjW7zGtIHnSMH/cNbsFHbVf+7abdV
         woAegvW/D80hCLCyPeu4KZITj4yq+yvsvZgI0PbaOG/LTIMgClxILmg/3aOvmFufVRGy
         Wc233fbeOh/fwLJFQeVu1JMkX+3H5KTVi0v5UCZyWF8ocG3x9UEgXC+o8aL3PH7N5V1F
         mt62jkYCnBqfkumpUpuafmXQP87PABORNCuX4UH2CpujgCIwigXEK1AbHMdBgEj4541V
         6m9A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWtOWBPURz0WWhW5NjjUMSh0prOtqVVADA/LS4aAocs07mwsZXF
	QDDUN7X12tlGGVjWPizS5XD8J4GREjkB2qLbx7MXdRWUVU3cwmD+NnFCrulYT8k/TDvh/nasb9B
	SNNyLWdvIg3cMh8wb/NEh0ymEgQu6QXI+3+DIs7nDCo5yOIDzqx8BNEIk0cpHJw4=
X-Received: by 2002:a50:9846:: with SMTP id h6mr76641453edb.263.1560948975052;
        Wed, 19 Jun 2019 05:56:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhsjPFOkmvAMKgT9a2CUbneki9HZr76OzDfM0tgIBdPj29v3ClN9YnnQiDboCoz5XfA21w
X-Received: by 2002:a50:9846:: with SMTP id h6mr76641401edb.263.1560948974212;
        Wed, 19 Jun 2019 05:56:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560948974; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGNZHffIBIrebV6j1EbHH8LTivWWkIkpen+/QNKBMhXShwCmhGtvx6chrcR9skBwNA
         ey4lM639q7bQqSSu7bPvU7xivfmppENyOS7z3h0SyHrBDl0a95TLdPtftiCsiwgYDxpw
         5LkIlWZL8wh0VsTDR5SUSU6dQOtkuwLx9YrNcwNhX+35zZTKduEIE9Hlzq1bI753JqvS
         pXWR5AxBidFtZRSAmmfwfUATlDSpv7zViwdSz8V2tT5OZnDXUW06tQ4ObiGEYhcjeHzl
         2JO0FNVivJpAHNb8wjFoIKsjfEhG+9kin+oHmqvEWtp+QCBgY9A+EzkaA+sn6gD5+o/J
         KvAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8om5Q9BL7tqW0w4aGZsSxpfoaa9D/ddDtXIlDfmm+rw=;
        b=nXovYNuywB3kkjpeGzFZncIpt1JF6PmqqBeCkrssXqVRrSSc+z2wKDaP8WAyCu4CZo
         kFeQM138NGsC5/ngTgCzsMRzFKVDLeEkmkaO58Fwv4YnrZUMjrlwrDIVp41MLp1CitAH
         yXtISPsI3gWL54CPdprHTdtkSawg2nL96+VJSm0QxVvH+4hbeVrSFGrrcwJQIxbNDEPT
         HvPcu5O4lGLP8CAEOVSZzBg3TxAv3oFFks13eT1YnyxFOcwu+zww3Ccju1RkvyCy+VQi
         ICI/aQPUz6m9VG0q0aHyMemadU4EISFcG14DR/O6JwJiEF7ZFSkWG5jRK15ncvwkUaYQ
         Flpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x2si10752191eji.246.2019.06.19.05.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 05:56:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78E24AFE9;
	Wed, 19 Jun 2019 12:56:13 +0000 (UTC)
Date: Wed, 19 Jun 2019 14:56:12 +0200
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
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 1/5] mm: introduce MADV_COLD
Message-ID: <20190619125611.GO2968@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-2-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610111252.239156-2-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 20:12:48, Minchan Kim wrote:
> When a process expects no accesses to a certain memory range, it could
> give a hint to kernel that the pages can be reclaimed when memory pressure
> happens but data should be preserved for future use.  This could reduce
> workingset eviction so it ends up increasing performance.
> 
> This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> MADV_COLD can be used by a process to mark a memory range as not expected
> to be used in the near future. The hint can help kernel in deciding which
> pages to evict early during memory pressure.
> 
> It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> 
> 	active file page -> inactive file LRU
> 	active anon page -> inacdtive anon LRU
> 
> Unlike MADV_FREE, it doesn't move active anonymous pages to inactive
> file LRU's head because MADV_COLD is a little bit different symantic.
> MADV_FREE means it's okay to discard when the memory pressure because
> the content of the page is *garbage* so freeing such pages is almost zero
> overhead since we don't need to swap out and access afterward causes just
> minor fault. Thus, it would make sense to put those freeable pages in
> inactive file LRU to compete other used-once pages. It makes sense for
> implmentaion point of view, too because it's not swapbacked memory any
> longer until it would be re-dirtied. Even, it could give a bonus to make
> them be reclaimed on swapless system. However, MADV_COLD doesn't mean
> garbage so reclaiming them requires swap-out/in in the end so it's bigger
> cost. Since we have designed VM LRU aging based on cost-model, anonymous
> cold pages would be better to position inactive anon's LRU list, not file
> LRU. Furthermore, it would help to avoid unnecessary scanning if system
> doesn't have a swap device. Let's start simpler way without adding
> complexity at this moment.

I would only add that it is a caveat that workloads with a lot of page
cache are likely to ignore MADV_COLD on anonymous memory because we
rarely age anonymous LRU lists.

[...]
> +static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +{

This is duplicating a large part of madvise_free_pte_range with some
subtle differences which are not explained anywhere (e.g. why does
madvise_free_huge_pmd need try_lock on a page while not here? etc.).

Why cannot we reuse a large part of that code and differ essentially on
the reclaim target check and action? Have you considered to consolidate
the code to share as much as possible? Maybe that is easier said than
done because the devil is always in details...

I would definitely feel much more comfortable to review the code without
thinking about all those subtle details that have been already solved
before. Especially all the THP ones.

Other than that the patch looks sane to me.

> +	struct mmu_gather *tlb = walk->private;
> +	struct mm_struct *mm = tlb->mm;
> +	struct vm_area_struct *vma = walk->vma;
> +	pte_t *orig_pte, *pte, ptent;
> +	spinlock_t *ptl;
> +	struct page *page;
> +	unsigned long next;
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
> +
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
> +		if (pmd_young(orig_pmd)) {
> +			pmdp_invalidate(vma, addr, pmd);
> +			orig_pmd = pmd_mkold(orig_pmd);
> +
> +			set_pmd_at(mm, addr, pmd, orig_pmd);
> +			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> +		}
> +
> +		test_and_clear_page_young(page);
> +		deactivate_page(page);
> +huge_unlock:
> +		spin_unlock(ptl);
> +		return 0;
> +	}
> +
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +regular_page:
> +	tlb_change_page_size(tlb, PAGE_SIZE);
> +	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	flush_tlb_batched_pending(mm);
> +	arch_enter_lazy_mmu_mode();
> +	for (; addr < end; pte++, addr += PAGE_SIZE) {
> +		ptent = *pte;
> +
> +		if (pte_none(ptent))
> +			continue;
> +
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, ptent);
> +		if (!page)
> +			continue;
> +
> +		if (pte_young(ptent)) {
> +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> +							tlb->fullmm);
> +			ptent = pte_mkold(ptent);
> +			set_pte_at(mm, addr, pte, ptent);
> +			tlb_remove_tlb_entry(tlb, pte, addr);
> +		}
> +
> +		/*
> +		 * We are deactivating a page for accelerating reclaiming.
> +		 * VM couldn't reclaim the page unless we clear PG_young.
> +		 * As a side effect, it makes confuse idle-page tracking
> +		 * because they will miss recent referenced history.
> +		 */
> +		test_and_clear_page_young(page);
> +		deactivate_page(page);
> +	}
> +
> +	arch_enter_lazy_mmu_mode();
> +	pte_unmap_unlock(orig_pte, ptl);
> +	cond_resched();
> +
> +	return 0;
> +}
-- 
Michal Hocko
SUSE Labs

