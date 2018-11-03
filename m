Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 432476B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 22:00:43 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v23-v6so3729871ioh.16
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 19:00:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f34-v6si15120016jaa.109.2018.11.02.19.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 19:00:42 -0700 (PDT)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181102133629.GN3178@hirez.programming.kicks-ass.net>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <80eb808d-4c17-9b1f-f866-3e22b9b2b18e@i-love.sakura.ne.jp>
Date: Sat, 3 Nov 2018 11:00:10 +0900
MIME-Version: 1.0
In-Reply-To: <20181102133629.GN3178@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On 2018/11/02 22:36, Peter Zijlstra wrote:
> On Fri, Nov 02, 2018 at 10:31:57PM +0900, Tetsuo Handa wrote:
>> syzbot is sometimes getting mixed output like below due to concurrent
>> printk(). Mitigate such output by using line-buffered printk() API.
>>
>>   RCU used illegally from idle CPU!
>>   rcu_scheduler_active = 2, debug_locks = 1
>>   RSP: 0018:ffffffff88007bb8 EFLAGS: 00000286
>>   RCU used illegally from extended quiescent state!
>>    ORIG_RAX: ffffffffffffff13
>>   1 lock held by swapper/1/0:
>>   RAX: dffffc0000000000 RBX: 1ffffffff1000f7b RCX: 0000000000000000
>>    #0: 
>>   RDX: 1ffffffff10237b8 RSI: 0000000000000001 RDI: ffffffff8811bdc0
>>   000000004b34587c
>>   RBP: ffffffff88007bb8 R08: ffffffff88075e00 R09: 0000000000000000
>>    (
>>   R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
>>   rcu_read_lock
>>   R13: ffffffff88007c78 R14: 0000000000000000 R15: 0000000000000000
>>   ){....}
>>    arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
>>    default_idle+0xc2/0x410 arch/x86/kernel/process.c:498
>>   , at: trace_call_bpf+0xf8/0x640 kernel/trace/bpf_trace.c:46
> 
> WTH is that buffered aPI, and no, that breaks my earlyprintk stuff.
> 

This API is nothing but a wrapper for reducing frequency of directly
calling printk() by using snprintf() if possible. Thus, whatever your
earlyprintk stuff is, this API should not affect it.
