Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F3F8C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:58:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBE3B2070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:58:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D/+9pqXk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBE3B2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D4966B026E; Tue, 28 May 2019 06:58:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85DFE6B026F; Tue, 28 May 2019 06:58:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D8766B0273; Tue, 28 May 2019 06:58:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36E686B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 06:58:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h7so15435692pfq.22
        for <linux-mm@kvack.org>; Tue, 28 May 2019 03:58:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fuHKQ9T5TF7CoHiaUBHdgwZ4clmbQ6BLbnAB0WfINcA=;
        b=U+yslH82EECI5r3ZV2hGRLvzpTwJ48yFmj45YrOKD9Gn29tgulxL2iI67gBVUAU4Fl
         +QnDWRsQOLO3Lj3j19j4VCu8r4GMGK50tZLhGdvje3ZUHil80VRSVEDUP+egZAnLffTe
         FcuPvImfRhyR+DrWJW7HaFx5eGYzOXrDWcZNpQWsM3nZhIElFKiS3OtPfofaq9n0N3mg
         EZaRlTSPb72DQEl57vejIgH5pahZ1V25wZ2n3CWBjcCyQihwprYT3/GOfdjSa8PBe4pF
         kOQdUqetGBZVjZf9h0tiWpIAzd+oqcZJ+PJORmeaGmToLokISfcU14qlAdNhBQJeKMtO
         h3AA==
X-Gm-Message-State: APjAAAUW97EUZHfMDsk0XdvkLL8jQ9EMnhoVo2U5mHBybomc8vw6N+4L
	HuXgyZVzJsPV1RDBkKQf5ZCB8KHz4CWMcf6ZiYy1Iry0kOkJk2mClSITbZFTPY722nSQlmS11m9
	Wu3WBa7LTRKpUCnVi5DmmdgWDr382O/nhfbimzzUAinXvDcXD/5GOalWsZ9vGaGI=
X-Received: by 2002:a62:5486:: with SMTP id i128mr47381976pfb.156.1559041094613;
        Tue, 28 May 2019 03:58:14 -0700 (PDT)
X-Received: by 2002:a62:5486:: with SMTP id i128mr47381901pfb.156.1559041093779;
        Tue, 28 May 2019 03:58:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559041093; cv=none;
        d=google.com; s=arc-20160816;
        b=X4wua8aBzJGh+3mS+GCVksAC4msTtbmZ72V227Xjm4tSQ3Dy33IET42SGuQPJbV4Ab
         vUlIewkfMPGpRGWyhRU8LVn+wwjFNu3RVAAUwGgs5dWV0+IVRfVWRIMaNLwSmsn9ylqb
         CZxIsbFP4581G4IBOfyoSF0i0IOrBGG71o//gaGmZofoW/Fu3+w1jwHIzsjRXUm0gHr2
         XWKfCgZV2PcV1+Tj/PT2gn9+QL8sRV1V432pCK6vrpFNMQI3QGecCGum9dc6hss0GCBP
         F5lVlcwZlvBi+0nhztfLxuzI5+ZoDsJIxGaTw6nP1LjMoFl8TP01eMV9PYM7qYO4bYAm
         6Heg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=fuHKQ9T5TF7CoHiaUBHdgwZ4clmbQ6BLbnAB0WfINcA=;
        b=oi+Aes88pMUq/6hsZoBjsUpSSRje6ia1DfrZ6nfk+hpdozj//V933je/Y40ylqbzEJ
         u77QbYyB0YeqidldzGSvg6eP9sf8Dhu9KRAR2FP/Ld70gkftwzW9IwvuP38GfyY5nkpI
         NQtW51SV9vpf4sqvAfIqmRQEW22QyRuNL1Mc0BckCu4Coad8DH1YtiqMFyZmyKuf7VMi
         M9224kkZ+O6u+cp82G1m09/xpjjEkdz8eep8M6g1+TA9ofV9GdeNfj0JE1XMkmjJOO66
         G8khZxHdrnx6e9/byfQsDdOH2+jHUGsy7EMIqcGaXIgU4zErbpjTZNUGqiRofcCVhG9v
         ZXgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="D/+9pqXk";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor2573714pjq.25.2019.05.28.03.58.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 03:58:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="D/+9pqXk";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fuHKQ9T5TF7CoHiaUBHdgwZ4clmbQ6BLbnAB0WfINcA=;
        b=D/+9pqXkGNjYgp2Awn39VAjUAH7/nskqQCjZIjBpGrNsU8NUQHbbB3a20tLDYIOQis
         EYsVHOQJNfzpr7QNHL8qEW4I1j6+C6mWtE/5DUdIRFwR5AG1fcpozoisjP/Dzka6WTQh
         az5zHrFFLHvyzQ6xflrryM9e2KKsSdziQto8Cpa+Xa8Yr+1JnvfXVf9C+xtBwv8yU4zi
         rKTTjYz+66mZLYd6+WIbSquKPKW3W/bTaCcFZyRSYtyi3Ul797P93SKxOd8QahUQ6qFP
         mTZlTff0hvO8tP0yZZ01RUQPH7AHoccYaS8wRbBvC7JRvxku3KdvviQkvlE/aQQC9IDC
         8dYw==
X-Google-Smtp-Source: APXvYqw26N29+Qub8Ub/ZJVZJG7pRxup0UUWkTRau57yBbLnouQ4Lumva5Q60FJpYlJ77RnCCBf5Pg==
X-Received: by 2002:a17:90a:4814:: with SMTP id a20mr5125900pjh.62.1559041093273;
        Tue, 28 May 2019 03:58:13 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id m7sm8311281pff.44.2019.05.28.03.58.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 03:58:11 -0700 (PDT)
Date: Tue, 28 May 2019 19:58:06 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190528105806.GA21060@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-2-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 04:53:01PM +0800, Hillf Danton wrote:
> 
> On Mon, 20 May 2019 12:52:48 +0900 Minchan Kim wrote:
> > +static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> > +{
> > +	pte_t *orig_pte, *pte, ptent;
> > +	spinlock_t *ptl;
> > +	struct page *page;
> > +	struct vm_area_struct *vma = walk->vma;
> > +	unsigned long next;
> > +
> > +	next = pmd_addr_end(addr, end);
> > +	if (pmd_trans_huge(*pmd)) {
> > +		spinlock_t *ptl;
> 
> Seems not needed with another ptl declared above.

Will remove it.

> > +
> > +		ptl = pmd_trans_huge_lock(pmd, vma);
> > +		if (!ptl)
> > +			return 0;
> > +
> > +		if (is_huge_zero_pmd(*pmd))
> > +			goto huge_unlock;
> > +
> > +		page = pmd_page(*pmd);
> > +		if (page_mapcount(page) > 1)
> > +			goto huge_unlock;
> > +
> > +		if (next - addr != HPAGE_PMD_SIZE) {
> > +			int err;
> 
> Alternately, we deactivate thp only if the address range from userspace
> is sane enough, in order to avoid complex works we have to do here.

Not sure it's a good idea. That's the way we have done in MADV_FREE
so want to be consistent.

> > +
> > +			get_page(page);
> > +			spin_unlock(ptl);
> > +			lock_page(page);
> > +			err = split_huge_page(page);
> > +			unlock_page(page);
> > +			put_page(page);
> > +			if (!err)
> > +				goto regular_page;
> > +			return 0;
> > +		}
> > +
> > +		pmdp_test_and_clear_young(vma, addr, pmd);
> > +		deactivate_page(page);
> > +huge_unlock:
> > +		spin_unlock(ptl);
> > +		return 0;
> > +	}
> > +
> > +	if (pmd_trans_unstable(pmd))
> > +		return 0;
> > +
> > +regular_page:
> 
> Take a look at pending signal?

Do you have any reason to see pending signal here? I want to know what's
your requirement so that what's the better place to handle it.

> 
> > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> 
> s/end/next/ ?

Why do you think it should be next?

> > +		ptent = *pte;
> > +
> > +		if (pte_none(ptent))
> > +			continue;
> > +
> > +		if (!pte_present(ptent))
> > +			continue;
> > +
> > +		page = vm_normal_page(vma, addr, ptent);
> > +		if (!page)
> > +			continue;
> > +
> > +		if (page_mapcount(page) > 1)
> > +			continue;
> > +
> > +		ptep_test_and_clear_young(vma, addr, pte);
> > +		deactivate_page(page);
> > +	}
> > +
> > +	pte_unmap_unlock(orig_pte, ptl);
> > +	cond_resched();
> > +
> > +	return 0;
> > +}
> > +
> > +static long madvise_cool(struct vm_area_struct *vma,
> > +			unsigned long start_addr, unsigned long end_addr)
> > +{
> > +	struct mm_struct *mm = vma->vm_mm;
> > +	struct mmu_gather tlb;
> > +
> > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > +		return -EINVAL;
> 
> No service in case of VM_IO?

I don't know VM_IO would have regular LRU pages but just follow normal
convention for DONTNEED and FREE.
Do you have anything in your mind?

