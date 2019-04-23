Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9EC8C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 830F220685
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:55:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OY0kxQQC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 830F220685
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249996B000D; Tue, 23 Apr 2019 04:55:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F70A6B000E; Tue, 23 Apr 2019 04:55:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D5C6B0010; Tue, 23 Apr 2019 04:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7B406B000D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:55:42 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s23so149594iol.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Vzytoljj+XSZztNSEXF/+jHuvarC7Phi+bRc5Lds+2A=;
        b=IecS+WrW4eVsXvRcEcG1C4JY7I4TXNwsHe89d5D/HQcqEbBFb5TyqOUY6ZshELln1N
         V6AUHE1vuS37f20aPQDvEQMQcWaKPXwBaKm8RwQ3FA7v6sIchdKoMqgi8dRBDQIz9UE1
         N/8KTU3XD6ndBSYKXlW4u5cB3y+DnRRWLNcZZMcYLRobzo0MY7P8F6EhLTjZlhxcUziD
         ysOecdb4u+BV89lRzPgRrhO5FyuTd6g1CElE7CzkNmq/xvN2xPVhmVHLCqwUeLy7+gku
         yfSMu5aKkJ2VdgUxuPha+kE3/bQscg3ulAPR2hP14NUR0faF9jPhnUNDtEvFy5GGRJpN
         jupw==
X-Gm-Message-State: APjAAAXT3B3NJF+9QL9/p6nujj06JVIoNdEDTvekg5pvM9Sf0+ZQDQAF
	9PlhIyprK8CvfVN0gUJWmLAbEHF8Gz7lw/S6szUiOWEAdjwo6mCthtxUECwfSsTdGPyfm3bXIMe
	HiqSDPFnOJAzcXuGM9kuwYHTzOcq+SmqKWJ08OcxPZ+QyCjed0KQzCLeCjRKoLnZDNw==
X-Received: by 2002:a02:1049:: with SMTP id 70mr15599854jay.114.1556009742728;
        Tue, 23 Apr 2019 01:55:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylWJOPajoD8HEpZtwSQ61Wbd/BkTzl7pOsaE5GB/rV+nfaZA1UK/lbbEUGz6Fhn7GxHGdp
X-Received: by 2002:a02:1049:: with SMTP id 70mr15599837jay.114.1556009742069;
        Tue, 23 Apr 2019 01:55:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556009742; cv=none;
        d=google.com; s=arc-20160816;
        b=AUwcWLWFOFkQrnE064yw00uf72WUx4mHWQDOe912fIqv/YoiixmG/z3qztQo+ta0h/
         5pbigZ7GOimlMaRwalEf18dT3rnijRwGT588XmugtRNzsQlU0/5tPdbxQ/y67T1B7p3Q
         MvuweHBjIoRCGBsc4v+EJXRXcUIcv0VhI/LHZwVGrMy5E2G8JxYtThbL0zSucGSR8A/O
         eNAmrgLR/nYPDbwajimpUllLNcdDN/K+nTFn/7O5L1lVsjqlck4nrdvURIBdzt8Vx17H
         sYuwzKz0Lgp+6C8pXfEcz4nOHghXpdJm3tueTmwbY/6/ZYhbrs6pZ4osI796ZNHBFKmz
         eE8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Vzytoljj+XSZztNSEXF/+jHuvarC7Phi+bRc5Lds+2A=;
        b=l1dDipFtS9Psi475WMNaF+mMW7DHYjoVuEbN4Lxx3oc7pAD8XooItcfmQ7dT9eSpOG
         xQBpQ9xFQpGX0EVYZ7GdCo8ozGZDHg3QawdlzLrjB6tjbooUhAgU1q4ghEJ4UjzkftaG
         Vv9xfhSZfchRrv2Af2URichkyCWuyjmSpaRwCc9+96evMxfjrOuDZD4n6qRlYMroFV6y
         3ALOmwoVkA9+NNYExvB9rzcKkYJiGufbbfyg4+OMBRQ5y/S7FPmxBp5RB6G4v0hzXull
         WsSpY76w5rVoMIpk+nUyXWXrCTzP5lvLWXWGV1aZvymOlZkVLeuM3KJtd1Ljc1rv9S56
         H8Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=OY0kxQQC;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 10si9384159jaz.79.2019.04.23.01.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:55:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=OY0kxQQC;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Vzytoljj+XSZztNSEXF/+jHuvarC7Phi+bRc5Lds+2A=; b=OY0kxQQCWaRRFvkHxaJDDH859D
	doWhg6jMgGLA2qRh0WfVL/ddu4Vh2aX0cvCWc/bIv+uWFJLp72sDTev5Fv71xin+ob6VuaaOqMLiq
	QsHPWqnIph1yIh2nHyb6oYyiM00+ru8vQPfFBkBTWxUJ6o7624/yf80Ve9cfq5y7GXw15gsoY8vqr
	XtFVBZWWJ8rD7frh7Hz8E/EmqdEAN+o19CfwdEvTrJojsmmZmwI5c0II2G2J1T0NFzqMErUS5sKnx
	2DSRihH4gZVdTtuParDoBhWKnqTH6ThfX/euuVzAu0Be8x3dVocjoO0Al4I1AVfng9SResQ7Zkq8p
	3CgMcKQg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIrDD-0001M3-DP; Tue, 23 Apr 2019 08:55:36 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DB27329B47DCB; Tue, 23 Apr 2019 10:55:33 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:55:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 3/5] numa: introduce per-cgroup preferred numa node
Message-ID: <20190423085533.GF11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <77452c03-bc4c-7aed-e605-d5351f868586@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <77452c03-bc4c-7aed-e605-d5351f868586@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:13:36AM +0800, 王贇 wrote:
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index af171ccb56a2..6513504373b4 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2031,6 +2031,10 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> 
>  	pol = get_vma_policy(vma, addr);
> 
> +	page = alloc_page_numa_preferred(gfp, order);
> +	if (page)
> +		goto out;
> +
>  	if (pol->mode == MPOL_INTERLEAVE) {
>  		unsigned nid;
> 

This I think is wrong, it overrides app specific mbind() requests.

