Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3013D6B0503
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 07:54:50 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id u188-v6so10529621oie.23
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 04:54:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d54si219717otf.171.2018.11.07.04.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 04:54:49 -0800 (PST)
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c4b4d3df-53c6-e938-122e-c172ba8b2500@i-love.sakura.ne.jp>
Date: Wed, 7 Nov 2018 21:54:02 +0900
MIME-Version: 1.0
In-Reply-To: <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/07 19:21, Petr Mladek wrote:
> On Tue 2018-11-06 23:35:02, Sergey Senozhatsky wrote:
>>> Since we want to remove "struct cont" eventually, we will try to remove
>>> both "implicit printk() users who are expecting KERN_CONT behavior" and
>>> "explicit pr_cont()/printk(KERN_CONT) users". Therefore, converting to
>>> this API is recommended.
>>
>> - The printk-fallback sounds like a hint that the existing 'cont' handling
>>   better stay in the kernel. I don't see how the existing 'cont' is
>>   significantly worse than
>> 		bpr_warn(NULL, ...)->printk() // no 'cont' support
>>   I don't see why would we want to do it, sorry. I don't see "it takes 16
>>   printk-buffers to make a thing go right" as a sure thing.
> 
> I see it the following way:
> 
>    + mixed cont lines are very rare but they happen
> 
>    + 16 buffers are more than 1 so it could only be better [*]
> 
>    + the printk_buffer() code is self-contained and does not
>      complicate the logic of the classic printk() code [**]
> 
> 
> [*] A missing put_printk_buffer() might cause that we would get
>     out of buffers. But the same problem is with locks,
>     disabled preemption, disabled interrupts, seq_buffer,
>     alloc/free. Such problems happen but they are rare.
> 
>     Also I do not expect that the same buffer would be shared
>     between many functions. Therefore it should be easy
>     to use it correctly.

Since we can allocate printk() buffer upon dup_task_struct()
and free it upon free_task_struct(), we can have enough printk()
buffers for task context. Also, since total number of exceptional
contexts (e.g. interrupts, oops) is finite, we can have enough
printk() buffers for exceptional contexts.

Is it possible to identify all locations which should use their own
printk() buffers (e.g. interrupt handlers, oops handlers) ? If yes,
despite Linus's objection, automatically switching printk() buffers
(like memalloc_nofs_save()/memalloc_nofs_restore() instead of
https://lkml.kernel.org/r/201709021512.DJG00503.JHOSOFFMFtVLOQ@I-love.SAKURA.ne.jp )
will be easiest and least error prone.
