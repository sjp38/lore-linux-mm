Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7E4AC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:24:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C621217D7
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:24:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FcMOrOHH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C621217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399626B0006; Thu,  9 May 2019 14:24:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A276B0007; Thu,  9 May 2019 14:24:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 261EA6B0008; Thu,  9 May 2019 14:24:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E30FC6B0006
	for <linux-mm@kvack.org>; Thu,  9 May 2019 14:24:42 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o8so2193717pgq.5
        for <linux-mm@kvack.org>; Thu, 09 May 2019 11:24:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N9B1cpMq+/LvLmsepUerJSSHdTQN572R9HJQBCxTJBE=;
        b=Twy35NMMoe+AgnT5xSpKgKYd1OWMt3V9aExSESjiEldVMFwpi1ksHXXsWPqw+vVOUC
         IcXy57KG2ctdsgAOaZFC7FhH6kdfGdADUQjuFcij077JPlfQIqtLnDhnJ+2vJMaHqzR4
         ZV/1POXqXzNYbFm23/CxotunFK2p8TqtfR3FwwW9YAyGIBky0LBJO3Q5lJ1ExDrIRdU0
         1o8UmAFLzddnRYVXMkRmE9U+ItWfS4m4tn0ELKDy6tiO4mWY/dz/J52mW7M/5mc/pg90
         uqChfXjjGCvCsOBNWPsJH7tt3fWP3ulq48BAswS5+CFq+CegdPnLFXqCTawCTG3ybotw
         sU/g==
X-Gm-Message-State: APjAAAWG1gdvF1s0nzbhLdm725dzZz2uoSAaxs4fRCi7wavJislHsWT0
	fAQOwMFiZEhs5Q/0LGTMvjhb/Xj86bohjE+cBdmCllTci0R25iPI17wY4WYfYhOmatDf8gZ9aOS
	YGO6kuAMGIhdnc5nKCCZtzM8C8cBzx3rRl+7GZ6HIopGuBcR6br+x0JorM19uK6fcaA==
X-Received: by 2002:a62:6444:: with SMTP id y65mr7468557pfb.148.1557426282509;
        Thu, 09 May 2019 11:24:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4BQzbUOjXb0ojoT7LzKoOl7U+iFr1yT8+lCpneZi/Fh1e8JaftQ8EqKCs599Wm5CYda2x
X-Received: by 2002:a62:6444:: with SMTP id y65mr7468458pfb.148.1557426281748;
        Thu, 09 May 2019 11:24:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557426281; cv=none;
        d=google.com; s=arc-20160816;
        b=rF9x88sW+fClDXkiv3NoKXRVPQEx4vsD/r4eHsQYFl36K9dgmm68Tx6In8LaSdj0f2
         8S/cTR0K9Movxg9bpzdX6gtYqamKdPDZ4MP5IO27R77Vl7i/RDlBL1ogEcVN9eSigg/R
         FL206dCGVamYVCTw1ow2iqCOCXS+/T52mQo64W0kZFEURXaDk13V90GlyG0qaWfq9yFw
         kmn3hq+djsw3vtGNqw28pKvI6tud3VgqzOfZpSrqCQ9LSh2Ah5EhhuAuKzCD3Wgr2DgC
         weAvYOMf0sqDcs7DAUdJqZWU+RJ2mXn6G+wKo9MJpEDtSw+KiLGN9t5QAOXeBB9yPoCD
         ME0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N9B1cpMq+/LvLmsepUerJSSHdTQN572R9HJQBCxTJBE=;
        b=U7rVS8czHwDChS7ivsGy0Ody5eAkUkW1xG/GXGiZgoMwwK+OSmsRVzeiUTEH4TYs2Y
         4d1hJSmpdyrW7NI/dqN/XDxaPX29N7soitLyedoGi3Aoh/FOCQsxE0iMG/3CZ5wxzkpx
         SI+0CgzJfTNkzzIR70wHWIM2V4AeAY6ldA0sD5kFKQ2BUKF2MRBDN/RO+yzonsTNoBxw
         O7FKEHND6jl0PCYWkTQY6IUusnXVUlL+oAoJrOqdQjIMvwEDT4zBucSHqeQayxi8Z2sc
         /Kti3PUSp5OMfWuC6Qk9z3j/Kh4t71ZkwnCTZQ/lYC+MZLhHJNDcmRGzXm2+kS2fVTrk
         twWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FcMOrOHH;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 2si3554299pld.334.2019.05.09.11.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 11:24:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FcMOrOHH;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=N9B1cpMq+/LvLmsepUerJSSHdTQN572R9HJQBCxTJBE=; b=FcMOrOHHcG1ZwURclcVBLK1Ut
	SPCIj8zaGs/U/st2rzMJHf1OgImQ3EzUSC3TzCjw8nolbOJvNd3b6VlKt0SE5qNFqiDR5YBOG4ygR
	F/LmZ8zNvc0VBqSiZrRP6vWWPOky/GDT0DXYAtxxopXEC1s9RSO7Fx6HqCM/2x+4E3qFk3xsjK243
	74JqVIF6vW3wMw1mPLz0vu0bvweRPPoQvXwIULz5rhYepTZUucDiZ1lIgpVeSmAG9dCHVfWp2DSJe
	0O2zDhqo3Um0naQTSkmMqwac4xnGnRsEd5odZRu4gdFHlSAGSBlj2BJLp6LzKD/biQI838QA8VM3l
	T/Bkhm4tw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOnig-00030y-1J; Thu, 09 May 2019 18:24:38 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B75302143093D; Thu,  9 May 2019 20:24:35 +0200 (CEST)
Date: Thu, 9 May 2019 20:24:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Will Deacon <will.deacon@arm.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>,
	"npiggin@gmail.com" <npiggin@gmail.com>,
	"minchan@kernel.org" <minchan@kernel.org>,
	Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190509182435.GA2623@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 05:36:29PM +0000, Nadav Amit wrote:
> > On May 9, 2019, at 3:38 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > index 99740e1dd273..fe768f8d612e 100644
> > --- a/mm/mmu_gather.c
> > +++ b/mm/mmu_gather.c
> > @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> > 		unsigned long start, unsigned long end)
> > {
> > 	/*
> > -	 * If there are parallel threads are doing PTE changes on same range
> > -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> > -	 * flush by batching, a thread has stable TLB entry can fail to flush
> > -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> > -	 * forcefully if we detect parallel PTE batching threads.
> > +	 * Sensible comment goes here..
> > 	 */
> > -	if (mm_tlb_flush_nested(tlb->mm)) {
> > -		__tlb_reset_range(tlb);
> > -		__tlb_adjust_range(tlb, start, end - start);
> > +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
> > +		/*
> > +		 * Since we're can't tell what we actually should have
> > +		 * flushed flush everything in the given range.
> > +		 */
> > +		tlb->start = start;
> > +		tlb->end = end;
> > +		tlb->freed_tables = 1;
> > +		tlb->cleared_ptes = 1;
> > +		tlb->cleared_pmds = 1;
> > +		tlb->cleared_puds = 1;
> > +		tlb->cleared_p4ds = 1;
> > 	}
> > 
> > 	tlb_flush_mmu(tlb);
> 
> As a simple optimization, I think it is possible to hold multiple nesting
> counters in the mm, similar to tlb_flush_pending, for freed_tables,
> cleared_ptes, etc.
> 
> The first time you set tlb->freed_tables, you also atomically increase
> mm->tlb_flush_freed_tables. Then, in tlb_flush_mmu(), you just use
> mm->tlb_flush_freed_tables instead of tlb->freed_tables.

That sounds fraught with races and expensive; I would much prefer to not
go there for this arguably rare case.

Consider such fun cases as where CPU-0 sees and clears a PTE, CPU-1
races and doesn't see that PTE. Therefore CPU-0 sets and counts
cleared_ptes. Then if CPU-1 flushes while CPU-0 is still in mmu_gather,
it will see cleared_ptes count increased and flush that granularity,
OTOH if CPU-1 flushes after CPU-0 completes, it will not and potentiall
miss an invalidate it should have had.

This whole concurrent mmu_gather stuff is horrible.

  /me ponders more....

So I think the fundamental race here is this:

	CPU-0				CPU-1

	tlb_gather_mmu(.start=1,	tlb_gather_mmu(.start=2,
		       .end=3);			       .end=4);

	ptep_get_and_clear_full(2)
	tlb_remove_tlb_entry(2);
	__tlb_remove_page();
					if (pte_present(2)) // nope

					tlb_finish_mmu();

					// continue without TLBI(2)
					// whoopsie

	tlb_finish_mmu();
	  tlb_flush()		->	TLBI(2)


And we can fix that by having tlb_finish_mmu() sync up. Never let a
concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
have completed.

This should not be too hard to make happen.

