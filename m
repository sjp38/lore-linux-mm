Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 034FF6B0333
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 09:35:19 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b39-v6so13427259plb.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 06:35:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor9833292pgp.79.2018.11.06.06.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 06:35:17 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Tue, 6 Nov 2018 23:35:02 +0900
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181106143502.GA32748@tigerII.localdomain>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/02/18 22:31), Tetsuo Handa wrote:
>   (1) Call get_printk_buffer() and acquire "struct printk_buffer *".
> 
>   (2) Rewrite printk() calls in the following way. The "ptr" is
>       "struct printk_buffer *" obtained in step (1).
> 
>       printk(fmt, ...)     => printk_buffered(ptr, fmt, ...)
>       vprintk(fmt, args)   => vprintk_buffered(ptr, fmt, args)
>       pr_emerg(fmt, ...)   => bpr_emerg(ptr, fmt, ...)
>       pr_alert(fmt, ...)   => bpr_alert(ptr, fmt, ...)
>       pr_crit(fmt, ...)    => bpr_crit(ptr, fmt, ...)
>       pr_err(fmt, ...)     => bpr_err(ptr, fmt, ...)
>       pr_warning(fmt, ...) => bpr_warning(ptr, fmt, ...)
>       pr_warn(fmt, ...)    => bpr_warn(ptr, fmt, ...)
>       pr_notice(fmt, ...)  => bpr_notice(ptr, fmt, ...)
>       pr_info(fmt, ...)    => bpr_info(ptr, fmt, ...)
>       pr_cont(fmt, ...)    => bpr_cont(ptr, fmt, ...)
> 
>   (3) Release "struct printk_buffer" by calling put_printk_buffer().

[..]

> Since we want to remove "struct cont" eventually, we will try to remove
> both "implicit printk() users who are expecting KERN_CONT behavior" and
> "explicit pr_cont()/printk(KERN_CONT) users". Therefore, converting to
> this API is recommended.

- The printk-fallback sounds like a hint that the existing 'cont' handling
  better stay in the kernel. I don't see how the existing 'cont' is
  significantly worse than
		bpr_warn(NULL, ...)->printk() // no 'cont' support
  I don't see why would we want to do it, sorry. I don't see "it takes 16
  printk-buffers to make a thing go right" as a sure thing.

A question.

How bad would it actually be to:

- Allocate seq_buf 512-bytes buffer (GFP_ATOMIC) just-in-time, when we
  need it.
    // How often systems cannot allocate a 512-byte buffer? //

- OK, assuming that systems around the world are so badly OOM like all the
  time and even kmalloc(512) is absolutely impossible, then have a fallback
  to the existing 'cont' handling; it just looks to me better than a plain
  printk()-fallback with removed 'cont' support.

- Do not allocate seq_buf if we are in printk-safe or in printk-nmi mode.
  To avoid "buffering for the sake of buffering". IOW, when in printk-safe
  use printk-safe.

	-ss
