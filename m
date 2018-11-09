Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2AC6B0704
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 10:43:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id r21-v6so1376500edp.5
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 07:43:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14-v6si218943edm.380.2018.11.09.07.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 07:43:29 -0800 (PST)
Date: Fri, 9 Nov 2018 16:43:26 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri 2018-11-09 18:55:26, Tetsuo Handa wrote:
> On 2018/11/09 15:12, Sergey Senozhatsky wrote:
> > On (11/08/18 20:37), Tetsuo Handa wrote:
> > > On 2018/11/08 13:45, Sergey Senozhatsky wrote:
> How early_printk requirement affects line buffered printk() API?
> 
> I don't think it is impossible to convert from
> 
>      printk("Testing feature XYZ..");
>      this_may_blow_up_because_of_hw_bugs();
>      printk(KERN_CONT " ... ok\n");
> 
> to
> 
>      printk("Testing feature XYZ:\n");
>      this_may_blow_up_because_of_hw_bugs();
>      printk("Testing feature XYZ.. ... ok\n");
> 
> in https://lore.kernel.org/lkml/CA+55aFwmwdY_mMqdEyFPpRhCKRyeqj=+aCqe5nN108v8ELFvPw@mail.gmail.com/ .

I just wonder how this pattern is common. I have tried but I failed
to find any instance.

This problem looks like a big argument against explicit buffers.
But I wonder if it is real.

> > 
> > So in my email I was not advertising printk_safe as a "buffered printk for
> > everyone", I was just talking about lockdep. It's a bit doubtful that Peter
> > will ACK lockdep transition to buffered printk.
> 
> What Linus is suggesting is "helper functions with no printk()", which is
> more difficult than my "helper functions with printk()" because we need to
> calculate enough buffer size (which may traverse many functions) because
> we can't printk() from helper functions when buffer size is too small.
> 
> I'm wondering if Linus still insists scattering "a data structure which
> Linus suggested" around. Rather, I'd like to propose below one. This is not
> perfect but modification is much smaller.
> 
> + * Line buffered printk() tries to assign a buffer when printk() from a new
> + * context identifier comes in. And it automatically releases that buffer when
> + * one of three conditions listed below became true.
> + *
> + *   (1) printk() from that context identifier emitted '\n' as the last
> + *       character of output.
> + *   (2) printk() from that context identifier tried to print a too long line
> + *       which cannot be stored into a buffer.
> + *   (3) printk() from a new context identifier noticed that some context
> + *       identifier is reserving a buffer for more than 10 seconds without
> + *       emitting '\n'.
> + *
> + * Since (3) is based on a heuristic that somebody forgot to emit '\n' as the
> + * last character of output(), pr_cont()/KERN_CONT users are expected to emit
> + * '\n' within 10 seconds even if they reserved a buffer.

This is my main concern about this approach. It is so easy to omit
the final '\n'.

They are currently delayed until another printk(). Even this is bad.
Unfortunately we could not setup timer from printk() because it
would add more locks into the game.

This patch will make it worse. They might get delayed by 10s or even
more. Many other lines might appear in between. Also the code is
more tricky[*].


Sign, I am really unhappy how the buffered_printk() conversion
looks in lockdep.c. But I still think that the approach is more
reliable. I am going to investigate much more pr_cont() users.
I wonder how many would be that complicated. I do not want
to give up just because one use-case that was complicated
even before.


[*] The buffer can get written and flushed by different processes.
    It is not trivial to do it correctly a lockless way.

    The proposed locking looks right on the first glance. But
    the code is a bit scary ;-)
