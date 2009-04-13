Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EF52D5F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 16:05:45 -0400 (EDT)
Date: Mon, 13 Apr 2009 12:57:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [V4][PATCH 0/4]page fault retry with NOPAGE_RETRY
In-Reply-To: <604427e00904131244y68fa7e62x85d599f588776eee@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.0904131254480.26713@localhost.localdomain>
References: <604427e00904131244y68fa7e62x85d599f588776eee@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-15?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>



On Mon, 13 Apr 2009, Ying Han wrote:
> 
> Benchmarks:
> case 1. one application has a high count of threads each faulting in
> different pages of a hugefile. Benchmark indicate that this double data
> structure walking in case of major fault results in << 1% performance hit.
> 
> case 2. add another thread in the above application which in a tight loop
> of mmap()/munmap(). Here we measure loop count in the new thread while other
> threads doing the same amount of work as case one. we got << 3% performance
> hit on the Complete Time(benchmark value for case one) and 10% performance
> improvement on the mmap()/munmap() counter.
> 
> This patch helps a lot in cases we have writer which is waitting behind all
> readers, so it could execute much faster.

Hmm. I normally think of "<<" as "much smaller than", but the way you use 
it makes me wonder. In particular, "<< 3%" sounds very odd. If it's much 
smaller than 3%, I'd have expected "<< 1%" again. So it probably isn't.

> benchmarks from Wufengguang:
> Just tested the sparse-random-read-on-sparse-file case, and found the
> performance impact to be 0.4% (8.706s vs 8.744s) in the worst case.
> Kind of acceptable.

Well, have you tried the obvious optimization of _not_ doing the RETRY 
path when atomic_read(&mm->counter) == 1?

After all, if it's not a threaded app, and it doesn't have a possibility 
of concurrent mmap/fault, then why release the lock?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
