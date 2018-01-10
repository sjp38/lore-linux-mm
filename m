Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 053626B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:07:03 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id j141so71185qke.4
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:07:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m6sor12204836qki.145.2018.01.10.10.57.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 10:57:50 -0800 (PST)
Date: Wed, 10 Jan 2018 10:57:47 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110185747.GO3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180110181252.GK3668920@devbig577.frc2.facebook.com>
 <20180110134157.1c3ce4b9@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110134157.1c3ce4b9@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Wed, Jan 10, 2018 at 01:41:57PM -0500, Steven Rostedt wrote:
> The issue with the solution you want to do with printk is that it can
> break existing printk usages. As Petr said, people want printk to do two
> things. 1 - print out data ASAP, 2 - not lock up the system. The two
> are fighting each other. You care more about 2 where I (and others,
> like Peter Zijlstra and Linus) care more about 1.
> 
> My solution can help with 2 without doing anything to hurt 1.

I'm not really sure why punting to a safe context is necessarily
unacceptable in terms of #1 because there seems to be a pretty wide
gap between printing useful messages synchronously and a system being
caught in printk flush to the point where the system is not
operational at all.

> You are NACKing my solution because it doesn't solve this bug with net
> console. I believe net console should be fixed. You believe that printk
> should have a work around to not let net console type bugs occur. Which
> to me is papering over the real bugs.

As I wrote along with nack, I was more concerned with how this was
pushed forward by saying that actual problems are not real.

As for the netconsole part, sure, that can be one way, but please
consider that the messages could be coming from network drivers, of
which we have many and a lot of them aren't too high quality.  Plus,
netconsole is a separate path and network drivers can easily
malfunction on memory allocation failures.

Again, not a critical problem.  We can decide either way but it'd be
better to be generally safe (if we can do that reasonably), right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
