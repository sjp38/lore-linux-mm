Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2A96B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 09:05:44 -0400 (EDT)
Received: by wgv5 with SMTP id 5so12928875wgv.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 06:05:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hr12si3035567wib.98.2015.06.09.06.05.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 06:05:42 -0700 (PDT)
Date: Tue, 9 Jun 2015 14:05:36 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150609130536.GT26425@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150609124328.GA23066@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 09, 2015 at 02:43:28PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > Sorry, I don't buy this, at all.
> > > 
> > > Please measure this, the code would become a lot simpler, as I'm not convinced 
> > > that we need pfn (or struct page) or even range based flushing.
> > 
> > The code will be simplier and the cost of reclaim will be lower and that is the 
> > direct case but shows nothing about the indirect cost. The mapped reader will 
> > benefit as it is not reusing the TLB entries and will look artifically very 
> > good. It'll be very difficult for even experienced users to determine that a 
> > slowdown during kswapd activity is due to increased TLB misses incurred by the 
> > full flush.
> 
> If so then the converse is true just as much: if you were to introduce finegrained 
> flushing today, you couldn't justify it because you claim it's very hard to 
> measure!
> 

I'm claiming the *INDIRECT COST* is impossible to measure as part of this
series because it depends on the workload and exact CPU used. The direct
cost is measurable and can be quantified.

> Really, in such cases we should IMHO fall back to the simplest approach, and 
> iterate from there.
> 
> I cited very real numbers about the direct costs of TLB flushes, and plausible 
> speculation about why the indirect costs are low on the achitecture you are trying 
> to modify here.
> 
> I think since it is you who wants to introduce additional complexity into the x86 
> MM code the burden is on you to provide proof that the complexity of pfn (or 
> struct page) tracking is worth it.
> 

I'm taking a situation whereby IPIs are sent like crazy with interrupt
storms and replacing it with something that is a lot more efficient that
minimises the number of potential surprises. I'm stating that the benefit
of PFN tracking is unknowable in the general case because it depends on the
workload, timing and the exact CPU used so any example provided can be naked
with a counter-example such as a trivial sequential reader that shows no
benefit. The series as posted is approximately in line with current behaviour
minimising the chances of surprise regressions from excessive TLB flush.

You are actively blocking a measurable improvement and forcing it to be
replaced with something whose full impact is unquantifiable. Any regressions
in this area due to increased TLB misses could take several kernel releases
as the issue will be so difficult to detect.

I'm going to implement the approach you are forcing because there is an
x86 part of the patch and you are the maintainer that could indefinitely
NAK it. However, I'm extremely pissed about being forced to introduce
these indirect unpredictable costs because I know the alternative is you
dragging this out for weeks with no satisfactory conclusion in an argument
that I cannot prove in the general case.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
