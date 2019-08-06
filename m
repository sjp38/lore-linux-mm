Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D62F4C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 19:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88EB1208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 19:09:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HYsW2QiO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88EB1208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D65E6B0003; Tue,  6 Aug 2019 15:09:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 160746B0006; Tue,  6 Aug 2019 15:09:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1B2F6B0007; Tue,  6 Aug 2019 15:09:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4B236B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 15:09:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x19so55486868pgx.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 12:09:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RaeoCUSmhxSCGOxwB43DaNZ/5YjX3sQn/mta3yU5yC4=;
        b=aXiOvs6704HTM6U6dqHOCmw2sesqPJzFQHDxZrP6JK+QAcPHiPRvosY4cZUZPXAOcJ
         9wnoWs/UD2/8Q7fMxbyHLPstMFievDXaH1VJyNUUsAXghKXvJlAXynd9XXfekgqAlWUe
         vMmFU+QWTmlkhgkljwo6HvMpgcjbMFKYnNUmglY1RK7un9bOkfq6i+76tdZ1OH5eE8bG
         a5NeUYBPBSL/6192HcH2gkeTVVg507WLZNH4zYEadfyHPQOXvdWPfJn6Hljykhw4S4i5
         HNkjcv21IeB9eHWJM3rw2DftNlpYDPs5aqUfKterC0SnJ/6si1wIhz9y99+5Qs5sQJWK
         0tmQ==
X-Gm-Message-State: APjAAAUZbnZSVmkukc8BqSARYUW1AiWNecL3/VziTe8J9jmbtmMCXi1Y
	vjuHkra+aUp0v+l/LH40yIZYXsM0SI24zzxYooDYvVlLofHM4I6Ee94b6Sx1dYE4VvltvdJcfEe
	XQIErU9JirRvsa2YgGbdHjt16AEiQKZ9fTbbztDTUSNk5L/HUQtM5yZATkYf0dc6ZRA==
X-Received: by 2002:a62:1750:: with SMTP id 77mr5327844pfx.172.1565118585279;
        Tue, 06 Aug 2019 12:09:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdw3efQLer2B1C5LF5r8AjkEULYE8Ev4yd+K0D6/qyKViTfKvyM9fK+6im7r1BUX3K5tTl
X-Received: by 2002:a62:1750:: with SMTP id 77mr5327783pfx.172.1565118584583;
        Tue, 06 Aug 2019 12:09:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565118584; cv=none;
        d=google.com; s=arc-20160816;
        b=aXs6tNzSiV0GBJN+Joxp9peHA/aJk4LG19u2KutH1ugpKlGeY1cCrLPmq1kM90FDWJ
         o3nZAuEK0BEYbt0p14NWr4Q2rfrbmiwLCWS9GN240r6VSEMpwM9+AWLkszgSyiDJ17EL
         bG1N0KZsWcbnSokIeYqLMW+AoV3MXqdnQdpQwB20ZnCKvgpnArdGgeCNBSm6FxTnnypv
         wh+MQQIOK4KWPDl67W1MI5YjIB6zXSMIFB31roc4nt6c3rvXsDNaBTZDZQSkhB9DtfmE
         lNAcNhXCaMHa9wX4g/EVTw4/99+ith8UJ7AwwyLpOkDZ+YOXuieTonl35iYqdKeTT5hN
         WgGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RaeoCUSmhxSCGOxwB43DaNZ/5YjX3sQn/mta3yU5yC4=;
        b=mFMFWigULgSwTWsdXLCDYES1qXUeBXOCbb0MXocFHRCqEaFkBw4v0rEJebjjiz5Gzi
         evqLEddQNgrMrkXZ2OssUHkC0f0FtzY0cG8i1JW5/NGDClqbF00zuYLxD9t+BLgCCEfM
         X7gSHGIINyJx6HRYkpxcuBVbtovQU1nXLX7zAaIZrbm7dLqdu5yXunMvBAslZd17Uk3S
         XgH7Xup5shOYVS6B2xeXCHO0iOO+CeM/3MSjiNnQSVdyOxTfZDGsBFKSpQx2fqzQ/HNn
         GrtrF1X0b0fLhkMEczD3cNdNOHSx9NGtW22VPWsuCXDKlJ1iK2CHQPKe8h2jt79/byBZ
         J3Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HYsW2QiO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s17si46207393pfc.237.2019.08.06.12.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 12:09:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HYsW2QiO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RaeoCUSmhxSCGOxwB43DaNZ/5YjX3sQn/mta3yU5yC4=; b=HYsW2QiOT4sji3EIN4Q0wKhkO
	8usk4G3VXuLKfPFt93yayYnL11+Wg7CD6fo5kXE0hCCJsU9hPCfQz0e8rb+Cj/PRiYXJqhgwWmGPZ
	F8nDYUjkOC3GE94SGbYaBkWqx/G9v7lBO1ePtBuaCUt+kGyE5vM2VgrlPTY6FmO8VQ8Gy+lQmUfzi
	lxOePzlgNMzkgaDgPtOdsG+LAhyELSbgT9YNqFNxQ5C/Rdia7AkWDcuYmqvmp0BklX9DjFbIrJZXD
	VvZqWIteZ7nvupkqGl8SD0m+FH3vaDhoP4qemEWgLPkSTRlvRi3LRgWr6rbkK6Z1XOSj9D1wvKK/z
	Ys7utKYGQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hv4q2-00022c-3C; Tue, 06 Aug 2019 19:09:38 +0000
Date: Tue, 6 Aug 2019 12:09:38 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190806190937.GD30179@bombadil.infradead.org>
References: <CAPM=9tzJQ+26n_Df1eBPG1A=tXf4xNuVEjbG3aZj-aqYQ9nnAg@mail.gmail.com>
 <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
 <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wi7L0MDG7DY39Hx6v8jUMSq3ZCE3QTnKKirba_8KAFNyw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:50:42AM -0700, Linus Torvalds wrote:
> In fact, I do note that a lot of the users don't actually use the
> "void *private" argument at all - they just want the walker - and just
> pass in a NULL private pointer. So we have things like this:
> 
> > +       if (walk_page_range(&init_mm, va, va + size, &set_nocache_walk_ops,
> > +                       NULL)) {
> 
> and in a perfect world we'd have arguments with default values so that
> we could skip those entirely for when people just don't need it.
> 
> I'm not a huge fan of C++ because of a lot of the complexity (and some
> really bad decisions), but many of the _syntactic_ things in C++ would
> be nice to use. This one doesn't seem to be one that the gcc people
> have picked up as an extension ;(
> 
> Yes, yes, we could do it with a macro, I guess.
> 
>    #define walk_page_range(mm, start,end, ops, ...) \
>        __walk_page_range(mm, start, end, (NULL , ## __VA_ARGS__))
> 
> but I'm not sure it's worthwhile.

Has anyone looked at turning the interface inside-out?  ie something like:

	struct mm_walk_state state = { .mm = mm, .start = start, .end = end, };

	for_each_page_range(&state, page) {
		... do something with page ...
	}

with appropriate macrology along the lines of:

#define for_each_page_range(state, page)				\
	while ((page = page_range_walk_next(state)))

Then you don't need to package anything up into structs that are shared
between the caller and the iterated function.

