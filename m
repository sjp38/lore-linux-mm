Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 698FA6B026A
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 09:36:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y144-v6so1637545pfb.10
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 06:36:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v1-v6si34815915plb.396.2018.11.02.06.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Nov 2018 06:36:41 -0700 (PDT)
Date: Fri, 2 Nov 2018 14:36:29 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181102133629.GN3178@hirez.programming.kicks-ass.net>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On Fri, Nov 02, 2018 at 10:31:57PM +0900, Tetsuo Handa wrote:
> syzbot is sometimes getting mixed output like below due to concurrent
> printk(). Mitigate such output by using line-buffered printk() API.
> 
>   RCU used illegally from idle CPU!
>   rcu_scheduler_active = 2, debug_locks = 1
>   RSP: 0018:ffffffff88007bb8 EFLAGS: 00000286
>   RCU used illegally from extended quiescent state!
>    ORIG_RAX: ffffffffffffff13
>   1 lock held by swapper/1/0:
>   RAX: dffffc0000000000 RBX: 1ffffffff1000f7b RCX: 0000000000000000
>    #0: 
>   RDX: 1ffffffff10237b8 RSI: 0000000000000001 RDI: ffffffff8811bdc0
>   000000004b34587c
>   RBP: ffffffff88007bb8 R08: ffffffff88075e00 R09: 0000000000000000
>    (
>   R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
>   rcu_read_lock
>   R13: ffffffff88007c78 R14: 0000000000000000 R15: 0000000000000000
>   ){....}
>    arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
>    default_idle+0xc2/0x410 arch/x86/kernel/process.c:498
>   , at: trace_call_bpf+0xf8/0x640 kernel/trace/bpf_trace.c:46

WTH is that buffered aPI, and no, that breaks my earlyprintk stuff.
