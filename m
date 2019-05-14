Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A42C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:52:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4C022084A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 11:52:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kDdgHx32"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4C022084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F306B0003; Tue, 14 May 2019 07:52:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418766B0006; Tue, 14 May 2019 07:52:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E0886B0007; Tue, 14 May 2019 07:52:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6F406B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 07:52:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b8so10415897pls.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 04:52:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kV9fT0KmOxuF+T41tUiDHBswBBV2DoIvK7WOkx75qek=;
        b=sx9C7myWCQ5UrkQVAk6eApTynIiCytBa19u5zvW4v931bV1dIwGh1/NGBoxSclvndM
         tvOuFG+PUZWCCRB5PfyEjVg0VOMQMnbSSeB+Q21hXRQ9r6y1TWJV/JQbpE3Un9R+trbU
         c7BDfrcHyh/60XxZNiM0tJd0scwXL+o08TapsTWipmyPiweZ1vGDqkkmAygUPwPeNtnV
         fBA60Vb5gPYO2co7NwF0bzdouErNUZH0CQ/4bKB/wk4dlNHC5vMFJTDiH86T6QImy2Ky
         SNQE0+lOecxfxs94jtlTKfH3xpqoYYipQDQntqYdQa8VrqOEemvzPGS4cJg3f+W1kPaX
         qLOw==
X-Gm-Message-State: APjAAAVk+pES6eDAdTeSdXz2aCwEPymav83ZRIlvpfzQfKxHerlcax29
	GOkO9/q2EAx7VerufgkGsNg4NFaQY1b/Yg80MbjAUbJro/B/ENdrFKFfmUVP8LA8iKsSOHIThjd
	qtmD3W3t/PKZF4uA3L5Xox69GPhG2f8UtP3Qbv+ic5c5FH8xvYn3bqkdF/rG3oq8qAQ==
X-Received: by 2002:a63:1a03:: with SMTP id a3mr37791453pga.412.1557834749318;
        Tue, 14 May 2019 04:52:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwahPeb8n17ISPJRorgBYEnGf5BHZ8n9W8ecxruBnaswjrH7ilkcOU9HLnpwBHTfpfU0pjj
X-Received: by 2002:a63:1a03:: with SMTP id a3mr37791404pga.412.1557834748573;
        Tue, 14 May 2019 04:52:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557834748; cv=none;
        d=google.com; s=arc-20160816;
        b=UzBqBC02wJ7Jqp67QhkT3mfk7EKQnZJYWOA1aF0bPHmxUPuBTzIgP46YfzHmrVyA1N
         M5VJ2JmngSOh2SayNiNTx7il2lgm/3LnlJJQIFKJVD/r/a4z8YWEESoCyZjuNB48830i
         3zyIfABJFAcWczT8tMwler9oQGRsVyibCy3lOe0hVhBhG6Q5Vkb8KNuNbQoLuxPbFngA
         OxQ6qjbzspSl6SnV+tjlnqtGq+mIm3rWGD7ZTYTd+1IXCTcFNp7nAjVyqiawOiAuGY2N
         RV1Q08EyzrscvPNyocH9n9RHt8AO0EZFXQGxgSLNbUYejzI7k1opTTsc0r3hMuvOcB0P
         ldNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kV9fT0KmOxuF+T41tUiDHBswBBV2DoIvK7WOkx75qek=;
        b=HS7kLUcr8J567t7FXvioszpTiewmo7cYi3wMVmzPIfOefCiWyurGGbKGfMqTAM2dIO
         YYWAlOQFQC6GkJ0tiHML2b662QRjahlm37qPXhNlVXknBs+aVBPxmzrKe8nt1NQo9Zr0
         /TnIXhm3Na9GouZCEWZpcUyeVae8DXboW1/cZiFe8H/8PknCS8+RmGLaiRgs48/QExC4
         WElHdvGLmHfzVELTVTyxT4FVmBEYaErfuFqFZzA6xvGqM7nFESjczXgPXrnEowci9jN2
         8sfAYABBFSjq369VK5TUmcp9gNS93GDfd8K1z9thGxko6Xu87UrzKPEm8WOziSvBZpm9
         ESpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kDdgHx32;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e15si9093685pge.578.2019.05.14.04.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 04:52:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kDdgHx32;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=kV9fT0KmOxuF+T41tUiDHBswBBV2DoIvK7WOkx75qek=; b=kDdgHx3228aF+DbfBwQD1cHRG
	u/MMbPjYEL0gI73Cjho8IW7rrNyWJy4SF3XGW94P8Iix0SV2SjWlCxAwbmOOTV6tTRG35LBFf4ipQ
	WmEQCqLcYVJNZRlMVG00mMJ3Qv2lX8Iz+NrAgp1/x5TvoLry+b+txJvm39UcpnKHKEv+LHnYevmog
	fegtKzNMW/YO31a+A3Y1v4wfIbgywog0U1mYkFEiP+JkWkud8tASItZBQ4YG4Ag6sY0EPevk/NcTD
	SZDLr79gKNk3xpJDx8ce5YhH5Q/HME7A5PGRbiT2hGoODErs/vd1MEby9pArSOAdz9E3f1/+6MSVm
	8NgwrlXfA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQVyr-0004nf-Bl; Tue, 14 May 2019 11:52:25 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D1F0D2029F877; Tue, 14 May 2019 13:52:23 +0200 (CEST)
Date: Tue, 14 May 2019 13:52:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, jstancek@redhat.com,
	namit@vmware.com, minchan@kernel.org, mgorman@suse.de,
	stable@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190514115223.GP2589@hirez.programming.kicks-ass.net>
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513163804.GB10754@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513163804.GB10754@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 05:38:04PM +0100, Will Deacon wrote:
> On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
> > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > index 99740e1..469492d 100644
> > --- a/mm/mmu_gather.c
> > +++ b/mm/mmu_gather.c
> > @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >  {
> >  	/*
> >  	 * If there are parallel threads are doing PTE changes on same range
> > +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
> > +	 * flush by batching, one thread may end up seeing inconsistent PTEs
> > +	 * and result in having stale TLB entries.  So flush TLB forcefully
> > +	 * if we detect parallel PTE batching threads.
> > +	 *
> > +	 * However, some syscalls, e.g. munmap(), may free page tables, this
> > +	 * needs force flush everything in the given range. Otherwise this
> > +	 * may result in having stale TLB entries for some architectures,
> > +	 * e.g. aarch64, that could specify flush what level TLB.
> >  	 */
> > +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
> > +		/*
> > +		 * Since we can't tell what we actually should have
> > +		 * flushed, flush everything in the given range.
> > +		 */
> > +		tlb->freed_tables = 1;
> > +		tlb->cleared_ptes = 1;
> > +		tlb->cleared_pmds = 1;
> > +		tlb->cleared_puds = 1;
> > +		tlb->cleared_p4ds = 1;
> > +
> > +		/*
> > +		 * Some architectures, e.g. ARM, that have range invalidation
> > +		 * and care about VM_EXEC for I-Cache invalidation, need force
> > +		 * vma_exec set.
> > +		 */
> > +		tlb->vma_exec = 1;
> > +
> > +		/* Force vma_huge clear to guarantee safer flush */
> > +		tlb->vma_huge = 0;
> > +
> > +		tlb->start = start;
> > +		tlb->end = end;
> >  	}
> 
> Whilst I think this is correct, it would be interesting to see whether
> or not it's actually faster than just nuking the whole mm, as I mentioned
> before.
> 
> At least in terms of getting a short-term fix, I'd prefer the diff below
> if it's not measurably worse.

So what point? General paranoia? Either change should allow PPC to get
rid of its magic mushrooms, the below would be a little bit easier for
them because they already do full invalidate correct.

> --->8
> 
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1dd273..cc251422d307 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>  	 * forcefully if we detect parallel PTE batching threads.
>  	 */
>  	if (mm_tlb_flush_nested(tlb->mm)) {
> +		tlb->fullmm = 1;
>  		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +		tlb->freed_tables = 1;
>  	}
>  
>  	tlb_flush_mmu(tlb);

