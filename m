Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A022F8E003B
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 16:29:34 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so811513pgt.11
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 13:29:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j29si10251928pgm.554.2019.01.07.13.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 13:29:33 -0800 (PST)
Date: Mon, 7 Jan 2019 22:29:21 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190107212921.GK14122@hirez.programming.kicks-ass.net>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190107095217.GB2861@worktop.programming.kicks-ass.net>
 <20190107204627.GA25526@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107204627.GA25526@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>

On Mon, Jan 07, 2019 at 03:46:27PM -0500, Johannes Weiner wrote:
> Hm, so the splat says this:
> 
> wakeups take the pi lock
> pi lock holders take the rq lock
> rq lock holders take the timer base lock (thanks psi)
> timer base lock holders take the zone lock (thanks kasan)
> problem: now a zone lock holder wakes up kswapd
> 
> right? And we can break the chain from the VM or from psi.

Yep. And since PSI it the latest addition to that chain, I figured we
ought maybe not do that. But I've not looked at a computer in 2 weeks,
so what do I know ;-)

> I cannot say one is clearly cleaner than the other, though. With kasan
> allocating from inside the basic timer code, those locks leak out from
> kernel/* and contaminate the VM locking anyway.
> 
> Do you think the rq->lock -> base->lock ordering is likely to cause
> issues elsewhere?

Not sure; we nest the hrtimer base lock under rq->lock (at the time I
fixed hrtimers to not hold it's base lock over the timer function
callback, just like regular timers already did) and that has worked
fine.

So maybe we should look at the kasan thing.. dunno.
