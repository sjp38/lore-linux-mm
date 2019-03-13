Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB2D4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:21:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80D332171F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:21:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rOXZk5Fu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80D332171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7F768E0003; Wed, 13 Mar 2019 10:21:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2E288E0001; Wed, 13 Mar 2019 10:21:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E1E8E0003; Wed, 13 Mar 2019 10:21:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92D588E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:21:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x17so2256980pfn.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:21:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qhm8Lr5hnFfgUvoGYultIFT6xnErP++SakeNfih78Mw=;
        b=SROarQsk7jmJ+CYFz6oykmbDM+0KU1kp3Q+pCZJ+s5EDbrU7eWFZLb7r6NXksyGhjp
         bjU3cM39NTIMadt34UhrzlsC8rTHgreqMF3dZ4hOlZ+Ql0iAWSQ8lqutO2WZWoLqa4MC
         Vbfn67QTsyoicpJ4vIwVodEHFoosPIo/m0qLoeug6l6MD2Sok0o9WhKJlRpXSzrvxEMJ
         jW2+b6+IOxVus/YWHKstiCcOhVmdej8pSG7Kuc4GCM0M/K1dkuHzhtCcNux7UoL0F7Q7
         1cOFPTc0oHBOCau91OLtn9Gb3ocuCaAFk4X2MsDkcXbYn6AL8uilgBlNqS6hPu5noqKK
         c3/g==
X-Gm-Message-State: APjAAAWrl4alCEkzqAUY2xnfVRK7E9hnKMXXH9Y8eikmyTWUCc0eGZtP
	c8rKzbnr7NKLkfvL7OXwQlN2wvthQ5CQJch4JuJLYUXq5i0gaW9+e+8Ux3zY8F2jUCQQ2MXs5f5
	QH6Z4pste4d4j9qldFVfQUVieneZ1F6D6TjKGDyrj68jxdGVmpVj1iiqkNfusac/ioQ==
X-Received: by 2002:a65:63c1:: with SMTP id n1mr40008466pgv.339.1552486909204;
        Wed, 13 Mar 2019 07:21:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyohTxmumlmvxNt9JTjlIH20QjDIS2aUR7NDQTFsffeOfBmYGOe0V/nusp8WsgsDJXsV3l6
X-Received: by 2002:a65:63c1:: with SMTP id n1mr40008395pgv.339.1552486908219;
        Wed, 13 Mar 2019 07:21:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552486908; cv=none;
        d=google.com; s=arc-20160816;
        b=RNaJmP7wWEmtMn3d7c+vtDvHhXA1ILBsilcUNAuufMnKitKwWngWugGiZjXiD/0UT3
         n/2I9hMtaufmpwgM/Jsm2BW3SpZDLrpOOafST5cEbLlVgj4iLMtH1qvcI2IyngqNJTwl
         cRA7M4z75weAebCADscBhItM6oOCO1BRKbZLqXxzuZixt9sGdQOHH8sDH4+HYy9+/Rzr
         u4h7ZoiGxKJ3hAtA+2aJOrW5XwoUqliaJwCyrznPbzPUt30IZDwhQB6ZA7zjALqByhOw
         YhXHDBAypuOgI8dgXpkD5zJ7JuAutcDBFK6BAPKJFKGngztaRqU6t4v0pqt8uIXJtE1H
         1ngg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qhm8Lr5hnFfgUvoGYultIFT6xnErP++SakeNfih78Mw=;
        b=qhB5fU0oXN5n7ztFmcJ1NqzcByEmziSwwTyzWzCk31kud/KOwQpVax6ZnsKyV5pNgf
         7s0gwohfGXXp00DuEEhiI4G+Pw8af8AhScXQEeeB1GRMC4M3eH/TPBtgaZIzjrqnhZ1t
         UuzaGt81dJjlCoxHaJ4vGrzh9r79F4sJ17Vq3Dfda+LwvkGk3wz6/VPdHnyhGtx5AXPo
         jcyjKv3w62l/4L16HpKS8pt2aBQP7y0pOI6VxDvKU6mfD+CFh1V3Pnc3fD0tuFBUzat6
         uykwJ6d1SWH8e6/EYC+jKLB/9kEllz6RvFeLj2PnO170TUJATfHdfGQ4Q8xX0sVg1ZbG
         oxzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rOXZk5Fu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 34si9714393pgs.553.2019.03.13.07.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 07:21:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rOXZk5Fu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qhm8Lr5hnFfgUvoGYultIFT6xnErP++SakeNfih78Mw=; b=rOXZk5FuXurDzuueRpFx2i3gp
	21S9A1jam2CZyrAaiBlXHzuZBWs+/WA6SDs39Mbfb3/XQ4XLejxCnn26y2msKmCow64PT11bek1QB
	o+XmUQI7KBC2xU72EGtNa9zZgPrjr6AlA0V+Yj0fHlecUlu9Y9+YjXikWzB/pb/+46ub+xAg6F59S
	Gx877e5StWHo+z3xCcI4QY+w1OVLOFekyp+SUThgjqW4RDnYlsAtf/L30fsrNSDrjvfx4Rl87FHd2
	5oazK4HwBupcspy+jgyeICjsSix8hgB5woymEknKzNQSfDcU956SRcsumIqTs+C9hR0tF0Lzj5Vq9
	e5W7n4mjw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h44lM-0001GR-Jt; Wed, 13 Mar 2019 14:21:44 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0AD3420298565; Wed, 13 Mar 2019 15:21:43 +0100 (CET)
Date: Wed, 13 Mar 2019 15:21:43 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Qian Cai <cai@lca.pw>, Jason Gunthorpe <jgg@mellanox.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Message-ID: <20190313142142.GE5996@hirez.programming.kicks-ass.net>
References: <20190310183051.87303-1-cai@lca.pw>
 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com>
 <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
 <20190313091844.GA24390@hirez.programming.kicks-ass.net>
 <CAK8P3a3_2O7KBKTSD-QC5tcpohy8bkVVHsdAJnanTU1B+H12-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a3_2O7KBKTSD-QC5tcpohy8bkVVHsdAJnanTU1B+H12-w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 02:46:55PM +0100, Arnd Bergmann wrote:
> I thiunk it needs an '__attribute__((aligned(8)))' annotation at least on
> x86-32, 

I _hate_ that s64 isn't already natively aligned.

Anyway, yes, unaligned atomics are a _bad_ idea if they work at all.

