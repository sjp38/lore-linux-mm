Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 979476B0029
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 01:31:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v14so10109236pgq.11
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 22:31:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f186sor368343pfc.65.2018.04.24.22.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 22:31:51 -0700 (PDT)
Date: Wed, 25 Apr 2018 14:31:46 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180425053146.GA25288@jagdpanzerIV>
References: <20180420021511.GB6397@jagdpanzerIV>
 <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
 <20180420080428.622a8e7f@gandalf.local.home>
 <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
 <20180420101751.6c1c70e8@gandalf.local.home>
 <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
 <20180420111307.44008fc7@gandalf.local.home>
 <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
 <20180423073603.6b3294ba@gandalf.local.home>
 <20180423124502.423fb57thvbf3zet@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423124502.423fb57thvbf3zet@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/23/18 14:45), Petr Mladek wrote:
[..]
> I am not sure how slow are the slowest consoles. If I take that
> everything should be faster than 1200 bauds. Then 10 minutes
> should be enough for 1000 lines and 80 characters per-line:

Well, the problem with the numbers is that they are too... simple...
let me put it this way.

What if I don't have a slow serial console? Or what if I have NMI
watchdog set to 40 seconds? Or what if I don't have NMIs at all?
Why am I all of a sudden limited by "1200 bauds"?

Another problem is that we limit the *wrong* thing.

Not only because we can [and probably need to] rate-limit the misbehaving
code that calls printk()-s, instead of printk(). But because we claim
that we limit the "number of lines" added recursively. This is wrong.
We limit the number of times vprintk_func() was called, which is != the
number of added lines. Because vprintk_func() is also called for pr_cont()
or printk(KERN_CONT) or printk("missing new line"). Backtraces contain
tons and tons of pr_cont()-s - registers print out, list of modules
print out, stack print out, code print out. Even this thing at the
bottom of a trace:

	Code: 01 ca 49 89 d1 48 89 d1 48 c1 ea 23 48 8b 14 d5 80 23 63 82 49 c1 e9 0c 48 c1 e9 1b 48 85 d2 74 0a 0f b6 c9 48 c1 e1 04 48 01 ca <48> 8b 12 49 c1 e1 06 b9 00 00 00 80 89 7d 80 89 75 84 48 8b 3d

is nothing but a bunch of pr_cont()-s, each of which will individually
end up in vprintk_func(). Error reports in general can contain even more
pr_cont() calls. E.g. core kernel code can hex dump slab memory, while
being called from one of console drivers.

Another problem is that nothing tells us that we *actually* have an
infinite loop. Nothing tells us that every call_console_drivers()
adds more messages to the logbuf. We see just one thing - the current
call_console_drivers() is about to add some lines to the logbuf later
on. OK, why is this a problem? This can be a one time thing. Or
console_unlock() may be in a schedulable context, getting rescheduled
after every line it prints [either implicitly after
printk_safe_exit_irqrestore(), or explicitly by calling into the
scheduler - cond_resched()].

Most likely, we don't even realize how many things we are about to
break.

> Alternatively, it seems that we are going to call console drivers
> outside printk_safe context => the messages will appear in the main
> log buffer immediately => only small risk of a ping-pong with printk
> safe buffers. We might reset the counter when all messages are handled
> in console_unlock(). It will be more complex patch than when using
> ratelimiting but it still should be sane.

We may have some sort of vprintk_func()-based solution, may be.
But we first need a real reason. Right now it looks to me like
we have "a solution" to a problem which we have never witnessed.

That vprintk_func()-based solution, if there will be no other
options on the table, must be much smarter than anything that
we have seen so far.

Sorry.

	-ss
