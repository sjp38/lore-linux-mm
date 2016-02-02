Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 24B316B0254
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 11:14:43 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l66so124524185wml.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 08:14:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l142si5653630wmb.55.2016.02.02.08.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 08:14:42 -0800 (PST)
Date: Tue, 2 Feb 2016 11:14:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation
 from IRQ context.
Message-ID: <20160202161421.GA30012@cmpxchg.org>
References: <201602022233.FFF65148.QVOLOtOMFJHSFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602022233.FFF65148.QVOLOtOMFJHSFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, rientjes@google.com, jstancek@redhat.com, linux-mm@kvack.org

On Tue, Feb 02, 2016 at 10:33:22PM +0900, Tetsuo Handa wrote:
> >From 20b3c1c9ef35547395c3774c6208a867cf0046d4 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 2 Feb 2016 16:50:45 +0900
> Subject: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation from IRQ context.
> 
> Jan Stancek hit a hard lockup problem due to flood of memory allocation
> failure messages which lasted for 10 seconds with IRQ disabled. Printing
> traces using warn_alloc_failed() is very slow (which can take up to about
> 1 second for each warn_alloc_failed() call). The caller used GFP_NOWARN
> inside a loop. If the caller used __GFP_NOWARN, it would not have lasted
> for 10 seconds.

Who is doing page allocations in a loop with irqs disabled?!

And then, why does it take that long? Is that a serial console? Most
of the output is KERN_INFO, it might be better to raise the loglevel
and still have all the debugging output in the logs.

If that's not enough, we could consider changing the ratelimit or make
should_suppress_show_mem() filter interrupts regardless of NODES_SHIFT.

Or ratelimit show_mem() in a different way than the single page alloc
failure line. It's not that the state changes significantly while an
avalanche of allocations are failing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
