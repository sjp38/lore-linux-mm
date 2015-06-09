Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B00EB6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:43:35 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so16898196wiw.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:43:35 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id bb4si2920736wib.124.2015.06.09.05.43.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:43:34 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so16825295wib.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:43:33 -0700 (PDT)
Date: Tue, 9 Jun 2015 14:43:28 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150609124328.GA23066@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150609112055.GS26425@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> > Sorry, I don't buy this, at all.
> > 
> > Please measure this, the code would become a lot simpler, as I'm not convinced 
> > that we need pfn (or struct page) or even range based flushing.
> 
> The code will be simplier and the cost of reclaim will be lower and that is the 
> direct case but shows nothing about the indirect cost. The mapped reader will 
> benefit as it is not reusing the TLB entries and will look artifically very 
> good. It'll be very difficult for even experienced users to determine that a 
> slowdown during kswapd activity is due to increased TLB misses incurred by the 
> full flush.

If so then the converse is true just as much: if you were to introduce finegrained 
flushing today, you couldn't justify it because you claim it's very hard to 
measure!

Really, in such cases we should IMHO fall back to the simplest approach, and 
iterate from there.

I cited very real numbers about the direct costs of TLB flushes, and plausible 
speculation about why the indirect costs are low on the achitecture you are trying 
to modify here.

I think since it is you who wants to introduce additional complexity into the x86 
MM code the burden is on you to provide proof that the complexity of pfn (or 
struct page) tracking is worth it.

> > I.e. please first implement the simplest remote batching variant, then 
> > complicate it if the numbers warrant it. Not the other way around. It's not 
> > like the VM code needs the extra complexity!
> 
> The simplest remote batching variant is a much more drastic change from what we 
> do today and an unpredictable one. If we were to take that direction, it goes 
> against the notion of making incremental changes. Even if we ultimately ended up 
> with your proposal, it would make sense to separte it from this series by at 
> least one release for bisection purposes. That way we get;
> 
> Current:     Send one IPI per page to unmap, active TLB entries preserved
> This series: Send one IPI per BATCH_TLBFLUSH_SIZE pages to unmap, active TLB entries preserved
> Your proposal: Send one IPI, flush everything, active TLB entries must refill

Not quite, my take of it is:

  Current:      Simplest method: send one IPI per page to unmap, active TLB 
                entries preserved. Remote TLB flushing cost is so high that it 
                probably moots any secondary effects of TLB preservation.

  This series:  Send one IPI per BATCH_TLBFLUSH_SIZE pages to unmap, add complex 
                tracking of pfn's with expensive flushing, active TLB entries 
                preserved. Cost of the more complex flushing are probably
                higher than the refill cost, based on the numbers I gave.

  My proposal:  Send one IPI per BATCH_TLBFLUSH_SIZE pages to unmap that flushes 
                everything. TLB entries not preserved but this is expected to be 
                more than offset by the reduction in remote flushing costs and the 
                simplicity of the flushing scheme. It can still be complicated to 
                your proposed pfn tracking scheme, based on numbers.

Btw., have you measured the full TLB flush variant as well? If so, mind sharing 
the numbers?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
