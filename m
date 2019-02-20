Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C0C6C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 01:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A3C62147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 01:34:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bZ/NLV4M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A3C62147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91A6B8E0004; Tue, 19 Feb 2019 20:34:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CC1D8E0002; Tue, 19 Feb 2019 20:34:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794BE8E0004; Tue, 19 Feb 2019 20:34:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3675D8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:34:17 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 134so1157520pfx.21
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 17:34:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PRSIKyWGlp4IRL5U3poRtn869xh39TrOyzFq0P3QZ2Q=;
        b=bkCcFlhX9VCCGpM2SibNOOkeewcGOA/Z3am4hRIey3srFqlPsLNrIC6HylrJ5W9VFY
         bH+q++W5vUFza6KPwk6+ZihoshVDh0j8owF6ubQ29dyklpolSt1eGhMu0JaSH+NZ4lQl
         oM31JxrkZIY7L8Lus0kvnvtYpA9MGgT87DITC5axUIQrQhwS78Du4WxHLt2XFMUu4FGI
         tiXYizjbXJ87S4ze7KQjw6UMZLeepMAmpf9zLykgCcvgkN7zh4A421ExFJabrbGBBzc0
         VJ7HzqF7cGeNuS/jJ1ymR7iIEVhj6O0De+PJ27XIRT5z7ZA3p8LWu0bfDKqm/BrhpnKL
         JVFA==
X-Gm-Message-State: AHQUAuY8K6WyTQwPYc2IAhQIl7fOechpmzZVpWjaWYDjeSgQOME/0cQp
	WPhHrLv/mGegD9qfguiBPm/p+zQwtB2S2jJvy450z6vPZcuWDv2N0/WnFu8c3X5/HAtodQrqWnC
	gmt00gRwuHpsY4OxJhiiQiOOc4fhFN6HvTbyhSGmIYfo+9mZqnNnWWm3WNznS1eyj7g==
X-Received: by 2002:a63:1625:: with SMTP id w37mr13171112pgl.13.1550626456798;
        Tue, 19 Feb 2019 17:34:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZAcy2Kp6fQK7rI3rrhWX79hsANIwGIdpzr0c4BqIyzDTV9SrKU/3N5fCS9YMHSJl2EyfD+
X-Received: by 2002:a63:1625:: with SMTP id w37mr13171050pgl.13.1550626455896;
        Tue, 19 Feb 2019 17:34:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550626455; cv=none;
        d=google.com; s=arc-20160816;
        b=C4rikdRc+CoWMbG7UMO5uq6SobKFnBFHi3TkQJMLIz79gJfNIK6aFA/WdX4QTBSCo0
         hIbRZNq4/spQSdrxVWhQYt4S80JviKBGaKyj/XpG20j1tGjljF0Iozq1z6ZdOhevZa5E
         QPtBd+IlE35YWcDCbPEgWlIeeGTv1AXzmbm6CiFb2Oi9Ig0/vec7W3AvOO6rPUOjgLLh
         AUOAviam6FZ4VbjyBKMWgvy04Y4lizSzfIlWg+r1GIfx2NCPxwhTRZ4WQBjQe9jYXBOv
         fzHFOdmQNm7hEJDFmMVJW/eLAwX0HYnZY4ww0HNbB/HriwChngxxddWNgyvAzW3uXD92
         dGjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PRSIKyWGlp4IRL5U3poRtn869xh39TrOyzFq0P3QZ2Q=;
        b=oa//zojknUQ328LhIZ4EJo7aQkmfzsDV8QzRXIhElHaGKcIIyXOvWoxyOY/q3FpmY9
         Vypu+EIIY1CG+2WjJRZW9qQ5JqkRsQCrZK4wt2EOvOHk4Cprwq0BOkwngwRD2kbXZNyE
         TxHOTPp3xq/9uY1QmM/jsDaRTzHWt8WwlYEk+oECgBQUYjcW72lXMs86lggW0YwLMFwe
         JDbhlPNZsqBL+3dcAXyaS6eFDU0KE9OQ5s7OF0P/VQ2UhjaPQygFDEQ33YIWTB0EQ09W
         I0IV6NQgRF6iY89o/pzlC/FKhM7qV34Riv5bBtNeWEeGgd+kPTt00i6lJS9PjE8d4yNQ
         nebw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="bZ/NLV4M";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p7si16863299pgh.84.2019.02.19.17.34.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 17:34:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="bZ/NLV4M";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PRSIKyWGlp4IRL5U3poRtn869xh39TrOyzFq0P3QZ2Q=; b=bZ/NLV4MwKY7lb9t+FHLKs94o
	iRgSB4twz8ypzAyCc4XL0EXdwWQWakzQHrkn3g42AU61Z8nvUXXSL7azQBJfBB7v9G7/ZeUqWxgM2
	mhwB/kBgupyMLUuGqqMOw41azGd4eMZ9RGg7KeQoNmiSa0hpT7sgObheSBf3thaeuuVRd/3sIHbKt
	IwaXpl3sdSAQN7fxbL2jqAI736aYMrTsIs83uUNcFadhLasZwn5vvIfXreisMMKTHBGpz6hokrI5a
	NLx4RHthG7Erm9QLRS/qs8kcLRqcfHoXYTTyCpNKi2wGitjNUladSNsLfJYsHO28jGYWRRB9/XSzE
	zoGzM1tjw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwGlz-00048r-IW; Wed, 20 Feb 2019 01:34:07 +0000
Date: Tue, 19 Feb 2019 17:34:07 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190220013407.GD12668@bombadil.infradead.org>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
 <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:47:12AM +0530, Anshuman Khandual wrote:
> + Matthew Wilcox
> On 02/19/2019 11:02 AM, Yu Zhao wrote:
> > On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
> >>
> >>
> >> On 02/19/2019 04:43 AM, Yu Zhao wrote:
> >>> For pte page, use pgtable_page_ctor(); for pmd page, use
> >>> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> >>> p4d and pgd), don't use any.
> >> pgtable_page_ctor()/dtor() is not optional for any level page table page
> >> as it determines the struct page state and zone statistics.
> > 
> > This is not true. pgtable_page_ctor() is only meant for user pte
> > page. The name isn't perfect (we named it this way before we had
> > split pmd page table lock, and never bothered to change it).
> > 
> > The commit cccd843f54be ("mm: mark pages in use for page tables")

Where did you get that commit ID from?  In Linus' tree, it's
1d40a5ea01d53251c23c7be541d3f4a656cfc537

> > clearly states so:
> >   Note that only pages currently accounted as NR_PAGETABLES are
> >   tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.
> 
> I think the commit is the following one and it does say so. But what is
> the rationale of tagging only PTE page as PageTable and updating the zone
> stat but not doing so for higher level page table pages ? Are not they
> used as page table pages ? Should not they count towards NR_PAGETABLE ?
> 
> 1d40a5ea01d53251c ("mm: mark pages in use for page tables")

I think they should all be accounted towards NR_PAGETABLE and marked
as being PageTable.  Somebody needs to make the case for that and
send the patches.  That patch even says that there should be follow-up
patches to do that.  I've been a little busy and haven't got back to it.
I thought you said you were going to do it.

> pgtable_page_ctor/dtor() use across arch is not consistent and there is a need
> for generalization which has been already acknowledged earlier. But for now we
> can atleast fix this on arm64.
> 
> https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com/

... were you not listening when you were told that was completely
inadequate?

