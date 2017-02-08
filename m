Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 921A86B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:56:27 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id an2so33500360wjc.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:56:27 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i74si2649754wmh.85.2017.02.08.06.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 06:56:26 -0800 (PST)
Date: Wed, 8 Feb 2017 15:56:22 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm, page_alloc: only use per-cpu allocator for irq-safe
 requests -fix
In-Reply-To: <20170208143128.25ahymqlyspjcixu@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1702081550440.3536@nanos>
References: <20170208143128.25ahymqlyspjcixu@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

On Wed, 8 Feb 2017, Mel Gorman wrote:

> preempt_enable_no_resched() was used based on review feedback that had no
> strong objection at the time. It avoided introducing a preemption point
> where one didn't exist before which was marginal at best.

Actually local_irq_enable() _IS_ a preemption point, indirect but still:

   local_irq_disable()
   ....
--> HW interrupt is raised
   ....
   local_irq_enable()

   handle_irq()
	set_need_resched()
   ret_from_irq()
     preempt()

while with preempt_disable that looks like this:

   preempt_disable()
   ....
--> HW interrupt is raised
   handle_irq()
	set_need_resched()
   ret_from_irq()
   ....
   preempt_enable()
      preempt()

Now if you use preempt_enable_no_resched() then you miss the preemption and
depending on the actual code path you might run something which takes ages
without hitting a preemption point after that.

It's not only a problem for RT. It's also in mainline a violation of the
preemption mechanism.

Thanks,

	tglx



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
