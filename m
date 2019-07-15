Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FC98C76192
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:07:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 472BF20868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:07:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q0Qsqf7x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 472BF20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF2E16B0006; Mon, 15 Jul 2019 09:06:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA2FC6B0007; Mon, 15 Jul 2019 09:06:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6B886B0008; Mon, 15 Jul 2019 09:06:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7092E6B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:06:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n9so7035014pgq.4
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:06:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=S6d0Uh9ElvljaSsYjmJyZ6Glp9AxqeU2DyFta5bh0Vk=;
        b=LTaCICNwK9kaUF/56ChC2LceiWfsh3sQZ5Y5GL12DndxYIto7aGuGt1HABMJ34hRId
         sk4R2p9jsRZUE1g2QJdG6ZLi6MheWA/6AU4AvqRzZl10U6Zb8Rip7WVFE68yWVmwkZUh
         jqNCnjxKqHK463iYEFjDL+IH1ooyXSOGk+mYtuI+RvJQe4+QV3fORM6MJZihEokB5CES
         EgMk7d6iRFnlxmom0zztZeepWMprLmsOuLcDXcbNJy8fIdZkKRw76i7Cj7Fy66Nwm2q8
         nZABIDXQFjbJj6efOH11BD2l5eHvkcMa6g9kAdGaljjXpsnsbPA1KXQcEu2ORJ92V+zF
         YZng==
X-Gm-Message-State: APjAAAWAZuPdZR4jeVES/waldRh6ahaq40EFcLg9ZfTxUOovJxi40b4i
	FBb1fMe3U6VbtyCVNhBrV/74xp9Rt70uHRrkZ5v6Uq3HlpinCLToAkzH4vIP2EXtdBail7t+s/A
	1p/jsR2G/3dVJ40lSAFcsy1xCjujrKxolJ4UQbSLp1CXtlbD5EdSHAz3rh5sviPVBvQ==
X-Received: by 2002:a17:902:e582:: with SMTP id cl2mr28520362plb.60.1563196018747;
        Mon, 15 Jul 2019 06:06:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlcnWMy9DhXpk3Oo/lRdrSm5ebzdwe1P1vNaXVOFX70IQ5eUoj7U5tRh8SXMLuvU5SYl4a
X-Received: by 2002:a17:902:e582:: with SMTP id cl2mr28520278plb.60.1563196018037;
        Mon, 15 Jul 2019 06:06:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563196018; cv=none;
        d=google.com; s=arc-20160816;
        b=r0Mv6SRdrstqxxdM7oLYCSZ+2Zq8bq0mNwQhTS+D8TUfwK0bTmkjqr14uU5E/BErIk
         ZjYZxWFkKe85JdIJl2ald70NS1Au6YQvkr7DREnj8tTzEjZkMRhxAzC2N3DXmyrlbuzN
         h4Yr6XWIgMsTg0K6MEFgpSAsdWhC7x8uESkIaYq1wCuNb/lLZn6NugfOo7aL3lnrenpb
         eMccjKdBHfCF/uLFKcqkgKpO/tFGbueb1dhAs2jDbBGK3Cd0XmtmpPjif9VxQ//MKcwc
         rQMa+ktd/900a7zLFwP3Y1/9ygRlilPMCMW/229lAn+So2mPWd4lFttbIbybsBjSSwRy
         PPZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=S6d0Uh9ElvljaSsYjmJyZ6Glp9AxqeU2DyFta5bh0Vk=;
        b=K9NQ/+jNL+tbT/+Y489azNZpOsm7tDb4dyyqI1RlCwPeTmAIH7KYwEyyueYvFEFb5F
         KQmxF9jLY/aBsoymAVhMd9fqoa4yXBcARcJOLn52T73weGXJ9QmIao45jNMTr4cWj5A5
         guz5SHR3HgA10H7fHj//ajqNZifuU3QVQJatDvKC/IClZ6Ds2y8xKtqmbd88IGBhrQSD
         0WZhXiKX9M6b8CcXZzlK8u+4BgX+CgtrMnispGr8x30jbksuCMqkJremLXNA1wv/gmY4
         0RjCDXOKjXP1S9CSOE3QVbioLjmYLx5UiHEk3swCaZo8hyH+R0KplPu9+ezbaN22Y8c7
         o/Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q0Qsqf7x;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d10si16024343pgl.163.2019.07.15.06.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 06:06:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q0Qsqf7x;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=S6d0Uh9ElvljaSsYjmJyZ6Glp9AxqeU2DyFta5bh0Vk=; b=q0Qsqf7xUmcdfbA8LatL4rZ+4
	4U+CqUCE7HPY1UJD/kTOy9twF8VftEu1clxmugXS00IRnERoxvFxg6C8tnlXDgnSpS0olgjtVoIES
	U8x6xMrZh6NVol0Edv2GSBuFRQKGjnawJ7BbhQZP+DUKnfahSLfYqu1ZxkJC8WzYnB0xb81ksKnIm
	0rjp+iUd8e9NwMP8p3Ov4NnE2mignjQ2Bi3UipKXSTzzBNsCfnyDnYzugrhCCw41AkbNENZuBfEMu
	y9/KJ5pMqPj64kBhtxgoDEGBlsnbYLsjEYjQh2VWotOgvw+r846gZJXDhYl0HIz4gPt6Qehf9Z6Gd
	txYH2h7Gg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hn0gq-0000nW-QN; Mon, 15 Jul 2019 13:06:48 +0000
Date: Mon, 15 Jul 2019 06:06:48 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
Message-ID: <20190715130648.GA32320@bombadil.infradead.org>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190713212548.GZ32320@bombadil.infradead.org>
 <4b4eb1f9-440c-f4cd-942c-2c11b566c4c0@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b4eb1f9-440c-f4cd-942c-2c11b566c4c0@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 14, 2019 at 08:47:07PM -0700, Yang Shi wrote:
> 
> 
> On 7/13/19 2:25 PM, Matthew Wilcox wrote:
> > On Sat, Jul 13, 2019 at 04:49:04AM +0800, Yang Shi wrote:
> > > When running ltp's oom test with kmemleak enabled, the below warning was
> > > triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> > > passed in:
> > There are lots of places where kmemleak will call kmalloc with
> > __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM (including the XArray code, which
> > is how I know about it).  It needs to be fixed to allow its internal
> > allocations to fail and return failure of the original allocation as
> > a consequence.
> 
> Do you mean kmemleak internal allocation? It would fail even though
> __GFP_NOFAIL is passed in if GFP_NOWAIT is specified. Currently buddy
> allocator will not retry if the allocation is non-blockable.

Actually it sets off a warning.  Which is the right response from the
core mm code because specifying __GFP_NOFAIL and __GFP_NOWAIT makes no
sense.

