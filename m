Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0E60C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 07:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92A50208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 07:04:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92A50208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 283956B0003; Thu, 20 Jun 2019 03:04:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2343C8E0002; Thu, 20 Jun 2019 03:04:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FB9A8E0001; Thu, 20 Jun 2019 03:04:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B62306B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:04:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l26so2993207eda.2
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 00:04:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=L+/CEm3ZufaqHTmvBpNnmNXe4K9WQ1vzNi1EkiNTph4=;
        b=gzT0Cd4Yk5Vqy6DROivRIHm1Sr/0ocvDtquuZbCKWCUMuFZJ6mkEHw1dPZZbTUGgIw
         oSE/LuQktXW5iM8JMSYen4V4KkiJUafNHINzQOYT+2NVzKUWi97dOCXoYqpxpXzPQv5f
         vxotJyd9k1mcTr6nQ2LewDBBAXbI4h5Qos+vysUlE2aooswfBE+R0eCcSx6/1uNQzS79
         5k5S6QbMn9qqlY6W3VaGluJpUwgeoNyaKfpr3LUJP9YYLajj3s9S6ZJEdffNEC0GkEJQ
         yRaJgfYmZ9K9rwzAq0DCTSEkDL7efHbp1aPvdX3ssBhrWIMWoAYoWxUXoJgMsm0Z3qW9
         cd5Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW+asAEHHtNLrJyvsv5ui3l2nP3YuhuZUXsvuUCrkBYbznPVo2D
	DHa5AyasC6VvPS/5mIsp4TacgNk3YOFGNmHLvn5EX7AwZ+wy2Dw5kis1zV0OIiUt+WCO3DMTriP
	vwjFpETzGTJIRCKVO/2x8vGHDM6TLf00GGbjS/BW6H6krX023NX1dsdSKssxDhQI=
X-Received: by 2002:a17:906:19d3:: with SMTP id h19mr13552732ejd.300.1561014288289;
        Thu, 20 Jun 2019 00:04:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgMIc0ObpzxURglG57STOjvej0dXSzCCuJ1Q40gXwoZWT4S+VybWxOMQFaRHCfLugRBN/s
X-Received: by 2002:a17:906:19d3:: with SMTP id h19mr13552664ejd.300.1561014287327;
        Thu, 20 Jun 2019 00:04:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561014287; cv=none;
        d=google.com; s=arc-20160816;
        b=cwkqfe47r1a+xbKCgz9Et+Bzav+s76FA7mKlcqSa0aXcnALp23KdqSQS+HT6p9O8ok
         2oAGIlnH2BjPYAGiFVYfh5SO2/1d3GlrG+s7r2rcFGXhkVnhjN7NYDXBRPWIrrtyI7ze
         QGnPYQ1ZR6oSHYyMBpVMRRWsajww6+wjFMxtvU5m79hYiclyDhm7dFrJMz8KxmwLmMKs
         Ok2PBll/0wkqQQOzRmybBEcnAOJgwvA76QJZ9F0Yiy32DbdNlEsGnVrb/i8I3TErlB5K
         gXKqldC5Ad+zdnLQwNV9aB4hbLWkt4xW1jWLOE+gXdtUOqrKUOAVIWxecMP6DIN3zY0G
         T6Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=L+/CEm3ZufaqHTmvBpNnmNXe4K9WQ1vzNi1EkiNTph4=;
        b=xp46Qz+hfaX/3qx6H1DdKxmM6dF5RfKoI/1TLLfOlthT1TFUWuyJOvQrmKP9b1Z7SE
         SRgUcEgQv3x29eHbRvJOPriE7yNQ4nzAbUBgCJU5s53S+VvajYVTrbmYTcRsyLQxp1Yq
         k6gTGaOUZLkieH3lst7tS1FIISiyB/79sNUhvHJL20gJxKubRQ6o1aa9oBo2Jc1DELgS
         jLRimWnegJDf8d8yNjjkFjsWJthbCTgRI0UxO85kaa5ZAMuDD8SG3asGxQUToFPY+Pjw
         Pml5WH64ZGsZIN2mV1usSiwELoeH0QMhnrngavyXtqeYvBLQLdEIs9EVpAg0fzBC9WZP
         fVGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z13si4645087ejm.227.2019.06.20.00.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 00:04:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A60D3AE34;
	Thu, 20 Jun 2019 07:04:46 +0000 (UTC)
Date: Thu, 20 Jun 2019 09:04:44 +0200
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
Message-ID: <20190620070444.GB12083@dhcp22.suse.cz>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
 <20190619132450.GQ2968@dhcp22.suse.cz>
 <20190620041620.GB105727@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620041620.GB105727@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 20-06-19 13:16:20, Minchan Kim wrote:
> On Wed, Jun 19, 2019 at 03:24:50PM +0200, Michal Hocko wrote:
> > On Mon 10-06-19 20:12:51, Minchan Kim wrote:
> > [...]
> > > +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> > > +				unsigned long end, struct mm_walk *walk)
> > 
> > Again the same question about a potential code reuse...
> > [...]
> > > +regular_page:
> > > +	tlb_change_page_size(tlb, PAGE_SIZE);
> > > +	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > +	flush_tlb_batched_pending(mm);
> > > +	arch_enter_lazy_mmu_mode();
> > > +	for (; addr < end; pte++, addr += PAGE_SIZE) {
> > > +		ptent = *pte;
> > > +		if (!pte_present(ptent))
> > > +			continue;
> > > +
> > > +		page = vm_normal_page(vma, addr, ptent);
> > > +		if (!page)
> > > +			continue;
> > > +
> > > +		if (isolate_lru_page(page))
> > > +			continue;
> > > +
> > > +		isolated++;
> > > +		if (pte_young(ptent)) {
> > > +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> > > +							tlb->fullmm);
> > > +			ptent = pte_mkold(ptent);
> > > +			set_pte_at(mm, addr, pte, ptent);
> > > +			tlb_remove_tlb_entry(tlb, pte, addr);
> > > +		}
> > > +		ClearPageReferenced(page);
> > > +		test_and_clear_page_young(page);
> > > +		list_add(&page->lru, &page_list);
> > > +		if (isolated >= SWAP_CLUSTER_MAX) {
> > 
> > Why do we need SWAP_CLUSTER_MAX batching? Especially when we need ...
> > [...]
> 
> It aims for preventing early OOM kill since we isolate too many LRU
> pages concurrently.

This is a good point. For some reason I thought that we consider
isolated pages in should_reclaim_retry but we do not anymore (since we
move from zone to node LRUs I guess). Please stick a comment there.

> > > +unsigned long reclaim_pages(struct list_head *page_list)
> > > +{
> > > +	int nid = -1;
> > > +	unsigned long nr_reclaimed = 0;
> > > +	LIST_HEAD(node_page_list);
> > > +	struct reclaim_stat dummy_stat;
> > > +	struct scan_control sc = {
> > > +		.gfp_mask = GFP_KERNEL,
> > > +		.priority = DEF_PRIORITY,
> > > +		.may_writepage = 1,
> > > +		.may_unmap = 1,
> > > +		.may_swap = 1,
> > > +	};
> > > +
> > > +	while (!list_empty(page_list)) {
> > > +		struct page *page;
> > > +
> > > +		page = lru_to_page(page_list);
> > > +		if (nid == -1) {
> > > +			nid = page_to_nid(page);
> > > +			INIT_LIST_HEAD(&node_page_list);
> > > +		}
> > > +
> > > +		if (nid == page_to_nid(page)) {
> > > +			list_move(&page->lru, &node_page_list);
> > > +			continue;
> > > +		}
> > > +
> > > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > > +						NODE_DATA(nid),
> > > +						&sc, 0,
> > > +						&dummy_stat, false);
> > 
> > per-node batching in fact. Other than that nothing really jumped at me.
> > Except for the shared page cache side channel timing aspect not being
> > considered AFAICS. To be more specific. Pushing out a shared page cache
> > is possible even now but this interface gives a much easier tool to
> > evict shared state and perform all sorts of timing attacks. Unless I am
> > missing something we should be doing something similar to mincore and
> > ignore shared pages without a writeable access or at least document why
> > we do not care.
> 
> I'm not sure IIUC side channel attach. As you mentioned, without this syscall,
> 1. they already can do that simply by memory hogging

This is way much more harder for practical attacks because the reclaim
logic is not fully under the attackers control. Having a direct tool to
reclaim memory directly then just opens doors to measure the other
consumers of that memory and all sorts of side channel.

> 2. If we need fix MADV_PAGEOUT, that means we need to fix MADV_DONTNEED, too?

nope because MADV_DONTNEED doesn't unmap from other processes.
-- 
Michal Hocko
SUSE Labs

