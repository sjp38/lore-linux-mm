Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id B50DB6B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:06:20 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so3618175qeb.25
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:06:20 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id t8si11079868qeu.56.2013.12.16.02.06.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Dec 2013 02:06:19 -0800 (PST)
Date: Mon, 16 Dec 2013 11:06:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Message-ID: <20131216100608.GU21999@twins.programming.kicks-ass.net>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <1386849309-22584-3-git-send-email-mgorman@suse.de>
 <20131212131309.GD5806@gmail.com>
 <52A9BC3A.7010602@linaro.org>
 <20131212141147.GB17059@gmail.com>
 <52AA5C92.7030207@linaro.org>
 <52AA6CB9.60302@linaro.org>
 <20131214141902.GA16438@laptop.programming.kicks-ass.net>
 <52AEB937.6050704@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AEB937.6050704@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Dec 16, 2013 at 04:26:31PM +0800, Alex Shi wrote:
> On 12/14/2013 10:19 PM, Peter Zijlstra wrote:
> > On Fri, Dec 13, 2013 at 10:11:05AM +0800, Alex Shi wrote:
> >> BTW,
> >> A bewitching idea is till attracting me.
> >> https://lkml.org/lkml/2012/5/23/148
> >> Even it was sentenced to death by HPA.
> >> https://lkml.org/lkml/2012/5/24/143
> >>
> >> That is that just flush one of thread TLB is enough for SMT/HT, seems
> >> TLB is still shared in core on Intel CPU. This benefit is unconditional,
> >> and if my memory right, Kbuild testing can improve about 1~2% in average
> >> level.
> >>
> >> So could you like to accept some ugly quirks to do this lazy TLB flush
> >> on known working CPU?
> >> Forgive me if it's stupid.
> > 
> > I think there's a further problem with that patch -- aside of it being
> > right from a hardware point of view.
> > 
> > We currently rely on the tlb flush IPI to synchronize with lockless page
> > table walkers like gup_fast().
> 
> I am sorry if I miss sth. :)
> 
> But if my understand correct, in the example of gup_fast, wait_split_huge_page
> will never goes to BUG_ON(). Since the flush TLB IPI still be sent out to clear
> each of _PAGE_SPLITTING on each CPU core. This patch just stop repeat TLB flush
> in another SMT on same core. If there only noe SMT affected, the flush still be 
> executed on it.

This has nothing what so ff'ing ever to do with huge pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
