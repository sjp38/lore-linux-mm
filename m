Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A08DC072B1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:27:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45CED2596E
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:27:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hC2RgOug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45CED2596E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACCD06B0283; Thu, 30 May 2019 02:26:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A57126B0285; Thu, 30 May 2019 02:26:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 946956B0286; Thu, 30 May 2019 02:26:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0E76B0283
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:26:59 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c3so3279637plr.16
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:26:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nIiCMY3JsQadXOBewqvsYP0/w5h7JL3rPxkhn+Tzu2Q=;
        b=i8mcEO0GxHX9roOdaNg6PdAQ65ny2Sq+HvZauH11XuiltCdvAfnKUBuTtjw2Ab4nJW
         4R/sG0Eb6F18uZy6nIsQDgMTi/5TXniedCtDijn4DaTTe4D9UGucuyz8+Buq0wMXGIXp
         1eLC93I14mCl7OomSmOCS3xK5uK9qx8OEqvQ9v1HhrV23U9jiX9LXhve6vyzqdnpw/d/
         F2OssTzfuvlnhzhFdUsTwGNLICqeDrdTyISFJQtVK1vKi+39x2RQGjbl7si3OGf4o3mg
         mH59qnMWKc4kewOYUe4ZVrNkrNDt2V9lRzKVFSe098gjdVxOXnfNsjT9D8q6KEtloGPf
         RoNA==
X-Gm-Message-State: APjAAAX+72r3WUPccfAAoE4Uq7ANDfd5VeZzBMgkHpsFLjcMyhQMehF1
	s8atwMMerhnbGTavdlJFx8N7kpejYXQngETl+7ync/XrLxqQGHIefR4PHm7DO38X6iqgAM0E5tM
	zudxND2Y83MNkE6RsvXLaEjwoFy5VlQtfZxaGOzSRzrxiVusIg38a4yB0V3Fp2iXpYg==
X-Received: by 2002:a63:9548:: with SMTP id t8mr2285983pgn.256.1559197618936;
        Wed, 29 May 2019 23:26:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHMIUCKXLEcuB9xSdprkhcbHtKZ9b1xk6vyB8kQYfmZ0+yHvK/bhIUrlAUwaFoWJToDy+/
X-Received: by 2002:a63:9548:: with SMTP id t8mr2285951pgn.256.1559197618295;
        Wed, 29 May 2019 23:26:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559197618; cv=none;
        d=google.com; s=arc-20160816;
        b=M/rzXhpZv5r1sE4bP/lEj7THM9bUgWdJ6oXVYKDGsm1nCKkZav0DqBPwmFoWdTDzVV
         Mkw6FYcajN7KS0SHs9hla+QwkyCJmYQqq32pLH/l91bnhIsBdqMEQXtyIm+DS/J5ZraK
         tYjXuMKSTRoxB1m8SZ5c2L8MZx7jQs/Z/ihM/paocDJTA/JfAGcixWR+fDygW3LriK3C
         kTbmeCYig+9E+SzbT+Ng1yVAnmOvpOu/UoX7VZkWERGJqntAn1HjmZML0A2E0qD2VCtR
         ai24vzyVRdlSC0C2jpTFfuRzt7p3MUTgWdZYYEuWAyq+5J6LfZFvg0x7E7JDd75s/mdG
         3bxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nIiCMY3JsQadXOBewqvsYP0/w5h7JL3rPxkhn+Tzu2Q=;
        b=Aoaf8IIDbga9EwKhp3xce2a/ABf4fUQ33VBoa6QsQsWnpGmM/wKAqKpP14Hcdfy64v
         8cTwMGQ2hKapxBUYgsAJWv4NE9XKbpXVRGGPqHPj/HuRaFDiSvqIKqHJA0B9jZYC9LRG
         NXOcfHArrlJXx5KtGv0B6Xt3D3SMD5gSPDn4xGgpozqrq6x40jRtv0LvdrL1vQnbqyig
         iYvOInakxo1YX+t4qtkME+Ii/PflqprrD6xj4dyTn8dLDoDwwfNaKbTNOPtbasIO+6aC
         sU7VjlnHxAob4Y+O6TxWcODX+CplT3ZcV9HNBSZJs/xk19MvFgPNs5JjspuMd8gV5Z++
         tYwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hC2RgOug;
       spf=pass (google.com: best guess record for domain of batv+882e7947623448fb4484+5758+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+882e7947623448fb4484+5758+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m6si2133259pjl.60.2019.05.29.23.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 23:26:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+882e7947623448fb4484+5758+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hC2RgOug;
       spf=pass (google.com: best guess record for domain of batv+882e7947623448fb4484+5758+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+882e7947623448fb4484+5758+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nIiCMY3JsQadXOBewqvsYP0/w5h7JL3rPxkhn+Tzu2Q=; b=hC2RgOug0p2SCJXT6WId54KYZ
	v+nobRuR3mH8lkQdzbw3GRGrGXL36RcXf+S1IvOq3wwzeEcXxmTx0/5VfoaIk5wrOE9C0ueIe4pBB
	FUHhDeeqJ0gc26hf9TnS8BTkU0bkb1Al35adx+XB2zakVTJRbVXBNBjXezVRhvyl8Ua+k5Q6sw+Zd
	krQ0bkX4dB2nu+L2GxdJUMDNOIpY9gibsE2B7/kY12MlJd85SaR3S5PeWpZGI1lVbqLLg8V9w2xN6
	zdIxrfTikliPWXb1R8Ok2wTLVU0UACNGmhYIMMEtvFHagDEhBJJoYcpDvHZsulSmwMQWdQU5b8PCM
	n0tHsmioA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWEWS-0006ir-UP; Thu, 30 May 2019 06:26:44 +0000
Date: Wed, 29 May 2019 23:26:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yue Hu <huyue2@yulong.com>,
	=?utf-8?Q?Micha=C5=82?= Nazarewicz <mina86@mina86.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Dmitry Vyukov <dvyukov@google.com>, etnaviv@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
Subject: Re: [PATCH 1/2] mm: cma: export functions to get CMA base and size
Message-ID: <20190530062644.GA20133@infradead.org>
References: <20190529104312.27835-1-l.stach@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529104312.27835-1-l.stach@pengutronix.de>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 12:43:11PM +0200, Lucas Stach wrote:
> Make them usable in modules. Some drivers want to know where their
> device CMA area is located to make better decisions about the DMA
> programming.

NAK.  This is very much a layering violation.  At very least you'd
need to wire this up through the DMA API and deal with dma_addr_t
addresses instead of physical addresses, which are opaque to DMA
using drivers.  But even for that we'd need a really good rationale.

