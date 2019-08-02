Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFA6AC0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:59:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1B8F2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:59:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qKZqH04Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1B8F2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DDD26B0003; Fri,  2 Aug 2019 18:59:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F216B0005; Fri,  2 Aug 2019 18:59:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07D856B0006; Fri,  2 Aug 2019 18:59:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C10716B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 18:59:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so49141427pfc.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 15:59:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4Vp/kqP9japOy3ACodrJwRs1V+FSeqYXiepD5OU8/Pg=;
        b=Jwedc/S0pX5CkobkNJQQspmUM7BuPit02hx7MOfk5XsN3+ARRWbE848I3JyYuzPZlA
         DoFf1j6a0GXM8VPKFLnD3pCmdWGXlzG+i/w8AG563G4gOnscYujIT9nn+txrKNWQpub2
         DRNjoee0a0SZj/zvZ2Ud/quoZBPBu8f6ZQaV89xseo/JKbfONpdJS639OP719/sKXe2T
         tCxZrGc24YXs6uYlbVLixRv+10sOLMjGbvIPh8l3H3fnadmeTgxy3n1RFtTSZSQeMSjl
         F7nUdTYoWbWNa8tMKe25KLexAlzVeZo8M23dnQgJELz9HWp9QJm80X92NId4SHcPhUbk
         KvjA==
X-Gm-Message-State: APjAAAUb/kxi3fyrg1yndgXVMaW//FpLFPtO9bf3AThwbjaWNAxnr/tA
	h1xE1j5w3rMgHuwwlVAKPkE+TDeelSCfwAQf6cCfHyvxH4LB8ShqMbvafW7w2vfYNU7jvylHeg5
	DWrqaRAEEGFoKWo9KhlRDJEiUPs2SYnwfsIkcyQDhtaJ1nWlPRZ1G1HjK7cHOKnb/gw==
X-Received: by 2002:a17:902:7202:: with SMTP id ba2mr135771488plb.266.1564786785466;
        Fri, 02 Aug 2019 15:59:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwv2VU91TTu+3Ma/YISwvRWXGMPeC/C1lw6pmC9BCfhLLlRMt8R6ldnEXn+3yNyv67KiGdK
X-Received: by 2002:a17:902:7202:: with SMTP id ba2mr135771458plb.266.1564786784858;
        Fri, 02 Aug 2019 15:59:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564786784; cv=none;
        d=google.com; s=arc-20160816;
        b=uL+PNyTRgkjL3PTEo7Y4FgF76ew2eSfH2PQKCatH61Fr6qyF0SQzIwiGuocPspr1Wn
         NvjudPWeScOOGfb5R/Q0lZj8/aQfRI1WBuS9ZTrqBq1Mf06iJ7u9wX/sGm1oatsOCzr9
         Fgg6kiGi+E+cn2YRlj+QP9INCfRP6AXwCb7xYLkXXU8GR6yQ6OFeQJeBmxoUryLZw4Zb
         Yq24V/KPTvh75sezewRXvmW7OqLbwzAhxjbWxfoNnQ8gAe3/EqCzjf/ZFOJ/E9/e5k1G
         BK4/pDVKV1cDCL1uoX64p6MQ5D6UC2Xjf7iCJ6LuacF8/hI93C7jukelxBt4rnWKS0eg
         A7ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=4Vp/kqP9japOy3ACodrJwRs1V+FSeqYXiepD5OU8/Pg=;
        b=j9PJYZQ7fjaAt8YQtJdge7BgwWdOuzYLWs2K4nbu8ORVubQoWW1ZA2fVPAdPFfCIoj
         R3sJwMas7BxPBsFqVCVGhsUZXmMjfxtn1HmWjidqx16BbGVL6ATiBV2q7CQS3KUR1T1u
         1nEtNy3WdFFGXoJnd8HBRaIzvQDrKAzO10tDVCwP9zGHlNq4TxMCRF2ow7Ym0t7CSn75
         xJXyWe5D57teWQcsvqrp4swPE5bjkF1neXJSJHHX5/2ApVGnkiROTU5zOk9vz3A0Wv4i
         3D4UFBlvka+d29vDRch3oXuLtVhvu3eVTgA7J6b1rXkQUrKRIzpIdzMzZUV/H3jXDFqK
         M2PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qKZqH04Z;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i17si7413384pju.96.2019.08.02.15.59.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 15:59:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qKZqH04Z;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=4Vp/kqP9japOy3ACodrJwRs1V+FSeqYXiepD5OU8/Pg=; b=qKZqH04Z5Il/hHnxT/u/iLha8B
	WenSRYxHMj0u1ZloMPhq0g6W3hB7+FE9AQ4R30P1C3J7aQa1ytNC2T/N26tNJ4FWsBGlkijfYHsxX
	UEYJBazuzGCdPoFBysXcXrkbSYWFkTNL4K38eV3n1fbdQu8ikuBK2gQmnFVnlCPpbd/DKS7xrlcCm
	1jHEuppTBrazcYe0A57CpIROQcyKrNvjl9ZNdspZPTx3AI2PaMDyJ1tWm2MLZyhre7wPX4USF933R
	kiVnEgHWD2atTokkjOx8fRL+uNE2pbJYu0R28sazP4B2iXaGpcwJjh2I8ADyClABJaInyn+mM7FQZ
	qUD5+fAw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htgWR-0004QR-HV; Fri, 02 Aug 2019 22:59:39 +0000
Date: Fri, 2 Aug 2019 15:59:39 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, petr@vandrovec.name,
	bugzilla-daemon@bugzilla.kernel.org,
	Christian Koenig <christian.koenig@amd.com>,
	Huang Rui <ray.huang@amd.com>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
Message-ID: <20190802225939.GE5597@bombadil.infradead.org>
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
 <20190802203344.GD5597@bombadil.infradead.org>
 <1564780650.11067.50.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1564780650.11067.50.camel@lca.pw>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 05:17:30PM -0400, Qian Cai wrote:
> On Fri, 2019-08-02 at 13:33 -0700, Matthew Wilcox wrote:
> > It occurs to me that when a page is freed, we could record some useful bits
> > of information in the page from the stack trace to help debug double-free 
> > situations.  Even just stashing __builtin_return_address in page->mapping
> > would be helpful, I think.
> 
> Sounds like need to enable "page_owner", so it will do  __dump_page_owner().

That doesn't help because we call reset_page_owner() in the free page path.

We could turn on tracing because we call trace_mm_page_free() in this
path.  That requires the reporter to be able to reproduce the problem,
and it's not clear to me whether this is a "happened once" or "every
time I do this, it happens" problem.

