Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15F9FC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:51:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E95206A2
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 05:51:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="u3O8WGEJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E95206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ECF66B000A; Tue,  6 Aug 2019 01:51:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69CA96B000C; Tue,  6 Aug 2019 01:51:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58B1B6B000D; Tue,  6 Aug 2019 01:51:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 234B66B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 01:51:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j9so257641pgk.20
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 22:51:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m+FFhH6JYl0+VCC7puYYO1iplwknB7XNzlWvEFcSM1M=;
        b=TED6rYUgg08Y+ydZHOtfpNLzW9lq74Rc5JcSvYG+undqzJPTE6vDGXHSSHeHoyy3rp
         Vnf9xWD703GSkyVJry5MGm4A68m3NpJp9hWf6azNiHiwWkA15FogHFuK6kAvKLguux6h
         nNLpJ3maoivrvp3/4J4wUXuHq/Xm99wwev8yModGOmthLq9lT/0z/0bJJ4RxAgAU00FO
         YWqq2bmCTWXN2vPAzD5wmolhs2g0d68KjpBY5glZCzKbdFKJgvsXXIfrv4N865ZQFEkF
         8grWkBDNORLpK02BIdzFw/XgOV0TeV1lKPI84qyh+KSXTsV0EufLd1VIXqGDrQs6g+fv
         jsKg==
X-Gm-Message-State: APjAAAX8B9D2zp4CC+H1Dhu6cNqDfAd8xI5jWNtZW3JKdGw1+xBds5BE
	Q9lK9iJY0BpXUawS+xsTKEteckaMHO9qV0year1H0xCKTHvTdtVMwI+TziDYbkzRwZpVNJkoHUn
	n0V9MUij8Sd911BueIkVme9ldX0UWHnvdTktmtN5sq6MCBV6aQDJqE8D0siw4RO1ikw==
X-Received: by 2002:a62:b615:: with SMTP id j21mr1839741pff.190.1565070702744;
        Mon, 05 Aug 2019 22:51:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIDXKwuGfESp2xY9ERCMpa5bEtfL0mVYsRMOCm8gH/wVYWCUHnSnBtmfYSuxXgvHOnxBpK
X-Received: by 2002:a62:b615:: with SMTP id j21mr1839703pff.190.1565070702106;
        Mon, 05 Aug 2019 22:51:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565070702; cv=none;
        d=google.com; s=arc-20160816;
        b=BFYtvSW+z/WFDFy0QcsJLagi5yltftu32aMaUfHU/Vio7en14iIZMmo76K2fUA3aXB
         +nzXq7MKbUWcagDFvhb01IRSoIHvlO3cNolfcUQzBEO+ew1ZiCmMuzepbGmyVxSCxYaZ
         UyXFLRksWhm4sBm79sszb/gM8/NddnGV+Ltp4oELyXTdveZj7Ab0vUkNZTkFV/IgKoPF
         wKtsAYxnoZyQw8f/L6O4IfH/V2I+OCbmruBFP0m9uRU4At4otlaq1fM+A3oenuGr2Msz
         uS/Lz9sSEvP+1jPY4P1ecSNDYix+yGVVmgPa5+xT/QL/PIP3kgjdv6Kuly7dNb4iJvWN
         yQEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m+FFhH6JYl0+VCC7puYYO1iplwknB7XNzlWvEFcSM1M=;
        b=Y2ag10I9SLBcaHDYrbpcNtjA2he0dKGw+yhvxoqvmrb700RVYrRWZnAjJ/RN8gi76I
         +cTfcQAmbNMqclLE9bClQlccBk2XyHgEy9ms+RXgxmgUrCTF1y41KBRBA9vgKyzdBP1G
         Zo/FxtcCmHmynVIMyf7b74W/m252QKWWlCAVivxpYffjdFl8ug9wUORCVYW2T0hRhumM
         UK2FaWNlZLQunXGEULqisGlc2Q+UKhMZJnj+UYrXJGsvMpa5s0gn/7rODz5gedDuti+A
         5A+BJPjAxg56fqYFrcMpkMBsFV1MT6g8x0IccBvcTHkHJiCgbhijSJsmJWYBCUJZHTzz
         1SnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=u3O8WGEJ;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h4si14070304pje.41.2019.08.05.22.51.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 22:51:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=u3O8WGEJ;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=m+FFhH6JYl0+VCC7puYYO1iplwknB7XNzlWvEFcSM1M=; b=u3O8WGEJ5SkndaXpMMJfWkypL
	4dnNwB9DdlDQnIXYmKW6f97UCH2dGrKxK7t5s/AtxtJO85oN20L9FOpTbJ+TQ0eREGbmRIdB0Y2v/
	+EyD+GW9Yg2L8LyAScZkezBBFcUCRazZ378duIe7vAmVuOUd5+sBwLfcS/Ze53V/dHIfTnqs5nfuw
	kGEsuKahLO44X6fGWKK3kXqBzfok3Js1ShzBYRTqDhSpG7jW2WXVISrXTJkLpArRvseUvzkvsisqw
	ee9DVV25DCNDdBV05ziUDt2DVJI7X/1zV184FnB+H1QERyWnmI5fIiG9f/aiWzu9NjyGtFSZzxuxh
	BhMD+3Lbw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1husNo-00083e-2r; Tue, 06 Aug 2019 05:51:40 +0000
Date: Mon, 5 Aug 2019 22:51:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 11/24] xfs:: account for memory freed from metadata
 buffers
Message-ID: <20190806055139.GA25736@infradead.org>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-12-david@fromorbit.com>
 <20190801081603.GA10600@infradead.org>
 <20190801092133.GK7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801092133.GK7777@dread.disaster.area>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 07:21:33PM +1000, Dave Chinner wrote:
> > static inline void shrinker_mark_pages_reclaimed(unsigned long nr_pages)
> > {
> > 	if (current->reclaim_state)
> > 		current->reclaim_state->reclaimed_pages += nr_pages;
> > }
> > 
> > plus good documentation on when to use it.
> 
> Sure, but that's something for patch 6, not this one :)

Sounds good, I just skimmend through the XFS patches.  While we are at
it:  there is a double : in the subject line.

