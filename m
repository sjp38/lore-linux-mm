Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 082F06B0253
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 05:19:08 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y18so7010720wrh.12
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 02:19:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e128si1533541wmg.160.2018.01.16.02.19.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 02:19:06 -0800 (PST)
Date: Tue, 16 Jan 2018 11:19:03 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116101903.iuzgln2agdr46jfy@pathway.suse.cz>
References: <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
 <20180116044716.GE6607@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116044716.GE6607@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Tue 2018-01-16 13:47:16, Sergey Senozhatsky wrote:
> if you don't mind, let me fix the thing that I broke.
> that would be responsible. I believe I also must say the following:
>   Tetsuo, many thanks for reporting the issues for song long, and
>   sorry that it took quite a while to revert that change.
> 
> 8<====
> 
> From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Subject: [PATCH] printk: never set console_may_schedule in console_trylock()
> 
> This patch, basically, reverts commit 6b97a20d3a79 ("printk:
> set may_schedule for some of console_trylock() callers").
> That commit was a mistake, it introduced a big dependency
> on the scheduler, by enabling preemption under console_sem
> in printk()->console_unlock() path, which is rather too
> critical. The patch did not significantly reduce the
> possibilities of printk() lockups, but made it possible to
> stall printk(), as has been reported by Tetsuo Handa [1].
> 
> Another issues is that preemption under console_sem also
> messes up with Steven Rostedt's hand off scheme, by making
> it possible to sleep with console_sem both in console_unlock()
> and in vprintk_emit(), after acquiring the console_sem
> ownership (anywhere between printk_safe_exit_irqrestore() in
> console_trylock_spinning() and printk_safe_enter_irqsave()
> in console_unlock()). This makes hand off less likely and,
> at the same time, may result in a significant amount of
> pending logbuf messages. Preempted console_sem owner makes
> it impossible for other CPUs to emit logbuf messages, but
> does not make it impossible for other CPUs to append new
> messages to the logbuf.
> 
> Reinstate the old behavior and make printk() non-preemptible.
> Should any printk() lockup reports arrive they must be handled
> in a different way.
> 
> [1] https://marc.info/?l=linux-mm&m=145692016122716
> Fixes: 6b97a20d3a79 ("printk: set may_schedule for some of console_trylock() callers")
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

IMHO, this is a step in the right direction.

Reviewed-by: Petr Mladek <pmladek@suse.com>

I'll wait for Steven's review and push this into printk.git.
I'll also add your Acks for the other patches.

Thanks for the patch and the various observations.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
