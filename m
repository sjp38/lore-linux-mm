Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 64B0B6B0071
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:59:57 -0400 (EDT)
Received: by wifx6 with SMTP id x6so40074461wif.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:59:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uc10si16579428wjc.54.2015.06.10.01.59.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 01:59:55 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:59:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610085950.GB26425@suse.de>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
 <20150610083332.GA25605@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150610083332.GA25605@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 10, 2015 at 10:33:32AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > Linear mapped reader on a 4-node machine with 64G RAM and 48 CPUs
> > 
> >                                         4.1.0-rc6          4.1.0-rc6
> >                                           vanilla       flushfull-v6
> > Ops lru-file-mmap-read-elapsed   162.88 (  0.00%)   120.81 ( 25.83%)
> > 
> >            4.1.0-rc6   4.1.0-rc6
> >              vanillaflushfull-v6r5
> > User          568.96      614.68
> > System       6085.61     4226.61
> > Elapsed       164.24      122.17
> > 
> > This is showing that the readers completed 25.83% faster with 30% less
> > system CPU time. From vmstats, it is known that the vanilla kernel was
> > interrupted roughly 900K times per second during the steady phase of the
> > test and the patched kernel was interrupts 180K times per second.
> > 
> > The impact is lower on a single socket machine.
> > 
> >                                         4.1.0-rc6          4.1.0-rc6
> >                                           vanilla       flushfull-v6
> > Ops lru-file-mmap-read-elapsed    25.43 (  0.00%)    20.59 ( 19.03%)
> > 
> >            4.1.0-rc6    4.1.0-rc6
> >              vanilla flushfull-v6
> > User           59.14        58.99
> > System        109.15        77.84
> > Elapsed        27.32        22.31
> > 
> > It's still a noticeable improvement with vmstat showing interrupts went
> > from roughly 500K per second to 45K per second.
> 
> Btw., I tried to compare your previous (v5) pfn-tracking numbers with these 
> full-flushing numbers, and found that the IRQ rate appears to be the same:
> 

That's expected because the number of IPIs sent is the same. What
changes is the tracking of the PFNs and then the work within the IPI
itself.

> > > From vmstats, it is known that the vanilla kernel was interrupted roughly 900K 
> > > times per second during the steady phase of the test and the patched kernel 
> > > was interrupts 180K times per second.
> 
> > > It's still a noticeable improvement with vmstat showing interrupts went from 
> > > roughly 500K per second to 45K per second.
> 
> ... is that because the batching limit in the pfn-tracking case was high enough to 
> not be noticeable in the vmstat?
> 

It's just the case that there are fewer cores and less activity in the
machine overall.

> In the full-flushing case (v6 without patch 4) the batching limit is 'infinite', 
> we'll batch as long as possible, right?
> 

No because we must flush before pages are freed so the maximum batching
is related to SWAP_CLUSTER_MAX. If we free a page before the flush then
in theory the page can be reallocated and a stale TLB entry can allow
access to unrelated data. It would be almost impossible to trigger
corruption this way but it's a concern.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
