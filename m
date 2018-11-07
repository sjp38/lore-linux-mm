Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 604296B04E9
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:21:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z72-v6so9250641ede.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:21:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13-v6si292064eje.11.2018.11.07.02.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 02:21:56 -0800 (PST)
Date: Wed, 7 Nov 2018 11:21:54 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106143502.GA32748@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Tue 2018-11-06 23:35:02, Sergey Senozhatsky wrote:
> On (11/02/18 22:31), Tetsuo Handa wrote:
> >   (1) Call get_printk_buffer() and acquire "struct printk_buffer *".
> > 
> >   (2) Rewrite printk() calls in the following way. The "ptr" is
> >       "struct printk_buffer *" obtained in step (1).
> > 
> >       printk(fmt, ...)     => printk_buffered(ptr, fmt, ...)
> >       vprintk(fmt, args)   => vprintk_buffered(ptr, fmt, args)
> >       pr_emerg(fmt, ...)   => bpr_emerg(ptr, fmt, ...)
> >       pr_alert(fmt, ...)   => bpr_alert(ptr, fmt, ...)
> >       pr_crit(fmt, ...)    => bpr_crit(ptr, fmt, ...)
> >       pr_err(fmt, ...)     => bpr_err(ptr, fmt, ...)
> >       pr_warning(fmt, ...) => bpr_warning(ptr, fmt, ...)
> >       pr_warn(fmt, ...)    => bpr_warn(ptr, fmt, ...)
> >       pr_notice(fmt, ...)  => bpr_notice(ptr, fmt, ...)
> >       pr_info(fmt, ...)    => bpr_info(ptr, fmt, ...)
> >       pr_cont(fmt, ...)    => bpr_cont(ptr, fmt, ...)
> > 
> >   (3) Release "struct printk_buffer" by calling put_printk_buffer().
> 
> [..]
> 
> > Since we want to remove "struct cont" eventually, we will try to remove
> > both "implicit printk() users who are expecting KERN_CONT behavior" and
> > "explicit pr_cont()/printk(KERN_CONT) users". Therefore, converting to
> > this API is recommended.
> 
> - The printk-fallback sounds like a hint that the existing 'cont' handling
>   better stay in the kernel. I don't see how the existing 'cont' is
>   significantly worse than
> 		bpr_warn(NULL, ...)->printk() // no 'cont' support
>   I don't see why would we want to do it, sorry. I don't see "it takes 16
>   printk-buffers to make a thing go right" as a sure thing.

I see it the following way:

   + mixed cont lines are very rare but they happen

   + 16 buffers are more than 1 so it could only be better [*]

   + the printk_buffer() code is self-contained and does not
     complicate the logic of the classic printk() code [**]


[*] A missing put_printk_buffer() might cause that we would get
    out of buffers. But the same problem is with locks,
    disabled preemption, disabled interrupts, seq_buffer,
    alloc/free. Such problems happen but they are rare.

    Also I do not expect that the same buffer would be shared
    between many functions. Therefore it should be easy
    to use it correctly.


[**] I admit that cont buffer implementation is much easier
     after removing the early flush to consoles but still...


Anyway, I do not think that both implementations are worth it.
We could keep both for some transition period but we should
remove the old one later.


> A question.
> 
> How bad would it actually be to:
> 
> - Allocate seq_buf 512-bytes buffer (GFP_ATOMIC) just-in-time, when we
>   need it.
>     // How often systems cannot allocate a 512-byte buffer? //
> 
> - OK, assuming that systems around the world are so badly OOM like all the
>   time and even kmalloc(512) is absolutely impossible, then have a fallback
>   to the existing 'cont' handling; it just looks to me better than a plain
>   printk()-fallback with removed 'cont' support.

This would prevent removing the fallback to struct cont. OOM is
one important scenario where continuous lines are used.


> - Do not allocate seq_buf if we are in printk-safe or in printk-nmi mode.
>   To avoid "buffering for the sake of buffering". IOW, when in printk-safe
>   use printk-safe.

Sure, my plan is to add a helper function is_buffered_printk_context() or so
that would check printk_context. Then we could do the following in
vprintk_buffered()

	if (is_buffered_printk_context())
		vprintk_func(....);

It might be added on top of the current patchset. I opened this
problem once and it got lost. So I did not want to complicate
it at this moment.

Best Regards,
Petr
