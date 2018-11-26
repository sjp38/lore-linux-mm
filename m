Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6AC56B4035
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 23:57:14 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so9099718plg.6
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 20:57:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f22sor3247319plr.54.2018.11.25.20.57.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 20:57:13 -0800 (PST)
Date: Mon, 26 Nov 2018 13:57:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181126045709.GD540@jagdpanzerIV>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
 <20181122101606.GP2131@hirez.programming.kicks-ass.net>
 <20181123024048.GD1582@jagdpanzerIV>
 <20181123114826.h27t7qiwfp7grrqx@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123114826.h27t7qiwfp7grrqx@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

On (11/23/18 12:48), Petr Mladek wrote:
[..]
> > This should make serial consoles re-entrant.
> > So printk->console_driver_write() hopefully will not deadlock.
> 
> Is the re-entrance safe? Some risk might be acceptable in Oops/panic
> situations. It is much less acceptable for random warnings.

Good question.

But what's the alternative? A deadlock in a serial console driver; such
that even panic() is not guaranteed to make through it (at least of now).
debug objects are used from the code which cannot re-entrant console
drivers.

bust_spinlock is called from various paths, not only panic.
git grep bust_spinlocks | wc -l
62

So we already switch to re-entrant consoles (and accept the risks) in
mm/fault.c, kernel/traps.c and so on. Which, I guess, makes us a little
more confident, faults/traps happen often enough.

It seems, that, more or less, serial consoles are ready to handle it.
UART consoles in ->write() callbacks just do a bunch of writel() [for
every char + \r\n].

	-ss
