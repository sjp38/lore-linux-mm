Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8412AC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:24:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4965B206E0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:24:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4965B206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA14A6B0003; Wed, 19 Jun 2019 09:24:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C51418E0002; Wed, 19 Jun 2019 09:24:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B406D8E0001; Wed, 19 Jun 2019 09:24:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65C716B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:24:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so26109733edm.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:24:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=b0O3mprRJ3WdZye48HA9IWlDk2nK2hgN1roQFBRqozQ=;
        b=dQD3COtNv4RKmDsAs1OiF3Vun9bJ7INe5vUgKI2jU5Z6oPOmUoh+IRS/YvtomTsEoN
         fpI43PLygshMvqmHb8LCalVmaVy/hdQu1h9r2eV7NDDfV3I+FbZ/+36CjpupCWwly9NF
         wG6n8XrPzxvEaDq2srPBTbxJmcz/TguSlc2DHROMmyL88FlPz1weyPtOBGpdQlZGEI9R
         MHjK6XzZSe2e6yeIPufRKjpoLMNzsVNto3cLCeJMZHSXj+BxDId77MtCp9o8J/fGucIw
         3Z0RYO6XuPUe8kQWjrjKPBZrU3S7dGRFx/+UHJKKtiImsHo2xzBZxPvts+4kofukNwM9
         FcDQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVzDsWn7sq+mOPNCFy9aq6G8pDiATM9kom/ysbodcqPeq/mEFL/
	JHIeWqmazPdGBkmaMuNspJTU+SUilR+PVpibnuyhI/px45FxMUoVMsjadRD/KlgtAa7lbjpogrW
	OaYR85g7s2HmvrMBUlkkw5zOsIHDJEwZzP3HES/6/ASeHjtepKTsxG1eyRMScWlY=
X-Received: by 2002:a50:fb86:: with SMTP id e6mr5920607edq.203.1560950692971;
        Wed, 19 Jun 2019 06:24:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgbXV6sgFfw8l6iYpdd2K5bSipUbyFz1RbT4MD2dFfi2jZOGEgu2xBGUam4dRRYOJZRihj
X-Received: by 2002:a50:fb86:: with SMTP id e6mr5920541edq.203.1560950692305;
        Wed, 19 Jun 2019 06:24:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560950692; cv=none;
        d=google.com; s=arc-20160816;
        b=gezfPri2sRvAy6432cRDdU4JC73cot/JAaGb6K+fukwSoCGPrRIdhS1zd+WiUE1RTC
         5Xib/BnGiRqYZwqvRVMCybX0h+/gTGapwdA0mdiy8nWk8DAhp6TIv2IcKpWaV5/dXBZU
         M2fAosTadMecBel4Eg5eb4AKZM99WrZoHO6+2z6iKKPYnwBSwW5fg7Ase/K+Wl5sShLP
         h/vLIWpUPajavTbNrMGgHI1qDDrRRCBAbJey0PHYCk+5PiIP2nWL8mswQNXXbxfB8jRg
         kmcu32/fnvMAramYbMqJHBsHGzSlsEHlqNPydtJkh+ep+qCY4ukZETR+gfXfF1cTeoTj
         nzJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=b0O3mprRJ3WdZye48HA9IWlDk2nK2hgN1roQFBRqozQ=;
        b=zVEA+uxae77KCCeG3IS2N9ZH7P0AumKTcrKkkh5pzEZFazixt6D4sxRH/MQpgZxncN
         ZGHYUFmY7EZp4A9iZaWizBqcpYkce0OAk5dUHSDvNpNmR9BNG77G7nC0O6E8urOLJyCa
         Dcotpv+qTazzKAKeP9Ma0Ktk4b1qqbdCFFAxrwn1daa1+nncQnBbjszp9rMrosKeue20
         ySnxArtB0oYBw40JuLn84klpZHw4ZmBL8Tk/JznJxsT8rNqHF0urt0uNSe+zu/ohj5RS
         REC7eMWLXbFL30PTnDqo70sUFbZpngYg4uu0fTS/8mIfWhNB0rIaTqh3A0icufgG7uY9
         MFAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t17si2455472ejq.121.2019.06.19.06.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 06:24:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A63F2AD96;
	Wed, 19 Jun 2019 13:24:51 +0000 (UTC)
Date: Wed, 19 Jun 2019 15:24:50 +0200
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
Subject: Re: [PATCH v2 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190619132450.GQ2968@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610111252.239156-5-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 10-06-19 20:12:51, Minchan Kim wrote:
[...]
> +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)

Again the same question about a potential code reuse...
[...]
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
> +		if (isolate_lru_page(page))
> +			continue;
> +
> +		isolated++;
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
> +		if (isolated >= SWAP_CLUSTER_MAX) {

Why do we need SWAP_CLUSTER_MAX batching? Especially when we need ...
[...]

> +unsigned long reclaim_pages(struct list_head *page_list)
> +{
> +	int nid = -1;
> +	unsigned long nr_reclaimed = 0;
> +	LIST_HEAD(node_page_list);
> +	struct reclaim_stat dummy_stat;
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
> +		.may_writepage = 1,
> +		.may_unmap = 1,
> +		.may_swap = 1,
> +	};
> +
> +	while (!list_empty(page_list)) {
> +		struct page *page;
> +
> +		page = lru_to_page(page_list);
> +		if (nid == -1) {
> +			nid = page_to_nid(page);
> +			INIT_LIST_HEAD(&node_page_list);
> +		}
> +
> +		if (nid == page_to_nid(page)) {
> +			list_move(&page->lru, &node_page_list);
> +			continue;
> +		}
> +
> +		nr_reclaimed += shrink_page_list(&node_page_list,
> +						NODE_DATA(nid),
> +						&sc, 0,
> +						&dummy_stat, false);

per-node batching in fact. Other than that nothing really jumped at me.
Except for the shared page cache side channel timing aspect not being
considered AFAICS. To be more specific. Pushing out a shared page cache
is possible even now but this interface gives a much easier tool to
evict shared state and perform all sorts of timing attacks. Unless I am
missing something we should be doing something similar to mincore and
ignore shared pages without a writeable access or at least document why
we do not care.
-- 
Michal Hocko
SUSE Labs

