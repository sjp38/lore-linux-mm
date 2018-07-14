Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 882976B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 04:48:21 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v7-v6so6203668wrn.17
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:48:21 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l8-v6si22261564wrv.161.2018.07.14.01.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Jul 2018 01:48:20 -0700 (PDT)
Date: Sat, 14 Jul 2018 10:48:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180714084801.GB4920@worktop.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180713092153.GU2494@hirez.programming.kicks-ass.net>
 <20180713161756.GA21168@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180713161756.GA21168@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


Hi Johannes,

A few quick comments on first reading; I'll do a second and more
thorough reading on Monday.

On Fri, Jul 13, 2018 at 12:17:56PM -0400, Johannes Weiner wrote:
> First off, what I want to do can indeed be done without a strong link
> of a sleeping task to a CPU. We don't rely on it, and it's something I
> only figured out in v2. The important thing is not, as I previously
> thought, that CPUs are tracked independently from each other, but that
> we use potential execution threads as the baseline for potential that
> could be wasted by resource delays. Tracking CPUs independently just
> happens to do that implicitly, but it's not a requirement.

I don't follow, but I don't think I agree.

Consider the case of 2 CPUs and 2 blocked tasks. If they both blocked on
the same CPU, then only that CPU has lost potential. Whereas the only
thing that matters is the number of blocked tasks and the number of idle
CPUs.

Those two tasks can fill the two idle CPUs. Tracking per CPU just
utterly confuses the matter.
