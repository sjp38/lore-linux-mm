Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09227C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 14:29:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9A0206C0
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 14:29:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="ilwFB7fJ";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="GLNUu1vY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9A0206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49E8B6B0007; Mon,  8 Apr 2019 10:29:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 426096B0008; Mon,  8 Apr 2019 10:29:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EDAE6B000A; Mon,  8 Apr 2019 10:29:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA6D6B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 10:29:15 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id x2so10645199ywc.7
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 07:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bjb1TNxwO9IQ74vJIuqW39NOHI4Pt0ZKoVwses82HUc=;
        b=ECIR1IF0VI97Yq7KLrIUToip6fhB7uYiEY+ebFz2K27JoTjys+NkF4a0upM97I2AVz
         nBG49uD9n5vBoLR4dtXrLC1t2Ww0LH4BqY5folatsFgcnEODz8d3OMaekz9RwXhHYGaw
         SmrKLJ+SXRfOKiAiLGeqrTRxXHkypBCAw+wCtatWB2DZDVW+M95/lmd1LxuAM+18eT0S
         /LCxJI+q1FaV4c7SF49FrYopWgarZ+m3UjXYiCckINqpaefCYUsXhWr9PidTGCmj/8Yg
         OU05+MTVJrlBYeKpytxkA5Xvl5wqiOkIfBb3JUOeyB+nAebcgz1fG41u/PHr+2C4wNqK
         OOqw==
X-Gm-Message-State: APjAAAXI1vo4t2SzhNYJsP+CLuEv8LoIiJj5GQhb72LkgDifLsAJMTUX
	PNXwlrsdxWXHWyI1yy21TyJHrEyn4No8LQQxlDPyXvrsQSVIAGFAERXHUicg+N0WMcegCgqaPww
	XeRF9bLzyWx+K+QYRzGhKO7lz+we8JHfQA+qQUFfG+E0dLJdb4i65JpbfHWH9ElzfGA==
X-Received: by 2002:a81:71d5:: with SMTP id m204mr23630753ywc.462.1554733754698;
        Mon, 08 Apr 2019 07:29:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd+ZD0W3+b1KetM9bCPICu9WGAuxyytxLBMtSaO966elcjpeTA7mO5uAGhxw8/WljOowC/
X-Received: by 2002:a81:71d5:: with SMTP id m204mr23630710ywc.462.1554733754017;
        Mon, 08 Apr 2019 07:29:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554733754; cv=none;
        d=google.com; s=arc-20160816;
        b=GdEhCnQ/zIk1mOtXrZq0JIEYSF1sieUdIL1z1Jcn9FZRDRezol+7Cw8W26aeNZWUAv
         inFc9v7PSUQe3jKXXx4w3XH4O44NOFGYXlnKTohSN1lNYUUIMs6MF4TI6BNNJEhX+KUN
         nfrJT7GDRaX5sK152vxKAzUEmGqsznmX6pgNAT23bKjmjIrKSTGfWbMpNpTU2jfx6Lws
         R3XwmaPJusSvJPiPQVJOH9JMi0M3Hr+4Y0m9u9ZqQDQY09FLweu/z/+AzEc45BzZejHJ
         by0m2QHHsN8L0YzsOWtuW2npml6rXvCR1gnzxEGYuJAnVECzC7StynZfzcfvEyCIxyne
         yOEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=bjb1TNxwO9IQ74vJIuqW39NOHI4Pt0ZKoVwses82HUc=;
        b=HxFjIWWU9fep3qj/hrENZMgsgTcHiVM3kAllLu4GAOLbsUApr7fcyqpNJlRTnNEZWf
         L73oOd9AFEk4Xc4BADQmHsPLOjQAK6usWBL4BhPbBeAxgjOEHF+XK4A/T1R1VLRkVvOQ
         OJTf4gI+QbFpzHyCmAM6raAfxDuOapvMS4DboXZNkcHt/vhB4GjfgtSDRWQUzWwHYic+
         +PJpZ6KuyTCr7YHfEY3LIeyh+S7RxDsERp8qadIckocfEOmAa/HuhGpJZ2zRerRMMK1K
         S1ZiW/mUATZjb++JmhsQi9MoCulSjZSr1qYx9wHdNFZtQdv95E/j84/8lvtgEyu1ecFx
         3UyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=ilwFB7fJ;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=GLNUu1vY;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id e2si14380153ybe.268.2019.04.08.07.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 07:29:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=ilwFB7fJ;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=GLNUu1vY;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 5958A8EE0ED;
	Mon,  8 Apr 2019 07:29:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1554733752;
	bh=R2xhiC+0vMbSg7pyXTxfOfREJ8q93QOZwD4dtmqxljg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=ilwFB7fJ1cbzFOf0lhsWoMxFI35bb2euibmlYKN0cxpzcwEUYt2YgMhpP7icNK+4X
	 JkAQcPyRFWB6jaR4LO5qn5p8cHBh519VWuXd6+aSGznAPErnEFpJfWfNgQUW+vBtL8
	 ebxAmLJJyEGo/raFw3pF04m5c+D8owzM/hBhBE2c=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bADbGIfHE9TE; Mon,  8 Apr 2019 07:29:12 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 80F3E8EE062;
	Mon,  8 Apr 2019 07:29:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1554733751;
	bh=R2xhiC+0vMbSg7pyXTxfOfREJ8q93QOZwD4dtmqxljg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=GLNUu1vYWD0x6NFM0uqCmwhz6PZzlLG7BZZqdWvMjwsNnixiLPttT06aQEa8KPU7x
	 owAuI+OKkBHyI+lc6yGODSnZ5PLrq/QXDry2XXSaYf9qHi3OHu677NuE27baySRIHg
	 4WrQ7Rf5ffDnXRDCNt+tyLUbVpEMigHNVThrQlOI=
Message-ID: <1554733749.3137.6.camel@HansenPartnership.com>
Subject: Re: Memory management broken by "mm: reclaim small amounts of
 memory when an external fragmentation event occurs"
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Mel Gorman <mgorman@techsingularity.net>, Mikulas Patocka
	 <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>,
  John David Anglin <dave.anglin@bell.net>, linux-parisc@vger.kernel.org,
 linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli
 <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>
Date: Mon, 08 Apr 2019 07:29:09 -0700
In-Reply-To: <20190408095224.GA18914@techsingularity.net>
References: 
	<alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
	 <20190408095224.GA18914@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-04-08 at 10:52 +0100, Mel Gorman wrote:
> First, if pa-risc is !NUMA then why are separate local ranges
> represented as separate nodes? Is it because of DISCONTIGMEM or
> something else? DISCONTIGMEM is before my time so I'm not familiar
> with it and I consider it "essentially dead" but the arch init code
> seems to setup pgdats for each physical contiguous range so it's a
> possibility. The most likely explanation is pa-risc does not have
> hardware with addressing limitations smaller than the CPUs physical
> address limits and it's possible to have more ranges than available
> zones but clarification would be nice.

Let me try, since I remember the ancient history.  In the early days,
there had to be a single mem_map array covering all of physical memory.
 Some pa-risc systems had huge gaps in the physical memory; I think one
gap was somewhere around 1GB, so this lead us to wasting huge amounts
of space in mem_map on non-existent memory.  What CONFIG_DISCONTIGMEM
did was allow you to represent this discontinuity on a non-NUMA system
using numa nodes, so we effectively got one node per discontiguous
range.  It's hacky, but it worked.  I thought we finally got converted
to sparsemem by the NUMA people, but I can't find the commit.

James

