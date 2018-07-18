Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id D44766B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 12:44:15 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 189-v6so2581634ybz.11
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:44:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15-v6sor1018430ybp.194.2018.07.18.09.44.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 09:44:10 -0700 (PDT)
Date: Wed, 18 Jul 2018 12:46:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718164656.GA2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718124627.GD2476@hirez.programming.kicks-ass.net>
 <20180718135633.GA5161@cmpxchg.org>
 <20180718163115.GV2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718163115.GV2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jul 18, 2018 at 06:31:15PM +0200, Peter Zijlstra wrote:
> On Wed, Jul 18, 2018 at 09:56:33AM -0400, Johannes Weiner wrote:
> > On Wed, Jul 18, 2018 at 02:46:27PM +0200, Peter Zijlstra wrote:
> 
> > > I'm confused by this whole MEMSTALL thing... I thought the idea was to
> > > account the time we were _blocked_ because of memstall, but you seem to
> > > count the time we're _running_ with PF_MEMSTALL.
> > 
> > Under heavy memory pressure, a lot of active CPU time is spent
> > scanning and rotating through the LRU lists, which we do want to
> > capture in the pressure metric. What we really want to know is the
> > time in which CPU potential goes to waste due to a lack of
> > resources. That's the CPU going idle due to a memstall, but it's also
> > a CPU doing *work* which only occurs due to a lack of memory. We want
> > to know about both to judge how productive system and workload are.
> 
> Then maybe memstall (esp. the 'stall' part of it) is a bit of a
> misnomer.

I'm not tied to that name, but I can't really think of a better
one. It was called PF_MEMDELAY in the past, but "delay" also has
busy-spinning connotations in the kernel. "wait" also implies that
it's a passive state.

> > > And esp. the wait_on_page_bit_common caller seems performance sensitive,
> > > and the above function is quite expensive.
> > 
> > Right, but we don't call it on every invocation, only when waiting for
> > the IO to read back a page that was recently deactivated and evicted:
> > 
> > 	if (bit_nr == PG_locked &&
> > 	    !PageUptodate(page) && PageWorkingset(page)) {
> > 		if (!PageSwapBacked(page))
> > 			delayacct_thrashing_start();
> > 		psi_memstall_enter(&pflags);
> > 		thrashing = true;
> > 	}
> > 
> > That means the page cache workingset/file active list is thrashing, in
> > which case the IO itself is our biggest concern, not necessarily a few
> > additional cycles before going to sleep to wait on its completion.
> 
> Ah, right. PageWorkingset() is only true if we (recently) evicted that
> page before, right?

Yep, but not all of those, only the ones who were on the active list
in their previous incarnation, aka refaulting *hot* pages, aka there
is little chance this is healthy behavior.
