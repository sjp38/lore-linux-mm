Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF1C6B0300
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:57:03 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id l200-v6so3498187ita.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:57:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p127-v6si14625629iof.31.2018.11.06.01.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:57:02 -0800 (PST)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181102133629.GN3178@hirez.programming.kicks-ass.net>
 <20181106083856.lhmibz6vrgtkqsj7@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b725c54e-a5b7-12fe-8269-8beccc4c88ce@i-love.sakura.ne.jp>
Date: Tue, 6 Nov 2018 18:56:03 +0900
MIME-Version: 1.0
In-Reply-To: <20181106083856.lhmibz6vrgtkqsj7@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On 2018/11/06 17:38, Petr Mladek wrote:
> If you would want to avoid buffering, you could set the number
> of buffers to zero. Then it would always fallback to
> the direct printk().

  1 lock held by swapper/1/0:
   #0: 
   (
  rcu_read_lock
  ){....}
  , at: trace_call_bpf+0xf8/0x640 kernel/trace/bpf_trace.c:46

is not welcomed and

  1 lock held by swapper/1/0:
   #0:  (rcu_read_lock){....}, at: trace_call_bpf+0xf8/0x640 kernel/trace/bpf_trace.c:46

is welcomed.

If you want to avoid fallback to direct printk(), please allocate on-stack
buffer with appropriate size. Since lockdep splat may happen when kernel
stack is already tight, blindly allocating large buffer on the stack is
not good.
