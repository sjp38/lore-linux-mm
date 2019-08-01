Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0230C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:08:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83865216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83865216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B2628E0019; Thu,  1 Aug 2019 10:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 161618E0001; Thu,  1 Aug 2019 10:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 050FD8E0019; Thu,  1 Aug 2019 10:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD4A68E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:08:24 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b6so35541335wrp.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9Krm7V9dm1DW1xERMxJYYqhRiT0zghcWUSHdiwkOOLk=;
        b=a/X5Ktmi2X17CC9JLCVxUUPVZmKav1oKGfV90cGKSyNOYTQLZOZeuydbcgvBLjlEwk
         UBbl0tx2RWt3//kwacHdGvQ6a/cMnBDAjVw7OtTB55lFYV0p8dHelVBLOr63GT9VZjgs
         AUDs/D+tTHYjxLg8IGUt+Uj5Gj0YO/dNvjUhIvvCdllXe/Do10QxBnK0MFJIB0sFG0AN
         q9sU1Kgn4LNrXc+SMDViVgjGFY1NkcV/y+p3lK3eJyAt5xvg6Oe/aEQNJH+37reVXKR6
         9I48sdpqwVQoyfvOBjkSmccyVdzat5vZlK+vp3A33EhYCJcOjMd8VCo45nQ4jqw18lbq
         1yFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVUQVfIYNaMdkK/NiDWVFCwAfptLQfQrHfONJu42MZdTwYXKw8o
	Hk9QQSN2QpnJ7UChC3TNMxbcNt8Xal6lnKuWQPCyHhg+aefQlHRzI+wn6JNsaEHCI3we/3/dZO/
	qkVzjdlVuczRykB6lY+AfqPDebrj7lPkmGUYXmUQqWjSxbsMveM9iV5xI8p9QnZwrgg==
X-Received: by 2002:a5d:6a52:: with SMTP id t18mr3254934wrw.178.1564668504279;
        Thu, 01 Aug 2019 07:08:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy60V+124vr60Jb78gE/1rM/nilt/8v+WXRjhR9iKFGpWah3aVC7aVPiZ8KqjcjP3akfKbq
X-Received: by 2002:a5d:6a52:: with SMTP id t18mr3254880wrw.178.1564668503604;
        Thu, 01 Aug 2019 07:08:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564668503; cv=none;
        d=google.com; s=arc-20160816;
        b=mjwk3oPqR+lvJeLCyAKcQnQN7NRitcAkWCc3rBW2d69YZQVn4tHmBGL/NKULJpamd4
         JCv7u2h+YmvyRv2sFzhDWRwGAhiufc9JakBaFHJxpZFKv1it8gQJH1QjeOGOidX0/CZP
         xZYbYZmvryycqEsGOmAg/bRNbZTpB0ZtFkdkm2ffRYd/0+HZ1N2W30jG9KjnuQkqDT5W
         M87OF+ftyR8Gm5cNuJWEnzt4OcIPFE6JMHKiG+bYgWB7aAUyGzeL4hkrKoStOrkxUVFX
         1t63EzxwUqsqceOCW1lrp2XWJG+t1Y5pDtE9qM3NO/keltVXlnZVWHgMFg9shF7UwwUd
         7ElQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9Krm7V9dm1DW1xERMxJYYqhRiT0zghcWUSHdiwkOOLk=;
        b=we8IPCvONqdol7zYHoXyFo/hjnOQR9LCtE+rdzLevpbehT7+l9YgWxnxC9HurJcHcH
         2cW/6SRLUht3RTxyeqJjHywweq+TbGyGzQLiQ93hxnP+mE11Jc4gpm6eznghae1+A55b
         YtgrSr8HNV8mot/nF53vslXLJCpSFlHMZIpTqfNaK1VgXdcytq1yGn1/IEyH2kXsnO7U
         8VYuVvZ04dVCCyjPll55cK9ANmUEECyLekvxXFogh4wQMXjkE0rw0Fw9CoXxDFWxGZrW
         MFKhprXH72mKMNEvI3RsjAGRS0KbXVEXW0gw3FaEmn5EsUmH8aOHEuUgCWP0X6XZ+9On
         YILA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z11si56430075wmi.85.2019.08.01.07.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 07:08:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7FDE168AFE; Thu,  1 Aug 2019 16:08:20 +0200 (CEST)
Date: Thu, 1 Aug 2019 16:08:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: catalin.marinas@arm.com, hch@lst.de, wahrenst@gmx.net,
	marc.zyngier@arm.com, Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, phill@raspberryi.org,
	f.fainelli@gmail.com, will@kernel.org, robh+dt@kernel.org,
	eric@anholt.net, mbrugger@suse.com, akpm@linux-foundation.org,
	frowand.list@gmail.com, m.szyprowski@samsung.com,
	linux-rpi-kernel@lists.infradead.org
Subject: Re: [PATCH 8/8] mm: comment arm64's usage of 'enum zone_type'
Message-ID: <20190801140820.GC23435@lst.de>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de> <20190731154752.16557-9-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731154752.16557-9-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 05:47:51PM +0200, Nicolas Saenz Julienne wrote:
> +	 * Architecture			Limit
> +	 * ----------------------------------
> +	 * parisc, ia64, sparc, arm64	<4G
> +	 * s390, powerpc		<2G
> +	 * arm				Various
> +	 * alpha			Unlimited or 0-16MB.
>  	 *
>  	 * i386, x86_64 and multiple other arches
> -	 * 			<16M.
> +	 *				<16M.

powerpc is also Various now, arm64 isn't really < 4G, ia64 only uses
ZONE_DMA32 these days, and parisc doesn't seem to use neither ZONE_DMA
nor ZONE_DMA32.

Based on that I'm not sure the list really makes much sense.

>  	 */
>  	ZONE_DMA,
>  #endif
>  #ifdef CONFIG_ZONE_DMA32
>  	/*
> -	 * x86_64 needs two ZONE_DMAs because it supports devices that are
> -	 * only able to do DMA to the lower 16M but also 32 bit devices that
> -	 * can only do DMA areas below 4G.
> +	 * x86_64 and arm64 need two ZONE_DMAs because they support devices
> +	 * that are only able to DMA a fraction of the 32 bit addressable
> +	 * memory area, but also devices that are limited to that whole 32 bit
> +	 * area.
>  	 */
>  	ZONE_DMA32,

Maybe just say various architectures instead of mentioning specific
ones?  Something like "Some 64-bit platforms need.."

