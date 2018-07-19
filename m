Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6CB6B000D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:18:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132-v6so3613186pga.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:18:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d9-v6si5344738pll.255.2018.07.19.06.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Jul 2018 06:18:43 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:18:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180719131836.GG2476@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
 <20180719092614.GY2512@hirez.programming.kicks-ass.net>
 <20180719125038.GB13799@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719125038.GB13799@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Arnaldo Carvalho de Melo <acme@kernel.org>

On Thu, Jul 19, 2018 at 08:50:38AM -0400, Johannes Weiner wrote:
> On Thu, Jul 19, 2018 at 11:26:14AM +0200, Peter Zijlstra wrote:
> > On Wed, Jul 18, 2018 at 02:03:18PM +0200, Peter Zijlstra wrote:
> > 
> > > Leaving us just 5 bytes short of needing a single cacheline :/
> > > 
> > > struct ponies {
> > >         unsigned int               tasks[3];                                             /*     0    12 */
> > >         unsigned int               cpu_state:2;                                          /*    12:30  4 */
> > >         unsigned int               io_state:2;                                           /*    12:28  4 */
> > >         unsigned int               mem_state:2;                                          /*    12:26  4 */
> > > 
> > >         /* XXX 26 bits hole, try to pack */
> > > 
> > >         /* typedef u64 */ long long unsigned int     last_time;                          /*    16     8 */
> > >         /* typedef u64 */ long long unsigned int     some_time[3];                       /*    24    24 */
> > >         /* typedef u64 */ long long unsigned int     full_time[2];                       /*    48    16 */
> > >         /* --- cacheline 1 boundary (64 bytes) --- */
> > >         /* typedef u64 */ long long unsigned int     nonidle_time;                       /*    64     8 */
> > > 
> > >         /* size: 72, cachelines: 2, members: 8 */
> > >         /* bit holes: 1, sum bit holes: 26 bits */
> > >         /* last cacheline: 8 bytes */
> > > };
> > > 
> > > ARGGH!
> > 
> > It _might_ be possible to use curr->se.exec_start for last_time if you
> > very carefully audit and place the hooks. I've not gone through it in
> > detail, but it might just work.
> 
> Hnngg, and chop off an entire cacheline...

Yes.. a worthy goal :-)

> But don't we flush that delta out and update the timestamp on every
> tick?

Indeed.

> entity_tick() does update_curr(). That might be too expensive :(

Well, since you already do all this accounting on every enqueue/dequeue,
this can run many thousands of times per tick already, so once per tick
doesn't sound bad.

However, I just realized this might not in fact work, because
curr->se.exec_start is per task, and you really want something per-cpu
for this.

Bah, if only perf had a useful tool to report on data layout instead of
this c2c crap.. :-( The thinking being that we could maybe find a
usage-hole (a data member that is not in fact used) near something we
already touch for writing. 
