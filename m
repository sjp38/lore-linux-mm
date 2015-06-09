Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0966B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 06:32:38 -0400 (EDT)
Received: by wifx6 with SMTP id x6so11654236wif.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 03:32:37 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id es2si2429473wib.12.2015.06.09.03.32.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 03:32:36 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so9592462wgb.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 03:32:35 -0700 (PDT)
Date: Tue, 9 Jun 2015 12:32:31 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150609103231.GA11026@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150609084739.GQ26425@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> > So have you explored the possibility to significantly simplify your patch-set 
> > by only deferring the flushing, and doing a simple TLB flush on the remote 
> > CPU?
> 
> Yes. At one point I looked at range flushing but it is not a good idea.

My suggestion wasn't range-flushing, but a simple all-or-nothing batched flush of 
user-space TLBs.

> The ranges that reach the end of the LRU are too large to be useful except in 
> the ideal case of a workload that sequentially accesses memory. Flushing the 
> full TLB has an unpredictable cost. [...]

Why would it have unpredictable cost? We flush the TLB on every process context 
switch. Yes, it's somewhat workload dependent, but the performance profile is so 
different anyway with batching that it has to be re-measured anyway.

> With a full flush we clear entries we know were recently accessed and may have 
> to be looked up again and we do this every 32 mapped pages that are reclaimed. 
> In the ideal case of a sequential mapped reader it would not matter as the 
> entries are not needed so we would not see the cost at all. Other workloads will 
> have to do a refill that was not necessary before this series. The cost of the 
> refill will depend on the CPU and whether the lookup information is still in the 
> CPU cache or not. That means measuring the full impact of your proposal is 
> impossible as it depends heavily on the workload, the timing of its interaction 
> with kswapd in particular, the state of the CPU cache and the cost of refills 
> for the CPU.
>
> I agree with you in that it would be a simplier series and the actual flush 
> would probably be faster but the downsides are too unpredictable for a series 
> that primarily is about reducing the number of IPIs.

Sorry, I don't buy this, at all.

Please measure this, the code would become a lot simpler, as I'm not convinced 
that we need pfn (or struct page) or even range based flushing.

I.e. please first implement the simplest remote batching variant, then complicate 
it if the numbers warrant it. Not the other way around. It's not like the VM code 
needs the extra complexity!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
