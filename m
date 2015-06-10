Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 093776B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 06:15:39 -0400 (EDT)
Received: by wigg3 with SMTP id g3so43139898wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:15:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1si16913293wja.170.2015.06.10.03.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 03:15:35 -0700 (PDT)
Date: Wed, 10 Jun 2015 11:15:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150610101529.GE26425@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <20150609130536.GT26425@suse.de>
 <20150610085141.GA25704@gmail.com>
 <20150610090813.GA30359@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610090813.GA30359@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 11:08:13AM +0200, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@kernel.org> wrote:
> 
> > Stop this crap.
> > 
> > I made a really clear and unambiguous chain of arguments:
> > 
> >  - I'm unconvinced about the benefits of INVLPG in general, and your patches adds
> >    a whole new bunch of them. [...]
> 
> ... and note that your claim that 'we were doing them before, this is just an 
> equivalent transformation' is utter bullsh*t technically: what we were doing 
> previously was a hideously expensive IPI combined with an INVLPG.
> 

And replacing it with an INVLPG without excessive IPI transmission is
changing one major variable. Going straight to a full TLB flush is changing
two major variables. I thought the refill cost was high, parially based
on the estimate of 22,000 cycles in https://lkml.org/lkml/2014/7/31/825.
I've been told in these discussions that I'm wrong and the cost is not
high. As it'll always be variable, we can never be sure which is why
I do not see a value to building a complex test around it that will be
invalidated the instant we use a different CPU. When/if a workload shows
up that really cares about those refill costs then there will be a stable
test case to work from.

> The behavior was dominated by the huge overhead of the remote flushing IPI, which 
> does not prove or disprove either your or my opinion!
> 
> Preserving that old INVLPG logic without measuring its benefits _again_ would be 
> cargo cult programming.
> 
> So I think this should be measured, and I don't mind worst-case TLB trashing 
> measurements, which would be relatively straightforward to construct and the 
> results should be unambiguous.
> 
> The batching limit (which you set to 32) should then be tuned by comparing it to a 
> working full-flushing batching logic, not by comparing it to the previous single 
> IPI per single flush approach!
> 

We can decrease it easily but increasing it means we also have to change
SWAP_CLUSTER_MAX because otherwise enough pages are not unmapped for
flushes and it is a requirement that we flush before freeing the pages. That
changes another complex variable because at the very least, it alters LRU
lock hold times.

> ... and if the benefits of a complex algorithm are not measurable and if there are 
> doubts about the cost/benefit tradeoff then frankly it should not exist in the 
> kernel in the first place. It's not like the Linux TLB flushing code is too boring 
> due to overwhelming simplicity.
> 
> and yes, it's my job as a maintainer to request measurements justifying complexity 
> and your ad hominem attacks against me are disgusting - you should know better.
> 

It was not intended as an ad hominem attack and my apologies for that.
I wanted to express my frustration that a series that adjusted one variable
with known benefit will be rejected for a series that adjusts two major
variables instead with the second variable being very sensitive to
workload and CPU.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
