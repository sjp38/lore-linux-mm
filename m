Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E1EDC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 10:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 405A3216C4
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 10:54:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iDGKS2pp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 405A3216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D28D86B0007; Thu,  9 May 2019 06:54:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD9896B0008; Thu,  9 May 2019 06:54:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC8B56B000A; Thu,  9 May 2019 06:54:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3626B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 06:54:57 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id q1so1739353itc.3
        for <linux-mm@kvack.org>; Thu, 09 May 2019 03:54:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bxtS26xVOjMNdacI/cyf12bZjI1vE2fsrBEFKhrTk7g=;
        b=f9Rlcq0zp9U1Xa2oNZLZXFxSEsd7qz5l7I5qty7/BdIex4xGs9OX1fU1/3rhcQgfjQ
         9digvTtTKN3nyRUm+yQnF4JOHvYEJUXZqrdI6vRj6bn4Lo7t/84XhdlXxePruhWIQFgv
         0qxHqHaDNIaa32KaVhl+3XosgbHjQRvvHbiWd2q3YHAcG3s/X4NvcQAP4BnDEg6Ggw/Z
         LaE2mdid9nfMwNAe4nwkAJUW5TJXoBt+1p6bzHOajWSeWi0pxlsbJdaNpLuktlFSyUBS
         WuP7vhTD5/VFXh+GRRT1O0zSTRp8c4gQfkGP8rc9WNBmhY9UH2qxVy+WlIf8ShEjVMGb
         6AZw==
X-Gm-Message-State: APjAAAUp2Mmfx51stVA4Dhm3AK0RceAbs8wtMlQOT+GQtxCYy+/TN3L+
	P/10GxKSUNu0HQEUwfZL69yCa8lh1Maxf634DsgyvNWwjFarqKNB16OXSB0h6nnKwtIyIvXu8nk
	On1jkjwnCCjzukxSNESXcsTETJXWdaIi7ICrv+mF54TWeMbsh5Z9eafbTNsEw8r2Juw==
X-Received: by 2002:a24:1a07:: with SMTP id 7mr2562097iti.16.1557399297420;
        Thu, 09 May 2019 03:54:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw57ZOG51tHdTsthOc9X7tudzMZzK6V8U2hIUzov6tUjDkz9iRvV8iUPUpxsjtWJbLWV3/k
X-Received: by 2002:a24:1a07:: with SMTP id 7mr2562058iti.16.1557399296705;
        Thu, 09 May 2019 03:54:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557399296; cv=none;
        d=google.com; s=arc-20160816;
        b=fFITeyE1HikKnMK+FUjDQ5ThS7umqP+9msqyoKVVNqvPfh03p6YfSLmLs6FiSGn/ka
         GRG2OMogTPJmump4vaRMzEDdRs6vw1gIFstLu1d4e+hGR4bF5Wj0Z00RUQbgNGHxs7m3
         wOxPEAngLEh3mfpOFLFjScQYm+QVBvLCKwD+TLUiqSJxYJkwmPfztu2qsOqfLRP3Hrf1
         ZxNjbEFnAsbHcu3DbYWRra0YolMJlrpwq2GEln/VKGnzfJES6K6Lz6Y6n4fUXBZFF3xs
         eoKKhVkctdR7d1glq5sdlISqy/liJNNCurvhFOJOuHOryUaiEhSQcmgrZBPzZ7lOCvDW
         KVXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bxtS26xVOjMNdacI/cyf12bZjI1vE2fsrBEFKhrTk7g=;
        b=L46NoVV8+T9HIaDYkABAWkM+1KVrMeKWqg+ILFdCaq2RRSgQg2JCEsUrBgjNW80LHk
         QZOevX9atZuY0nV9+sDKimaY6QEad61OHRB7Y35vbesBZ2glsD6zUjzeJOOJggVjKHRI
         ueBzPHD1UY0i6kZumpt/s39eBU4+DPgTQqcev+RQ3qSpOPyYC3eXjTvmXeucCSp5EhwJ
         9NzRc9qXP7IXM7s8AHK1ztyu+fmFd+i7RPNI0VuN8+WAQ6/DSWvHlVRHlplHplPFYnOZ
         4/mIR9MVrweneBv/BFV+YWJbdyJ2fqbnC0NMRaGdpcdzca+ti3NbbOePr0F+XxXo79PQ
         PA7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=iDGKS2pp;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a20si1082225ioc.19.2019.05.09.03.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 03:54:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=iDGKS2pp;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bxtS26xVOjMNdacI/cyf12bZjI1vE2fsrBEFKhrTk7g=; b=iDGKS2ppg8lbhcOC+BzYkdvjM
	z5i/B1R6hdkzVBmMJWHMxfFimmt4hdp3TzbU+MywQd+Xwu663pbMFF8BIv0Iarlkg/ymD1fSsC9bo
	6Zu8tuFyf6WvfJvQh+SKe+oHS378YgAqvmedIMRbj/Q6ReFedtC9T2QQJ7SFiF8Nkkvb4Ze5tbYGt
	lyKf09vFEeOoMkA7Tt3FgpN43Cdw0XE5U5EWAPI32slF+0IWwSfFHvJSta5SlAuhDVCMUcapq/mfh
	eU+riuTeHZPZqLqIcGmHqsuZW8z6GV8wszrd2pJXqjK14AKZpqVeiInwSygR0y95cUmGO4Ls9iavp
	xryW1hWcw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOghM-0002T0-Bg; Thu, 09 May 2019 10:54:48 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D7A9220274AF5; Thu,  9 May 2019 12:54:46 +0200 (CEST)
Date: Thu, 9 May 2019 12:54:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, jstancek@redhat.com,
	akpm@linux-foundation.org, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com,
	namit@vmware.com, minchan@kernel.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190509105446.GL2650@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509103813.GP2589@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 12:38:13PM +0200, Peter Zijlstra wrote:

> That's tlb->cleared_p*, and yes agreed. That is, right until some
> architecture has level dependent TLBI instructions, at which point we'll
> need to have them all set instead of cleared.

> Anyway; am I correct in understanding that the actual problem is that
> we've cleared freed_tables and the ARM64 tlb_flush() will then not
> invalidate the cache and badness happens?
> 
> Because so far nobody has actually provided a coherent description of
> the actual problem we're trying to solve. But I'm thinking something
> like the below ought to do.

There's another 'fun' issue I think. For architectures like ARM that
have range invalidation and care about VM_EXEC for I$ invalidation, the
below doesn't quite work right either.

I suspect we also have to force: tlb->vma_exec = 1.

And I don't think there's an architecture that cares, but depending on
details I can construct cases where any setting of tlb->vm_hugetlb is
wrong, so that is _awesome_. But I suspect the sane thing for now is to
force it 0.

> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index 99740e1dd273..fe768f8d612e 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>  		unsigned long start, unsigned long end)
>  {
>  	/*
> -	 * If there are parallel threads are doing PTE changes on same range
> -	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> -	 * flush by batching, a thread has stable TLB entry can fail to flush
> -	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> -	 * forcefully if we detect parallel PTE batching threads.
> +	 * Sensible comment goes here..
>  	 */
> -	if (mm_tlb_flush_nested(tlb->mm)) {
> -		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
> +		/*
> +		 * Since we're can't tell what we actually should have
> +		 * flushed flush everything in the given range.
> +		 */
> +		tlb->start = start;
> +		tlb->end = end;
> +		tlb->freed_tables = 1;
> +		tlb->cleared_ptes = 1;
> +		tlb->cleared_pmds = 1;
> +		tlb->cleared_puds = 1;
> +		tlb->cleared_p4ds = 1;
>  	}
>  
>  	tlb_flush_mmu(tlb);

