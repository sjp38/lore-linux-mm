Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72F71C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:16:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 286622171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:16:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pag4yExu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 286622171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6D7E6B0005; Fri,  9 Aug 2019 06:16:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F6F06B0006; Fri,  9 Aug 2019 06:16:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 870DF6B0007; Fri,  9 Aug 2019 06:16:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B96C6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 06:16:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so61158277pfw.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 03:16:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qtavp7CPHfZNeNkYBrPvAtPsbANfqFLQtCdliW3pDao=;
        b=sySh9ugcXTizBokynAqTwzpJfZxtpECiwPhSYi46gSZYjCmYk5IDIUtV+osCxknmCM
         snZQjL3DWp0O0lL6u/ddqOFZjeLkMi4+3AugXYwcvLUt/H55FvbX4X5QM0BcpBxsulWA
         9Y2Sg/YhNNWG+v8khm/m0FPojpCCCsMMHhvvo8ZOFqi2ajtXfiVki008s/pguDATZCha
         40HESnFXhRnSj3SFokuaoY05bjKGfSR2uq4vx6n68ScJjuJTr6vi+QG5NdN7ujh2YePz
         G0IRu9OYGn/SSNEBZEPXJz9PuHXxqP1c5wUJKNheiPAiqRRwq6IJBH70hCLuY+oY7w/F
         klMw==
X-Gm-Message-State: APjAAAUCTkJYKSpYdUyIZgoy3GQEi7JyGKF3M1XrEyZVwD1ie7aCUcSS
	RdIwA+ZSqwCYQ1eyFi1EIgPBg68f4zcMkJ0PgkAr/iM3X+XkAvrO6FlFakLFC7sUyEjZNnWhlVZ
	83/h8PwW5lDqw5oD6BdnXwKBVvghZrpdout/fDI5EfKzXCzS8a6I7ydaVFQnpPylSOw==
X-Received: by 2002:a63:4461:: with SMTP id t33mr16502259pgk.124.1565345802868;
        Fri, 09 Aug 2019 03:16:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVdYCsqBuLkG5i8OhlMt/sbRUHSFyykSl0dQPL7pwoRpq3tjLvlX/ZJM3aODIFE5JBIg9r
X-Received: by 2002:a63:4461:: with SMTP id t33mr16502213pgk.124.1565345802024;
        Fri, 09 Aug 2019 03:16:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565345802; cv=none;
        d=google.com; s=arc-20160816;
        b=oXbeThlun8e8xVYg9SvDHRgrQPIIga6k75ZtzC1G/1xJMUtBiXYKFwGCT4bvkDSkBH
         cE6O0SEror4dkIoc59pQxFIG4vYEL2rdR46eUv2DIWfeSfHFM4Lu5f7Udx5y3uzWN8bd
         1vF21f+O4RJyWyOcWLwOaN778t75tGbmTfEuThBFPSCRLmcwm+7O5C/k7QWCXleHxjC4
         gUUWj+8O+ux9rqGGSbN4HImNjy8xY6ewCwCwL/gYzlnDGGMqPATYamb+aMOHOdjhObLj
         BfLqarJYymjeNc7pxLenY4eJ0wID4amwODg0W7syTFGKKm4WARwAc3jN5HBcHvJrQWeh
         l54w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qtavp7CPHfZNeNkYBrPvAtPsbANfqFLQtCdliW3pDao=;
        b=nJvnXJ19E7W55SAinPuCoyG1AQyfm44xwmM1td4HTKPZu95mmPgsyFfyiOIKN7cmko
         bPLacvGA+oJp1mpsTGN8NoJm21Smt7NVbHQyIZLgImLdA2T0U8JH9MRbecLyvxHFPmvc
         fW1ZWvg2uc3g8et4Hstadfjf720/NYz33y8XoV0ZmSTZU6SiIvSWTxHtqbST2HQRMBU8
         yKNEdFmUA3J6FAizWyfS9M3LHz7NRW7bJ/poTBMNzCHqKs5ak/21fdYhCPwLB5b3/wrP
         XIrjgB3SttrGL6S1BLmqX1dtAmtm+HZqzlWbtS7JCRBuaRQxA1/p+VIeFUEpADluo5Lz
         AwCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pag4yExu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d7si54068597pgv.86.2019.08.09.03.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 09 Aug 2019 03:16:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=pag4yExu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qtavp7CPHfZNeNkYBrPvAtPsbANfqFLQtCdliW3pDao=; b=pag4yExuYAml6RAwW8ClSI/8O
	4SvhyG05DRb/VW/V9CDsF+zHeZ5UXFBZuSEmH6L2R/TkkFTUdvg0G5X+mChPhSDo0bv/G81bqVcOE
	H0+ebgEssg+HPPdNYRmJesf50lZppQPNOWSyxdr7otHpaF8cn8K9ckBUuEcdXQR2moiTTpd1jGx/f
	vjh5YbK7fMXAxAHvYpu7bjS0cCBSZ//FEHycRa1QcZu/mYorpr133FpqiXnyp7o6RFhVYguPt/B8f
	P2fGNwRrQbpxYk76nYUeyruj+MAsigriKyn6idQDkNDTkIb9YC0oHITHhwpJDVUNGhDUhHSp0NaMd
	UOTH8wydQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hw1wn-0006xR-4P; Fri, 09 Aug 2019 10:16:33 +0000
Date: Fri, 9 Aug 2019 03:16:33 -0700
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
Message-ID: <20190809101632.GM5482@bombadil.infradead.org>
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
> Should alloc_gigantic_page() be made available as an interface for general
> use in the kernel. The test module here uses very similar implementation from
> HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
> needs to be exported through a header.

Why are you allocating memory at all instead of just using some
known-to-exist PFNs like I suggested?

