Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA956B05F5
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 07:44:20 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g12-v6so5277696plo.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 04:44:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7-v6sor4962350pfe.47.2018.11.08.04.44.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 04:44:19 -0800 (PST)
Date: Thu, 8 Nov 2018 21:44:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181108124413.GB30440@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <20181108115310.rf7htdyyocaowbdk@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108115310.rf7htdyyocaowbdk@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/08/18 12:53), Petr Mladek wrote:
> > lockdep.c
> > 	printk_safe_enter_irqsave(flags);
> > 	lockdep_report();
> > 	printk_safe_exit_irqrestore(flags);
> 
> All this looks nice. Let's look it also from the other side.
> The following comes to my mind:
> 
> a) lockdep is not the only place when continuous lines get mixed.
>    This patch mentions also RCU stalls. The other patch mentions
>    OOM. I am sure that there will be more.
> 
> b) It is not obvious where printk_safe() would be necessary.
>    While buffered printk is clearly connected with continuous
>    lines.
> 
> c) I am not sure that disabling preemption would always be
>    acceptable.
> 
> d) We might need to increase the size of the per-CPU buffers if
>    they are used more widely.
> 
> e) People would need to learn a new (printk_safe) API when it is
>    use outside printk sources.
> 
> f) Losing the entire log is more painful than loosing one line
>    when the buffer never gets flushed.
> 
> Sigh, no solution is perfect. If only we could agree that one
> way was better than the other.

I agree with what you are saying. All of the above (in my email)
was for lockdep only, that's why I did mention lockdep several times.
Like I said, a random and wild idea.
I'm not proposing printk_safe as a "better" buffered printk for
everyone. The buffered_printk patch is pretty big, and comes with a
price tag.

If lockdep and OOM people will ACK buffered printk transition in
its current form, then we can go ahead.

It's debatable if we need a fixed size list of buffers; or we can
do kmalloc()+cont fallback. But if we will have ACKs, then we can
move forward.

	-ss
