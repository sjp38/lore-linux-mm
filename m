Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8136B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:29:11 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so14579750wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:29:10 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id jo10si13765754wjb.197.2015.08.21.02.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 02:29:09 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so11065465wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:29:09 -0700 (PDT)
Date: Fri, 21 Aug 2015 11:29:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
Message-ID: <20150821092907.GH23723@dhcp22.suse.cz>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
 <20150820131842.GH20110@dhcp22.suse.cz>
 <20150820134240.GC12432@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820134240.GC12432@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-08-15 14:42:40, Mel Gorman wrote:
> On Thu, Aug 20, 2015 at 03:18:43PM +0200, Michal Hocko wrote:
> > On Wed 12-08-15 11:45:26, Mel Gorman wrote:
> > [...]
> > > 4-node machine stutter
> > > 4-node machine stutter
> > >                              4.2.0-rc1             4.2.0-rc1
> > >                                vanilla           nozlc-v1r20
> > > Min         mmap     53.9902 (  0.00%)     49.3629 (  8.57%)
> > > 1st-qrtle   mmap     54.6776 (  0.00%)     54.1201 (  1.02%)
> > > 2nd-qrtle   mmap     54.9242 (  0.00%)     54.5961 (  0.60%)
> > > 3rd-qrtle   mmap     55.1817 (  0.00%)     54.9338 (  0.45%)
> > > Max-90%     mmap     55.3952 (  0.00%)     55.3929 (  0.00%)
> > > Max-93%     mmap     55.4766 (  0.00%)     57.5712 ( -3.78%)
> > > Max-95%     mmap     55.5522 (  0.00%)     57.8376 ( -4.11%)
> > > Max-99%     mmap     55.7938 (  0.00%)     63.6180 (-14.02%)
> > > Max         mmap   6344.0292 (  0.00%)     67.2477 ( 98.94%)
> > > Mean        mmap     57.3732 (  0.00%)     54.5680 (  4.89%)
> > 
> > Do you have data for other leads? Because the reclaim counters look
> > quite discouraging to be honest.
> > 
> 
> None of the other workloads showed changes that were worth reporting.

OK, that is a good sign. I would agree that an extreme and artificial
load shouldn't be considered as a blocker.

> > >                                  4.1.0       4.1.0
> > >                                vanilla  nozlc-v1r4
> > > Swap Ins                           838         502
> > > Swap Outs                      1149395     2622895
> > 
> > Twice as much swapouts is a lot.
> > 
> > > DMA32 allocs                  17839113    15863747
> > > Normal allocs                129045707   137847920
> > > Direct pages scanned           4070089    29046893
> > 
> > 7x more scanns by direct reclaim also sounds bad.
> > 
> 
> With this benchmark, the results for stutter will be highly variable as
> it's hammering the system. The intent of the test was to measure stalls at
> a time when desktop interactivity went to hell during IO and could stall
> for several minutes. Due to it nature, there is intense reclaim *and*
> compaction activity going on and there is no point drawing conclusions
> from the reclaim stats that are inherently good or bad.
> 
> There will be differences in direct reclaim figures because instead of
> looping in the page allocator waiting for zlc to clear, it'll enter direct
> reclaim.

OK, I haven't considered this. kswapd might be stuck for quite some time
but all of them being stuck shouldn't be that likely. But still, this is
not a desirable behavior.

> In effect, the zlc causes processes to busy loop while kswapd
> does the work. If it turns out that this is the correct behaviour then
> we should do that explicitly, not rely on the broken zlc behaviour for
> the same reason we no longer rely on sprinkling congestion_wait() all
> over the place.

Fair point. I do agree that this should be done outside of
get_page_from_freelist. I am still surprised by the considerable
increase of swapouts but that should be handled separately if we see
that in the real world loads.

That being said
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
