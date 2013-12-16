Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8166B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:44:55 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id u56so4484044wes.8
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:44:54 -0800 (PST)
Received: from mail-ea0-x22b.google.com (mail-ea0-x22b.google.com [2a00:1450:4013:c01::22b])
        by mx.google.com with ESMTPS id wj1si5054545wjb.46.2013.12.16.05.44.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 05:44:54 -0800 (PST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2234245eak.2
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:44:54 -0800 (PST)
Date: Mon, 16 Dec 2013 14:44:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131216134449.GA3034@gmail.com>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131216125923.GS11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> > Whatever we did right in v3.4 we want to do in v3.13 as well - or 
> > at least understand it.
> 
> Also agreed. I started a bisection before answering this mail. It 
> would be cooler and potentially faster to figure it out from direct 
> analysis but bisection is reliable and less guesswork.

Trying to guess can potentially last a _lot_ longer than a generic, 
no-assumptions bisection ...

The symptoms could point to anything: scheduler, locking details, some 
stupid little change in a wakeup sequence somewhere, etc.

It might even be a non-deterministic effect of some timing change 
causing the workload 'just' to avoid a common point of preemption and 
not scheduling as much - and become more unfair and thus certain 
threads lasting longer to finish.

Does the benchmark execute a fixed amount of transactions per thread? 

That might artificially increase the numeric regression: with more 
threads it 'magnifies' any unfairness effects because slower threads 
will become slower, faster threads will become faster, as the thread 
count increases.

[ That in itself is somewhat artificial, because real workloads tend 
  to balance between threads dynamically and don't insist on keeping 
  the fastest threads idle near the end of a run. It does not
  invalidate the complaint about the unfairness itself, obviously. ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
