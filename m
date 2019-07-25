Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE7B9C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:58:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84273229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:58:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="sHapK5Dv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84273229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40EFA6B0007; Thu, 25 Jul 2019 17:58:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3982F6B000D; Thu, 25 Jul 2019 17:58:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2614F8E0002; Thu, 25 Jul 2019 17:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB4656B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:58:30 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a5so16760576wrt.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:58:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent:sender;
        bh=3G0DbANSEEz3gBLVg4LbmF0CvfiTNd4gqwl2oAi+YHw=;
        b=a8hz7EXfBdM1Ilt/EUbQL3LQjblSIB4nPjDiYRT+R55ABD30P2ndHYghSrpvmX0Vcm
         ZwzSUNsGqlnLUBgXPXV0J6vmGRveSM0upQmhdmvf5BVnsu4532CpuLOyz16YAXOAI6bn
         iliCGqRSuZLC0T8ywaFdWJ2Sd6txKCEBv4chELF0IjiJAi+xy00Vw39J/WLCZ0TewMri
         ifkkOgQjdW2/5hjp2+tG0+q+31U63eIVGZeZV2M5ohQdsfBD2X63aJ8ZaFsjMIELM8tL
         83ghNwTULjdpI2vWhBPg81m4JwPuLPYyiLtnGTWC37D0MBIiZNTDxWpedvJEb4pmT1gQ
         i08g==
X-Gm-Message-State: APjAAAV/qYbb07RujZlJVO1cPXVHWJMLYDXaf2vMz2CQ50m1KjUxCWQj
	I9NaTi6T+l0z/SrqUoO9DGrYY2GYQ9kc/9pG51yjUj/rof1NEaf9YKgep+eXwqHvbk05uwN4GhU
	5CJ4KP5gG5qwBF+hZHA2zDwmmGwcoE52Vbqa/mEj219tcunSeDsQ1cw5KIJjdxzzY6Q==
X-Received: by 2002:a05:600c:2182:: with SMTP id e2mr17133504wme.104.1564091910367;
        Thu, 25 Jul 2019 14:58:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfyaR4IbJH4mQbBSn6lA/CHRye+vc+/7VYyjmgH4Q8y8Ob9Z1pW44hIso6P87JmT9LJwwj
X-Received: by 2002:a05:600c:2182:: with SMTP id e2mr17133483wme.104.1564091909629;
        Thu, 25 Jul 2019 14:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564091909; cv=none;
        d=google.com; s=arc-20160816;
        b=BmvJ7ekmkgxOTucl2OHUJADjGnbStIINTzjaH1LVVyy/VKm6dMO0IAJTdv7V7MNgJi
         EVFN9Z9QQjNnzgrPz5y922/f3GSl4H2SlMcEfUvVKa1GAEjUyzOvCYXy5A060qlOHTEt
         K+BzhEUDoFscBkMfIZ6hhjJCUFAFk6I6P5yOh6vX5G1FvegKnUs7X+nzgKhogUg/YxBu
         P0NWWLtIVXB7puxpgmAZjxoikYEkWECuETV5LzTr4b8pQjMYyezc7BdPUbQq/LoXkNco
         EyTRlel1MALsh/oR+z7XEv1ZBpNh4lWNJkSIyqlC9OFPLNLqmco34dIRvUIcGJyrFcFY
         66NA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date:dkim-signature;
        bh=3G0DbANSEEz3gBLVg4LbmF0CvfiTNd4gqwl2oAi+YHw=;
        b=fpAFgblmKKHTFq+PhwYyq25ZeUO7A3EDYSjHSrYyWcRaFRxlPGgamhdo0rPjYPjPSc
         RBRYFvOdmW94AVFaLwiZq7xvTNHgnNTECJi39Yui8gWnWHEY32jmWlOHK7IPz/6aoZHZ
         vbyD3kejkHfz9hSKzkCmbnaQ6zrYvIkfz1m26Qb71VfqNQFa1KHPj7qS4Qua7fO6pRdr
         6MONq48tI1zQtyLLC7mqB9+7JvD7YZKM8w0a305CB19gq3otrljPr8a7QUMB9ZPuwrPA
         vDTsPqSln09RyxICcgGDcla4MVrvCiFq+K8BTnHtOY8xOQ7aS7flU//HU0RMvvkjvCPY
         WleQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=sHapK5Dv;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id b10si22860314wrh.126.2019.07.25.14.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 14:58:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) client-ip=2001:4d48:ad52:3201:214:fdff:fe10:1be6;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@armlinux.org.uk header.s=pandora-2019 header.b=sHapK5Dv;
       spf=pass (google.com: best guess record for domain of linux+linux-mm=kvack.org@armlinux.org.uk designates 2001:4d48:ad52:3201:214:fdff:fe10:1be6 as permitted sender) smtp.mailfrom="linux+linux-mm=kvack.org@armlinux.org.uk";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=armlinux.org.uk
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3G0DbANSEEz3gBLVg4LbmF0CvfiTNd4gqwl2oAi+YHw=; b=sHapK5Dv01/JCHeQu/SjqvySW
	pH6NXKfPa0ocMNU8dGO4QMKJt+V/hxIZBWxflM6ndEmDYOb+0THMyDtpoiwsq1QwIEczr5gydc+AX
	ukWeOWFYxCs1H6b9ICoaEjcsxGhK/oWcWJZ2XRa7t1VukD9tmGNPRuMHBe/ljDRZlPMihyMqVlK2D
	Zix8A5XlQ9FwZM/jPoOI9e2CCXMdN+i0KM+peI6omltOm/LQWwmL8ST1sdCM4dZxZpjZ50MpqviaZ
	xvkaCb3IbY8GQo0+w56JWRDQeiSn6vs2kO1h0XtKVS+EnAzq8fGF8RKxA0nrZQogQb0j3TfenlS3k
	s2G1lrXVA==;
Received: from shell.armlinux.org.uk ([2001:4d48:ad52:3201:5054:ff:fe00:4ec]:37148)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1hqlkb-0002Yr-TM; Thu, 25 Jul 2019 22:58:14 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1hqlka-00062y-II; Thu, 25 Jul 2019 22:58:12 +0100
Date: Thu, 25 Jul 2019 22:58:12 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Matthew Wilcox <willy@infradead.org>
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
Message-ID: <20190725215812.GN1330@shell.armlinux.org.uk>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
 <20190725213858.GK1330@shell.armlinux.org.uk>
 <20190725214222.GG30641@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725214222.GG30641@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 02:42:22PM -0700, Matthew Wilcox wrote:
> On Thu, Jul 25, 2019 at 10:38:58PM +0100, Russell King - ARM Linux admin wrote:
> > On Thu, Jul 25, 2019 at 07:39:21AM -0700, Matthew Wilcox wrote:
> > > But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> > > architectures doing the right thing if asked to make a PMD for a randomly
> > > aligned page.
> > > 
> > > How about finding the physical address of something like kernel_init(),
> > > and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
> > > address?  It's also better to pass in the pfn/page rather than using global
> > > variables to communicate to the test functions.
> > 
> > There are architectures (32-bit ARM) where the kernel is mapped using
> > section mappings, and we don't expect the Linux page table walking to
> > work for section mappings.
> 
> This test doesn't go so far as to insert the PTE/PMD/PUD/... into the
> page tables.  It merely needs an appropriately aligned PFN to create a
> PTE/PMD/PUD/... from.

Well, in any case,

c085ac68 t kernel_init

so I'm not sure that would be an improvement.

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

