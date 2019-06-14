Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE79EC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:51:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 614E621721
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 09:51:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="W4N6jtac"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 614E621721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C89E6B000A; Fri, 14 Jun 2019 05:51:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079696B000D; Fri, 14 Jun 2019 05:51:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAAA16B000E; Fri, 14 Jun 2019 05:51:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3CB56B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:51:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d19so1327521pls.1
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:51:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=eyC03vikXiwWfawO7Qlmx4pYoHpj/VV0tTc9G1eO/2M=;
        b=cmQkgj5bULjcuJod3WKs5o2LbfiHyb8yDTS7hWBcLbfOTHe/6YEreQfklhUanKKoSE
         CaR13NE31sVldSbFwcDf+MamEriQ2uKBwZj1eemIPtKWP5VuWbXY7UaXOd39JaowS6od
         T+2itkGNPwI3w+teFbRNNYi8YD+81H8gyTUV9uKV5uQHTBh4i/5PiSmBHeRad5Q76uyA
         sBLP4Igc5oMqG6wd1HrJuy7YdXoA2qlOy5mS5O9urNvzkeAdqms255fERpZjUMkWIm0C
         PP25lvYgLaSsR5o59QCs+T5/bC8Cwk8S4br3zPh4vwKYg6sEa3IMZxjR7zSfr4p4V98E
         kr0Q==
X-Gm-Message-State: APjAAAVC63Uu3cR/58KsQQ20le0W2uWAevZv8rwy95rq9/AQqjFQ+uhD
	uCEXQhDbTnnsa5NplnnqC0UuOr14Id5eUdd1pIEAEnXh1Dl5ySCUJgl/Gb4XJqUFDoASXasu1AD
	jui3KOdzMwX6ls7Dhp2mrfZvkXJNc7+T5BTCxb0U4G8opeOecMSAeefBNmY7IByMT/g==
X-Received: by 2002:a17:902:848b:: with SMTP id c11mr69845568plo.217.1560505898246;
        Fri, 14 Jun 2019 02:51:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqww7OTxnPjf5ZP9IYP3vYf96C/6Z/op5m4j4c88XrwE97kIdRmifohfDzNyldLr7QjTj5PG
X-Received: by 2002:a17:902:848b:: with SMTP id c11mr69845518plo.217.1560505897523;
        Fri, 14 Jun 2019 02:51:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560505897; cv=none;
        d=google.com; s=arc-20160816;
        b=XMikmuzt/L1Y/5r6A9KrlPaMlowKZ5sADGcJoHbt7U+lNIe4HQng1BgRnG/TgsNtWC
         2XYtPjD/7Je7ufv85UxWXg4tgwN2uQk1XCbgrMpiR8yvS4mnGAkpwv/Y46g2WXruu13h
         aPILL1wrbFAHgIHfvR3cS9ly8ckwQNPfhL8eP/vjInGzZWrlqDDoRXOKwigZ+7EQPPhw
         U0fvgpPdc5krUaT+7AQucl45cuh/BvaTiKlhR89MWdtDjqcZE+J+HmVI6h1KLVHpT4+g
         PvMTFURtAFJez92+BL17aM3hnF731nuR0h7ZvZBJwCUxmJCS9YbXQRt5lGUXG1y6XMLK
         6mZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eyC03vikXiwWfawO7Qlmx4pYoHpj/VV0tTc9G1eO/2M=;
        b=faD583XHtpUiHzLNQt2Ymmkhm5XU5PZliOG5jLpHURMu4zCYhrj0WvSHBMS/PxUieD
         qTy+9N7xs/KYKMhWnIROV1bQQwuMjI8uHF5qBB9PrMHPpqTSO56FzpieHuxQ0zSIPl4N
         bwYRH0OJAbPPHfwGXbomfiNggtynhaSGc8pw2FHOtCRuEZdXRSA2GTPNH3fB0lWraa6i
         3yL050M/UUx4bZkc2EGMxqT1/6HQvo5xurJYZMtA8kXmLbFeGpg5yrU5AGrSbMOysCpQ
         uSIrrTl3u707a92Lzyx+cbyz8ArHwkwcEchT4020LUp4l8gd2Oxm9vzaR8fnerTUHGVI
         caoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W4N6jtac;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f1si1920196pld.78.2019.06.14.02.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 02:51:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W4N6jtac;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=eyC03vikXiwWfawO7Qlmx4pYoHpj/VV0tTc9G1eO/2M=; b=W4N6jtac4NDjjqmz5HnAxAouh
	InHuflpblor7GHBWlLRdnNuT+ez7uTV5koHf3E14IuTEfmEj/L809EEQc/yLOHQhar2VHzWpgkzh3
	Buzls+HHqkjXm+FiA2UAibkmrYNt/auf+rnYm7aG+UhusetsJSmeKWZPpMQsrISdsaQzoYGHdoOpM
	qOjcb8wb2uhGYCWSjf/EFgVFzgUH3MUxM2i/Z9TcGfc/a1WdFwvDL8Ouem6Ou5YMjsU3X2yaVOmOL
	/cSIaAAlXxDZz1t8vlgF14JmpQeGTd/ZoREYDN4MZvmXwoqSU/OoAxEiQdENGWRIwoEawlIZ0ZyLK
	ItPRrqLYA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbirt-0000GE-T3; Fri, 14 Jun 2019 09:51:34 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 1254E20A26CE6; Fri, 14 Jun 2019 11:51:32 +0200 (CEST)
Date: Fri, 14 Jun 2019 11:51:32 +0200
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
Subject: Re: [PATCH, RFC 18/62] x86/mm: Implement syncing per-KeyID direct
 mappings
Message-ID: <20190614095131.GY3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 08, 2019 at 05:43:38PM +0300, Kirill A. Shutemov wrote:
> For MKTME we use per-KeyID direct mappings. This allows kernel to have
> access to encrypted memory.
> 
> sync_direct_mapping() sync per-KeyID direct mappings with a canonical
> one -- KeyID-0.
> 
> The function tracks changes in the canonical mapping:
>  - creating or removing chunks of the translation tree;
>  - changes in mapping flags (i.e. protection bits);
>  - splitting huge page mapping into a page table;
>  - replacing page table with a huge page mapping;
> 
> The function need to be called on every change to the direct mapping:
> hotplug, hotremove, changes in permissions bits, etc.

And yet I don't see anything in pageattr.c.

Also, this seems like an expensive scheme; if you know where the changes
where, a more fine-grained update would be faster.

> The function is nop until MKTME is enabled.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/mktme.h |   6 +
>  arch/x86/mm/init_64.c        |  10 +
>  arch/x86/mm/mktme.c          | 441 +++++++++++++++++++++++++++++++++++
>  3 files changed, 457 insertions(+)


> @@ -1247,6 +1254,7 @@ void mark_rodata_ro(void)
>  	unsigned long text_end = PFN_ALIGN(&__stop___ex_table);
>  	unsigned long rodata_end = PFN_ALIGN(&__end_rodata);
>  	unsigned long all_end;
> +	int ret;
>  
>  	printk(KERN_INFO "Write protecting the kernel read-only data: %luk\n",
>  	       (end - start) >> 10);
> @@ -1280,6 +1288,8 @@ void mark_rodata_ro(void)
>  	free_kernel_image_pages((void *)text_end, (void *)rodata_start);
>  	free_kernel_image_pages((void *)rodata_end, (void *)_sdata);
>  
> +	ret = sync_direct_mapping();
> +	WARN_ON(ret);
>  	debug_checkwx();
>  }
>  

If you'd done pageattr, the above would not be needed.

