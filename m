Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7DF0C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 18:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9083520868
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 18:37:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WTfyIvoK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9083520868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00ACB6B029C; Thu, 23 May 2019 14:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFD996B029E; Thu, 23 May 2019 14:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB9C6B029F; Thu, 23 May 2019 14:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9A836B029C
	for <linux-mm@kvack.org>; Thu, 23 May 2019 14:37:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i8so4755786pfo.21
        for <linux-mm@kvack.org>; Thu, 23 May 2019 11:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mcI32xfmsEoQcujsoa3t+R8aU7MbjBpf8zoUWNfm5Mc=;
        b=BTvuzgJZ4+UaUBebS2rmJqG1pxZlB1syil9vYd6VqWLI6fpNKqcwbdMah1trdIgPX0
         gezg3zQhKhX/03R0QWvxbUXwKUMrl2r7fSoEA+wEB5tJ7obJL3bc9Vx+iEVmZuuWQx/f
         hpzm+efgPlZRp+Sf+qdb/CRx6WDCHLlj9kdzphkWYokDwCJsy1Pve1Ee50AYaJIbKHwI
         20RyqPRZ476wc+4jl5Bx756SSpvMz8LYujSQ6T5xbrheOcDQMelLZtez2pzC+6kV6lq+
         oIunlyYgLtoJJCtna4EWxpd6zdPqvoq6Clnl+zFdaQNWv13aZr07QJDzNFZAvPuLDT/Q
         KZjQ==
X-Gm-Message-State: APjAAAW+QdpPGYPqiO+9jdUr0Ggbmj72l2H+xW+alHITZ0b2mAOu4Fve
	pUBNllcxfppfOzUYK4sZuudI0E2jquuPRkPI5BHcbS4hvvRBrRIOIja6KC4n535bWfwqtJaR4dU
	b0iT7UEB/9ZIumtfkyFH4yc3RcicCZOvURW/hjQP3myrb4VJTJpyTVVmtX7V/g+qp5A==
X-Received: by 2002:a62:75d8:: with SMTP id q207mr73833466pfc.35.1558636637369;
        Thu, 23 May 2019 11:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy70gvEt7fWMlIuMRyYWePqszmoGHmobv2jidnH1R8CxZZRDtH8nHTSAOPyPqL4Niq7He9Y
X-Received: by 2002:a62:75d8:: with SMTP id q207mr73833358pfc.35.1558636636462;
        Thu, 23 May 2019 11:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558636636; cv=none;
        d=google.com; s=arc-20160816;
        b=pq3UUAaCV7jQtsyruFNttgrXT+jXS1vP1akiFs+4uzSdzoqzWpoDvRa1I3sjUnlma7
         CfpMWlq11e4KPjpZKI28CmgTwBKZ859U8VhjpySwZ32JqVRm2mmDurjXFFtfU8hKUONF
         TOoVn/bph41HpSzPJ+eGnYcmNjKp1oGb7+uRct+hOrQbgD1Qqh6S4pGV0KbjJWW8ezT4
         IZn6DNKOiyfPs1WJtiq6OOddb8CN07eE28eIKRRnFSOWRfrIQ05ichphul6gxE6DcRQp
         knKrS4asxK1iTr7qtE524j9bfJI8h1MKBdJucG/lg78A253gzyoWq/FIa830ZpKI5/2v
         XUmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mcI32xfmsEoQcujsoa3t+R8aU7MbjBpf8zoUWNfm5Mc=;
        b=txHP4buutw12cY+soRB/Q2ptVHJcnt2uUVE31+AtAV6FRjwCe1O2Nt7Ulg9RUcLpcG
         C7kjzDet/loFwPIcZONRSyWf/E0ynFe1SNnIg33GuSl5PMkrz89bR4k8GeakSRxLTJ2V
         5r2VxO9wH3yXJFBUClQ9nx+G/QGXpdqI1/N7Tf8XmQOrsVilND0HTVtcDUm3CYTMJL0i
         hF1xJTA2209u5ysCh7eN1tU19y0RCHQU/qRTm2s6XPVs3RouKdTIPgbA4VU3P2ytKVn4
         i1sCsdI5o+DOM6vX7g+eJO7+gSDVyEYuQ3bst+oGzQ9e51QF45yz7MkKWoQDzUMAoKDc
         MghA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WTfyIvoK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d24si389887pgm.405.2019.05.23.11.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 11:37:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WTfyIvoK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=mcI32xfmsEoQcujsoa3t+R8aU7MbjBpf8zoUWNfm5Mc=; b=WTfyIvoKVJm2DtUE/xPqWyYm+
	Z0YNQ6XiR2MOOAu+0LvMWrNrpmIaQYlAXhcb1EkVK0yf4yZmSN3JFep+4miWgbPzPJyVVR1w1Ox3h
	auWVTq8Zue8S7pfTCV0sfCU3vS0Qj5jPsbsPCGHr3NmFY5ZATleXTeHZWt4MyNOdf8vSBkIPYxJLK
	wO6b+VxTYrkEOI2zTm0LvCjqyMZBGtB81IhsgJZT/Auj/8FA/F7FPWMtVr+s7sYDSF08ckTEKytJq
	+gsKFxg7ihVs8pvvq5JBdorV8+zoiycyDywe9Jjg40fmAAS2NrzkIVDXt2RQY16w8LqMQvAGnDAng
	4QH435N1Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTsaX-0005kv-P8; Thu, 23 May 2019 18:37:13 +0000
Date: Thu, 23 May 2019 11:37:13 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190523183713.GA14517@bombadil.infradead.org>
References: <20190523174349.GA10939@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523174349.GA10939@cmpxchg.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 01:43:49PM -0400, Johannes Weiner wrote:
> I noticed that recent upstream kernels don't account the xarray nodes
> of the page cache to the allocating cgroup, like we used to do for the
> radix tree nodes.
> 
> This results in broken isolation for cgrouped apps, allowing them to
> escape their containment and harm other cgroups and the system with an
> excessive build-up of nonresident information.
> 
> It also breaks thrashing/refault detection because the page cache
> lives in a different domain than the xarray nodes, and so the shadow
> shrinker can reclaim nonresident information way too early when there
> isn't much cache in the root cgroup.
>
> I'm not quite sure how to fix this, since the xarray code doesn't seem
> to have per-tree gfp flags anymore like the radix tree did. We cannot
> add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
> xarray api doesn't seem to really support gfp flags, either (xas_nomem
> does, but the optimistic internal allocations have fixed gfp flags).

Would it be a problem to always add __GFP_ACCOUNT to the fixed flags?
I don't really understand cgroups.

