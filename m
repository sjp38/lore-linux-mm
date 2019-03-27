Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 895CDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:50:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7EE2070D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:50:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oD1tLB1L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7EE2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8282E6B0003; Wed, 27 Mar 2019 07:50:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D5326B0006; Wed, 27 Mar 2019 07:50:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EBB36B0007; Wed, 27 Mar 2019 07:50:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3626B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 07:50:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id p11so4207408plr.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:50:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2JzlpAdmBNeKMsGiSD5xhZyfgPsLZPvBX1ubCGB+Vp4=;
        b=Me2OjQW3UnlBPvSth8oDRJ+FvA56nRYFaS3ce+1denrReR0APmd6ER9AuMDFdeMk3W
         b6aBMft1DvE/Lb1TlHjD7Vx3WOIzDICd7devKZ9VUywFBVpj/iBWivnLWAu8019OO/G3
         hwti5CW1TMVcfK0ZnhjG8V+pX2zKg8i5CtW5QrmTAAKaI435og3hroEUtkQis1mGzc3D
         vbDvM+QGJRyN+H0r/h2P/HbECIFRKn5n3Vh1yzxagfdR+vPTDM8FmglTTN3aXrVZZ9CC
         DJcS8Wc7h4PqW/V/YafKj4ofunqfaIhePGYNZlJgs8GLpzdmqxnSWpIhI4P88+FwvJRH
         oALA==
X-Gm-Message-State: APjAAAW1yLUKJJSbASWDuyWVsEqftxTtFeCX6m/LNahtKRZSluAHEKbu
	3oXGr9/4AAz2g7RpBqfrDxj+LBLLXbG3I5NtchUg3v7c6z8kg6m1Nq2VvMY89fBbEDymsTPK/zk
	+5tU0BrEOFqJdYnx2ORuN29KqFQ1ZrEcD+l61pNspl/2KSm6Yg6MebJWsvme4jv51yA==
X-Received: by 2002:a17:902:8c81:: with SMTP id t1mr37049439plo.309.1553687415691;
        Wed, 27 Mar 2019 04:50:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjE518DFEmqu0Dakv2HLsmjpiZKOGH7dS/qo9nSp/Ld8RgcxKELwz39952U15vyfY9roUb
X-Received: by 2002:a17:902:8c81:: with SMTP id t1mr37049394plo.309.1553687414924;
        Wed, 27 Mar 2019 04:50:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553687414; cv=none;
        d=google.com; s=arc-20160816;
        b=K4lIVh6faFO9JcNQ8A+NddLcBeAvTdixUMhgwd348h42T9Yo742FKON1FHDH7IN4U/
         17XqmGPG8B6npjJfEIlRJx83GtBJjTOeR8zOO61plSzk/oO0q2RkPsT3ZFheaKyu0ONO
         qasLlWzusFPVilDfxkhDsEJyWUR4rZ6iSKfjWTIuzN608gsn5LVJLSy7Iz5DnHUqgFdY
         N1XxLwV3PJ0Ykjdxd6UVvsq3PTbTsQwCw0up6YK1UfKpYQ+zPCrcyFSch5TWuk4ma3c7
         V8C0abkhuildVgupTsIywyYXAcy0k/QhQTNjc1AGCnbc1nR8eF5KPEyVXPIfuKcfRHXZ
         IQAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2JzlpAdmBNeKMsGiSD5xhZyfgPsLZPvBX1ubCGB+Vp4=;
        b=y4w4HmK4y3JKQCapXSs23iiDI29sbJJDDZ5j1y/mENlDdH2/sKdt8fgFkibjuE6KKb
         da+nzv6c1BE9yDTJbNssx4nTPxW/wSFZdAmiW10Sn8qJlAKQIxT1U54b/EN+8W/TTeIH
         GQ56ktjyXCFXEe0u2jqsMgvOWWvyj/sGPFEh/c2POehGO8bVlhsxRlbmCeTBqG8eyRQa
         DrxeQF9VbFatgEHJe9V1MA+4Kx8F83mTtaMm0oXFZyQ6Z3GLL8S1fWzN6FJfzeTXHL3u
         vZvhGcWhEH/4/b4x8a303DnmlWq73yes4vjn26j6atBae16dTya9GKNZ7dqmMJYxErza
         e5/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oD1tLB1L;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j21si18862570pll.271.2019.03.27.04.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 04:50:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oD1tLB1L;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2JzlpAdmBNeKMsGiSD5xhZyfgPsLZPvBX1ubCGB+Vp4=; b=oD1tLB1LI3PFhkaSfE94lSSu2
	XTkPysAFfESqqcrrs2InrIzcIc7i/4K1M/op6bcQ+UwM0qEqs/td4nlDx/qSxbzTfD/oruxX6T2Bw
	F6vw+B2osm0M00olhuxJCpPiSx1bbrJT2XC1phaZmisSugXDub4Imf8+bgKqNZgN5sHRGnisdGSUE
	nAHn70Tf+8N0OdP1HKovK04T34W6LBfbMt4Knx2hhmuoWsyBVXhKYGhmr3L8MQ9u1MPs0y/i9iZeE
	VS9XbSCxSjMe4cNhqyr3CrAJrG2VdcjPlIqZnnHgcl/nwIBVmuW2rPw56Mi7lpAP1kZtvS/+GA8KY
	p4HXvFMcA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h974M-0000Lc-OB; Wed, 27 Mar 2019 11:50:10 +0000
Date: Wed, 27 Mar 2019 04:50:10 -0700
From: Matthew Wilcox <willy@infradead.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Qian Cai <cai@lca.pw>, Huang Ying <ying.huang@intel.com>,
	linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190327115010.GQ10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
 <D2A51D2E-81A5-478A-9AF7-C08F85C5C874@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D2A51D2E-81A5-478A-9AF7-C08F85C5C874@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000308, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 04:48:42AM -0600, William Kucharski wrote:
> > On Mar 23, 2019, at 9:04 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > static inline struct page *find_subpage(struct page *page, pgoff_t offset)
> > {
> > +       unsigned long index = page_index(page);
> > +
> >        VM_BUG_ON_PAGE(PageTail(page), page);
> > -       VM_BUG_ON_PAGE(page->index > offset, page);
> > -       VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) <= offset,
> > -                       page);
> > -       return page - page->index + offset;
> > +       VM_BUG_ON_PAGE(index > offset, page);
> > +       VM_BUG_ON_PAGE(index + (1 << compound_order(page)) <= offset, page);
> > +       return page - index + offset;
> > }
> > 
> > 
> >> [   56.915812] page dumped because: VM_BUG_ON_PAGE(index + compound_order(page)
> >> <= offset)
> 
> Is a V5 patch coming incorporating these?

No; Andrew prefers to accumulate fixes as separate patches, so that's
what I sent on March 24th; Andrew added it to -mm yesterday.

