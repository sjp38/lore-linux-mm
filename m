Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 146286B52B5
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 08:09:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w15so1052856edl.21
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 05:09:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5-v6si592107ejv.69.2018.11.29.05.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 05:09:29 -0800 (PST)
Date: Thu, 29 Nov 2018 14:09:28 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181129130928.wvejyvfhjyuje7sq@pathway.suse.cz>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
 <20181122101606.GP2131@hirez.programming.kicks-ass.net>
 <20181123024048.GD1582@jagdpanzerIV>
 <20181123114826.h27t7qiwfp7grrqx@pathway.suse.cz>
 <20181126045709.GD540@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126045709.GD540@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

On Mon 2018-11-26 13:57:09, Sergey Senozhatsky wrote:
> On (11/23/18 12:48), Petr Mladek wrote:
> [..]
> > > This should make serial consoles re-entrant.
> > > So printk->console_driver_write() hopefully will not deadlock.
> > 
> > Is the re-entrance safe? Some risk might be acceptable in Oops/panic
> > situations. It is much less acceptable for random warnings.
> 
> Good question.
> 
> But what's the alternative? A deadlock in a serial console driver; such
> that even panic() is not guaranteed to make through it (at least of now).
> debug objects are used from the code which cannot re-entrant console
> drivers.
> 
> bust_spinlock is called from various paths, not only panic.
> git grep bust_spinlocks | wc -l
> 62

bust_spinlocks() is followed by die() in several situations. The rests
seems to be Oops situations where we an invalid address is being accessed.
There is a nontrivial chance that the system would die anyway.

Now, if I look into Documentation/core-api/debug-objects.rst,
the API is used to detect:

  -  Activation of uninitialized objects
  -  Initialization of active objects
  -  Usage of freed/destroyed objects

Of course, all the above situations might lead to the system crash. But
even in the worst case, use-after-free, there is a non-trivial chance
that the data still would be valid and the system would survive.

There might be many other warnings of the same severity.


> So we already switch to re-entrant consoles (and accept the risks) in
> mm/fault.c, kernel/traps.c and so on. Which, I guess, makes us a little
> more confident, faults/traps happen often enough.

Where is the border line, please?
Do we want to have the kernel sources full of bust_spinlocks() callers?


> It seems, that, more or less, serial consoles are ready to handle it.
> UART consoles in ->write() callbacks just do a bunch of writel() [for
> every char + \r\n].

But oops_in_progress does not affect only serial (UART) consoles.

We want safe lockless consoles. We do not want to run
a most-of-the-time-safe code too often.


BTW: I have heard that someone from the RT people is working
on a big printk() rewrite. One part is a lockless buffer. Another
part should be a different handling of safe (lockless) and
more complicated consoles. It was presented on some recent
conference (I forgot which one). I do not know any details.
But the first version should be sent in a near future.

Best Regards,
Petr
