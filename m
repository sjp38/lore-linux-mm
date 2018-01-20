Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D68546B0033
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 07:19:57 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id c20so6808872qtn.22
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 04:19:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q4sor8652961qtl.154.2018.01.20.04.19.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jan 2018 04:19:57 -0800 (PST)
Date: Sat, 20 Jan 2018 04:19:53 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180120121953.GA1096857@devbig577.frc2.facebook.com>
References: <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119132052.02b89626@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Fri, Jan 19, 2018 at 01:20:52PM -0500, Steven Rostedt wrote:
> I was thinking about this a bit more, and instead of offloading a
> recursive printk, perhaps its best to simply throttle it. Because the
> problem may not go away if a printk thread takes over, because the bug
> is really the printk infrastructure filling the printk buffer keeping
> printk from ever stopping.
> 
> This patch detects that printk is causing itself to print more and
> throttles it after 3 messages have printed due to recursion. Could you
> see if this helps your test cases?

Sure, if this is the approach we're gonna take, I can try it with the
silly test code and also try to reproduce the original problem and see
whether this helps.

I'm a bit worried tho because this essentially seems like "detect
recursion, ignore messages" approach.  netcons can have a very large
surface for bugs.  Suppressing those messages would make them
difficult to debug.  For example, all our machines have both serial
console (thus the slowness) and netconsole hooked up and netcons code
has had its fair share of issues.  This would likely make tracking
down those problems more challenging.

Can we discuss pros and cons of this approach against offloading
before committing to this?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
