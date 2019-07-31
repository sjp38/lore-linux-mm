Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C21A8C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:14:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7758D206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:14:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pIS3Y8Su"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7758D206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21CE18E0003; Wed, 31 Jul 2019 02:14:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A7D68E0001; Wed, 31 Jul 2019 02:14:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0473D8E0003; Wed, 31 Jul 2019 02:14:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C05A18E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:14:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t2so36873988plo.10
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 23:14:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iqFMksg+GEFnhHcmM4K8TjXa4SGBpwoJKaNawCff3BE=;
        b=av3MRrB0Saq2+sl80h1dqkqu2nSleW6XtPtpHE6f+Cz8rbQZqZZut9N5LjPvJELrn3
         aXO+Zr1/mIB4wG3FYNoDmn/bUuUUpLwRhIGvFQCcIZVeZG84KKQIgGAaVQeYs2xzCd9u
         1Oar4T1+tMZVpCjBYQc5B6aG5tFieRBYMb5XKnwds0z2is/0oNmBTmF03iXPtcLUdrO7
         qpU/zSAKaYoi1ff8OM2KkxtguBcB59yTEjRiip1CJC9HLSXndgumfipthrdUQqAYggcQ
         lp8JqPogtJNLBg26j6SL0dlXN/sOOaP/ceSz35tHXWKIKITwOZk3LdFd7DdFvJ/tcfjj
         Wbow==
X-Gm-Message-State: APjAAAXwQlcwq8FPlmdRrsyskk2UXF+3c8avEmMjLwGjjMRNnotEilxH
	eDA+Pen2MYXrFrjDVmFItcTo2InH2KHJ3Bjt2D0GWTaFDF+6sYJOsAN/oFjFdbvVVJHrQk3hMvf
	sjNuAKB4pjzasj+GvpfFHb26P2Sjg5eiM5+SvQUAYW0ZJxn82DBbYIwD/a9F0Iy4=
X-Received: by 2002:a63:e901:: with SMTP id i1mr95151459pgh.451.1564553687370;
        Tue, 30 Jul 2019 23:14:47 -0700 (PDT)
X-Received: by 2002:a63:e901:: with SMTP id i1mr95151415pgh.451.1564553686498;
        Tue, 30 Jul 2019 23:14:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564553686; cv=none;
        d=google.com; s=arc-20160816;
        b=kgqFtoJwEs3Pd8+wG4871bSaSV3QmxZTlJB+SZrhD9VI7LY9TEOOjEuVeIFVCO93Ue
         a0Xrn2Fkc28kswRYjhFc5xvocEQnU4ci8p84gZYoAoINZLf8f1IuK6CsO2yezWBjg3wm
         OozrV0c56umOVqSX09Swxi2taZKjmnzZEYrW8Bh0ucG8fB2xFQnP051aXlmpN10yDfV3
         M8BwjIqFFcel1WSK2zWmgZZrsd+oE2MMoHx1vkez9n6Zp/bXLigiTsggfDF/9M6UlwCU
         i/kxYCTtZIA9eZItNErNeJ6epZKEdyYerT4jV+Y3+7RdupKurKFnBz+HGj74momJiU9P
         rUYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=iqFMksg+GEFnhHcmM4K8TjXa4SGBpwoJKaNawCff3BE=;
        b=uO63ny/A4c9tv34EOfh1vu61gVlhNDoebwK9NYvyQWNuocg5Aa4wruyDehiUx1/86a
         w1E+WtANcYAcuLfBkMz1Cc3Jp//ew89rW+NlrQQu1qo0MCLAxFw8VFazYDe9fLv+j08n
         C4MBHoAbgjWxD+RHw5aj4IJvjRUqlKYDGzdKDUJpX33sLT+nwf1c1ANjy3kLhWpNSxh2
         +Vg3IckqubGD0uokIa95S6TuAO/3Xt/5TstoiZyQOOm/CgD5xp85C6Z/9i/14U3OMfK/
         vMA+ELeI4Uh5/t/0xGY3IavhCLQj/YgdKnRzC/V5wo5We176LEWN8IaMR8W4vmZU1idq
         wd/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pIS3Y8Su;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bg9sor80692322plb.73.2019.07.30.23.14.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 23:14:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pIS3Y8Su;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iqFMksg+GEFnhHcmM4K8TjXa4SGBpwoJKaNawCff3BE=;
        b=pIS3Y8SuH3hxHZYjEY+VPhyyjAyo+FGqtGWW4NAuNJfqiqSygcvaq1zogoZMZ22TDV
         e5/jFcKAqDx4QgkhPV/1LWdmUTVf2YDlRCVHSue09MBhLKtMMGWoxspklADGUYxUARbJ
         46c8B/8+nQT0JQ7zxbD0kr8Vock5IGm9m0UJ+m6oCCl3Q06B+1fGK6bCiDdMJdQQucoY
         0v8ReN13g5if32JdgIjkTLHW7JfgkznVnENKTdGMGreyrD3BpaVGsIQIjIoZXNLxzCzo
         0R7aNcYuW3KqKa7dbBwWu3xZthNfGW+NlU04sAXWE4Ds4uO6RSpJ1mgPAfQfkoGmC6qg
         gL/w==
X-Google-Smtp-Source: APXvYqx8tKIyBtlv4dSHH0G37FgBEdYFHX+HUdL62kS7gU/eDjdnm7vXcKWh9rO0yaniakChi9hDcQ==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr122711848plb.30.1564553685998;
        Tue, 30 Jul 2019 23:14:45 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id 22sm76624580pfu.179.2019.07.30.23.14.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 23:14:44 -0700 (PDT)
Date: Wed, 31 Jul 2019 15:14:40 +0900
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190731061440.GC155569@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190730124207.da70f92f19dc021bf052abd0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730124207.da70f92f19dc021bf052abd0@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 12:42:07PM -0700, Andrew Morton wrote:
> On Mon, 29 Jul 2019 17:20:52 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > > > @@ -1022,7 +1023,16 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> > > >  	flush_tlb_batched_pending(mm);
> > > >  	arch_enter_lazy_mmu_mode();
> > > >  	do {
> > > > -		pte_t ptent = *pte;
> > > > +		pte_t ptent;
> > > > +
> > > > +		if (progress >= 32) {
> > > > +			progress = 0;
> > > > +			if (need_resched())
> > > > +				break;
> > > > +		}
> > > > +		progress += 8;
> > > 
> > > Why 8?
> > 
> > Just copied from copy_pte_range.
> 
> copy_pte_range() does
> 
> 		if (pte_none(*src_pte)) {
> 			progress++;
> 			continue;
> 		}
> 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
> 							vma, addr, rss);
> 		if (entry.val)
> 			break;
> 		progress += 8;
> 
> which appears to be an attempt to balance the cost of copy_one_pte()
> against the cost of not calling copy_one_pte().
> 

Indeed.

> Your code doesn't do this balancing and hence can be simpler.

Based on the balancing code of copy_one_pte, it seems we should balance
it with cost of mark_page_accessed against the cost of not calling
mark_page_accessed. IOW, add up 8 only when mark_page_accessed is called.

However, every mark_page_accessed is not heavy since it uses pagevec
and caller couldn't know whether the target page will be activated or
just have PG_referenced which is cheap. Thus, I agree, do not make it
complicated.

> 
> It all seems a bit overdesigned.  need_resched() is cheap.  It's
> possibly a mistake to check need_resched() on *every* loop because some
> crazy scheduling load might livelock us.  But surely it would be enough
> to do something like
> 
> 	if (progress++ && need_resched()) {
> 		<reschedule>
> 		progress = 0;
> 	}
> 
> and leave it at that?

Seems like this?

From bb1d7aaf520e98a6f9d988c25121602c28e12e67 Mon Sep 17 00:00:00 2001
From: Minchan Kim <minchan@kernel.org>
Date: Mon, 29 Jul 2019 15:28:48 +0900
Subject: [PATCH] mm: release the spinlock on zap_pte_range

In our testing(carmera recording), Miguel and Wei found unmap_page_range
takes above 6ms with preemption disabled easily. When I see that, the
reason is it holds page table spinlock during entire 512 page operation
in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
run in the time because it could make frame drop or glitch audio problem.

I had a time to benchmark it via adding some trace_printk hooks between
pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
device is 2018 premium mobile device.

I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
task runs on little core even though it doesn't have any IPI and LRU
lock contention. It's already too heavy.

If I remove activate_page, 35-40% overhead of zap_pte_range is gone
so most of overhead(about 0.7ms) comes from activate_page via
mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
accumulate up to several ms.

Thus, this patch adds preemption point for once every 32 times in the
loop.

Reported-by: Miguel de Dios <migueldedios@google.com>
Reported-by: Wei Wang <wvw@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memory.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 2e796372927fd..8bfcef09da674 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1007,6 +1007,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct zap_details *details)
 {
 	struct mm_struct *mm = tlb->mm;
+	int progress = 0;
 	int force_flush = 0;
 	int rss[NR_MM_COUNTERS];
 	spinlock_t *ptl;
@@ -1022,7 +1023,15 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	flush_tlb_batched_pending(mm);
 	arch_enter_lazy_mmu_mode();
 	do {
-		pte_t ptent = *pte;
+		pte_t ptent;
+
+		if (progress++ >= 32) {
+			progress = 0;
+			if (need_resched())
+				break;
+		}
+
+		ptent = *pte;
 		if (pte_none(ptent))
 			continue;
 
@@ -1123,8 +1132,11 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	if (force_flush) {
 		force_flush = 0;
 		tlb_flush_mmu(tlb);
-		if (addr != end)
-			goto again;
+	}
+
+	if (addr != end) {
+		progress = 0;
+		goto again;
 	}
 
 	return addr;
-- 
2.22.0.709.g102302147b-goog

