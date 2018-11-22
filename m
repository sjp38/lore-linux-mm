Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6C46B2B13
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:16:15 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id v79so2734871pfd.20
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:16:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q8si49471297pgk.40.2018.11.22.02.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Nov 2018 02:16:14 -0800 (PST)
Date: Thu, 22 Nov 2018 11:16:06 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181122101606.GP2131@hirez.programming.kicks-ass.net>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122020422.GA3441@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 22, 2018 at 11:04:22AM +0900, Sergey Senozhatsky wrote:
> Some serial consoles call mod_timer(). So what we could have with the
> debug objects enabled was
> 
> 	mod_timer()
> 	 lock_timer_base()
> 	  debug_activate()
> 	   printk()
> 	    call_console_drivers()
> 	     foo_console()
> 	      mod_timer()
> 	       lock_timer_base()       << deadlock
> 
> That's one possible scenario. The other one can involve console's
> IRQ handler, uart port spinlock, mod_timer, debug objects, printk,
> and an eventual deadlock on the uart port spinlock. This one can
> be mitigated with printk_safe. But mod_timer() deadlock will require
> a different fix.
> 
> So maybe we need to switch debug objects print-outs to _always_
> printk_deferred(). Debug objects can be used in code which cannot
> do direct printk() - timekeeping is just one example.

No, printk_deferred() is a disease, it needs to be eradicated, not
spread around.
