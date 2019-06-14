Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FE7DC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06E7521473
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:34:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kH34VcWN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06E7521473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 828A46B0007; Fri, 14 Jun 2019 05:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D9606B0008; Fri, 14 Jun 2019 05:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A13B6B000A; Fri, 14 Jun 2019 05:34:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 343436B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:34:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f1so1415342pfb.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:34:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v8sKDZr9w6cVAjaj6YSpqDHjOecR4ISemYmtJwZe3FY=;
        b=IAX0UpkpdHMtxbmZf6uqp8Gq4qTNaAuQ+C5BRCA9WXrgzn+NNsXkXRz8xnpQ4o50Z5
         2crXgr9PYLYD0doIMkibdtoeMifhyUikbcS9TuEqnXI4NGu9eXwRDcD8mk70GpPLtMG7
         PclNjs6n8wHgEgYrnBcwUoi6H/0Z6DyAb1JHUOFlB6ZE5+xx+KJX6Pm7TADGS0zNCI+b
         xwu+k9ROhXFv03F2RUZhySHfs5yVrkXSIV9zgmBSBMbXVp9n3D+OnRjSq5UVvZyILKSo
         lGIMPzy/F2DUCxnF5E4oP0o/VsjW6/ssGCasaT6XuXgKHJTlq8jmKwCzU/7hf0jthpwG
         O3yA==
X-Gm-Message-State: APjAAAUGZP6KOPBdCcMGWt5fi2LSjxt7l4ZaibyvcE/CSNPWqfgRoqiJ
	BThSsID1yZcsZiEXhlTau34nuBGg66Jnt/E+38l5IuRgDlnOeRMvFCMZmyOZJh0JRbn89D106+N
	pZI31WCuJZF/UqY1pZLeLGXqla3rC36ec4YR+LlM+Jc9MKGFdXLGwzs+YsBb6QMqWnA==
X-Received: by 2002:a17:90a:c504:: with SMTP id k4mr10064485pjt.104.1560504861854;
        Fri, 14 Jun 2019 02:34:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3gJD8cXJjKI6C+r4xpEnB3Bd7Zu8UAEW8J4ARJ6HJsdCRYa+HkKMGTwNpFTbRgvAKxMLI
X-Received: by 2002:a17:90a:c504:: with SMTP id k4mr10064418pjt.104.1560504860978;
        Fri, 14 Jun 2019 02:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560504860; cv=none;
        d=google.com; s=arc-20160816;
        b=bSCID8EFqvA6zLCcUDKMrdL0pOq4j1sSdu2IJ1Kf/gA77Z6kDczpZ01xCGso7dFBfH
         KZFp+kYwp0m7xccw8FFlmfh+aGAeaETovr6g0On0maFusMAC4aJ16ySgl1IFrEjp+Lp2
         Y+uk5zFndj3jgQLGu61ljgFcKYu7LgEsmpLIopqXKAR1NJSgFzG+9aiDSOCDMZPAYrmt
         vhAQjdAkqIoY+f9KgitAfzogDF32brd+Y66XUuR0+r/OSymp/Jq1jdW+qVkrjQvxal1g
         t78qhqlm20T1km2DiPfZgR9z5rkhSfL1YemfSA9Jcx69+DvYaxgmbQArrVsHWEgOcOIT
         Wdjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v8sKDZr9w6cVAjaj6YSpqDHjOecR4ISemYmtJwZe3FY=;
        b=SgPvN7qcUFuHEG/UPes6RDpxc5AdgTZZ5cBgcC1IfBiUAOkFc3PFUHkRjO5bQ1Sj8w
         VHEwMmOMe9FlJU9O+yuGKWI9aJoOA+qZxguxKrCHeOxIy/RFdgEwdtXFKEBoYgAJkeFY
         YpDx4eD31KR5xWw5rrlSpkD9mDXW6lv+2+KwBWNpMtcJj+HEeod6aqP96AZ0PJpn9FYQ
         pyZUN6WmBJv3CPta1OzZjPkmnwOiO+LKBbV7WNDur4xKoCKRbbGLsSwYMgs57lQLCXu/
         nTjzs8Wp4Jb6OH1KAVJEJ0o59M8KhzGHHWkx6vqi4dVh3ivn2M4ysR1ApEp/5iE9J22W
         4yuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kH34VcWN;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a94si1930128pje.19.2019.06.14.02.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 02:34:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kH34VcWN;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=v8sKDZr9w6cVAjaj6YSpqDHjOecR4ISemYmtJwZe3FY=; b=kH34VcWNT4Cav+GjG7CqlXy44
	JXzqwvLIwTvMinkAO+TRylimlvR57aQTl6R7J8h2IT4P0MA63u6VdOzQDzCbMD9iu/1rxFj9RKZmb
	o9u06p8ViQ8gJ5dyh2N4jaMWyIT0MJZGbPd9FIUyjWfyRvtbC+nqGDLMKjoHQoItVNnVNETBg3XHa
	/EFK8hfeCAK0wqta5ky6wI9fQlG4ZeH6B63bsMuP6+A1WJ3DVQE48CdQv5tm0qSB/i6C7Ev/Yco27
	JReMy3HKsSnOQ3TVN9wgekm5FU1rDzfRGnsiJhXNfi53fnyqodzPmaUbJT/6qnRMCKPprYWDjQ4GG
	pfErC0P/Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbib5-00058b-5L; Fri, 14 Jun 2019 09:34:11 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 5673620A26CE6; Fri, 14 Jun 2019 11:34:09 +0200 (CEST)
Date: Fri, 14 Jun 2019 11:34:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free
 encrypted pages
Message-ID: <20190614093409.GX3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:33PM +0300, Kirill A. Shutemov wrote:

> +/* Prepare page to be used for encryption. Called from page allocator. */
> +void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> +{
> +	int i;
> +
> +	/*
> +	 * The hardware/CPU does not enforce coherency between mappings
> +	 * of the same physical page with different KeyIDs or
> +	 * encryption keys. We are responsible for cache management.
> +	 */

On alloc we should flush the unencrypted (key=0) range, while on free
(below) we should flush the encrypted (key!=0) range.

But I seem to have missed where page_address() does the right thing
here.

> +	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
> +
> +	for (i = 0; i < (1 << order); i++) {
> +		/* All pages coming out of the allocator should have KeyID 0 */
> +		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
> +		lookup_page_ext(page)->keyid = keyid;
> +

So presumably page_address() is affected by this keyid, and the below
clear_highpage() then accesses the 'right' location?

> +		/* Clear the page after the KeyID is set. */
> +		if (zero)
> +			clear_highpage(page);
> +
> +		page++;
> +	}
> +}
> +
> +/*
> + * Handles freeing of encrypted page.
> + * Called from page allocator on freeing encrypted page.
> + */
> +void free_encrypted_page(struct page *page, int order)
> +{
> +	int i;
> +
> +	/*
> +	 * The hardware/CPU does not enforce coherency between mappings
> +	 * of the same physical page with different KeyIDs or
> +	 * encryption keys. We are responsible for cache management.
> +	 */

I still don't like that comment much; yes the hardware doesn't do it,
and yes we have to do it, but it doesn't explain the actual scheme
employed to do so.

> +	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
> +
> +	for (i = 0; i < (1 << order); i++) {
> +		/* Check if the page has reasonable KeyID */
> +		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);

It should also check keyid > 0, so maybe:

	(unsigned)(keyid - 1) > keyids-1

instead?

> +		lookup_page_ext(page)->keyid = 0;
> +		page++;
> +	}
> +}
> -- 
> 2.20.1
> 

