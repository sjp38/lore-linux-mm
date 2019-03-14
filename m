Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02F6AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A57D920854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:47:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="KLueMx+1";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CYSoMbcW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A57D920854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 406BB6B0003; Thu, 14 Mar 2019 16:47:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38BD56B0005; Thu, 14 Mar 2019 16:47:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22EA66B0006; Thu, 14 Mar 2019 16:47:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1BD76B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:47:22 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f15so6579713qtk.16
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yLDcuHp0DhRpR1BcCx+aKpC2sxaXs3xGUSd0iNo1cIA=;
        b=D48TMT3Q+aADEMhddWJIJcu1AbQpzDAaC6LZ69LSe3WVM6lG8XVMIcw+Jj0tQn8WpW
         vbT1+HF1czClG8Mar8cXlVdnvsTZWZx5crWRzN7scQi9zHrlMD+2wi+5T55KIf3ENbE4
         dGTdFx9AO6/uU80x85L3YGm1SP5hWw3JYnYNWvXxJZMf/fAsTwI85GODUrmGQQN9tzKq
         0jNdi2uXE9fou0SlFhEwamXHju4KiyJVgEaYpmXg1yX8BgGSqM6JfdqUCf7KEzBaPdeL
         sknLJVj2TneCQNmyQJ0c7d36GBodvSmcDCIlS6LqfzP99f1qsktD/MvNLdiSZJOdKBiu
         IuLg==
X-Gm-Message-State: APjAAAURrxERyt5xfwhEYL0ulQ1E9zvyHrEJCZOUxkrw3yHigsd3AFyl
	ZDQpmxNX4axZuW50wYVgKKhxQ/7inREoL3I0h8s6Jq6xmE7weF31UdNputnd2CXHgi9xvrl0Hh0
	ZKLwWGHZ+h2tGZlHHgyL2P+CUri+2ATpglcT7npTEtckd8MwFzBieyp7y8FyOcS5COQ==
X-Received: by 2002:ac8:27ba:: with SMTP id w55mr66628qtw.228.1552596442697;
        Thu, 14 Mar 2019 13:47:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzyrjZV90uDYHePctLqEB8fuWqiejhLTtOR+s1nwQOjYf+ypNOzrOngTOlxZxpjQs1R9Pp
X-Received: by 2002:ac8:27ba:: with SMTP id w55mr66590qtw.228.1552596441986;
        Thu, 14 Mar 2019 13:47:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552596441; cv=none;
        d=google.com; s=arc-20160816;
        b=Jy70I7pavI+fso7dSIQQOe/Qrt2+G18n5/feT6wVi6TkRmn5jnHgpaeKsQJRC9o8Et
         ALBg2xQyHDunRJqv0/IUfEw4L5qrcfnS4pyxrJx42p+Eb1DxVkyLoAuaQs6ToGv3LVQq
         TGo6ixC6bQi1/WEAzHdQe2HasdLZE13o4ogNd/NTOGp96EG885JctZbSipNLYtKsG+9g
         9RAva/p5siSurTa1FPGmCXaUe9SM08XetO1CehTYpeI7cBLLGdRfjkZ+B8AI+B66yCwT
         +3QXcA/WaS9brH6JzLVIf+fDt79jmJIGW7d4RJv1R71RXWReTzQbnh3yUKXgEP3KZGkd
         3yHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=yLDcuHp0DhRpR1BcCx+aKpC2sxaXs3xGUSd0iNo1cIA=;
        b=vkYEbZIzTXdaxz8YMJxP0AS1OLz6LLsuiwffvYKtsaw71URiNf3sr4NmUzX23Ul6Vb
         UUYFnJkwFwftmBLPFxND3Ep2D/osh1ICxSrx5DSGBwIKTwASbKPq0z50MHj7W/US+XMi
         olIqVvpPTMwqn1S1FPZtJC8wJ65Ovzjsqme4ZLo2KeNFXQrA3ZZL6JDcxzrc1YgeH62h
         5cRpytFyJSuoe7EtEwzz8W8xWGQRrHoY/0ySVJ3ZnEDLNnkVyRTUHJmIki0sPal0SXJU
         XwwPqx7H/CG1gnd05xKuQkPqmw0GKTuCNZqhKMuhVXPCSSx7pkQXY8JHbGjp89oU6q2R
         4KSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=KLueMx+1;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=CYSoMbcW;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id k31si89662qvh.70.2019.03.14.13.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 13:47:21 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=KLueMx+1;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=CYSoMbcW;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id B91D521D35;
	Thu, 14 Mar 2019 16:47:21 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Thu, 14 Mar 2019 16:47:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=yLDcuHp0DhRpR1BcCx+aKpC2sxa
	Xs3xGUSd0iNo1cIA=; b=KLueMx+1d35u7zYB1YugeyNJvkHB9+RQ2+4Eu43no2U
	lTg9F9j4s+Vzl65H7V6YTohqtBGV6HWcm9/5+rX9DYCgCRqbjXKcETXe3xj+acr8
	WNDOZYCl0xrG4C6yq6kr1iSVrtWHxGlEI48r+Mb3wOwmFM8TMRGzcOKARZKdlpSk
	iLSWPF2sMq2IdkFdbEAyTUVvo3M9f/hQMxPKRpAynB8a23J29OvZGYiWE3woqV5W
	fDaPHLr+3GaDyu566qe3vQP32B/2iAFOVFnfe30E9bvIyBrQmhzzJzwMlNQkvSQ+
	SeErVmc8/o4lVzcN/F9Bk6rkNZ+RA1sRXqldn41w4Fg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=yLDcuH
	p0DhRpR1BcCx+aKpC2sxaXs3xGUSd0iNo1cIA=; b=CYSoMbcWmJisv+NFYF4Tc1
	xLDK+MjQ1+1CGnzo95WdVdYekFNjO8F680UHJ7f5c01fkJrj7FtMcvXPhvRgN7Cp
	LOgkVk/ySl7FTp+1mkDHrTtZ234rlBuTzdM7sal+qFM9K6GNNROfK02v3qTDo6xO
	U+6GlqRxHP4RXTEZi/3lUIpHTwPM+0AoWHpIn1Q+6o8txM9TKt8aX6ijUrB+FScX
	j3hxuDOdQ+bAfdEm9GR5BSW6w7lcUwDee9V4hChWvIy2nmyZk2xQ1vbmMAd3B8NG
	++XzlD72M82KxdCJvL5ZhFGpNkFs+7dM9rxI6r8b/m7/y+KlYu1gqbZmqpcFbroQ
	==
X-ME-Sender: <xms:2L2KXGCO8ycsFPbw7xcG60r8O4HwsS8NoF4cZ5Jqgf8ssJRxPfjhGg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrheefgdehtdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:2L2KXHeZ8lbdtzHyVZ76DT-lFu6xXcKuKq3jqcqwOBSkK5-2GH4f4Q>
    <xmx:2L2KXCh3U3Ewh67sGKSCY-jTPLFEoo0PaYGahg9UA9vjqgeAzswjrA>
    <xmx:2L2KXMmjRSOhP_UVG5xAug07zv3nhKmKdGIsdPJPmc_Pk_99m_7eGQ>
    <xmx:2b2KXN1Aw24UaYyCqed31pZzPf-KqgXTPIdYxWlxxwce3mWa7fPJ2w>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6813F100E5;
	Thu, 14 Mar 2019 16:47:19 -0400 (EDT)
Date: Fri, 15 Mar 2019 07:47:00 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v3 3/7] slob: Use slab_list instead of lru
Message-ID: <20190314204700.GA10222@eros.localdomain>
References: <20190314053135.1541-1-tobin@kernel.org>
 <20190314053135.1541-4-tobin@kernel.org>
 <20190314185219.GA6441@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314185219.GA6441@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 06:52:25PM +0000, Roman Gushchin wrote:
> On Thu, Mar 14, 2019 at 04:31:31PM +1100, Tobin C. Harding wrote:
> > Currently we use the page->lru list for maintaining lists of slabs.  We
> > have a list_head in the page structure (slab_list) that can be used for
> > this purpose.  Doing so makes the code cleaner since we are not
> > overloading the lru list.
> > 
> > The slab_list is part of a union within the page struct (included here
> > stripped down):
> > 
> > 	union {
> > 		struct {	/* Page cache and anonymous pages */
> > 			struct list_head lru;
> > 			...
> > 		};
> > 		struct {
> > 			dma_addr_t dma_addr;
> > 		};
> > 		struct {	/* slab, slob and slub */
> > 			union {
> > 				struct list_head slab_list;
> > 				struct {	/* Partial pages */
> > 					struct page *next;
> > 					int pages;	/* Nr of pages left */
> > 					int pobjects;	/* Approximate count */
> > 				};
> > 			};
> > 		...
> > 
> > Here we see that slab_list and lru are the same bits.  We can verify
> > that this change is safe to do by examining the object file produced from
> > slob.c before and after this patch is applied.
> > 
> > Steps taken to verify:
> > 
> >  1. checkout current tip of Linus' tree
> > 
> >     commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")
> > 
> >  2. configure and build (select SLOB allocator)
> > 
> >     CONFIG_SLOB=y
> >     CONFIG_SLAB_MERGE_DEFAULT=y
> > 
> >  3. dissasemble object file `objdump -dr mm/slub.o > before.s
> >  4. apply patch
> >  5. build
> >  6. dissasemble object file `objdump -dr mm/slub.o > after.s
> >  7. diff before.s after.s
> > 
> > Use slab_list list_head instead of the lru list_head for maintaining
> > lists of slabs.
> > 
> > Reviewed-by: Roman Gushchin <guro@fb.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  mm/slob.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/slob.c b/mm/slob.c
> > index 39ad9217ffea..94486c32e0ff 100644
> > --- a/mm/slob.c
> > +++ b/mm/slob.c
> > @@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
> >  
> >  static void set_slob_page_free(struct page *sp, struct list_head *list)
> >  {
> > -	list_add(&sp->lru, list);
> > +	list_add(&sp->slab_list, list);
> >  	__SetPageSlobFree(sp);
> >  }
> >  
> >  static inline void clear_slob_page_free(struct page *sp)
> >  {
> > -	list_del(&sp->lru);
> > +	list_del(&sp->slab_list);
> >  	__ClearPageSlobFree(sp);
> >  }
> >  
> > @@ -282,7 +282,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
> >  
> >  	spin_lock_irqsave(&slob_lock, flags);
> >  	/* Iterate through each partially free page, try to find room */
> > -	list_for_each_entry(sp, slob_list, lru) {
> > +	list_for_each_entry(sp, slob_list, slab_list) {
> >  #ifdef CONFIG_NUMA
> >  		/*
> >  		 * If there's a node specification, search for a partial
> 
> 
> Hi Tobin!
> 
> How about list_rotate_to_front(&next->lru, slob_list) from the previous patch?
> Shouldn't it use slab_list instead of lru too?

I'll let this sit for a day or two in case we get any more comments on
the list.h stuff then do another version ready for US Monday morning.

Thanks again,
Tobin.

