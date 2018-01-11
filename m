Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF386B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 06:24:31 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p190so1340225wmd.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 03:24:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si6156369wrc.376.2018.01.11.03.24.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 03:24:29 -0800 (PST)
Date: Thu, 11 Jan 2018 12:24:26 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111112426.GB24497@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <532107698.142.1515609640436.JavaMail.zimbra@efficios.com>
 <20180111073618.GA477@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111073618.GA477@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu 2018-01-11 16:36:18, Sergey Senozhatsky wrote:
> Hi Mathieu,
> 
> On (01/10/18 18:40), Mathieu Desnoyers wrote:
> [..]
> > 
> > There appears to be two problems at hand. One is making sure a console
> > buffer owner only flushes a bounded amount of data.
> 
> which, realistically, has quite little to do with the "and thus it
> fixes the lockups". logbuf size is mutable, the number of consoles we
> need to sequentially push the data to is mutable, the watchdog threshold
> is mutable... if combination of first two mutable things produces the
> result which makes the check based on the third mutable thing happy,
> then it's just an accident. my 5 cents.

Yes, there might be situations when Steven's patch is not able to
prevent the softlockup. But there is clear evidence that it will
help in many other situations.

The offload-based solution prevents the softlockup completely.
But there might be situations where the offload does not happen
and people might miss important messages.

And this is my point. Steven's patch is not perfect. But it helps
and it seems that it does not cause regressions. The offload based
solution solves one problem a better way but it might cause
regressions that are being discussed for years.


IMHO, nobody know how much Steven's solution is effective until we
push it into the wild. IMHO, it is safe to be pushed.

You might argue that we already know that Steven's solution will
not be enough. IMHO, the problem here is the term "real life example".

My understanding is that real-life example is a softlockup report
from a system running in production or used for debugging any bug.
So far, Steven's opponents provided only hand made code or
scenarios. The provided code usually produced printk() messages
in a tight loop. In each case, there is not a consensus that they
simulated a real life problem good enough. We might continue
discussing it but basically any discussion is theoretical unless
there are hard data behind it.

I vote to push Steven's patch into the wild and see. I really would
like to give it a chance.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
