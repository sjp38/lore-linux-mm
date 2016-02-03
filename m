Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6B2828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 05:41:04 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id w123so12004153pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 02:41:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 137si8577626pfb.80.2016.02.03.02.41.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 02:41:03 -0800 (PST)
Subject: Re: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation from IRQ context.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602022233.FFF65148.QVOLOtOMFJHSFF@I-love.SAKURA.ne.jp>
	<20160202161421.GA30012@cmpxchg.org>
In-Reply-To: <20160202161421.GA30012@cmpxchg.org>
Message-Id: <201602031940.IFH52643.JLOOFtMQOFFHVS@I-love.SAKURA.ne.jp>
Date: Wed, 3 Feb 2016 19:40:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@kernel.org, rientjes@google.com, jstancek@redhat.com, linux-mm@kvack.org

Johannes Weiner wrote:
> On Tue, Feb 02, 2016 at 10:33:22PM +0900, Tetsuo Handa wrote:
> > >From 20b3c1c9ef35547395c3774c6208a867cf0046d4 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Tue, 2 Feb 2016 16:50:45 +0900
> > Subject: [RFC][PATCH] mm, page_alloc: Warn on !__GFP_NOWARN allocation from IRQ context.
> > 
> > Jan Stancek hit a hard lockup problem due to flood of memory allocation
> > failure messages which lasted for 10 seconds with IRQ disabled. Printing
> > traces using warn_alloc_failed() is very slow (which can take up to about
> > 1 second for each warn_alloc_failed() call). The caller used GFP_NOWARN

                                                                s/GFP_NOWARN/GFP_NOWAIT/

> > inside a loop. If the caller used __GFP_NOWARN, it would not have lasted
> > for 10 seconds.
> 
> Who is doing page allocations in a loop with irqs disabled?!

lib/dma-debug.c functions which are called with irqs disabled.
http://lkml.kernel.org/r/201601292135.DHG60988.SOQFJFOHFVMLOt@I-love.SAKURA.ne.jp

> 
> And then, why does it take that long? Is that a serial console? Most
> of the output is KERN_INFO, it might be better to raise the loglevel
> and still have all the debugging output in the logs.

Yes, I think it is a serial console.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
