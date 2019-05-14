Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 961C1C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 522442084E
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:54:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 522442084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E66146B000A; Tue, 14 May 2019 10:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF0036B000C; Tue, 14 May 2019 10:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2D776B000D; Tue, 14 May 2019 10:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 849FB6B000A
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:54:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b22so23754145edw.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/YbdaWr/TLVffU34SPaypXt+dkbB/KmzqXLEP5cAQHs=;
        b=Pq1tReMxpQVuQkYTeHKT/oAJHg99a7DvZ9ShVQEGgZl+GPDgx8Swy5YL5/D8y+BVuv
         Hxzha7ijXWLg83fmHGhqGMmTe8xyv+h7wR3IxYA/0XfQQJeW7tpQL4ujuiKz72EVr2RS
         73vxlePru5W3+0OkI1tUD8xC5y3kgy1ZODs5u6xIiY04GKZX2ANNhNMJABiB0LfOmL+a
         7p1uT1OAWON0BNE2PoAhgjvmwfMtT66+DBooEytEjsHmcVxtObewk1fhGg1PExNTPFGx
         de1JVomWnd4v2GnxiMK7KQIJh1RBjaMl9UBTIZI0CNja+JAocd2SvPxnwAZsM9/oqds3
         8TFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAUa9XAo+5+/ezmYHszR0fjWdG9Nhy8YSrY8+rZu46Ukf0vKhz1l
	k+wf4/MSaK4q8B57jRa4xwyX2tAsRDkc6oNhjRatfKWvgWmg+TTwIgvwBO+SI5s2pnNObKpTyTS
	+Y2NOEHDaapFQCzfP6lyNudoP866oxqJteH6xJ9diTvKsnwwdbriVW6zQsnZTh+E7gw==
X-Received: by 2002:a50:9d43:: with SMTP id j3mr35858982edk.59.1557845692056;
        Tue, 14 May 2019 07:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEDSKs7B9sFk6+nM5pocuI1xvwpqQg7F00kxjcocqN27L/7+icNzhzfhIYshboioXr4c10
X-Received: by 2002:a50:9d43:: with SMTP id j3mr35858887edk.59.1557845691139;
        Tue, 14 May 2019 07:54:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557845691; cv=none;
        d=google.com; s=arc-20160816;
        b=jztjq5cgbKiGjN7oG6wLKxLS4HJ22PblD8/u3pBhnKA97yTwWfdkzU+rPGn23POh3O
         UzuRUuOO8odO47tYvlldlf0A+1NTTlQb/0mvWA9iJoPW72nucLcTxF1Ynpu/k9v9S0vS
         k4iB1nEyi/KGGyUVJVq2UkVwQWLM/OkbssT3ACiQ1pGNb0Q8lqeUAE97Bp7ZLEkxoudZ
         emPmvNHL+1CyncU+13OV8jQK3kj3/P1D/2l4Y63j247IxADfoGz0PSlsi4/B/+oopucy
         oSNW/B4WUItL5kc8EpU2qzoJ8YTe/C38OONJ5W3QAu3YiDiuHT7g/YdbrmDoAgv7bda9
         eZ2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/YbdaWr/TLVffU34SPaypXt+dkbB/KmzqXLEP5cAQHs=;
        b=X3tymPpPWmIH/EGAxBdiK9isA9Y9YV/VOSaG+US4GDciDrNy/kYWaltcv+gbNY5/dH
         jUncpDWRfVJntt+K5F0AIQ2ceFp33ysVba/MTSymw7cmMqJsBOl0utonC/orobWEYyth
         6aKWTgGbxi3XAW/kqei4BzeYy3vwKa+nSNkVuL3k3fafV7aDFEMH5LMg+YwEVVRN3dV6
         YmJU9/2B4xelK+RMGZSEkNjsYAZKfgIQ0NzxVk3n9VXYe6VdecU8THd8jkOl57OKslCA
         gD4czji4hhLqpKUj2GNc+vhrtggsM+GS0lWapvqBh47Lq2BUL1FrYht87zSPvJ1qbKZT
         mORQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o9si3936429ejz.286.2019.05.14.07.54.50
        for <linux-mm@kvack.org>;
        Tue, 14 May 2019 07:54:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CC259374;
	Tue, 14 May 2019 07:54:49 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2CC6F3F703;
	Tue, 14 May 2019 07:54:48 -0700 (PDT)
Date: Tue, 14 May 2019 15:54:45 +0100
From: Will Deacon <will.deacon@arm.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: jstancek@redhat.com, peterz@infradead.org, namit@vmware.com,
	minchan@kernel.org, mgorman@suse.de, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190514145445.GB2825@fuggles.cambridge.arm.com>
References: <1557444414-12090-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513163804.GB10754@fuggles.cambridge.arm.com>
 <360170d7-b16f-f130-f930-bfe54be9747a@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <360170d7-b16f-f130-f930-bfe54be9747a@linux.alibaba.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 04:01:09PM -0700, Yang Shi wrote:
> 
> 
> On 5/13/19 9:38 AM, Will Deacon wrote:
> > On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
> > > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > > index 99740e1..469492d 100644
> > > --- a/mm/mmu_gather.c
> > > +++ b/mm/mmu_gather.c
> > > @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> > >   {
> > >   	/*
> > >   	 * If there are parallel threads are doing PTE changes on same range
> > > -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> > > -	 * flush by batching, a thread has stable TLB entry can fail to flush
> > > -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> > > -	 * forcefully if we detect parallel PTE batching threads.
> > > +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
> > > +	 * flush by batching, one thread may end up seeing inconsistent PTEs
> > > +	 * and result in having stale TLB entries.  So flush TLB forcefully
> > > +	 * if we detect parallel PTE batching threads.
> > > +	 *
> > > +	 * However, some syscalls, e.g. munmap(), may free page tables, this
> > > +	 * needs force flush everything in the given range. Otherwise this
> > > +	 * may result in having stale TLB entries for some architectures,
> > > +	 * e.g. aarch64, that could specify flush what level TLB.
> > >   	 */
> > > -	if (mm_tlb_flush_nested(tlb->mm)) {
> > > -		__tlb_reset_range(tlb);
> > > -		__tlb_adjust_range(tlb, start, end - start);
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
> > >   	}
> > Whilst I think this is correct, it would be interesting to see whether
> > or not it's actually faster than just nuking the whole mm, as I mentioned
> > before.
> > 
> > At least in terms of getting a short-term fix, I'd prefer the diff below
> > if it's not measurably worse.
> 
> I did a quick test with ebizzy (96 threads with 5 iterations) on my x86 VM,
> it shows slightly slowdown on records/s but much more sys time spent with
> fullmm flush, the below is the data.
> 
>                                     nofullmm                 fullmm
> ops (records/s)              225606                  225119
> sys (s)                            0.69                        1.14
> 
> It looks the slight reduction of records/s is caused by the increase of sys
> time.

That's not what I expected, and I'm unable to explain why moving to fullmm
would /increase/ the system time. I would've thought the time spent doing
the invalidation would decrease, with the downside that the TLB is cold
when returning back to userspace.

FWIW, I ran 10 iterations of ebizzy on my arm64 box using a vanilla 5.1
kernel and the numbers are all over the place (see below). I think
deducing anything meaningful from this benchmark will be a challenge.

Will

--->8

306090 records/s
real 10.00 s
user 1227.55 s
sys   0.54 s
323547 records/s
real 10.00 s
user 1262.95 s
sys   0.82 s
409148 records/s
real 10.00 s
user 1266.54 s
sys   0.94 s
341507 records/s
real 10.00 s
user 1263.49 s
sys   0.66 s
375910 records/s
real 10.00 s
user 1259.87 s
sys   0.82 s
376152 records/s
real 10.00 s
user 1265.76 s
sys   0.96 s
358862 records/s
real 10.00 s
user 1251.13 s
sys   0.72 s
358164 records/s
real 10.00 s
user 1243.48 s
sys   0.85 s
332148 records/s
real 10.00 s
user 1260.93 s
sys   0.70 s
367021 records/s
real 10.00 s
user 1264.06 s
sys   1.43 s

