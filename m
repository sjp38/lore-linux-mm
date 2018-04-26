Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 701366B0003
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 05:42:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x16so3908652wmc.8
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 02:42:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v13si239714edk.456.2018.04.26.02.42.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Apr 2018 02:42:13 -0700 (PDT)
Date: Thu, 26 Apr 2018 11:42:11 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180426094211.okftwdzgfn72rik3@pathway.suse.cz>
References: <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
 <20180420080428.622a8e7f@gandalf.local.home>
 <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
 <20180420101751.6c1c70e8@gandalf.local.home>
 <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
 <20180420111307.44008fc7@gandalf.local.home>
 <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
 <20180423073603.6b3294ba@gandalf.local.home>
 <20180423124502.423fb57thvbf3zet@pathway.suse.cz>
 <20180425053146.GA25288@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180425053146.GA25288@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed 2018-04-25 14:31:46, Sergey Senozhatsky wrote:
> On (04/23/18 14:45), Petr Mladek wrote:
> [..]
> > I am not sure how slow are the slowest consoles. If I take that
> > everything should be faster than 1200 bauds. Then 10 minutes
> > should be enough for 1000 lines and 80 characters per-line:
> 
> Well, the problem with the numbers is that they are too... simple...
> let me put it this way.

Sometimes a simple solution is the acceptable one.

For example, I created a complicated solution for lock-less printk
in NMI that reduced loosing messages to minimum. It ended in lkml
archives, covered by not very nice comments. Instead we ended with
quite limited per-CPU buffers.

Believe me, I could perfectly understand the desire to create perfect
defensive solutions that would never break anything. It is not easy
to decide when the best-effort solutions are worth the risk.


> What if I don't have a slow serial console? Or what if I have NMI
> watchdog set to 40 seconds? Or what if I don't have NMIs at all?
> Why am I all of a sudden limited by "1200 bauds"?

Because it keeps the solution simple and I believe that it might
be enough.


> We limit the number of times vprintk_func() was called, which is != the
> number of added lines. Because vprintk_func() is also called for
> pr_cont().

Good point. Well, it is rather trivial to count characters instead
of a number of calls.


> Another problem is that nothing tells us that we *actually* have an
> infinite loop. This can be a one time thing.

  + one time event => should fit into limit => nothing lost

  + repeated thing => repeated message does not bring new information
     => limiting is acceptable and even useful.

Honestly, I do not believe that console drivers are like Scheherazade.
They are not able to make up long interesting stories. Let's say that
lockdep splat has more than 100 lines but it can happen only once.
Let's say that WARNs have about 40 lines. I somehow doubt that we
could ever see 10 different WARN calls from one con->write() call.

1200 baud slow console is able to handle 90kB of text within 10
minutes:

   (1200 / 8) * 60 * 10 = 90000

It is more than 1000 lines full of 80 characters:

   (1200 / 8) * 60 * 10 / 80 = 1125

IMHO, it is more than enough to get useful report.


> But we first need a real reason. Right now it looks to me like
> we have "a solution" to a problem which we have never witnessed.

I am trying to find a "simple" and generic solution for the problem
reported by Tejun:

<paste from 20180110170223.GF3668920@devbig577.frc2.facebook.com>
The particular case that we've been seeing regularly in the fleet was
the following scenario

1. Console is IPMI emulated serial console.  Super slow.  Also
   netconsole is in use.
2. System runs out of memory, OOM triggers.
3. OOM handler is printing out OOM debug info.
4. While trying to emit the messages for netconsole, the network stack
   / driver tries to allocate memory and then fail, which in turn
   triggers allocation failure or other warning messages.  printk was
   already flushing, so the messages are queued on the ring.
5. OOM handler keeps flushing but 4 repeats and the queue is never
   shrinking.  Because OOM handler is trapped in printk flushing, it
   never manages to free memory and no one else can enter OOM path
   either, so the system is trapped in this state.
</paste>

It was a bit specific because offloading helped to unblock OOM path
and calm down the errors.

But let me use your words:

<paste from 20180425053146.GA25288@jagdpanzerIV>
call_console_drivers() is super complex, unbelievable complex. In fact,
it's so complex that we never know where we will end up, because it can
pass the control to almost every core kernel mechanism or subsystem:
kobjects, spin locks, tty, sdp, uart, vt, fbdev, dri, kms, timers,
timekeeping, networking, mm, scheduler, you name it. Thousands and
thousands lines of code, which are not executed exclusively by the
console drivers.
</paste>

For me it is hard to believe that all these possible errors will be
cured just by offloading. Not to say that offloading is not trivial
and there is some resistance against it.

Finally, the limiting does not only help to unblock the victim that
called console_unlock(). I also helps printk() subsystem to survive
a potential infinite DOS attack.



Well, I think about alternative solution inspired by:

<paste from 20180416042553.GA555@jagdpanzerIV>
I'd really prefer to rate limit the function which flushes per-CPU
printk_safe buffers; not the function that appends new messages to
the per-CPU printk_safe buffers.
</paste>

The is one unused flag in struct printk_log flags:5. We could use
it to mark messages from console drivers context. Then we could store
all messages and ratelimit only flushing these messages to the
console.

I still think that limiting the write into the log buffer is better
approach because it would prevent loosing other useful messages.
But this alternative approach is definitely more conservative.

Best Regards,
Petr
