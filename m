Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 423326B0071
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 18:35:16 -0400 (EDT)
Received: by wiga1 with SMTP id a1so30053840wig.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:35:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db10si13918174wjb.46.2015.06.09.15.35.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 15:35:15 -0700 (PDT)
Date: Tue, 9 Jun 2015 23:35:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150609223509.GX26425@suse.de>
References: <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
 <55771909.2020005@intel.com>
 <55775749.3090004@intel.com>
 <CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
 <20150609223203.GW26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150609223203.GW26425@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 09, 2015 at 11:32:03PM +0100, Mel Gorman wrote:
> On Tue, Jun 09, 2015 at 02:54:01PM -0700, Linus Torvalds wrote:
> > On Tue, Jun 9, 2015 at 2:14 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> > >
> > > The 0 cycle TLB miss was also interesting.  It goes back up to something
> > > reasonable if I put the mb()/mfence's back.
> > 
> > So I've said it before, and I'll say it again: Intel does really well
> > on TLB fills.
> > 
> > The reason is partly historical, with Win95 doing a ton of TLB
> > invalidation (I think every single GDI call ended up invalidating the
> > TLB, so under some important Windows benchmarks of the time, you
> > literally had a TLB flush every 10k instructions!).
> > 
> > But partly it is because people are wrong in thinking that TLB fills
> > have to be slow. There's a lot of complete garbage RISC machines where
> > the TLB fill took forever, because in the name of simplicity it would
> > stop the pipeline and often be done in SW.
> > 
> > The zero-cycle TLB fill is obviously a bit optimistic, but at the same
> > time it's not completely insane. TLB fills can be prefetched, and the
> > table walker can hit the cache, if you do them right. And Intel mostly
> > does.
> > 
> > So the normal full (non-global) TLB fill really is fairly cheap. It's
> > been optimized for, and the TLB gets re-filled fairly efficiently. I
> > suspect that it's really the case that doing more than just a couple
> > of single-tlb flushes is a complete waste of time: the flushing takes
> > longer than re-filling the TLB well.
> > 
> 
> I expect I'll do another revision of the series after 4.2-rc1 as it's way
> too close to 4.1's release. When that happens, I'll drop patch 4 and leave
> just the full non-global flush patch. In the event there is an architecture
> that really cares about the refill cost or we find that there is a corner
> case where the TLB refill hurts then patch 4 will be in the mail archives
> to consider for rebase and testing.
> 

To be clear I meant patch 4 from v6 of the series will be dropped. In that
series, patch 2 does a full non-global flush and patch 4 does the per-pfn
tracking with multiple single page frame flushes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
