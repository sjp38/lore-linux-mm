Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD7FD6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:54:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x24so7533281pge.13
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:54:55 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q12si12434811plk.730.2018.01.10.10.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:54:54 -0800 (PST)
Date: Wed, 10 Jan 2018 13:54:51 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110135451.4d74135b@vmware.local.home>
In-Reply-To: <20180110162900.GA21753@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110162900.GA21753@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 17:29:00 +0100
Petr Mladek <pmladek@suse.com> wrote:

> he next versions used lazy offload from console_unlock() when
> the thread spent there too much time. IMHO, this is one
> very promising solution. It guarantees that softlockup
> would never happen. But it tries hard to get the messages
> out immediately.
> 
> Unfortunately, it is very complicated. We have troubles to understand
> the concerns, for example see the long discussion about v3 at
> https://lkml.kernel.org/r/20170509082859.854-1-sergey.senozhatsky@gmail.com
> I admit that I did not have enough time to review this.
> 
> 
> Anyway, in October, 2017, Steven came up with a completely
> different approach (console owner/waiter transfer). It does
> not guarantee that the softlockup will not happen. But it
> does not suffer from the problem that blocked the obvious
> solution for years. It moves the owner at runtime, so
> it is guaranteed that the new owner would continue
> printing.

Yes, I believe my solution and the offloading solution are two agnostic
solutions, and they are not mutually exclusive. They both can be
applied. But mine shouldn't be controversial as it has no down sides
from the current printk solution.

After adding this one, if issues come up, we should have a better idea
of how to handle them, because I'm betting the issues will only come up
in some pretty unique scenarios. And they may even be solved without
having to touch printk (and hurt the get out ASAP requirement). I don't
want to paper over some real issues of those that use printk, with
printk work arounds.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
