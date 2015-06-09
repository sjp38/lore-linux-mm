Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 188EE6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 17:14:54 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so22394211pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 14:14:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bt1si10427476pbb.171.2015.06.09.14.14.52
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 14:14:53 -0700 (PDT)
Message-ID: <55775749.3090004@intel.com>
Date: Tue, 09 Jun 2015 14:14:49 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de> <20150608174551.GA27558@gmail.com> <20150609084739.GQ26425@suse.de> <20150609103231.GA11026@gmail.com> <20150609112055.GS26425@suse.de> <20150609124328.GA23066@gmail.com> <5577078B.2000503@intel.com> <55771909.2020005@intel.com>
In-Reply-To: <55771909.2020005@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

I did some of what I talked about earlier in the thread.

I think the sfence (via mb()) is potentially unfair since it removes
some of the CPU's ability to optimize things.  For this kind of test,
any ability that the CPU has to smear the overhead around is a bonus in
practice and should be taken in to account for these tests.

Here's the horribly hacked-together patch so you can see precisely
what's going on:

	https://www.sr71.net/~dave/intel/measure-tlb-stuff.patch

Here's a Haswell Xeon:

> [    0.222090] x86/fpu:########  MM instructions:            ############################
> [    0.222168] x86/fpu: Cost of: __flush_tlb()               fn            :   124 cycles avg:   125
> [    0.222623] x86/fpu: Cost of: __flush_tlb_global()        fn            :   960 cycles avg:   968
> [    0.222744] x86/fpu: Cost of: __flush_tlb_single()        fn            :   216 cycles avg:   216
> [    0.222864] x86/fpu: Cost of: __flush_tlb_single() vmal   fn            :   216 cycles avg:   219
> [    0.222987] x86/fpu: Cost of: __flush_tlb_one() OLD       fn            :   216 cycles avg:   216
> [    0.223139] x86/fpu: Cost of: __flush_tlb_range()         fn            :   284 cycles avg:   287
> [    0.223272] x86/fpu: Cost of: tlb miss                    fn            :     0 cycles avg:     0

And a Westmere Xeon:

> [    1.057770] x86/fpu:########  MM instructions:            ############################
> [    1.065876] x86/fpu: Cost of: __flush_tlb()               fn            :   108 cycles avg:   109
> [    1.075188] x86/fpu: Cost of: __flush_tlb_global()        fn            :   828 cycles avg:   829
> [    1.084162] x86/fpu: Cost of: __flush_tlb_single()        fn            :   232 cycles avg:   237
> [    1.093175] x86/fpu: Cost of: __flush_tlb_single() vmal   fn            :   240 cycles avg:   240
> [    1.102214] x86/fpu: Cost of: __flush_tlb_one() OLD       fn            :   284 cycles avg:   286
> [    1.111299] x86/fpu: Cost of: __flush_tlb_range()         fn            :   472 cycles avg:   478
> [    1.120281] x86/fpu: Cost of: tlb miss                    fn            :     0 cycles avg:     0

I was rather surprised how close the three __flush_tlb_single/one()
variants were on Haswell.  I've looked at a few other CPUs and this was
the only one that acted like this.

The 0 cycle TLB miss was also interesting.  It goes back up to something
reasonable if I put the mb()/mfence's back.

I don't think this kind of thing is a realistic test unless we put
mfence's around all of our TLB flushes in practice. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
