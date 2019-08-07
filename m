Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74914C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:56:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A90821E73
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:56:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pM3PBYRi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A90821E73
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8CAA6B0003; Wed,  7 Aug 2019 11:56:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3BAA6B0006; Wed,  7 Aug 2019 11:56:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 952106B0007; Wed,  7 Aug 2019 11:56:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 601186B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:56:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so52696203plo.6
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:56:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XZaTxyRD4Nqbdn0ljW5bmpndWHMns933E3SJhOAN/+0=;
        b=LzrEfH+0YKtusqQDXj6mNEtOlHTNqnmxxpvw8Ndy+LW675zpoVnsYfS4o9MKe0z4Mu
         eP1BZGtZ0NkAoNyyNaVE47vepW4XPpcqzYE76N4sFQlBaKuzVnvUFIIkFGJc9m5xsFqW
         vODfoK8PQzteuQFIwQbOzr9aA9GP3asUEt5PZ37bhXNBvzv00AFepmnYPc8AnzAoLjKE
         6l04GkvyDOywMKwYsjYhEU90JDpykJtxf8quhVh3ZiM5v00m/kVNtov49j67xCiWgT9G
         vui+SRiPaLLpd6wQid0z2OYFD9xOrYL+KGYPnJMIj3pRKuqKkRTeP3tC6NQ0kWXl6qk4
         5wZQ==
X-Gm-Message-State: APjAAAVzhzK98hkfEbfsD4cimP39et7QZofyLjz3Sgf/mGrQORl8Twq1
	qqW7fVMwD/ZuSgn1QaOfX91HPg+pSNU2JtFQGUwSPG/lTiQGM3/kmAnViMqt7Qn4/AOvfJRLiCG
	HNs91PpLnrE2U/m3VElR1eslwSEII6fJxNFtiwSiJCVw634M0Iz3n8vBn0cMqteWvyA==
X-Received: by 2002:a62:1750:: with SMTP id 77mr10134148pfx.172.1565193369914;
        Wed, 07 Aug 2019 08:56:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4xjTjbXog129KAlIrHFWF/BiNUvmlr4TsPeGytCD9Nq6L2y+7IQyCfBF74L2yeep9eP/i
X-Received: by 2002:a62:1750:: with SMTP id 77mr10134093pfx.172.1565193369050;
        Wed, 07 Aug 2019 08:56:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565193369; cv=none;
        d=google.com; s=arc-20160816;
        b=OnBHmoFoGEgx4g3oCUrDDXiSR8ETsFjm2VGpRC3/U2J5iqf7Xw9omv2gzCA/Rg8DUz
         uFiyhM4OkraAqlUcL+/l4aoRlBVRdUYZcJpXZhXiuP7rHSW8jcGMNHYPJfm2A01ZmvKO
         xjecbOuxDITmmiDHq4edpVR4yI9lHXpYWUO89Jgw69d9yApBUvfDHwKVHdF2OKuKMk0i
         J1ykJxCEQHWz8ZAQa2uHgYEyOwjmmHEJDfx5Dk3Y+hmz040WHjaJca/tzYATQs6bdoNP
         sfuRkAJBVd97K92eHqwWAjqbN2ac0hvmz1ZkM6Hte1RLqV6RrumtEsO/gzfPAN6jKXCi
         r5UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XZaTxyRD4Nqbdn0ljW5bmpndWHMns933E3SJhOAN/+0=;
        b=Fl4L83l0s2gMVRdbxG5IpdoYsSiEPdrTwcy1UFhC3S/Ks9cIbKLHcv3JPBmi4tm1ON
         Lk12boP2A96Chf5TBxtDYSvxdSjM+vWESvSH98sygGvj6syLtwyUJL2DaOxeo9DMotXW
         kvVR9Z5WnLTp1N/ml3mp639+WjUGj87WgjqVQewU3atOQvvKXyLWsNGdx92R9M6wYeHx
         lg+SZMm1vaCz5eNrvcA/RrnVSbyY3MHCicXxDW1HGg+OdXGNBuYdw3uLWjFjMBihI7eS
         miBkvEBP4LUqbPlP9Xp3x6nw4A4wQwT8UNQiRQii/i0uSSoJFGOYRAnK24ZMbQ8YeVmb
         LThg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pM3PBYRi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l63si51321151pfl.41.2019.08.07.08.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 08:56:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pM3PBYRi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XZaTxyRD4Nqbdn0ljW5bmpndWHMns933E3SJhOAN/+0=; b=pM3PBYRihFz16BOz8wLJG1o5c
	NyBoWBzn5CGIWmxPpktF2eWRDVBbyQMF12sbpfKP7j8HNcAn1uIrznqlktDyq2Djlv/ZKtm/ZzS8E
	mUgofDi7T+Xk+j4KXA6M23Z5mLC4xlH5gxWCawx05rt8ZVmnltSW/Bw2ju8YikIomytGnPGJTiI/7
	EmXgKTBdum89gqwtkn1wPDW7NDohQM4mLoJsIbR7K9WsWlFFN8ft2OIxOX7t8STJWlJUFQpdmO9Pi
	ut/BTpn1S0Rpf7EPF2vHHZ4HjpHZ16bs9nxTD4N/KjcxdCRm6KMJQpmLgCugCt7sHUxnVJvytI1VS
	N0izq+XDg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvOIB-0006Y2-H6; Wed, 07 Aug 2019 15:55:59 +0000
Date: Wed, 7 Aug 2019 08:55:59 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Steven Price <steven.price@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190807155559.GC5482@bombadil.infradead.org>
References: <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
 <20190806190937.GD30179@bombadil.infradead.org>
 <20190807064000.GC6002@infradead.org>
 <20190807141517.GA5482@bombadil.infradead.org>
 <62cbe523-e8a4-cdfd-90c2-80260cefa5de@arm.com>
 <20190807145601.GB5482@bombadil.infradead.org>
 <4b9ea419-571b-93ab-ee52-811e52c0ae91@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b9ea419-571b-93ab-ee52-811e52c0ae91@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 04:32:51PM +0100, Steven Price wrote:
> On 07/08/2019 15:56, Matthew Wilcox wrote:
> > On Wed, Aug 07, 2019 at 03:30:38PM +0100, Steven Price wrote:
> >> On 07/08/2019 15:15, Matthew Wilcox wrote:
> >>> On Tue, Aug 06, 2019 at 11:40:00PM -0700, Christoph Hellwig wrote:
> >>>> On Tue, Aug 06, 2019 at 12:09:38PM -0700, Matthew Wilcox wrote:
> >>>>> Has anyone looked at turning the interface inside-out?  ie something like:
> >>>>>
> >>>>> 	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };
> >>>>>
> >>>>> 	for_each_page_range(&state, page) {
> >>>>> 		... do something with page ...
> >>>>> 	}
> >>>>>
> >>>>> with appropriate macrology along the lines of:
> >>>>>
> >>>>> #define for_each_page_range(state, page)				\
> >>>>> 	while ((page = page_range_walk_next(state)))
> >>>>>
> >>>>> Then you don't need to package anything up into structs that are shared
> >>>>> between the caller and the iterated function.
> >>>>
> >>>> I'm not an all that huge fan of super magic macro loops.  But in this
> >>>> case I don't see how it could even work, as we get special callbacks
> >>>> for huge pages and holes, and people are trying to add a few more ops
> >>>> as well.
> >>>
> >>> We could have bits in the mm_walk_state which indicate what things to return
> >>> and what things to skip.  We could (and probably should) also use different
> >>> iterator names if people actually want to iterate different things.  eg
> >>> for_each_pte_range(&state, pte) as well as for_each_page_range().
> >>>
> >>
> >> The iterator approach could be awkward for the likes of my generic
> >> ptdump implementation[1]. It would require an iterator which returns all
> >> levels and allows skipping levels when required (to prevent KASAN
> >> slowing things down too much). So something like:
> >>
> >> start_walk_range(&state);
> >> for_each_page_range(&state, page) {
> >> 	switch(page->level) {
> >> 	case PTE:
> >> 		...
> >> 	case PMD:
> >> 		if (...)
> >> 			skip_pmd(&state);
> >> 		...
> >> 	case HOLE:
> >> 		....
> >> 	...
> >> 	}
> >> }
> >> end_walk_range(&state);
> >>
> >> It seems a little fragile - e.g. we wouldn't (easily) get type checking
> >> that you are actually treating a PTE as a pte_t. The state mutators like
> >> skip_pmd() also seem a bit clumsy.
> > 
> > Once you're on-board with using a state structure, you can use it in all
> > kinds of fun ways.  For example:
> > 
> > struct mm_walk_state {
> > 	struct mm_struct *mm;
> > 	unsigned long start;
> > 	unsigned long end;
> > 	unsigned long curr;
> > 	p4d_t p4d;
> > 	pud_t pud;
> > 	pmd_t pmd;
> > 	pte_t pte;
> > 	enum page_entry_size size;
> > 	int flags;
> > };
> > 
> > For this user, I'd expect something like ...
> > 
> > 	DECLARE_MM_WALK_FLAGS(state, mm, start, end,
> > 				MM_WALK_HOLES | MM_WALK_ALL_SIZES);
> > 
> > 	walk_each_pte(state) {
> > 		switch (state->size) {
> > 		case PE_SIZE_PTE:
> > 			... 
> > 		case PE_SIZE_PMD:
> > 			if (...(state->pmd))
> > 				continue;
> 
> You need to be able to signal whether you want to descend into the PMD
> or skip the entire part of the tree. This was my skip_pmd() function above.

Do you?  My assumption was that if there's a PMD entry, you either want
to be called once for the entire PMD entry, or 512 times for each PTE
entry that would be in the PMD if it hadn't been collapsed, and you
could indicate this through a flag in the state.  Is it more dynamic
than that for some users?

In any case, we could have a skip_pmd(&state) function; I'm just not
sure we need it.

> > 		...
> > 		}
> > 	}
> > 
> > There's no need to have start / end walk function calls.
> 
> You've got a start walk function (it's your DECLARE_MM_WALK_FLAGS
> above). The end walk I agree I think you don't actually need it since
> struct mm_walk_state contains all the state.

Ah, I misunderstood what you meant.

