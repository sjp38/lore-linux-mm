Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4508D6B0581
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 21:30:13 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 18-v6so15640428pgn.4
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 18:30:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q3-v6sor3161213plb.60.2018.11.07.18.30.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 18:30:12 -0800 (PST)
Date: Thu, 8 Nov 2018 11:30:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181108023007.GB2343@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/07/18 19:52), Tetsuo Handa wrote:
> > A question.
> > 
> > How bad would it actually be to:
> > 
> > - Allocate seq_buf 512-bytes buffer (GFP_ATOMIC) just-in-time, when we
> >   need it.
> >     // How often systems cannot allocate a 512-byte buffer? //
> 
> It is a very bad thing to do GFP_ATOMIC without __GFP_NOWARN.

Absolutely, __GFP_NOWARN.

> "it does not sleep". Not suitable for printk() which might be called from
> critically dangerous situations.

So I'm really not convinced that we can use buffered printk in critically
dangerous situations. Premature 'cont' flushes and 'cont' flushes on panic
are nice and right in critically dangerous situations.

[..]
> > - Do not allocate seq_buf if we are in printk-safe or in printk-nmi mode.
> >   To avoid "buffering for the sake of buffering". IOW, when in printk-safe
> >   use printk-safe.
> 
> Why? Since printk_safe_flush_buffer() forcibly flushes the partial line

We need to leave printk_safe and enable local IRQs for that partial
flush to occur. I'm not sure that those "partial flushes" from printk_safe
actually happen.

	-ss
