Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 92D2B6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:33:38 -0400 (EDT)
Received: by wifx6 with SMTP id x6so39372255wif.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:33:38 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id go2si8228929wib.16.2015.06.10.01.33.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 01:33:37 -0700 (PDT)
Received: by wgv5 with SMTP id 5so29952032wgv.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:33:36 -0700 (PDT)
Date: Wed, 10 Jun 2015 10:33:32 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610083332.GA25605@gmail.com>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433871118-15207-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> Linear mapped reader on a 4-node machine with 64G RAM and 48 CPUs
> 
>                                         4.1.0-rc6          4.1.0-rc6
>                                           vanilla       flushfull-v6
> Ops lru-file-mmap-read-elapsed   162.88 (  0.00%)   120.81 ( 25.83%)
> 
>            4.1.0-rc6   4.1.0-rc6
>              vanillaflushfull-v6r5
> User          568.96      614.68
> System       6085.61     4226.61
> Elapsed       164.24      122.17
> 
> This is showing that the readers completed 25.83% faster with 30% less
> system CPU time. From vmstats, it is known that the vanilla kernel was
> interrupted roughly 900K times per second during the steady phase of the
> test and the patched kernel was interrupts 180K times per second.
> 
> The impact is lower on a single socket machine.
> 
>                                         4.1.0-rc6          4.1.0-rc6
>                                           vanilla       flushfull-v6
> Ops lru-file-mmap-read-elapsed    25.43 (  0.00%)    20.59 ( 19.03%)
> 
>            4.1.0-rc6    4.1.0-rc6
>              vanilla flushfull-v6
> User           59.14        58.99
> System        109.15        77.84
> Elapsed        27.32        22.31
> 
> It's still a noticeable improvement with vmstat showing interrupts went
> from roughly 500K per second to 45K per second.

Btw., I tried to compare your previous (v5) pfn-tracking numbers with these 
full-flushing numbers, and found that the IRQ rate appears to be the same:

> > From vmstats, it is known that the vanilla kernel was interrupted roughly 900K 
> > times per second during the steady phase of the test and the patched kernel 
> > was interrupts 180K times per second.

> > It's still a noticeable improvement with vmstat showing interrupts went from 
> > roughly 500K per second to 45K per second.

... is that because the batching limit in the pfn-tracking case was high enough to 
not be noticeable in the vmstat?

In the full-flushing case (v6 without patch 4) the batching limit is 'infinite', 
we'll batch as long as possible, right?

Or have I managed to get confused somewhere ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
