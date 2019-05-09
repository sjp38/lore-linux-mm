Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B941AC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 13:58:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C4382089E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 13:58:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mWEhZ+vQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C4382089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06A2A6B0003; Thu,  9 May 2019 09:58:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01ACA6B0006; Thu,  9 May 2019 09:58:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4B386B0007; Thu,  9 May 2019 09:58:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAED06B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 09:58:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so1654561pfa.10
        for <linux-mm@kvack.org>; Thu, 09 May 2019 06:58:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rOY9E3+dek9YwLxHwXjgru83uQ3foeFioW100HDFl54=;
        b=PQk9Tb9qQM2SPv7LfOUWUAgC4fJ15/ib8sSrsOBKeXHsnCK3bD73yI05yEcavDUI2C
         W74d/kyq53dNbn+myxB1fzSfK6sToMYcT25MxTbBXpYpPMWwWwAx9Hpclorq/pIRRO3O
         i+NAQvxOPE5D0/CrXSzWPCeCLPBN1QY/J8PXhVDHsNIX8N0vaR2u4zRwz3fs+4C0/ggL
         vCxmVp1aN04CS7tKDmgE3sW6cTeTof0/jRm648RgfpKvMiV1NLu1Su4LVILEKUsQM3h1
         mZ9n+Yx55ZGDL1ADkJsRADRoOAArLJLFFRc4xbnTq/5AMUUaIFYjlne+ZYUAkHNhdISp
         yWtQ==
X-Gm-Message-State: APjAAAV7CFYU9PTWWoupcLB3rotFm9WDHTSTJpHTOi9wFCLtTjzskq/p
	fl3L/qOOHKtyMQE//uVybHeAJoL+iRwB7MaKLcY/FTQ2nxISmfWgOj3bVsKJ533aOmHjR/ZTO6p
	ldGH1k2EiHC/XGCVUtPmxcVueiCBDWWPi5NGlK1UjioSGt0f0YmJ+Lju27V8zJAmKpg==
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr5276956plb.217.1557410300199;
        Thu, 09 May 2019 06:58:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylirETpVdrPCwPBO4xKROcus7NWR+l5rUrdndaG51ewQw8/A7sxp+V1r8N8arugSLeL9qZ
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr5276868plb.217.1557410299439;
        Thu, 09 May 2019 06:58:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557410299; cv=none;
        d=google.com; s=arc-20160816;
        b=K/rFyskwqefLW9mE1oXFHd5kLfb2e2ydXQHplEMAj9qSXIaqiZVUzDooFmQOwA84Cw
         DBMe+sPesr7OsZcmfEmjGZIUeR4hWl1Mp5K/qjuu4cWjSU9z1O5d+cXOeXg/AXNqSZvq
         iOwvA8eyMtOMrJ79Haib0Rd0M+7T0q6hTeIX5/NDv74V5o2T2fBH6/RCcBiAQrupNCs3
         3BSL5/X4NvX2pj18IJX9Cj6Lt5cN09aFWnZWcGQlwRhSvgL3TDwEtzoAKpaUIL572R9s
         wMGGitsPyxk99AfPFoHyRf5HxXsw0O1HsOO4Fv0JZ2OvtETcl7MPQ4y8exZdBkums1rw
         /DEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rOY9E3+dek9YwLxHwXjgru83uQ3foeFioW100HDFl54=;
        b=Q0WCzhzsahBSd2fmWF/pd9vH+ur0S1e9qo8AehmU+gq5yaW24P4N2hmfCkPHyjqygr
         iYTSkyPUUX+R3E9RXwaqONzSqXGFfyyLs+Uozu8xLf7ObKn5XtxhH451PDvwcnpyK5EU
         ZYd9U11iX56eDrv6LR2bU0jvxMvsjVmTljWBIO/BM10n+zt3T2Goi93gV2NgpRE+VBaj
         sJLoeOsx6UgL5srWwSZgwle9eyJOmejKrg9bbjZfFyChNDPaPtJzrgh12peka6CLKx0B
         w+Klf3iQs9EvdHqo4ORQf5BlQz8zBfGV3+b9/G/5wDE5wpTh9glSHzsjKh5xrKOYjkBN
         8lhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mWEhZ+vQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h10si2820457plb.348.2019.05.09.06.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 06:58:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mWEhZ+vQ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rOY9E3+dek9YwLxHwXjgru83uQ3foeFioW100HDFl54=; b=mWEhZ+vQD6r6YIkqozH+3Q0Ip
	5Y2gb1Ka/X02WfBi5kTcf3BdwWalc2AXekXVzUBK8YBsaeuHYmpEafKONjZvIilCDmAP1mWBiU6K/
	mnLwN35GzqjPwWkCydMRHag/d0MhSd/JEJGBQAyiHy9eDejj5ovVOZJJfntDYr8pqcLgDwKJzawzM
	0c0ycNFdwgLuG+LE4ISm+H8Sp+/Jz4t2mSa9l44m3JUWGuTLzIFVq6bAPFmUnVFRMplNNq68qJqtF
	g7Y+yuxI4OzK4YRrGKojxWqC6MRSmFMFHz3Cw/+BOBXSCrmOBEpZ/oJwM6frbomHk4nyRjioDU3SK
	03IFfQ2Tw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOjYu-0002v4-MT; Thu, 09 May 2019 13:58:16 +0000
Date: Thu, 9 May 2019 06:58:16 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH 02/11] mm: Pass order to __alloc_pages_nodemask in GFP
 flags
Message-ID: <20190509135816.GA23561@bombadil.infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190507040609.21746-3-willy@infradead.org>
 <20190509015015.GA26131@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509015015.GA26131@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 06:50:16PM -0700, Ira Weiny wrote:
> On Mon, May 06, 2019 at 09:06:00PM -0700, Matthew Wilcox wrote:
> > Save marshalling an extra argument in all the callers at the expense of
> > using five bits of the GFP flags.  We still have three GFP bits remaining
> > after doing this (and we can release one more by reallocating NORETRY,
> > RETRY_MAYFAIL and NOFAIL).

> > -static void *dsalloc_pages(size_t size, gfp_t flags, int cpu)
> > +static void *dsalloc_pages(size_t size, gfp_t gfp, int cpu)
> >  {
> >  	unsigned int order = get_order(size);
> >  	int node = cpu_to_node(cpu);
> >  	struct page *page;
> >  
> > -	page = __alloc_pages_node(node, flags | __GFP_ZERO, order);
> > +	page = __alloc_pages_node(node, gfp | __GFP_ZERO | __GFP_ORDER(order));
> 
> Order was derived from size in this function.  Is this truely equal to the old
> function?
> 
> At a minimum if I am wrong the get_order call above should be removed, no?

I think you have a misunderstanding, but I'm not sure what it is.

Before this patch, we pass 'order' (a small integer generally less than 10)
in the bottom few bits of a parameter called 'order'.  After this patch,
we pass the order in some of the high bits of the GFP flags.  So we can't
remove the call to get_order() because that's what calculates 'order' from
'size'.

> > +#define __GFP_ORDER(order) ((__force gfp_t)(order << __GFP_BITS_SHIFT))
> > +#define __GFP_ORDER_PMD	__GFP_ORDER(PMD_SHIFT - PAGE_SHIFT)
> > +#define __GFP_ORDER_PUD	__GFP_ORDER(PUD_SHIFT - PAGE_SHIFT)
> > +
> > +/*
> > + * Extract the order from a GFP bitmask.
> > + * Must be the top bits to avoid an AND operation.  Don't let
> > + * __GFP_BITS_SHIFT get over 27, or we won't be able to encode orders
> > + * above 15 (some architectures allow configuring MAX_ORDER up to 64,
> > + * but I doubt larger than 31 are ever used).
> > + */
> > +#define gfp_order(gfp)	(((__force unsigned int)gfp) >> __GFP_BITS_SHIFT)

