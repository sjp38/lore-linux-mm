Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 057406B0691
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:12:12 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id z13-v6so570883pgv.18
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:12:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor6766083pgp.16.2018.11.08.22.12.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:12:10 -0800 (PST)
Date: Fri, 9 Nov 2018 15:12:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181109061204.GC599@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/08/18 20:37), Tetsuo Handa wrote:
> On 2018/11/08 13:45, Sergey Senozhatsky wrote:
> > So, can we just do the following? /* a sketch */
> > 
> > lockdep.c
> > 	printk_safe_enter_irqsave(flags);
> > 	lockdep_report();
> > 	printk_safe_exit_irqrestore(flags);
> 
> If buffer size were large enough to hold messages from out_of_memory(),
> I would like to use it for out_of_memory() because delaying SIGKILL
> due to waiting for printk() to complete is not good. Surely we can't
> hold all messages because amount from dump_tasks() is unpredictable.
> Maybe we can hold all messages from dump_header() except dump_tasks().
> 
> But isn't it essentially same with
> http://lkml.kernel.org/r/1493560477-3016-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> which Linus does not want?

Dunno. I guess we still haven't heard from Linus because he did quite a good
job setting up his 'email filters' ;)

Converting the existing users to buffered printk is not so simple.
Apparently there are different paths; some can afford buffered printk, some
cannot. Some of 'cont' users tend to get advantage of transparent 'cont'
context: start 'cont' output in function A: A()->pr_cont(), continue it in
B: A()->B()->pr_cont(), and then in C: A()->B()->C()->pr_cont(), and
finally flush in A: A()->pr_cont(\n). And then some paths have the
early_printk requirement. We can break the 'transparent cont' by passing
buffer pointers around [it can get a bit hairy; looking at lockdep patch],
but early_printk requirement is a different beast.

So in my email I was not advertising printk_safe as a "buffered printk for
everyone", I was just talking about lockdep. It's a bit doubtful that Peter
will ACK lockdep transition to buffered printk.

	-ss
