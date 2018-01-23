Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16710800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:43:52 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id o22so1128074qtb.17
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:43:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w54sor486342qtb.50.2018.01.23.07.43.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 07:43:51 -0800 (PST)
Date: Tue, 23 Jan 2018 07:43:47 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123154347.GE1771050@devbig577.frc2.facebook.com>
References: <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
 <20180123152130.GB429@tigerII.localdomain>
 <20180123104121.2ef96d81@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123104121.2ef96d81@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Tue, Jan 23, 2018 at 10:41:21AM -0500, Steven Rostedt wrote:
> > I don't want to have heuristics in print_safe, I don't want to have a magic
> > number controlled by a user-space visible knob, I don't want to have the
> > first 3 lines of a lockdep splat.
> 
> We can have more. But if printk is causing printks, that's a major bug.
> And work queues are not going to fix it, it will just spread out the
> pain. Have it be 100 printks, it needs to be fixed if it is happening.
> And having all printks just generate more printks is not helpful. Even
> if we slow them down. They will still never end.

So, at least in the case that we were seeing, it isn't that black and
white.  printk keeps causing printks but only because printk buffer
flushing is preventing the printk'ing context from making forward
progress.  The key problem there is that a flushing context may get
pinned flushing indefinitely and using a separate context does solve
the problem.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
