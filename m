Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90F8B6B0260
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:22:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r8so11864904pgq.1
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:22:59 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h8si12096824pfi.0.2018.01.10.10.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:22:58 -0800 (PST)
Date: Wed, 10 Jan 2018 13:22:55 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110132255.30745b57@vmware.local.home>
In-Reply-To: <20180110170223.GF3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110162900.GA21753@linux.suse>
	<20180110170223.GF3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 09:02:23 -0800
Tejun Heo <tj@kernel.org> wrote:

> Hello, Linus, Andrew.
> 
> On Wed, Jan 10, 2018 at 05:29:00PM +0100, Petr Mladek wrote:
> > Where is the acceptable compromise? I am not sure. So far, the most
> > forceful people (Linus) did not see softlockups as a big problem.
> > They rather wanted to see the messages.  
> 
> Can you please chime in?  Would you be opposed to offloading to an
> independent context even if it were only for cases where we were
> already punting?  The thing with the current offloading is that we
> don't know who we're offloading to.  It might end up in faster or
> slower context, or more importantly a dangerous one.

And how is that different to what we have today? It could be the
"dangerous one" that did the first printk, and 100 other CPUs in "non
dangerous" locations are constantly calling printk and making that
"dangerous" one NEVER STOP.

My solution is, if there are a ton of printks going off, each one will
do a single print, and pass it to the next one. The printk will only be
stuck doing more than one message if no more printks happen. Which is a
good thing!

Again, my algorithm bounds printk to printing AT MOST the printk buffer
size. And that can only happen if there was a burst of printks on all
CPUs, and then no printks. The one to get handed off the printk would
just finish the buffer and continue. Which should not be an issue.

> 
> The particular case that we've been seeing regularly in the fleet was
> the following scenario.
> 
> 1. Console is IPMI emulated serial console.  Super slow.  Also
>    netconsole is in use.
> 2. System runs out of memory, OOM triggers.
> 3. OOM handler is printing out OOM debug info.
> 4. While trying to emit the messages for netconsole, the network stack
>    / driver tries to allocate memory and then fail, which in turn
>    triggers allocation failure or other warning messages.  printk was
>    already flushing, so the messages are queued on the ring.

This looks like a bug in the netconsole, as the net console shouldn't
print warnings if the warning is caused by it doing a print.

Totally unrelated problem to my and Petr's patch set. Basically your
argument is "I see this bug, and your patch doesn't fix it". Well maybe
we are not solving your bug. Not to mention, it looks like printk isn't
the bug, but net console is.


> 5. OOM handler keeps flushing but 4 repeats and the queue is never
>    shrinking.  Because OOM handler is trapped in printk flushing, it
>    never manages to free memory and no one else can enter OOM path
>    either, so the system is trapped in this state.
> 
> The system usually never recovers in time once this sort of condition
> hits and the following was the patch that I suggested which only punts
> when messages are already being punted and we can easily make it less
> punty by delaying the punting by N messages.
> 
>  http://lkml.kernel.org/r/20171102135258.GO3252168@devbig577.frc2.facebook.com
> 
> We definitely can fix the above described case by e.g. preventing
> printk flushing task from queueing more messages or whatever, but it
> just seems really dumb for the system to die from things like this in
> general and it doesn't really take all that much to trigger the
> condition.

It seems really dumb to not fix that recursive net console bug, and
try to solve it with a printk work around. 

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
