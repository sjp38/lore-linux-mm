Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF566B7EEA
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 10:59:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m207-v6so22268272itg.5
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 07:59:17 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i23-v6si5350632jaf.106.2018.09.07.07.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Sep 2018 07:59:16 -0700 (PDT)
Date: Fri, 7 Sep 2018 16:58:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907145858.GK24106@hirez.programming.kicks-ass.net>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <20180907101634.GO24106@hirez.programming.kicks-ass.net>
 <20180907144422.GA11088@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907144422.GA11088@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Sep 07, 2018 at 10:44:22AM -0400, Johannes Weiner wrote:

> > This does the whole seqcount thing 6x, which is a bit of a waste.
> 
> [...]
> 
> > It's a bit cumbersome, but that's because of C.
> 
> I was actually debating exactly this with Suren before, but since this
> is a super cold path I went with readability. I was also thinking that
> restarts could happen quite regularly under heavy scheduler load, and
> so keeping the individual retry sections small could be helpful - but
> I didn't instrument this in any way.

I was hoping going over the whole thing once would reduce the time we
need to keep that line in shared mode and reduce traffic. And yes, this
path is cold, but I was thinking about reducing the interference on the
remote CPU.

Alternatively, we memcpy the whole line under the seqlock and then do
everything later.

Also, this only has a single cpu_clock() invocation.
