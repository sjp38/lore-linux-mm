Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F30A6B02D6
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 03:39:02 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i19-v6so9835609pfi.21
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 00:39:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6-v6si50351826plg.84.2018.11.06.00.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 00:39:00 -0800 (PST)
Date: Tue, 6 Nov 2018 09:38:56 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181106083856.lhmibz6vrgtkqsj7@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181102133629.GN3178@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102133629.GN3178@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On Fri 2018-11-02 14:36:29, Peter Zijlstra wrote:
> On Fri, Nov 02, 2018 at 10:31:57PM +0900, Tetsuo Handa wrote:
> > syzbot is sometimes getting mixed output like below due to concurrent
> > printk(). Mitigate such output by using line-buffered printk() API.
> > 
> >   RCU used illegally from idle CPU!
> >   rcu_scheduler_active = 2, debug_locks = 1
> >   RSP: 0018:ffffffff88007bb8 EFLAGS: 00000286
> >   RCU used illegally from extended quiescent state!
> >    ORIG_RAX: ffffffffffffff13
> >   1 lock held by swapper/1/0:
> >   RAX: dffffc0000000000 RBX: 1ffffffff1000f7b RCX: 0000000000000000
> >    #0: 
> >   RDX: 1ffffffff10237b8 RSI: 0000000000000001 RDI: ffffffff8811bdc0
> >   000000004b34587c
> >   RBP: ffffffff88007bb8 R08: ffffffff88075e00 R09: 0000000000000000
> >    (
> >   R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> >   rcu_read_lock
> >   R13: ffffffff88007c78 R14: 0000000000000000 R15: 0000000000000000
> >   ){....}
> >    arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
> >    default_idle+0xc2/0x410 arch/x86/kernel/process.c:498
> >   , at: trace_call_bpf+0xf8/0x640 kernel/trace/bpf_trace.c:46
> 
> WTH is that buffered aPI, and no, that breaks my earlyprintk stuff.

The API is supposed to replace the existing unreliable and tricky code,
see struct cont and KERN_CONT flag in kernel/printk/printk.c.

The solution has been discussed many times. The preferred solution
is to use explicit buffers instead of having many
per-cpu/per-context ones and auto magically switching between them.

The original idea was to use buffers on stack. But the stack is
limited and people would need to guess the length.

This current approach uses small pool of buffers and simple logic
to get/put one. If any buffer is not available, it falls back
to direct printk(), see
https://lkml.kernel.org/r/1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

If you would want to avoid buffering, you could set the number
of buffers to zero. Then it would always fallback to
the direct printk().

Best Regards,
Petr
