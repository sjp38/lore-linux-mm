Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C038E828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:36:19 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id w128so90495059pfb.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:36:19 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id b8si42878485pfd.34.2016.03.02.06.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 06:36:18 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id fl4so133895882pad.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:36:18 -0800 (PST)
Date: Wed, 2 Mar 2016 23:34:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
Message-ID: <20160302143415.GB614@swordfish>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
 <20160302133810.GB22171@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160302133810.GB22171@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, sergey.senozhatsky@gmail.com, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org

On (03/02/16 14:38), Petr Mladek wrote:
[..]
> > 
> > CONFIG_PREEMPT_NONE=y
> > # CONFIG_PREEMPT_VOLUNTARY is not set
> > # CONFIG_PREEMPT is not set
> > CONFIG_PREEMPT_COUNT=y
> 
> preempt_disable() / preempt_enable() would do the job.
> The question is where to put it. If you are concerned about
> the delay, you might want to disable preemption around
> the whole locked area, so that it works reasonable also
> in the preemptive kernel.

another question is why cond_resched() is suddenly so expensive?
my guess is because of OOM, so we switch to tasks that potentially
do direct reclaims, etc. if so, then even offloaded printk will take
a significant amount of time to print the logs to the consoles; just
because it does cond_resched() after every call_console_drivers().


> I am looking forward to have the console printing offloaded
> into the workqueues. Then printk() will become consistently
> "fast" operation and will cause less surprises like this.

I'm all for it. I need this rework badly. If Jan is too busy at
the moment, which I surely can understand, then I'll be happy to
help ("pick up the patches". please, don't get me wrong).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
