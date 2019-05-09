Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B44CC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 10:38:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B02220989
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 10:38:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E5jKWBxG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B02220989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EE876B0003; Thu,  9 May 2019 06:38:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A0CD6B0006; Thu,  9 May 2019 06:38:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78EB76B0007; Thu,  9 May 2019 06:38:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58FFD6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 06:38:27 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id b19so1345312ion.11
        for <linux-mm@kvack.org>; Thu, 09 May 2019 03:38:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=c6Ta/z7A7D/ipm/ZpxXFg014k6CtyteotS2JTyMAkLE=;
        b=NeFKDQtmAfhaSQzUHIPKWCvB+xmbN2N1w06h4Ouz7Y+UJBC7xNmeK1MbT6Gv493+9d
         ugO6IsU8XIkbVRRtkpvo4j2o0wmBzX2yuPHMUvdaZo++5aWO/4tBQzVXU95Yd4c9GkLm
         g+R2OEWRClvuIu99JeFkWVYZZ0KVlPhcEZs4VEgs0ShoqxIAeQteCNltNuLziLF3w5p9
         4m8IdA6PU360sb4l81q+wE346oOo3Kl/Fyr+El2VYxt8F3FC+GfSHPuflOZ1IpUr7GBE
         yaXYi2fTwSj3AqC7AyH+9pycXgGel3b8wCxdjDf6MCUClY3PdVBcp1ili1StvJ5dCQQT
         m9zg==
X-Gm-Message-State: APjAAAX7u9tuTPyrErAHNI1WvQW+alqr9dgrB7L0Uw/UVoJUHGPPWstb
	IJc5Qfrd20nb4bPO/neSbDPtf5MeRlWMVfWoHtebNQ93c/duRlW0MBgAjkmK5K8BrGFrRKz2Izf
	xyBWYBn7SZFmycAZKUl+3BgyoSp8bPodnw/bmh1UGDGMCjVOpl0S17X1K1SSZozJByw==
X-Received: by 2002:a02:a1d6:: with SMTP id o22mr2477682jah.102.1557398307089;
        Thu, 09 May 2019 03:38:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGkG2QZTtx0KnohHHeMx5clPnixHqJLTCVIs4V/zAvbx/uSqIGGpb3ybQYrlrgmCMZsUri
X-Received: by 2002:a02:a1d6:: with SMTP id o22mr2477611jah.102.1557398306206;
        Thu, 09 May 2019 03:38:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557398306; cv=none;
        d=google.com; s=arc-20160816;
        b=caZ+CR7rc/d7Owcb9vQPrLnBw9ap4tqoakUzl3+cbPA5CyEIhsSrlYNz2c5K5tpv+6
         ULLgdwHujKxsruBjnc5zI2VTTAYkyK46dgpUcoOaR0yaSSc39a2CPo8+vH5WoX4qOJjH
         Ue2nDdlpfmBwsyjfk+ER3dMlsbB4M2izJxLqoczK9RNbTzF17TPWBsi9ld5nYrGkuMKc
         en6UeWsND2Z/kQKGZqLB8Ld7SPKQ4uv4g52gw/tvkGZY2vgJz97Kdgl3XZFGthBPFrmm
         UY44XusApZ/6rkA0FDQNN4riodW9+SgjzRBQ0Dux5v/A+kUFRWTvHJtBLIPMgj1JpVW6
         dArw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=c6Ta/z7A7D/ipm/ZpxXFg014k6CtyteotS2JTyMAkLE=;
        b=NbGFB2MjrWbSY3ERrSc6G+R6PAEpsJ217OBsxtv5OcGVbVpQ5R7eT6EsDlmZtCUE5B
         45CuajfCq5SzcGwqS5s1MjJ8dw/QuDUs/drYzSSAD7Hc6a96cZu/6hQFqXDb/4ynbOtt
         S21eQSByhYdtG7PKeboY9wD9x+wIAz1T4W0xgHW4VKdR7KQtmBwhyPMzEMfCdY5q5wud
         i2MjAdT9aauIy2sN9lC7TcO+AtJkkHq4aFzGiriLWRVSNVzBn7hC3EWt858cO7eUNoyk
         V7s9gzW9KrgP7c0MKChAPAt6sLiuC9ZjsFD24I+ETHnos9AwfO/4PdYiNQRzUyK103ps
         ryZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=E5jKWBxG;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t191si1247487ita.132.2019.05.09.03.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 03:38:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=E5jKWBxG;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=c6Ta/z7A7D/ipm/ZpxXFg014k6CtyteotS2JTyMAkLE=; b=E5jKWBxGSeiX8WbFfJfvgFavm
	K1oNFHBelwvt7SaaVN7KVbzemOZI4o/Ac989NId6cbca+Uc32vIEYJKEy0JGTCMWJT85WAZMTAEWy
	9Hs3XU51yMeQSpp7t4YSVeKjwBDRXOatZnk7NAW0g94SWyaHkKdN7ms8DxjZgwUapXGmT7z/kpfaY
	LaBGwaWsv2NttVebEM01hllp+vwBjND8i3R0l1+E/rGpXhiTVGp0U67eyXuVb/P3+UNsrvwE7ExaS
	xcoMFzrjVrNhk2tf+GXZMzBygQk6yYvPY/Pf68SKus+wHFk/1IS50Emq2mJU1FjapJh6hNlQlcFrY
	56BKYF12g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOgRL-0002O4-9K; Thu, 09 May 2019 10:38:15 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id AC71A2029F87C; Thu,  9 May 2019 12:38:13 +0200 (CEST)
Date: Thu, 9 May 2019 12:38:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, jstancek@redhat.com,
	akpm@linux-foundation.org, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com,
	namit@vmware.com, minchan@kernel.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190509103813.GP2589@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509083726.GA2209@brain-police>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 09:37:26AM +0100, Will Deacon wrote:
> Hi all, [+Peter]

Right, mm/mmu_gather.c has a MAINTAINERS entry; use it.

Also added Nadav and Minchan who've poked at this issue before. And Mel,
because he loves these things :-)

> Apologies for the delay; I'm attending a conference this week so it's tricky
> to keep up with email.
> 
> On Wed, May 08, 2019 at 05:34:49AM +0800, Yang Shi wrote:
> > A few new fields were added to mmu_gather to make TLB flush smarter for
> > huge page by telling what level of page table is changed.
> > 
> > __tlb_reset_range() is used to reset all these page table state to
> > unchanged, which is called by TLB flush for parallel mapping changes for
> > the same range under non-exclusive lock (i.e. read mmap_sem).  Before
> > commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
> > munmap"), MADV_DONTNEED is the only one who may do page zapping in
> > parallel and it doesn't remove page tables.  But, the forementioned commit
> > may do munmap() under read mmap_sem and free page tables.  This causes a
> > bug [1] reported by Jan Stancek since __tlb_reset_range() may pass the

Please don't _EVER_ refer to external sources to describe the actual bug
a patch is fixing. That is the primary purpose of the Changelog.

Worse, the email you reference does _NOT_ describe the actual problem.
Nor do you.

> > wrong page table state to architecture specific TLB flush operations.
> 
> Yikes. Is it actually safe to run free_pgtables() concurrently for a given
> mm?

Yeah.. sorta.. it's been a source of 'interesting' things. This really
isn't the first issue here.

Also, change_protection_range() is 'fun' too.

> > So, removing __tlb_reset_range() sounds sane.  This may cause more TLB
> > flush for MADV_DONTNEED, but it should be not called very often, hence
> > the impact should be negligible.
> > 
> > The original proposed fix came from Jan Stancek who mainly debugged this
> > issue, I just wrapped up everything together.
> 
> I'm still paging the nested flush logic back in, but I have some comments on
> the patch below.
> 
> > [1] https://lore.kernel.org/linux-mm/342bf1fd-f1bf-ed62-1127-e911b5032274@linux.alibaba.com/T/#m7a2ab6c878d5a256560650e56189cfae4e73217f
> > 
> > Reported-by: Jan Stancek <jstancek@redhat.com>
> > Tested-by: Jan Stancek <jstancek@redhat.com>
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > Signed-off-by: Jan Stancek <jstancek@redhat.com>
> > ---
> >  mm/mmu_gather.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> > index 99740e1..9fd5272 100644
> > --- a/mm/mmu_gather.c
> > +++ b/mm/mmu_gather.c
> > @@ -249,11 +249,12 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
> >  	 * flush by batching, a thread has stable TLB entry can fail to flush
> 
> Urgh, we should rewrite this comment while we're here so that it makes sense...

Yeah, that's atrocious. We should put the actual race in there.

> >  	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> >  	 * forcefully if we detect parallel PTE batching threads.
> > +	 *
> > +	 * munmap() may change mapping under non-excluse lock and also free
> > +	 * page tables.  Do not call __tlb_reset_range() for it.
> >  	 */
> > -	if (mm_tlb_flush_nested(tlb->mm)) {
> > -		__tlb_reset_range(tlb);
> > +	if (mm_tlb_flush_nested(tlb->mm))
> >  		__tlb_adjust_range(tlb, start, end - start);
> > -	}
> 
> I don't think we can elide the call __tlb_reset_range() entirely, since I
> think we do want to clear the freed_pXX bits to ensure that we walk the
> range with the smallest mapping granule that we have. Otherwise couldn't we
> have a problem if we hit a PMD that had been cleared, but the TLB
> invalidation for the PTEs that used to be linked below it was still pending?

That's tlb->cleared_p*, and yes agreed. That is, right until some
architecture has level dependent TLBI instructions, at which point we'll
need to have them all set instead of cleared.

> Perhaps we should just set fullmm if we see that here's a concurrent
> unmapper rather than do a worst-case range invalidation. Do you have a feeling
> for often the mm_tlb_flush_nested() triggers in practice?

Quite a bit for certain workloads I imagine, that was the whole point of
doing it.

Anyway; am I correct in understanding that the actual problem is that
we've cleared freed_tables and the ARM64 tlb_flush() will then not
invalidate the cache and badness happens?

Because so far nobody has actually provided a coherent description of
the actual problem we're trying to solve. But I'm thinking something
like the below ought to do.


diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 99740e1dd273..fe768f8d612e 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -244,15 +244,20 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end)
 {
 	/*
-	 * If there are parallel threads are doing PTE changes on same range
-	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
-	 * flush by batching, a thread has stable TLB entry can fail to flush
-	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
-	 * forcefully if we detect parallel PTE batching threads.
+	 * Sensible comment goes here..
 	 */
-	if (mm_tlb_flush_nested(tlb->mm)) {
-		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
+	if (mm_tlb_flush_nested(tlb->mm) && !tlb->full_mm) {
+		/*
+		 * Since we're can't tell what we actually should have
+		 * flushed flush everything in the given range.
+		 */
+		tlb->start = start;
+		tlb->end = end;
+		tlb->freed_tables = 1;
+		tlb->cleared_ptes = 1;
+		tlb->cleared_pmds = 1;
+		tlb->cleared_puds = 1;
+		tlb->cleared_p4ds = 1;
 	}
 
 	tlb_flush_mmu(tlb);

