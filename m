Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 115346B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 00:15:30 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c25so727174pfi.11
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:15:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a138sor4667155pfd.57.2018.01.10.21.15.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 21:15:29 -0800 (PST)
Date: Thu, 11 Jan 2018 14:15:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111051524.GC494@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <20180110182153.GP6176@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110182153.GP6176@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/10/18 19:21), Peter Zijlstra wrote:
> 
> On Wed, Jan 10, 2018 at 09:02:23AM -0800, Tejun Heo wrote:
> > 2. System runs out of memory, OOM triggers.
> > 3. OOM handler is printing out OOM debug info.
> > 4. While trying to emit the messages for netconsole, the network stack
> >    / driver tries to allocate memory and then fail, which in turn
> >    triggers allocation failure or other warning messages.  printk was
> >    already flushing, so the messages are queued on the ring.
> > 5. OOM handler keeps flushing but 4 repeats and the queue is never
> >    shrinking.  Because OOM handler is trapped in printk flushing, it
> >    never manages to free memory and no one else can enter OOM path
> >    either, so the system is trapped in this state.
> 
> Why not kill recursive OOM (msgs) ?

hm... do I understand it correctly that there is a

console_unlock()->call_console_drivers()->FOO_write()->kmalloc()->printk() recursion?

we call console drivers from printk-safe context now. so those printks
from kmalloc are redirected to per-CPU printk-safe buffer, which is
limited in size (we probably might start losing some of those OOM
messages) and which is flushed (log_store()) from another context.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
