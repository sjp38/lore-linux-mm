Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE036B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:59:05 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so4566031wgh.33
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:59:05 -0800 (PST)
Received: from mail-ea0-x22a.google.com (mail-ea0-x22a.google.com [2a00:1450:4013:c01::22a])
        by mx.google.com with ESMTPS id hq3si3877897wib.38.2013.12.16.05.59.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 05:59:04 -0800 (PST)
Received: by mail-ea0-f170.google.com with SMTP id k10so2272520eaj.1
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:59:04 -0800 (PST)
Date: Mon, 16 Dec 2013 14:59:01 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Message-ID: <20131216135901.GA6171@gmail.com>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <1386849309-22584-3-git-send-email-mgorman@suse.de>
 <20131212131309.GD5806@gmail.com>
 <52A9BC3A.7010602@linaro.org>
 <20131212141147.GB17059@gmail.com>
 <52AA5C92.7030207@linaro.org>
 <52AA6CB9.60302@linaro.org>
 <20131214141902.GA16438@laptop.programming.kicks-ass.net>
 <20131214142741.GB16438@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131214142741.GB16438@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alex Shi <alex.shi@linaro.org>, Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Sat, Dec 14, 2013 at 03:19:02PM +0100, Peter Zijlstra wrote:
> > On Fri, Dec 13, 2013 at 10:11:05AM +0800, Alex Shi wrote:
> > > BTW,
> > > A bewitching idea is till attracting me.
> > > https://lkml.org/lkml/2012/5/23/148
> > > Even it was sentenced to death by HPA.
> > > https://lkml.org/lkml/2012/5/24/143
> > > 
> > > That is that just flush one of thread TLB is enough for SMT/HT, seems
> > > TLB is still shared in core on Intel CPU. This benefit is unconditional,
> > > and if my memory right, Kbuild testing can improve about 1~2% in average
> > > level.
> > > 
> > > So could you like to accept some ugly quirks to do this lazy TLB flush
> > > on known working CPU?
> > > Forgive me if it's stupid.
> > 
> > I think there's a further problem with that patch -- aside of it being
> > right from a hardware point of view.
> > 
> > We currently rely on the tlb flush IPI to synchronize with lockless page
> > table walkers like gup_fast().
> > 
> > By not sending an IPI to all CPUs you can get into trouble and crash the
> > kernel.
> > 
> > We absolutely must keep sending the IPI to all relevant CPUs, we can
> > choose not to actually do the flush on some CPUs, but we must keep
> > sending the IPI.
> 
> The alternative is switching x86 over to use HAVE_RCU_TABLE_FREE.

So if the kbuild speedup of 1-2% is true and reproducable then that 
might be worth doing.

Building the kernel is obviously a prime workload - and given that the 
kernel is active only about 10% of the time for a typical kernel 
build, a 1-2% speedup means a 10-20% speedup in kernel performance 
(which sounds a bit too good at first glance).

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
