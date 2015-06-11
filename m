Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A04E76B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 11:25:28 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so77285174wib.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:25:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba7si1829246wjb.155.2015.06.11.08.25.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 08:25:26 -0700 (PDT)
Date: Thu, 11 Jun 2015 16:25:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150611152520.GI26425@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
 <20150610083332.GA25605@gmail.com>
 <20150610085950.GB26425@suse.de>
 <20150611150250.GA14086@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150611150250.GA14086@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 11, 2015 at 05:02:51PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > In the full-flushing case (v6 without patch 4) the batching limit is 
> > > 'infinite', we'll batch as long as possible, right?
> > 
> > No because we must flush before pages are freed so the maximum batching is 
> > related to SWAP_CLUSTER_MAX. If we free a page before the flush then in theory 
> > the page can be reallocated and a stale TLB entry can allow access to unrelated 
> > data. It would be almost impossible to trigger corruption this way but it's a 
> > concern.
> 
> Well, could we say double SWAP_CLUSTER_MAX to further reduce the IPI rate?
> 

We could but it's a suprisingly subtle change. The impacts I can think
of are;

1. LRU lock hold times increase slightly because more pages are being
   isolated
2. There are slight timing changes due to more pages having to be
   processed before they are freed. There is a slight risk that more
   pages than are necessary get reclaimed but I doubt it'll be
   measurable
3. There is a risk that too_many_isolated checks will be easier to
   trigger resulting in a HZ/10 stall
4. The rotation rate of active->inactive is slightly faster but there
   should be fewer rotations before the lists get balanced so it
   shouldn't matter.
5. More pages are reclaimed in a single pass if zone_reclaim_mode is
   active but that thing sucks hard when it's enabled no matter what
6. More pages are isolated for compaction so page hold times there
   are longer while they are being copied

There might be others. To be honest, I'm struggling to think of any serious
problems such a change would cause. The biggest risk is issue 3 but I expect
that hitting that requires that the system is already getting badly hammered.
The main downside is that it affects all page reclaim activity, not just
the mapped pages which are triggering the IPIs. I'll add a patch to the
series that alters SWAP_CLUSTER_MAX with the intent to further reduce
IPIs and see what falls out and see if any other VM person complains.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
