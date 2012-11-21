Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A5FC06B00C6
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 07:09:04 -0500 (EST)
Date: Wed, 21 Nov 2012 12:08:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH, v2] mm, numa: Turn 4K pte NUMA faults into effective
 hugepage ones
Message-ID: <20121121120857.GB8218@suse.de>
References: <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <20121120152933.GA17996@gmail.com>
 <20121120160918.GA18167@gmail.com>
 <50ABB06A.9000402@redhat.com>
 <20121120165239.GA18345@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121120165239.GA18345@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Nov 20, 2012 at 05:52:39PM +0100, Ingo Molnar wrote:
> 
> * Rik van Riel <riel@redhat.com> wrote:
> 
> > Performance measurements will show us how much of an impact it 
> > makes, since I don't think we have never done apples to apples 
> > comparisons with just this thing toggled :)
> 
> I've done a couple of quick measurements to characterise it: as 
> expected this patch simply does not matter much when THP is 
> enabled - and most testers I worked with had THP enabled.
> 
> Testing with THP off hurst most NUMA workloads dearly and tells 
> very little about the real NUMA story of these workloads. If you 
> turn off THP you are living with a constant ~25% regression - 
> just check the THP and no-THP numbers I posted:
> 
>                 [ 32-warehouse SPECjbb test benchmarks ]
> 
>       mainline:                 395 k/sec
>       mainline +THP:            524 k/sec
> 
>       numa/core +patch:         512 k/sec     [ +29.6% ]
>       numa/core +patch +THP:    654 k/sec     [ +24.8% ]
> 
> The group of testers who had THP disabled was thus very low - 
> maybe only Mel alone? The testers I worked with all had THP 
> enabled.
> 
> I'd encourage everyone to report unusual 'tweaks' done before 
> tests are reported - no matter how well intended the purpose of 
> that tweak.

Jeez, it was an oversight. Do I need to send a card or something?

> There's just so many config variations we can test 
> and we obviously check the most logically and most scalably 
> configured system variants first.
> 

I managed to not break the !THP case for the most part in balancenuma
for the cases I looked at. As stated elsewhere not all machines can
support THP that care about HPC -- ppc64 is a major example.  THPs are
not always available, particularly on the node you are trying to migrate
to is fragmented. You can just fail the migration in this case of course
but unless you are willing to compact, this situation can persist for a
long time. You get to keep THP but on a remote node. If we are to ever
choose to split THP to get better placement then we must be able to cope
with the !THP case from the start. Lastly, not all workloads can use THP
if they depend heavily on large files or shared memory.

Focusing on the THP case initially will produce better figures but I worry
it will eventually kick us in the shins and be hard to back out of.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
