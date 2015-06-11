Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E14826B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 11:26:06 -0400 (EDT)
Received: by wgme6 with SMTP id e6so7288115wgm.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:26:06 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id el1si2479882wib.120.2015.06.11.08.26.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 08:26:05 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so12384799wib.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:26:04 -0700 (PDT)
Date: Thu, 11 Jun 2015 17:26:00 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150611152559.GA15509@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <20150609130536.GT26425@suse.de>
 <20150610085141.GA25704@gmail.com>
 <20150610090813.GA30359@gmail.com>
 <20150610101529.GE26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610101529.GE26425@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> > > I made a really clear and unambiguous chain of arguments:
> > > 
> > >  - I'm unconvinced about the benefits of INVLPG in general, and your patches adds
> > >    a whole new bunch of them. [...]
> > 
> > ... and note that your claim that 'we were doing them before, this is just an 
> > equivalent transformation' is utter bullsh*t technically: what we were doing 
> > previously was a hideously expensive IPI combined with an INVLPG.
> 
> And replacing it with an INVLPG without excessive IPI transmission is changing 
> one major variable. Going straight to a full TLB flush is changing two major 
> variables. [...]

But this argument employs the fallacy that the transition to 'batching with PFN 
tracking' is not a major variable in itself. In reality it is a major variable: it 
adds extra complexity, such as the cross CPU data flow (the pfn tracking), and it 
also changes the distribution of the flushes and related caching patterns.

> > [...]
> > 
> > The batching limit (which you set to 32) should then be tuned by comparing it 
> > to a working full-flushing batching logic, not by comparing it to the previous 
> > single IPI per single flush approach!
> 
> We can decrease it easily but increasing it means we also have to change 
> SWAP_CLUSTER_MAX because otherwise enough pages are not unmapped for flushes and 
> it is a requirement that we flush before freeing the pages. That changes another 
> complex variable because at the very least, it alters LRU lock hold times.

('should then be' implied 'as a separate patch/series', obviously.)

I.e. all I wanted to observe is that I think the series did not explore the 
performance impact of the batching limit, because it was too focused on the INVLPG 
approach which has an internal API limit of 33.

Now that the TLB flushing side is essentially limit-less, a future enhancement 
would be to further increase batching.

My suspicion is that say doubling SWAP_CLUSTER_MAX would possibly further reduce 
the IPI rate, at a negligible cost.

But this observation does not impact the current series in any case.

> > ... and if the benefits of a complex algorithm are not measurable and if there 
> > are doubts about the cost/benefit tradeoff then frankly it should not exist in 
> > the kernel in the first place. It's not like the Linux TLB flushing code is 
> > too boring due to overwhelming simplicity.
> > 
> > and yes, it's my job as a maintainer to request measurements justifying 
> > complexity and your ad hominem attacks against me are disgusting - you should 
> > know better.
> 
> It was not intended as an ad hominem attack and my apologies for that. I wanted 
> to express my frustration that a series that adjusted one variable with known 
> benefit will be rejected for a series that adjusts two major variables instead 
> with the second variable being very sensitive to workload and CPU.

... but that's not what it did: it adjusted multiple complex variables already, 
with a questionable rationale for more complexity.

And my argument was and continues to be: start with the simplest variant and 
iterate from there. Which you seem to have adapted in your latest series, so my 
concerns are addressed:

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
