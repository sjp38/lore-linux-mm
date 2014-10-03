Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id DB10D6B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 04:35:22 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id r5so647458qcx.7
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 01:35:22 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id j4si11139963qao.36.2014.10.03.01.35.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 01:35:21 -0700 (PDT)
Date: Fri, 3 Oct 2014 03:35:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch resend] mm: page_alloc: fix zone allocation fairness on
 UP
In-Reply-To: <CALq1K=KYYXgtK5mRvBO_+Kdxt8nHmq-cquo1Qqj=UdB+TDrueA@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1410030333080.7898@gentwo.org>
References: <20140909131540.GA10568@cmpxchg.org> <CALq1K=LFd_MWYUMGhZxu4yb-u5WcDqb=DvY4N3P+wV0WO3Zq_g@mail.gmail.com> <20140911123632.GA8296@cmpxchg.org> <CALq1K=KYYXgtK5mRvBO_+Kdxt8nHmq-cquo1Qqj=UdB+TDrueA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 11 Sep 2014, Leon Romanovsky wrote:

> >> I think the better way will be to apply Mel's patch
> >> https://lkml.org/lkml/2014/9/8/214 which fix zone_page_state shadow casting
> >> issue and convert all atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH])) to
> >> zone_page__state(zone, NR_ALLOC_BATCH). This move will unify access to
> >> vm_stat.
> >
> > It's not as simple.  The counter can go way negative and we need that
> > negative number, not 0, to calculate the reset delta.  As I said in
> > response to Mel's patch, we could make the vmstat API signed but I'm
> > not convinced that is reasonable, given the 99% majority of usecases.
> You are right, I missed that NR_ALLOC_BATCH is in use as a part of calculations
> +                       high_wmark_pages(zone) - low_wmark_pages(zone) -
> +                       atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));

How about creating __zone_page_state for zone_page_state without the 0
check? That would be much nicer and would move the stuff to a central
place. Given the nastiness of this issue there are bound to be more fixes
coming up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
