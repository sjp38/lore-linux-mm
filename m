Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5076B05DF
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 06:24:48 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m45-v6so11159363edc.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 03:24:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p16si216085edx.140.2018.11.08.03.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 03:24:46 -0800 (PST)
Date: Thu, 8 Nov 2018 12:24:43 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108022138.GA2343@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Thu 2018-11-08 11:21:38, Sergey Senozhatsky wrote:
> On (11/07/18 11:21), Petr Mladek wrote:
> What is the problem:
> - we have tons of CPUs, with tons of tasks running on them, with preemption,
>   and interrupts, and potentially printk-s coming from various
>   contexts/CPUs/tasks etc. so one 'cont' buffer is not enough.
> 
> What is the proposed solution:
> - if 1 is not enough then 16 will do. And if 16 is not enough then this
>   is not our problem anymore, it's a kernel misconfiguration and users'
>   fault.

I believe that I mentioned this more times. 16 buffers is the first
attempt. We could improve it later in several ways:

  + add more buffers
  + combine buffers on stack, dynamically allocated and static ones.

BTW: I do not remember seeing mixed lines from anything even close to 16
CPUs. Maybe I was just lucky or my memory is leaky.


> Let's have one more look at what we will fix and what we will break.
> 
> 'cont' has premature flushes.
> 
>   Why is it good.
>   It preserves the correct order of events.
> 
>   pr_cont("calling foo->init()....");
>   foo->init()
>    printk("Can't allocate buffer\n");    // premature flush
>   pr_cont("...blah\h");
> 
>  Will end up in the logbuf as:
>  [12345.123] calling foo->init()....
>  [12345.124] Can't allocate buffer
>  [12345.125] ...blah
> 
>  Where buffered printk will endup as:
>  [12345.123] Can't allocate buffer
>  [12345.124] calling foo->init().......blah

We will always have this problem with API using explicit buffers.
What do you suggest instead, please?

I am afraid that we are running in cycles. The other serious
alternative was having per-process and per-context buffers
but it was rejected several times.


> Not to mention that buffered printk does not flush on panic.
> So, frankly, as of now, I don't see buffered printk as a 'cont'
> replacement.

The static array of buffers can be flushed on panic.


> If our problem is OOM and lockdep print outs, then let's address only
> those two; let's not "fix" the rest of the kernel, especially the early
> boot, - we can break more things than we can mend.

Do you have any alternative proposal how to handle OOM and lockdep, please?


> [..]
> > I opened this problem once and it got lost. So I did not want to
> > complicate it at this moment.
>
> - I don't exactly like the completely of the vprintk_buffered. If
>   buffered printk is for single line, then it must be for single
>   line only.

My undestanding is that the new API is similar to the current cont
buffer from this point of view:

    + buffer size is LOG_LINE_MAX
    + it is flushed when full

The only difference is that it is flushed also when there is a
complete line. Is this a problem, please?


> And I'm not buying the "we will need this for printk origin
> info injection" argument.

I was against this idea several times. The current API does
not do anything like this.


> - It seems that buffered printk attempts to solve too many problems.
>   I'd prefer it to address just one.

This API tries to handle continuous lines more reliably.
Do I miss anything, please?

Best Regards,
Petr
