Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 715B06B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 13:07:07 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so54987737wib.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 10:07:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o19si19183605wjr.59.2015.06.10.10.07.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 10:07:05 -0700 (PDT)
Date: Wed, 10 Jun 2015 18:07:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150610170700.GG26425@suse.de>
References: <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
 <55771909.2020005@intel.com>
 <55775749.3090004@intel.com>
 <CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
 <20150610131354.GO19417@two.firstfloor.org>
 <CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 09:17:15AM -0700, Linus Torvalds wrote:
> On Wed, Jun 10, 2015 at 6:13 AM, Andi Kleen <andi@firstfloor.org> wrote:
> >
> > Assuming the page tables are cache-hot... And hot here does not mean
> > L3 cache, but higher. But a memory intensive workload can easily
> > violate that.
> 
> In practice, no.
> 
> You'll spend all your time on the actual real data cache misses, the
> TLB misses won't be any more noticeable.
> 
> And if your access patters are even *remoptely* cache-friendly (ie
> _not_ spending all your time just waiting for regular data cache
> misses), then a radix-tree-like page table like Intel will have much
> better locality in the page tables than in the actual data. So again,
> the TLB misses won't be your big problem.
> 
> There may be pathological cases where you just look at one word per
> page, but let's face it, we don't optimize for pathological or
> unrealistic cases.
> 

It's concerns like this that have me avoiding any micro-benchmarking approach
that tried to measure the indirect costs of refills. No matter what the
microbenchmark does, there will be other cases that render it irrelevant.

> And the thing is, you need to look at the costs. Single-page
> invalidation taking hundreds of cycles? Yeah, we definitely need to
> take the downside of trying to be clever into account.
> 
> If the invalidation was really cheap, the rules might change. As it
> is, I really don't think there is any question about this.
> 
> That's particularly true when the single-page invalidation approach
> has lots of *software* overhead too - not just the complexity, but
> even "obvious" costs feeding the list of pages to be invalidated
> across CPU's. Think about it - there are cache misses there too, and
> because we do those across CPU's those cache misses are *mandatory*.
> 
> So trying to avoid a few TLB misses by forcing mandatory cache misses
> and extra complexity, and by doing lots of 200+ cycle operations?
> Really? In what universe does that sound like a good idea?
> 
> Quite frankly, I can pretty much *guarantee* that you didn't actually
> think about any real numbers, you've just been taught that fairy-tale
> of "TLB misses are expensive". As if TLB entries were somehow sacred.
> 

Everyone has been taught that one. Papers I've read from the last two
years on TLB implementations or page reclaim management bring this up as
a supporting point for whatever they are proposing. It was partially why
I kept PFN tracking and also to put much of the cost on the reclaimer and
minimise interference on the recipient of the IPI. I still think it was
a rational concern but will assume that refills are cheaper than smart
invalidations until it can be proven otherwise.

> If somebody can show real numbers on a real workload, that's one
> thing.

The last adjustments made today  to the series are at
http://git.kernel.org/cgit/linux/kernel/git/mel/linux-balancenuma.git/log/?h=mm-vmscan-lessipi-v7r5
I'll redo it on top of 4.2-rc1 whenever that happens so gets a full round
in linux-next.  Patch 4 can be revisited if a real workload is found that
is not deliberately pathological running on a CPU that matters. The forward
port of patch 4 for testing will be trivial.

It also separated out the dynamic allocation of the structure so that it
can be excluded if deemed to be an unnecessary complication.

> So anyway, I like the patch series. I just think that the final patch
> - the one that actually saves the addreses, and limits things to
> BATCH_TLBFLUSH_SIZE, should be limited.
> 

I see your logic but if it's limited then we send more IPIs and it's all
crappy tradeoffs. If a real workload complains, it'll be far easier to
work with.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
