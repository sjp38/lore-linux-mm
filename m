Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 455A26B0071
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:19:20 -0400 (EDT)
Received: by wigg3 with SMTP id g3so41614782wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:19:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ml5si8436853wic.74.2015.06.10.02.19.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:19:18 -0700 (PDT)
Date: Wed, 10 Jun 2015 10:19:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150610091913.GC26425@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <20150609130536.GT26425@suse.de>
 <20150610085141.GA25704@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610085141.GA25704@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 10:51:41AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > I think since it is you who wants to introduce additional complexity into the 
> > > x86 MM code the burden is on you to provide proof that the complexity of pfn 
> > > (or struct page) tracking is worth it.
> > 
> > I'm taking a situation whereby IPIs are sent like crazy with interrupt storms 
> > and replacing it with something that is a lot more efficient that minimises the 
> > number of potential surprises. I'm stating that the benefit of PFN tracking is 
> > unknowable in the general case because it depends on the workload, timing and 
> > the exact CPU used so any example provided can be naked with a counter-example 
> > such as a trivial sequential reader that shows no benefit. The series as posted 
> > is approximately in line with current behaviour minimising the chances of 
> > surprise regressions from excessive TLB flush.
> > 
> > You are actively blocking a measurable improvement and forcing it to be replaced 
> > with something whose full impact is unquantifiable. Any regressions in this area 
> > due to increased TLB misses could take several kernel releases as the issue will 
> > be so difficult to detect.
> > 
> > I'm going to implement the approach you are forcing because there is an x86 part 
> > of the patch and you are the maintainer that could indefinitely NAK it. However, 
> > I'm extremely pissed about being forced to introduce these indirect 
> > unpredictable costs because I know the alternative is you dragging this out for 
> > weeks with no satisfactory conclusion in an argument that I cannot prove in the 
> > general case.
> 
> Stop this crap.
> 
> I made a really clear and unambiguous chain of arguments:
> 
>  - I'm unconvinced about the benefits of INVLPG in general, and your patches adds
>    a whole new bunch of them. I cited measurements and went out on a limb to 
>    explain my position, backed with numbers and logic. It's admittedly still a 
>    speculative position and I might be wrong, but I think it's well grounded 
>    position that you cannot just brush aside.
> 

And I explained my concerns with the use of a full flush and the difficulty
of measuring its impact in the general case. I also explained why I thought
starting with PFN tracking was an incremental approach. The argument looped
so I bailed.

>  - I suggested that you split this approach into steps that first does the simpler
>    approach that will give us at least 95% of the benefits, then the more complex
>    one on top of it. Your false claim that I'm blocking a clear improvement is
>    pure demagogy!
> 

The splitting was already done, released and I followed up saying that
I'll be dropping patch 4 in the final merge request. In the event we
find in a few kernel releases time that it was required then there will
be a realistic bug report to use as a reference.

>  - I very clearly claimed that I am more than willing to be convinced by numbers.
>    It's not _that_ hard to construct a memory trashing workload with a
>    TLB-efficient iteration that uses say 80% of the TLB cache, to measure the
>    worst-case overhead of full flushes.
> 

And what I had said was that in the general case that it will not show us any
proof. Any other workload will always behave differently and two critical
components are the exact timing versus kswapd running and the CPU used.
Even if it's demonstrated for a single workload on one CPU then we would
still be faced with the same problem and dropping patch 4.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
