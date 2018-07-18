Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE016B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 12:31:24 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e93-v6so2863693plb.5
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:31:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id ce14-v6si3748397plb.391.2018.07.18.09.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Jul 2018 09:31:22 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:31:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718163115.GV2494@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718124627.GD2476@hirez.programming.kicks-ass.net>
 <20180718135633.GA5161@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718135633.GA5161@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jul 18, 2018 at 09:56:33AM -0400, Johannes Weiner wrote:
> On Wed, Jul 18, 2018 at 02:46:27PM +0200, Peter Zijlstra wrote:

> > I'm confused by this whole MEMSTALL thing... I thought the idea was to
> > account the time we were _blocked_ because of memstall, but you seem to
> > count the time we're _running_ with PF_MEMSTALL.
> 
> Under heavy memory pressure, a lot of active CPU time is spent
> scanning and rotating through the LRU lists, which we do want to
> capture in the pressure metric. What we really want to know is the
> time in which CPU potential goes to waste due to a lack of
> resources. That's the CPU going idle due to a memstall, but it's also
> a CPU doing *work* which only occurs due to a lack of memory. We want
> to know about both to judge how productive system and workload are.

Then maybe memstall (esp. the 'stall' part of it) is a bit of a
misnomer.

> > And esp. the wait_on_page_bit_common caller seems performance sensitive,
> > and the above function is quite expensive.
> 
> Right, but we don't call it on every invocation, only when waiting for
> the IO to read back a page that was recently deactivated and evicted:
> 
> 	if (bit_nr == PG_locked &&
> 	    !PageUptodate(page) && PageWorkingset(page)) {
> 		if (!PageSwapBacked(page))
> 			delayacct_thrashing_start();
> 		psi_memstall_enter(&pflags);
> 		thrashing = true;
> 	}
> 
> That means the page cache workingset/file active list is thrashing, in
> which case the IO itself is our biggest concern, not necessarily a few
> additional cycles before going to sleep to wait on its completion.

Ah, right. PageWorkingset() is only true if we (recently) evicted that
page before, right?
