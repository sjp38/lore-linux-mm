Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EE32C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 13:52:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FCC92171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 13:52:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DCezGss2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FCC92171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78976B0003; Fri,  9 Aug 2019 09:52:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B29076B0006; Fri,  9 Aug 2019 09:52:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F09E6B0007; Fri,  9 Aug 2019 09:52:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7546B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 09:52:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j22so61440343pfe.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 06:52:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EreDrMASgymCoOwex2lDSh6PBVp8vwwZo8lBW7Dx+AU=;
        b=LxGR0nxwRNpRghKOvUzomRYPxtqlJfaRh1IAkVAP8boqWreYJg7iReRTp/ra53CAlT
         KM1rl3qyp4hd6G7TgPecc8085n6uBN+IOTElpI5Kp/bsB1PsBLarDPnwy00/GjtGIWeT
         niry/QL5tkFkwCI05wIxBjxANWlhsGZwyckwwThxjJVnmq7SLXBZTKgiBvbEVVPM4l8Y
         O4ObpmuvrjEjU4dVxMxYORtlzA5HN45zUXfSRxIeqH30i1RUJ3LJaxXFxsYpV5gPi0tQ
         MRyHngjKasVotVDqJOO1mWedYRsIohTbbxofioB7SNdRnGvmVu0/VAaZbWC7PwLCTU5W
         HCog==
X-Gm-Message-State: APjAAAX3K5ggaqRJjEOHvP3f9KxKib34S3fDSty1Yf/4Yc5xcj+4/fHp
	MhlGIMP8q5VQs0yCFXJamDwTD/ZCVKPbLGV9FkS5uKCfH7uizuHjw61iUqXQSrpYW2MnPX7bn1L
	QM+LPgtCJCtU8cm69HsmMh/VKEXwmDgtK3v1+PZGrMVQOAL3i8pSgA9zyxQOqQJ6nMA==
X-Received: by 2002:a17:90a:9bca:: with SMTP id b10mr9515955pjw.90.1565358730967;
        Fri, 09 Aug 2019 06:52:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq4SDWzkLC8BDX68C/2jqcmJxtvtyj1llPFWRV0NTgIxY9xvlc1aL7Ppf0YCpPJAALQdll
X-Received: by 2002:a17:90a:9bca:: with SMTP id b10mr9515897pjw.90.1565358730097;
        Fri, 09 Aug 2019 06:52:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565358730; cv=none;
        d=google.com; s=arc-20160816;
        b=NB68swUBe0P4DgmWApVtpcghqL2gKl1v0gP7VGOpQexrW65Etds5lDD7FV5wytf+my
         RduwIsZO2Zf5beqXNKLggbDDqyVDy7CUzoE9s+qyjuP3HJ7ErQBkd7AsizVCfoRf7jpL
         6RuFYcbT78grhKQVSGS31oOdZRwQ55CGGahQObvY+kyWL/cVXEa88rJv4lZ4jCyBZlxp
         vfyYqUkr1LRoGh8p7QtIrB3TQ7bXx9ebIUBd0q6QvG9sy3fFDt+xwBHw3aSQpGPMmpTX
         qh09BuqteqNeYx93geRjxg08AkKwN+1O9HFsg7Pv2k8bd0g6rRWsILRURxBPaFxur4JS
         U+1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EreDrMASgymCoOwex2lDSh6PBVp8vwwZo8lBW7Dx+AU=;
        b=shoCb/8zILKNKRNUKtupbhk2G+7cli1/7J8xu2+bM3KAB0KnCoz8HWthGJ3W2XMX+X
         TRMpYvi/rtc6Q+9dBPze0KKUFDXeO5iKoCZMOG8S3Kic23IuvylvbvdVPH3kxElKGNXN
         /r3yBxbyfDEChOh91UnfFxv37glnJxqwfcs0cJgfkLuXq2OlIQmMgX06wrBaf6ul+6Vi
         YbOG0njcy2G8wwLUizsTdQsBYwJOXnyd8ms/P1QONrhHqT1IQ0XfdJ7xTGotdUx8zt40
         N6t8cCAB+jNFFZ8729nK07+2n2e3iv0XLhtCIbWAu86FmBkNfJ1JXEgrhhbDs6XosKM1
         s2wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DCezGss2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a21si57304310pfl.167.2019.08.09.06.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 09 Aug 2019 06:52:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=DCezGss2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=EreDrMASgymCoOwex2lDSh6PBVp8vwwZo8lBW7Dx+AU=; b=DCezGss28UrQwdHuY2bFdI4p4
	S1IQudbzVnxD+07DxZGKpMaIkZjBN26Cdg8l2/Fs8GMFEeX1pJqh0qZAiUghQaE6El6M1XDplTDve
	EJJcjL9sO79CkY0k30aJUEJAymr58OsH+p8EsukYG7F9sRPnn0G8pCmZVLattID9zhXymV5yWXtFQ
	ciqngFSM0ntk8BRdLo5xQ4zieBSWsCrkihQ+/ft5+CPIVKlVlUX+N97pCSyIU0MATtJ4kwuaN/o18
	WCkKlxmfNm5M1Hch5V2lnDpS3brZehU45KR0NW0dNC4+r+Ph0RyNwH7KE6Q/WHvIQU+odBuHV4vuK
	lstsiJ0Mg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hw5JK-0002PQ-U7; Fri, 09 Aug 2019 13:52:02 +0000
Date: Fri, 9 Aug 2019 06:52:02 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <broonie@kernel.org>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Russell King - ARM Linux <linux@armlinux.org.uk>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vineet Gupta <vgupta@synopsys.com>, James Hogan <jhogan@kernel.org>,
	Paul Burton <paul.burton@mips.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC V2 0/1] mm/debug: Add tests for architecture exported page
 table helpers
Message-ID: <20190809135202.GN5482@bombadil.infradead.org>
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
 <20190809101632.GM5482@bombadil.infradead.org>
 <a5aab7ff-f7fd-9cc1-6e37-e4185eee65ac@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a5aab7ff-f7fd-9cc1-6e37-e4185eee65ac@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 04:05:07PM +0530, Anshuman Khandual wrote:
> On 08/09/2019 03:46 PM, Matthew Wilcox wrote:
> > On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
> >> Should alloc_gigantic_page() be made available as an interface for general
> >> use in the kernel. The test module here uses very similar implementation from
> >> HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
> >> needs to be exported through a header.
> > 
> > Why are you allocating memory at all instead of just using some
> > known-to-exist PFNs like I suggested?
> 
> We needed PFN to be PUD aligned for pfn_pud() and PMD aligned for mk_pmd().
> Now walking the kernel page table for a known symbol like kernel_init()

I didn't say to walk the kernel page table.  I said to call virt_to_pfn()
for a known symbol like kernel_init().

> as you had suggested earlier we might encounter page table page entries at PMD
> and PUD which might not be PMD or PUD aligned respectively. It seemed to me
> that alignment requirement is applicable only for mk_pmd() and pfn_pud()
> which create large mappings at those levels but that requirement does not
> exist for page table pages pointing to next level. Is not that correct ? Or
> I am missing something here ?

Just clear the bottom bits off the PFN until you get a PMD or PUD aligned
PFN.  It's really not hard.

