Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F39C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20CDE206B8
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 13:52:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="krIXjZuV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20CDE206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC0566B0006; Fri,  6 Sep 2019 09:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B71D56B0007; Fri,  6 Sep 2019 09:52:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5FCD6B0008; Fri,  6 Sep 2019 09:52:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8099D6B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:52:18 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 04E1A180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:52:18 +0000 (UTC)
X-FDA: 75904635156.24.crush32_886afb2c72055
X-HE-Tag: crush32_886afb2c72055
X-Filterd-Recvd-Size: 5826
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:52:17 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id i8so6311711edn.13
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 06:52:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pSwKQqKejHvomA4UPmYTw+LwVuiZyDGPrk1Lq89yOlc=;
        b=krIXjZuVxCJl33L5P7YERwE4VpW6UrHy0iuJSfbsUbAM2HhB6s8TIJj2x5Hf3zSSY1
         MGNmvNeJHedKm9o8yTZ4y3OWRnSZpy1E89bkh8N6KCZcGEvnUD2QDqGx4aWMI4mJGvcL
         Ppngok3/qzQFA60NDMu9y3Q2d+DBULexYZr3CRhAE2biifMMgReAKg2wLCahJVaZmLIe
         U6QyykZqKzBuNjnaOLd6b5CpCS7/4xcWLvjvu94C9WJ0MilQrePsupa948MD7IKO/fA+
         lBnIO/x45lK43GFvdSCfU7J+usjhIpohx3G5q9zUwCDJbMKC787DRIQfcSfSI0yFIUE6
         9ARA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=pSwKQqKejHvomA4UPmYTw+LwVuiZyDGPrk1Lq89yOlc=;
        b=spFHKqkh1GHP9h6s5dUr4giANoZGO1Hb4i0OYhfQiCr5qtzzDPR06pVvQnyMPVTDU/
         nabdsIa9ZL/CpFMvpqI4WZWzi/DBBBZdxBAI0gss7NiezlIHQXFdYAfmx861v8BTTp1b
         CQt05zlNzm5T+9Twf8ODXwKkLBP/0aEW6UNiBfdKpnWIURq8aiIJm9iP94i71dTHmuWS
         EOGGSNROmD0DCeSlFa+C2TR+wmssxlrMFAWm1PqXZQCbEDT4cVLIaSk3QXuX3io1JUyF
         JxV0ZtutqqNS0hZqncUz76BKwfL9OxVSQY5O3nj2cl5Ro8JZcCau+hisLXaQsUOeOneL
         YpcA==
X-Gm-Message-State: APjAAAWqzjYHHQB1hmI3HQtmQDh3oU+KcoHWTguY+RF3w3uJ3Eg5Mfsn
	wCGqxndB+4cX2X6C79PHNm8XbA==
X-Google-Smtp-Source: APXvYqw0w8tC1bR5JsQaeK6MSBWtjs6baFEFAYcol6N9qf3I0kpnA/iP0itaefwAoZGEL3PxWMG0Pg==
X-Received: by 2002:aa7:df1a:: with SMTP id c26mr9588705edy.106.1567777936212;
        Fri, 06 Sep 2019 06:52:16 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id g6sm955486edk.40.2019.09.06.06.52.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Sep 2019 06:52:15 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 4DA191049F1; Fri,  6 Sep 2019 16:52:15 +0300 (+03)
Date: Fri, 6 Sep 2019 16:52:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH 3/3] mm: Allow find_get_page to be used for large pages
Message-ID: <20190906135215.f4qvsswrjaentvmi@box>
References: <20190905182348.5319-1-willy@infradead.org>
 <20190905182348.5319-4-willy@infradead.org>
 <20190906125928.urwopgpd66qibbil@box>
 <20190906134145.GW29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906134145.GW29434@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 06:41:45AM -0700, Matthew Wilcox wrote:
> On Fri, Sep 06, 2019 at 03:59:28PM +0300, Kirill A. Shutemov wrote:
> > > +/**
> > > + * __find_get_page - Find and get a page cache entry.
> > > + * @mapping: The address_space to search.
> > > + * @offset: The page cache index.
> > > + * @order: The minimum order of the entry to return.
> > > + *
> > > + * Looks up the page cache entries at @mapping between @offset and
> > > + * @offset + 2^@order.  If there is a page cache page, it is returned with
> > 
> > Off by one? :P
> 
> Hah!  I thought it reasonable to be ambiguous in the English description
> ...  it's not entirely uncommon to describe something being 'between A
> and B' when meaning ">= A and < B".

It is reasable. I was just a nitpick.

> > > +	if (compound_order(page) < order) {
> > > +		page = XA_RETRY_ENTRY;
> > > +		goto out;
> > > +	}
> > 
> > compound_order() is not stable if you don't have pin on the page.
> > Check it after page_cache_get_speculative().
> 
> Maybe check both before and after?  If we check it before, we don't bother
> to bump the refcount on a page which is too small.

Makes sense. False-positives should be rare enough to ignore them.

> > > @@ -1632,6 +1696,10 @@ EXPORT_SYMBOL(find_lock_entry);
> > >   * - FGP_FOR_MMAP: Similar to FGP_CREAT, only we want to allow the caller to do
> > >   *   its own locking dance if the page is already in cache, or unlock the page
> > >   *   before returning if we had to add the page to pagecache.
> > > + * - FGP_PMD: We're only interested in pages at PMD granularity.  If there
> > > + *   is no page here (and FGP_CREATE is set), we'll create one large enough.
> > > + *   If there is a smaller page in the cache that overlaps the PMD page, we
> > > + *   return %NULL and do not attempt to create a page.
> > 
> > Is it really the best inteface?
> > 
> > Maybe allow user to ask bitmask of allowed orders? For THP order-0 is fine
> > if order-9 has failed.
> 
> That's the semantics that filemap_huge_fault() wants.  If the page isn't
> available at order-9, it needs to return VM_FAULT_FALLBACK (and the VM
> will call into filemap_fault() to handle the regular sized fault).

Ideally, we should not have division between ->fault and ->huge_fault.
Integrating them together will give a shorter fallback loop and more
flexible inteface here would give benefit.

But I guess it's out-of-scope of the patchset.

-- 
 Kirill A. Shutemov

