Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBF806B0273
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 05:43:17 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id c7-v6so9525074iod.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 02:43:17 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u123si1664996ith.127.2018.11.12.02.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 02:43:16 -0800 (PST)
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
 <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
 <20181108123049.GA30440@jagdpanzerIV>
 <20181109141012.accx62deekzq5gh5@pathway.suse.cz>
 <20181112075920.GA497@jagdpanzerIV>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a09073bb-78b3-b056-e976-c90e41f1b00d@i-love.sakura.ne.jp>
Date: Mon, 12 Nov 2018 19:42:16 +0900
MIME-Version: 1.0
In-Reply-To: <20181112075920.GA497@jagdpanzerIV>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/12 16:59, Sergey Senozhatsky wrote:
> Tetsuo, lockdep report with buffered printks looks a bit different:
> 
>  kernel:  Possible unsafe locking scenario:
>  kernel:        CPU0                    CPU1
>  kernel:        ----                    ----
>  kernel:   lock(bar_lock);
>  kernel:                                lock(
>  kernel: foo_lock);
>  kernel:                                lock(bar_lock);
>  kernel:   lock(foo_lock);
>  kernel: 
> 

Yes. That is because vprintk_buffered() eliminated KERN_CONT.
Since there was pending partial printk() output, vprintk_buffered()
should not eliminate KERN_CONT. Petr Mladek commented

  1. The mixing of normal and buffered printk calls is a bit confusing
     and error prone. It would make sense to use the buffered printk
     everywhere in the given section of code even when it is not
     strictly needed.

and I made a draft version for how the code would look like if we try to
avoid the mixing of normal and buffered printk calls. The required changes
seem to be too large to apply tree wide. And I suggested try_buffered_printk().
