Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACADEC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:42:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C03127412
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JaGOnQRJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C03127412
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDEA46B0266; Mon,  3 Jun 2019 12:42:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8F8A6B0269; Mon,  3 Jun 2019 12:42:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7F576B026B; Mon,  3 Jun 2019 12:42:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8018C6B0266
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:42:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u1so8537092pgh.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:42:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PF/DPANZU4B/91WFDIx5XMAZHVrwBhQKQlUd+pBcvEQ=;
        b=eo6Dseazf1Kxm/y3xGKOJUPkrlaSB7UIpdKVL7XpKRWE7bhqd6PXN5N8FdG+Y4Z/yE
         APgwmCLPl2R8L2WvSFD515k2QDFFCH/Q2NdPmo04ZxmuYs5Wac48kiVOELr8vof5Phn9
         FhTN2XO3/dYSSfFXplZINrml3qQOtuZbrLoad/tHlrdQ1zfwFSjXBjI3ZtS7oEmCJSAG
         HQLupqj9jyfeh7tLW5i0Ze6NKZ0owPgOR7Ow3R9fwUbqpHlgD9leIfc/hmDNsLkmTInl
         vGDNgLPg+mXOT2+pggPRHArLR3zv31xmhBpIPkO2ctao9UtAip8ifjg28a6RKzb+u3EG
         kR5Q==
X-Gm-Message-State: APjAAAWTVVVd1ZYy3iywgVNSDQVTQjFWATycTdKogQHmr2cXBoBidiKF
	Iy6R8CC7wj+5lhjWGYLnD0mVUJpJFd/gVahZFiXUBcl1PW6SEb5wDyZt8YlABcKLzlZdJBs6hBv
	UhGqrXV2GP9cjNGhKlpSwYt4tJQRPwWzRw672x06UvtaoiMWdSgQ2Svjt+uhcqX46Pg==
X-Received: by 2002:a63:1c16:: with SMTP id c22mr30849197pgc.333.1559580128200;
        Mon, 03 Jun 2019 09:42:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoAKYUbV5piI/uC6O5U/lFOSIVLkef+3Ff4bZsb7ly45BS/qhIa9EIR9Zu1Ob5AcJLriLL
X-Received: by 2002:a63:1c16:: with SMTP id c22mr30849122pgc.333.1559580127535;
        Mon, 03 Jun 2019 09:42:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580127; cv=none;
        d=google.com; s=arc-20160816;
        b=0scQacUY8b/CBF6vaqkWERuLnzOXIU04LjYYh19ib9PK8ABA2LnqaFarbtZA51jKcT
         Yt9UgKoFwkR/TCXZoCaY+iPLCae8VvsY2fhHso1HQT19URVKtYJs6zTKaDXeR0anq0ne
         hkuWuJF+rdrJ4LDz8sg/zRoLir1Q1tImyjn/ANF+DKw7OV3/lPxI1aLekrRILPbl3p9V
         98DrHfxkTLRNYc74+AJL/czFDTNPu6b6vZ5TdT8H2JeuknYf6vq2TGbh7b+bRQkASwdD
         ErpL56ETvAtEBaQOeI0n07TlIGjtr7ej8vDIZcF9s17ihk+rFB42f9ygttLB3ttjQWMa
         ZcvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PF/DPANZU4B/91WFDIx5XMAZHVrwBhQKQlUd+pBcvEQ=;
        b=UjLKmJ9Zgd8BWk4CQhPSKtIDVLhW1Da7jGo30GQJWvb0xFdS99kIPOPdnMHzK8Y1VO
         dpYrA/dso8yEjxKiLH7FmleynxWHnHZEgFksLX0SNgbWJXXC3OmUcqqLwiPvAL6coSN7
         V7G7pLMC8gGxsketqmZ0KOB1BoQeMYXJ5yp/twdrTiR9YsjcyBSFwdD4UOTuiAL4O3BP
         YJyRwD7UWBxo2+X2404KS0KSggTe91AmKdYnW7MKr6bkIdqnTdbkpFQ17IPkJMSeU/mO
         wq/6cTlzXtO8fmoGqHAIsizUY8jH/J201aKzCBv7/IunqCUEnR/bPfhWGwsVR5oQobIM
         W0UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JaGOnQRJ;
       spf=pass (google.com: best guess record for domain of batv+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t7si18096157pjq.53.2019.06.03.09.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 09:42:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JaGOnQRJ;
       spf=pass (google.com: best guess record for domain of batv+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PF/DPANZU4B/91WFDIx5XMAZHVrwBhQKQlUd+pBcvEQ=; b=JaGOnQRJd1s1Tei2klsqm9Xw/
	K+z8AjG++0f7WOFL/9N6Okkg4uIaPUTec2wS0KZv9WBhCaHl/IlAg12WlNGF9X3X1ne26v6tNfcRm
	baazZKctsmnFG3aRsZx9tnHSrz9yxqhAKpKpiJ1sfbSRzxS/uDGXrmsE0lPn/YhAz4qbBZrsD3WEp
	FbTU1Uf+Wizk64U4jhZaOSb/xG1FH0WAO0PocMjrBCWoPs/TFenlK4ecED2g5xHbefvRUt0vQb5Ky
	fsv04MugJsd7+QypPkbI1we9jNwnpg22UdePuUom2zg4VPZISZ9R3lbk3EDd4sqSVYBhL1ouD3fwO
	dIMR8XMFg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXq2A-0002Ps-63; Mon, 03 Jun 2019 16:42:06 +0000
Date: Mon, 3 Jun 2019 09:42:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190603164206.GB29719@infradead.org>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +#if defined(CONFIG_CMA)

You can just use #ifdef here.

> +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> +	struct page **pages)

Please use two instead of one tab to indent the continuing line of
a function declaration.

> +{
> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {

IMHO it would be a little nicer if we could move this into the caller.

