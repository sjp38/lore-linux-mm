Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE4B8E003B
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 16:33:30 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id o22so1485044iob.13
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 13:33:30 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 79si5452592itu.38.2019.01.07.13.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 13:33:29 -0800 (PST)
Date: Mon, 7 Jan 2019 22:33:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190107213308.GE16284@hirez.programming.kicks-ass.net>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190107095217.GB2861@worktop.programming.kicks-ass.net>
 <20190107204627.GA25526@cmpxchg.org>
 <20190107212921.GK14122@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107212921.GK14122@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>

On Mon, Jan 07, 2019 at 10:29:21PM +0100, Peter Zijlstra wrote:
> On Mon, Jan 07, 2019 at 03:46:27PM -0500, Johannes Weiner wrote:
> > Hm, so the splat says this:
> > 
> > wakeups take the pi lock
> > pi lock holders take the rq lock
> > rq lock holders take the timer base lock (thanks psi)
> > timer base lock holders take the zone lock (thanks kasan)

That's not kasan, that's debugobjects, and that would be equally true
for the hrtimer usage we already have in the scheduler.

With that, I'm not entirely sure we're responsible for this splat.. I'll
try and have another look tomorrow.
