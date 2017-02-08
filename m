Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F43C6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 10:12:28 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so33556001wjc.4
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 07:12:28 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id z96si9469424wrb.48.2017.02.08.07.12.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 07:12:27 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id E0AFA1DC009
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 15:12:26 +0000 (UTC)
Date: Wed, 8 Feb 2017 15:12:26 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: only use per-cpu allocator for irq-safe
 requests -fix
Message-ID: <20170208151226.rctwvaqwkgjpbzzn@techsingularity.net>
References: <20170208143128.25ahymqlyspjcixu@techsingularity.net>
 <alpine.DEB.2.20.1702081550440.3536@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702081550440.3536@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>

On Wed, Feb 08, 2017 at 03:56:22PM +0100, Thomas Gleixner wrote:
> On Wed, 8 Feb 2017, Mel Gorman wrote:
> 
> > preempt_enable_no_resched() was used based on review feedback that had no
> > strong objection at the time. It avoided introducing a preemption point
> > where one didn't exist before which was marginal at best.
> 
> Actually local_irq_enable() _IS_ a preemption point, indirect but still:
> 
>    local_irq_disable()
>    ....
> --> HW interrupt is raised
>    ....
>    local_irq_enable()
> 
>    handle_irq()
> 	set_need_resched()
>    ret_from_irq()
>      preempt()
> 
> while with preempt_disable that looks like this:
> 
>    preempt_disable()
>    ....
> --> HW interrupt is raised
>    handle_irq()
> 	set_need_resched()
>    ret_from_irq()
>    ....
>    preempt_enable()
>       preempt()
> 
> Now if you use preempt_enable_no_resched() then you miss the preemption and
> depending on the actual code path you might run something which takes ages
> without hitting a preemption point after that.
> 

Thanks for the education, I had missed it. The changelog should have been
"fix a dumb mistake and stick to preempt_enable".  Assuming Andrew picks
this patch up, it'll be folded into the patch that introduced the problem
in the first place and will the broken usage will never hit mainline.

> It's not only a problem for RT. It's also in mainline a violation of the
> preemption mechanism.
> 

Understood, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
