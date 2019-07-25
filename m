Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4850CC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:39:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F17F4218EA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:39:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SVrTjode"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F17F4218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72C3C6B0003; Thu, 25 Jul 2019 10:39:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DD946B0005; Thu, 25 Jul 2019 10:39:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F3C48E0002; Thu, 25 Jul 2019 10:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA6B6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:39:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so30955782pfk.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:39:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=38kZYSDy3zC5/h/SWKUk1efaWYIuv6kOUF9lD42ddaQ=;
        b=JvGXwWGzAUZQ2PSkZiBCPFEQ85suO73iTwozloq92oGrqn20sg6AXxNprnIEQpL0r1
         NUstPQDnWWxmZOZpGW+BV/TS6VfEcSKOouAs9USMxQIyMP+pmwhg3k1wn//Am2OiQcaE
         MJ2GPFWWAo4jFQqSdBtI4LRqTLjsC+N8J/pzeFzMxH9wq5iAxiB0ueFU9pIo5ofaGuQz
         +gOp9w0liFZyTGqWwvEL7ws2oCeNi3+IfUg1RBfrTUwrftanQEZvYd7Bkr5GyZ71v1ua
         WtVjRoK1DwuisJ+yIzztWYyh4ge3IM0/s73kdv6vdXoY/8CLera7qwQ2I5+0M9o7Pdv2
         U+/A==
X-Gm-Message-State: APjAAAWVAkyLi0PpnX2b4O7QTyU42ijeVO/O3k5XFZ+L48TeZePaD2ee
	+N2iXTa3hIslYuUwEdRqwLBw5bqgyRmPgme3MWGzpqm12bJaBQd03q8tjmUlT9aHWujVRYjN24o
	LxFIEtx7Ujm5CeSX/5GW8yWJrhmBBVSXBOF4fqVomxs1DJCRwPEeBeFLmVtRtOvmzew==
X-Received: by 2002:a62:35c6:: with SMTP id c189mr17042423pfa.96.1564065563667;
        Thu, 25 Jul 2019 07:39:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtzrnjryEfy/LBFIJFifT0bWzSet6wA8tfEqa3cMTBhXq/efKrU391TWWVeJ62QhdhMe6T
X-Received: by 2002:a62:35c6:: with SMTP id c189mr17042373pfa.96.1564065562881;
        Thu, 25 Jul 2019 07:39:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564065562; cv=none;
        d=google.com; s=arc-20160816;
        b=g99Zm9ey9FoaX8MezUPexWrIoieipxKvfQSZinCSGH7rSmpAgJPl04ymmZAyvfnqFA
         PhATVb/S1HJYeXS5srTIJA2AhZflJYwlDVxGig/ZsCgPbqJjfsYLx6HanUcODwzOe6vw
         kU9C0HgxE8fLFBAg1qd5ELY3GK4xpBZ4upFiVtVUj4GWyOnd8D5lgmQcICN6Dsep0G1I
         4YONOUBTsuxYmUX/AyyMok3P+flSsH5UeJPA3wXNwQrahtHBkMromz6x05FGFpLuMLQD
         bLa3z3xODw/xKwD8cqCpTc8Ps/ZdsZ8GPE+Tmr2gZNcMV+IryZ0+MDG4zj+YmF4blfHF
         xHiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=38kZYSDy3zC5/h/SWKUk1efaWYIuv6kOUF9lD42ddaQ=;
        b=TqL6cH+sfDHtcWlZ4E8XKqcBcNPa7DWPVLV0L6a4H6QitaGoIw4mYAOvTamfRYcDik
         W1qTFEEOmbRzlmstXofC/WtonSXRozuxEHHV2hYJUfWinY8P2dptrEbmEdtPOUGAjzdA
         pVQ40WXPxorRlJGlxH4D6p1+1UGP5Z+pFE0yGoUMfBmt7BJLCghZ04SO3ylrzQIg3HLS
         NmAC0is6HjQq2MXjIV0ls57UNl4ChRHj6SQlaNNamTu4JsHzM2Kbcc23Vtr7zMDqccsL
         8z1mtLpVZwruwWR0Ceip+HVUiWTApGiIW43+TemSV2f2LnbYN6wK6XkN26UFPkiwQrSr
         VgaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SVrTjode;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f139si47405954pfa.2.2019.07.25.07.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 07:39:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SVrTjode;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=38kZYSDy3zC5/h/SWKUk1efaWYIuv6kOUF9lD42ddaQ=; b=SVrTjodeLNK7q0jCMYEkBveo4
	Zu8/xuN291RTd2NCB0e0+OKyqdrkLflFyiEomdig7SwNxjlQDVAFmlQ2jeu20983UVJf83F2NB1eA
	5GNZIlel3ONkkxUoEQSUm6JN7E1HklNo+yop3vUZEmV775yV+YPo6NKgu6tqVvjKADkkdeAlwDaXg
	qxc/MJUpLs89zfDsR86K96FcPpSsvxoeEJxChdYwnoF/UzBTxasoFp/jNygj7PyXRonQta/gM89q8
	fPQ7GNopogRdlK47Z+dQF7P0aVZ8Oq5puPimr1TAo1+SQaiNFVfNa2j0J3pcmRuzNBLX+Y7aLOjNj
	7aDrkIKmg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqett-0001f5-5B; Thu, 25 Jul 2019 14:39:21 +0000
Date: Thu, 25 Jul 2019 07:39:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-arm-kernel@lists.infradead.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190725143920.GW363@bombadil.infradead.org>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
> This adds a test module which will validate architecture page table helpers
> and accessors regarding compliance with generic MM semantics expectations.
> This will help various architectures in validating changes to the existing
> page table helpers or addition of new ones.

I think this is a really good idea.

>  lib/Kconfig.debug       |  14 +++
>  lib/Makefile            |   1 +
>  lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++

Is this the right place for it?  I worry that lib/ is going to get overloaded
with test code, and this feels more like mm/ test code.

> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
> +static void pmd_basic_tests(void)
> +{
> +	pmd_t pmd;
> +
> +	pmd = mk_pmd(page, prot);

But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
architectures doing the right thing if asked to make a PMD for a randomly
aligned page.

How about finding the physical address of something like kernel_init(),
and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
address?  It's also better to pass in the pfn/page rather than using global
variables to communicate to the test functions.

> +	/*
> +	 * A huge page does not point to next level page table
> +	 * entry. Hence this must qualify as pmd_bad().
> +	 */
> +	WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));

I didn't know that rule.  This is helpful because it gives us somewhere
to document all these tricksy little rules.

> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> +static void pud_basic_tests(void)

Is this the right ifdef?

