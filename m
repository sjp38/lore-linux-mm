Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA581C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:57:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 748FA22C7D
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:57:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XhsBF6Xu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 748FA22C7D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20F5A6B0003; Thu, 25 Jul 2019 18:57:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E64D6B0005; Thu, 25 Jul 2019 18:57:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FC4F6B0006; Thu, 25 Jul 2019 18:57:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE7EA6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:57:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so27173829pla.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:57:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rzTThFl8sllwWs3QosLRBrU3gklbSk14p9uDQON6994=;
        b=SMIM0Ky4Q2/uiAjMUgvPcifWMg3zPIOGY3IwerUh2cVKfLIpFQ/hN+/Ox1LwDheZTc
         TXS603kKKSx/YVHpKbIh6AzNzhQ5AdoAl16Ye7J6Hz8iWL+EKzf3/83+JoBVdRdVHqC/
         vLNjMZxp63eduZz/LE0oCJBzYMYPVcXzcsXnbIFgsgWGp0avXlaMZ8/H3cHIrNj+9i71
         Oo6Z27sE88L1JE8RD/REev05u83eunf+MeRy0kDEpkMGIajolkQ1F4rCVmKU9sMsyZuV
         Cvs7TMILGtkOikhSC13km8oMqpD4+ujM4A3n45akcR3xXbClZt33i/gWP/sJiZP20W6z
         Ed4Q==
X-Gm-Message-State: APjAAAUQ8pdx2Xf0DIeshgV6mcGe4hsdqTs/EZaNWq2S4bCwxPjn/Vnx
	ViZ7Kn923txZQb3cG6d57BoC5ivnwPhoKJNCAKsSj6EnXb3WyDwYQaQhxcJDrHvZ0P8WcdH6YVG
	qORaOyuFY0Kgwod0FA4WUCqIOucnYqU3TlRnE81Gbtm6lQQLSyexgqQ0iZPlRr5PjNg==
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr52573556pla.338.1564095426429;
        Thu, 25 Jul 2019 15:57:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzgUS/5P+fYp46IT6X9X+ON9fvrFmrub354qrJd3Ql0EO5YFCuHudfW0ftV8+dGzgZsNGD
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr52573533pla.338.1564095425809;
        Thu, 25 Jul 2019 15:57:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564095425; cv=none;
        d=google.com; s=arc-20160816;
        b=rarFqIxXwPQJYI5pBB2DAunUd5L4GW+QHuNzmtshDVar2DvHcJP2yc0IXEv5Wryyw9
         WLO/rvYvvKHeoBo31KNEYCuQbqpoOp4P5jYSy7jQRQyjvpORZm4uxl0YqbiFcdJ+/GmF
         yUemjpuj3Eu3x1NwyGl3FnPrvozja9E6XshbgaBYkXxRKADJ8FbXQ84IYIVlcJ+S0C3m
         KmRX/x1evUZUWxrzaxVFXZMfECPHOdZWeHC1mvxs4QU5t7BKOE98Tcshhuz06LvfDFX5
         A2goJI2CrPJTuLnLJ7eNmt96nklAFbfnbzCMmi0VptKNVhj2O/UwClO+m5A4BRTqtyMZ
         eo4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rzTThFl8sllwWs3QosLRBrU3gklbSk14p9uDQON6994=;
        b=CpC9mRKQG4ZaqATgp4aa+dGfej9PdeSG8h4nUn74mC4vyO6yBSWrElJG9+HVjgbMUf
         QoIlGQHmK5XowLKXprTWsHtB5jAmronr0536DmMGrsTyojMC3zht+ERN6wT5EerLhCap
         v2+F5gU5LGKVyoQsSJ5ZaZAThNfj4OYdQq3KcUdEVbd2MtQAu0XJ0KHeMNGyVLbKaBmy
         7WA3QVXFF/wD+VPo/2mZ/tXgEoyeTlkdDjww3ZcccCz4eKTNoEK8QKfAH3a1i2ULxQy2
         1O/iDptDkph+mZdhqc7p2rqG6itGRNLJogVL3rh2Fjh+zLoJFPWzrJ8Lss2XwFCku3/h
         nZyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XhsBF6Xu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e11si20261777pgi.121.2019.07.25.15.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 15:57:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=XhsBF6Xu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rzTThFl8sllwWs3QosLRBrU3gklbSk14p9uDQON6994=; b=XhsBF6Xu9T4+TRncHszD+UAfi
	3N6mrPwJwqY1vGBjs4egkbrISOObA/gGcb7nQAVA32WcAEv7FsQzSgUISurRtdaE4WHDtiCE+f6Cp
	hi7x7TSz85sm2NebmON0hxbw9c85xRSVVIjsSywMO0FEKu8i6oHd/imp7xtGAi4EqwaaRFUafCrUO
	arIgYvTVlNR90z19yX+j9gtYozrxnMTB2deF9gyjtOhieQjB2LwOOrU8cw6nBiop5o78N1+U0Tp1v
	3NK/8EUWT8E2DKITOmMmuBSGFuR6bNhyXa386yRU1dwNPROLzUnpNfNEzcnIz7LZdkIO+mj39vQsX
	rA76zFfow==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqmfT-0004Nn-1f; Thu, 25 Jul 2019 22:56:59 +0000
Date: Thu, 25 Jul 2019 15:56:58 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, x86@kernel.org,
	Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
	Steven Price <Steven.Price@arm.com>, linux-mm@kvack.org,
	Mark Brown <Mark.Brown@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190725225658.GH30641@bombadil.infradead.org>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
 <20190725213858.GK1330@shell.armlinux.org.uk>
 <20190725214222.GG30641@bombadil.infradead.org>
 <20190725215812.GN1330@shell.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725215812.GN1330@shell.armlinux.org.uk>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 10:58:12PM +0100, Russell King - ARM Linux admin wrote:
> On Thu, Jul 25, 2019 at 02:42:22PM -0700, Matthew Wilcox wrote:
> > On Thu, Jul 25, 2019 at 10:38:58PM +0100, Russell King - ARM Linux admin wrote:
> > > On Thu, Jul 25, 2019 at 07:39:21AM -0700, Matthew Wilcox wrote:
> > > > But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> > > > architectures doing the right thing if asked to make a PMD for a randomly
> > > > aligned page.
> > > > 
> > > > How about finding the physical address of something like kernel_init(),
> > > > and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
> > > > address?  It's also better to pass in the pfn/page rather than using global
> > > > variables to communicate to the test functions.
> > > 
> > > There are architectures (32-bit ARM) where the kernel is mapped using
> > > section mappings, and we don't expect the Linux page table walking to
> > > work for section mappings.
> > 
> > This test doesn't go so far as to insert the PTE/PMD/PUD/... into the
> > page tables.  It merely needs an appropriately aligned PFN to create a
> > PTE/PMD/PUD/... from.
> 
> Well, in any case,
> 
> c085ac68 t kernel_init
> 
> so I'm not sure that would be an improvement.

I said "the corresponding pte/pmd/pud/p4d/pgd that encompasses that address"

So for a PTE, you'd use PFN 0xc085a000, for a PMD, you'd use PFN 0xc0000000
and for a PGD, you'd use PFN 0 (assuming 9 bits per level of table).

