Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 896FCC04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:34:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 483C3216C4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:34:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oncT9ByR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 483C3216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D58D56B0003; Fri, 17 May 2019 12:34:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D099D6B0005; Fri, 17 May 2019 12:34:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD1FA6B0006; Fri, 17 May 2019 12:34:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 870A86B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 12:34:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c7so4868880pfp.14
        for <linux-mm@kvack.org>; Fri, 17 May 2019 09:34:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Gfmhm1QndU1vd1KEmZzYh+ZiMXcMk0B49UsIQYdD2dY=;
        b=lpeD37E85PP9rNjZoCQU4fZLcPM7vSQd48+vu8N8LgLjEG9D5NekMWue+wQ5Ti1xsI
         rofOG/mWO+SGZaTSUsIEAZpnModRe+I8Ars6n8wW5s66mutPkeTQ5K/KcoyDrCpRG6Ne
         l0RPe5lv1IfcqXyvHZqEX2vv2T0TCXqsX1ifP+P1CdXIgUDDgZUdw6lolZ67g8ssqzOr
         nORME/5IE9hdctHQ0qFljwvXAaiyUBZAGMfEM1J9/4C0FIfdjluAXEfKlf28AvTOpvN4
         CnKGpQcM+UnPifQhrY7+c4eauTPNOoW1iivqoTRhrPYTF2S04mtBPJGGFc4fAlXGrIUD
         EG9w==
X-Gm-Message-State: APjAAAUm/YR/6Wala1vgKUlA0PHDIp3vloIyIWFmFYSkBQ1phVIv6SNK
	o9TvW3z9tL8gUPpzlIbj3zGxZoWrajoreGaAmg50EHfRQYMRqBPn77loQbDDw5LwLpF4tq4abYt
	YdNOaLP0APeQmoaucpbzjquecPvN2kFwYMkZWD3JhV1ttw2Xx3Dga/bqC+o+9M+ONMQ==
X-Received: by 2002:a63:fd52:: with SMTP id m18mr57975255pgj.267.1558110863168;
        Fri, 17 May 2019 09:34:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf2uOuQBfPqUg+KgVes7klC7KkSYr2ufLqbCAZgr1nlsXhK47duubCziwX2DaTxGFWi7io
X-Received: by 2002:a63:fd52:: with SMTP id m18mr57975197pgj.267.1558110862440;
        Fri, 17 May 2019 09:34:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558110862; cv=none;
        d=google.com; s=arc-20160816;
        b=WiMarlN4RJ7xmBpSrxYTa9yK+SVifq0iWLOZuGW5xXLpLlCcdiV22u+MYCmd7fNGgW
         X9TdEd+KE5IZNydEjTCsbbVg1pKsb12yC+M11QfmYAacmKOAtCdCBVH81b54a14+ETrj
         +ADl1d3gKGgGwCaqdlsCy7d8gULDl60RjGab4hTnaGpVALIKepQ/7fNkK8rwZTCYKMaO
         KO25MKjEoeCmXQDThWMEaY9lyCRtlZhWb9GIczRmxi5RgL+6/UXQBmKHct2rAQ7TPX+p
         AKvrNe2cNCdDmr5FS1NYIuXLQ2HFjvGKmf9iS4OwDpW73d2NzhLJpUEOZ9tUNusAYC8r
         ZUjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Gfmhm1QndU1vd1KEmZzYh+ZiMXcMk0B49UsIQYdD2dY=;
        b=FtXVL128nJIRW1C5Uw9duoHdeWONBMTo9jFBC3Wc1ll60RX+HQLB339RVx7njgdrU8
         fH+qfl8bjOZKGPUqrWSl8bkOVTzRJ2dO5a9+OpsQ8p1GlGvkHckrHKS3APweALrijAZt
         iYy59lCPlK2xoOyAAllxcr/0Tq0Y1zlBlyWemNPoBnCP/hrnXW2UZVakpeTZKW66RDpZ
         2L1z4+xAeEbwyd7beJ0yHiZEDJ15bdkLqbcnclGcXkd2YH7aeLrxxthjBjyrgyHC97id
         D24LjdWi3oQUPGtORMqpSsh/FLsOU8yE5mXkoZo/Eo/ipdysOEJePvSRwGftEQZjBOWi
         EJCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oncT9ByR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b13si8580129pge.437.2019.05.17.09.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 09:34:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oncT9ByR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Gfmhm1QndU1vd1KEmZzYh+ZiMXcMk0B49UsIQYdD2dY=; b=oncT9ByRFsu0LIodjLvi9FTXl
	B/LOhGID0QvmlZPRC5j2ltiGoiPdmoOFyFLY1k/V3UaaLked3INDzOiNZmLdkTHFvtvHmo4iLSSpj
	y1hqmUexfR8Qhk9mNHA+EMLMcS9HqKL5fhpZIvbNrCYJxOtPXfJt1aFxJkDlD6OLngDMoXVoh+VFQ
	GTsJ3fHQ0lx76k6yEztxe0DGZ6CVIVq4AA8jVgmVrVXMPDfuJxIt4227EKDZrwDNye969GcP3PC5W
	0sh5QzdtGZNC1dqNYRhwmJY4EUlsTVkaH7ZoEKyqb2FPxcDcqGZGGBZa7fkS/9sIQomHVg+gIWV8/
	GxFHUoq5Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hRfoK-0002UT-DP; Fri, 17 May 2019 16:34:20 +0000
Date: Fri, 17 May 2019 09:34:20 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jaewon Kim <jaewon31.kim@gmail.com>
Cc: gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
	linux-mm@kvack.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jaewon Kim <jaewon31.kim@samsung.com>,
	ytk.lee@samsung.com
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
Message-ID: <20190517163420.GG31704@bombadil.infradead.org>
References: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 18, 2019 at 01:02:28AM +0900, Jaewon Kim wrote:
> Hello I don't have enough knowledge on USB core but I've wondered
> why GFP_NOIO has been used in xhci_alloc_dev for
> xhci_alloc_virt_device. I found commit ("a6d940dd759b xhci: Use
> GFP_NOIO during device reset"). But can we just change GFP_NOIO
> to __GFP_RECLAIM | __GFP_FS ?

No.  __GFP_FS implies __GFP_IO; you can't set __GFP_FS and clear __GFP_IO.

It seems like the problem you have is using the CMA to do DMA allocation.
Why would you do such a thing?

> Please refer to below case.
> 
> I got a report from Lee YongTaek <ytk.lee@samsung.com> that the
> xhci_alloc_virt_device was too slow over 2 seconds only for one page
> allocation.
> 
> 1) It was because kernel version was v4.14 and DMA allocation was
> done from CMA(Contiguous Memory Allocator) where CMA region was
> almost filled with file page and  CMA passes GFP down to page
> isolation. And the page isolation only allows file page isolation only to
> requests having __GFP_FS.
> 
> 2) Historically CMA was changed at v4.19 to use GFP_KERNEL
> regardless of GFP passed to  DMA allocation through the
> commit 6518202970c1 "(mm/cma: remove unsupported gfp_mask
> parameter from cma_alloc()".
> 
> I think pre v4.19 the xhci_alloc_virt_device could be very slow
> depending on CMA situation but free to USB deadlock issue. But as of
> v4.19, I think, it will be fast but can face the deadlock issue.
> Consequently I think to meet the both cases, I think USB can pass
> __GFP_FS without __GFP_IO.
> 
> If __GFP_FS is passed from USB core, of course, the CMA patch also
> need to be changed to pass GFP.


