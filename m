Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C737FC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 12:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79CF320881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 12:02:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79CF320881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2420E6B0007; Tue, 14 May 2019 08:02:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EE8A6B0008; Tue, 14 May 2019 08:02:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DDE66B000A; Tue, 14 May 2019 08:02:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2D006B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 08:02:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y22so18750935eds.14
        for <linux-mm@kvack.org>; Tue, 14 May 2019 05:02:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xLo4b1OAYRv30TeuYjgpk/OjC183NLin3aZGUPtrEbI=;
        b=Iq3KOmYTpdenLUxHeZ8k9AM6vZm8w/YDyTchPFc9JegHSp6fDvnLrGJEjK9r+d/f77
         lN0ri8jbaZcMuFfgkeA12KAqK3ukDoOi/6yz/eSBqnsCsz91SKcUO7FZYDk6hz/jLOMp
         L6OYK+dqwVvDdjqJMAwKFumXvc2XV7l2PLr64gGXNr4wFjEK8jc55kv9Zh/Fagf26+V9
         nqiyqpts2brnc1hyS15mTeNKQKLsA0DSPVzj1I/WtL6cJqI+XU8Ne9p3/mOr/ooPNIMo
         mrG/05O41f+uMJ2lflFET90hCSdvD97Em2iC4LNK952dxXYVs9Fu2ZUuaLJZ/eqNdTMN
         cJsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAW51WNndnoIPDh1rZ492+K0gZK2Urj7BzLTx1bDxDWLxeZtPSzs
	RouImeJdaxPrUcuWb4erlMXxnEhGKkTbY5wAYt2g/6P5tEiY0FR7lmnpbQPkN8QLQlcMLLAhw9H
	+Dgkg3Aae4A93ausd+m3cyol4ZdJ66ITskLnj0YFNCJ1uKU+B3FcRYrdFXn9JYSSdbA==
X-Received: by 2002:a05:6402:8d8:: with SMTP id d24mr35546153edz.36.1557835349305;
        Tue, 14 May 2019 05:02:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweWWZtum19xI5MbPPj4hH1AJX3OaxR7VZBg616c87TFstZYKuYQwytjlYtkJiCdwAwIcdc
X-Received: by 2002:a05:6402:8d8:: with SMTP id d24mr35546034edz.36.1557835348291;
        Tue, 14 May 2019 05:02:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557835348; cv=none;
        d=google.com; s=arc-20160816;
        b=b4bVClcjwtYLEA//cq6I/0sShBkqrY0XZtZC47V3dZE52qbMF4rsJBy8xthouJmbH7
         C9z4WVI80TLSDD+DUyoymcvX4YtJPYa6MDnI14ni4m6kR/cWaxXre8AaWlDHlpLoA0Hw
         UrAZPqzFqH3RFhV1GjeESIn8LPlknJDJqGEHIIQcmgyIq+ESHufuCpgZgH9evn3/GbtQ
         JCJgaNEstCgwYVSHPwHtlPqKDXRc58NvIITYYUlJX+n92RJTsMaQnNAY33T2M8jhQMfh
         ys+Z64Wcmb8WazNL42oEvIm0RsmAfcoZnWRNe0k28nEeOo7Eup7T6fPG7hfkt3jn6Fcq
         LbGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xLo4b1OAYRv30TeuYjgpk/OjC183NLin3aZGUPtrEbI=;
        b=rVIZCqIGkbdzkDOKIgXG+dPhA+3XM+f9bPcmV8EMfF8aKNPaxGi7oY0dd145P2wuQt
         DDuScmgABgWNUHorxWRxreL5wZkR7qJ2kp2EZgZnHk0gW0CjD5uJLmvRcwycdhXXSRR4
         wr6h3hxZU/kLwESIUynG0MPj6nsBCpgcPT9Pauib3+v0h+ZfooqYoRoffe5/QOFVpAxp
         OcKOFw/PGeOwhncVcmT37kngLH/dNl8yPr4BwqeufGClJ+XPIrR2lW9ldB56lCugywyg
         3Fz4IDhHV1jpdQe0IZga0EjPx+zreBBjhLhp0D2gT1I2zYHwl67P7QohWr8dZyv9xm2L
         IcEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c6si1178294edb.238.2019.05.14.05.02.27
        for <linux-mm@kvack.org>;
        Tue, 14 May 2019 05:02:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3890D341;
	Tue, 14 May 2019 05:02:27 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8F02D3F71E;
	Tue, 14 May 2019 05:02:25 -0700 (PDT)
Date: Tue, 14 May 2019 13:02:20 +0100
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, jstancek@redhat.com,
	namit@vmware.com, minchan@kernel.org, mgorman@suse.de,
	stable@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190514120220.GA16314@fuggles.cambridge.arm.com>
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513163804.GB10754@fuggles.cambridge.arm.com>
 <20190514115223.GP2589@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514115223.GP2589@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 01:52:23PM +0200, Peter Zijlstra wrote:
> On Mon, May 13, 2019 at 05:38:04PM +0100, Will Deacon wrote:
> > On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
> > > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > > index 99740e1..469492d 100644
> > > --- a/mm/mmu_gather.c
> > > +++ b/mm/mmu_gather.c
> > > @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> > >  {
> > >  	/*
> > >  	 * If there are parallel threads are doing PTE changes on same range
> > > +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
> > > +	 * flush by batching, one thread may end up seeing inconsistent PTEs
> > > +	 * and result in having stale TLB entries.  So flush TLB forcefully
> > > +	 * if we detect parallel PTE batching threads.
> > > +	 *
> > > +	 * However, some syscalls, e.g. munmap(), may free page tables, this
> > > +	 * needs force flush everything in the given range. Otherwise this
> > > +	 * may result in having stale TLB entries for some architectures,
> > > +	 * e.g. aarch64, that could specify flush what level TLB.
> > >  	 */
> > > +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
> > > +		/*
> > > +		 * Since we can't tell what we actually should have
> > > +		 * flushed, flush everything in the given range.
> > > +		 */
> > > +		tlb->freed_tables = 1;
> > > +		tlb->cleared_ptes = 1;
> > > +		tlb->cleared_pmds = 1;
> > > +		tlb->cleared_puds = 1;
> > > +		tlb->cleared_p4ds = 1;
> > > +
> > > +		/*
> > > +		 * Some architectures, e.g. ARM, that have range invalidation
> > > +		 * and care about VM_EXEC for I-Cache invalidation, need force
> > > +		 * vma_exec set.
> > > +		 */
> > > +		tlb->vma_exec = 1;
> > > +
> > > +		/* Force vma_huge clear to guarantee safer flush */
> > > +		tlb->vma_huge = 0;
> > > +
> > > +		tlb->start = start;
> > > +		tlb->end = end;
> > >  	}
> > 
> > Whilst I think this is correct, it would be interesting to see whether
> > or not it's actually faster than just nuking the whole mm, as I mentioned
> > before.
> > 
> > At least in terms of getting a short-term fix, I'd prefer the diff below
> > if it's not measurably worse.
> 
> So what point? General paranoia? Either change should allow PPC to get
> rid of its magic mushrooms, the below would be a little bit easier for
> them because they already do full invalidate correct.

Right; a combination of paranoia (need to remember to update this code
to "flush everything" if we add new fields to the gather structure) but
I also expected the performance to be better on arm64, where having two
CPUs spamming TLBI messages at the same time is likely to suck.

I'm super confused about the system time being reported as higher with
this change.  That's really not what I expected.

Will

