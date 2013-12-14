Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id C522F6B0031
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 09:19:14 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id ii20so330021qab.9
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 06:19:14 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id v3si5928314qat.133.2013.12.14.06.19.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Dec 2013 06:19:12 -0800 (PST)
Date: Sat, 14 Dec 2013 15:19:02 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Message-ID: <20131214141902.GA16438@laptop.programming.kicks-ass.net>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <1386849309-22584-3-git-send-email-mgorman@suse.de>
 <20131212131309.GD5806@gmail.com>
 <52A9BC3A.7010602@linaro.org>
 <20131212141147.GB17059@gmail.com>
 <52AA5C92.7030207@linaro.org>
 <52AA6CB9.60302@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AA6CB9.60302@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>

On Fri, Dec 13, 2013 at 10:11:05AM +0800, Alex Shi wrote:
> BTW,
> A bewitching idea is till attracting me.
> https://lkml.org/lkml/2012/5/23/148
> Even it was sentenced to death by HPA.
> https://lkml.org/lkml/2012/5/24/143
> 
> That is that just flush one of thread TLB is enough for SMT/HT, seems
> TLB is still shared in core on Intel CPU. This benefit is unconditional,
> and if my memory right, Kbuild testing can improve about 1~2% in average
> level.
> 
> So could you like to accept some ugly quirks to do this lazy TLB flush
> on known working CPU?
> Forgive me if it's stupid.

I think there's a further problem with that patch -- aside of it being
right from a hardware point of view.

We currently rely on the tlb flush IPI to synchronize with lockless page
table walkers like gup_fast().

By not sending an IPI to all CPUs you can get into trouble and crash the
kernel.

We absolutely must keep sending the IPI to all relevant CPUs, we can
choose not to actually do the flush on some CPUs, but we must keep
sending the IPI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
