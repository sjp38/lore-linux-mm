Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57B2D6B05E1
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 06:38:37 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id j192-v6so12651289oih.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 03:38:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s189-v6si1432016oif.154.2018.11.08.03.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 03:38:36 -0800 (PST)
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
Date: Thu, 8 Nov 2018 20:37:39 +0900
MIME-Version: 1.0
In-Reply-To: <20181108044510.GC2343@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/08 13:45, Sergey Senozhatsky wrote:
> So, can we just do the following? /* a sketch */
> 
> lockdep.c
> 	printk_safe_enter_irqsave(flags);
> 	lockdep_report();
> 	printk_safe_exit_irqrestore(flags);

If buffer size were large enough to hold messages from out_of_memory(),
I would like to use it for out_of_memory() because delaying SIGKILL
due to waiting for printk() to complete is not good. Surely we can't
hold all messages because amount from dump_tasks() is unpredictable.
Maybe we can hold all messages from dump_header() except dump_tasks().

But isn't it essentially same with
http://lkml.kernel.org/r/1493560477-3016-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
which Linus does not want?
