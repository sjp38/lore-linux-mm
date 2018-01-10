Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9221E6B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:40:42 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id h17so13965205qkj.23
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:40:42 -0800 (PST)
Received: from mail.efficios.com (mail.efficios.com. [167.114.142.141])
        by mx.google.com with ESMTPS id f72si5521067qkh.1.2018.01.10.10.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:40:41 -0800 (PST)
Date: Wed, 10 Jan 2018 18:40:40 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <532107698.142.1515609640436.JavaMail.zimbra@efficios.com>
In-Reply-To: <20180110170223.GF3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com> <20180110140547.GZ3668920@devbig577.frc2.facebook.com> <20180110162900.GA21753@linux.suse> <20180110170223.GF3668920@devbig577.frc2.facebook.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel <linux-kernel@vger.kernel.org>

----- On Jan 10, 2018, at 12:02 PM, Tejun Heo tj@kernel.org wrote:

> Hello, Linus, Andrew.
> 
> On Wed, Jan 10, 2018 at 05:29:00PM +0100, Petr Mladek wrote:
>> Where is the acceptable compromise? I am not sure. So far, the most
>> forceful people (Linus) did not see softlockups as a big problem.
>> They rather wanted to see the messages.
> 
> Can you please chime in?  Would you be opposed to offloading to an
> independent context even if it were only for cases where we were
> already punting?  The thing with the current offloading is that we
> don't know who we're offloading to.  It might end up in faster or
> slower context, or more importantly a dangerous one.
> 
> The particular case that we've been seeing regularly in the fleet was
> the following scenario.
> 
> 1. Console is IPMI emulated serial console.  Super slow.  Also
>   netconsole is in use.
> 2. System runs out of memory, OOM triggers.
> 3. OOM handler is printing out OOM debug info.
> 4. While trying to emit the messages for netconsole, the network stack
>   / driver tries to allocate memory and then fail, which in turn
>   triggers allocation failure or other warning messages.  printk was
>   already flushing, so the messages are queued on the ring.
> 5. OOM handler keeps flushing but 4 repeats and the queue is never
>   shrinking.  Because OOM handler is trapped in printk flushing, it
>   never manages to free memory and no one else can enter OOM path
>   either, so the system is trapped in this state.

Hi Tejun,

There appears to be two problems at hand. One is making sure a console
buffer owner only flushes a bounded amount of data. Steven&Co patches
seem to address this.

The second problem you describe here appears to be related to the
side-effects of console drivers, namely netconsole in this scenario.
Its use of the network stack can allocate memory, which can fail, and
therefore trigger more printk. Having a way to detect that code is
directly called from a printk driver, and making sure error handling
is _not_ done by pushing more printk messages to that printk driver in
those situations comes to mind as a possible solution.

The problem you describe seems to be _another_ issue of the current
printk implementation which Steven's approach does not address, but
I don't think that Steven's changes prevent doing further improvements
on the netconsole driver front.

I also don't see what's wrong in the incremental approach proposed by
Steven. Even though it does not fix your console driver problem, his
patchset appears to address some real-world latency issues.

Thanks,

Mathieu

> 
> The system usually never recovers in time once this sort of condition
> hits and the following was the patch that I suggested which only punts
> when messages are already being punted and we can easily make it less
> punty by delaying the punting by N messages.
> 
> http://lkml.kernel.org/r/20171102135258.GO3252168@devbig577.frc2.facebook.com
> 
> We definitely can fix the above described case by e.g. preventing
> printk flushing task from queueing more messages or whatever, but it
> just seems really dumb for the system to die from things like this in
> general and it doesn't really take all that much to trigger the
> condition.
> 
> Thanks.
> 
> --
> tejun

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
