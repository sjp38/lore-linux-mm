Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id C73496B04F8
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:53:47 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id r127-v6so21246932itr.4
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:53:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z26-v6si176446iob.9.2018.11.07.02.53.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 02:53:46 -0800 (PST)
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <42f33aae-a1d1-197f-a1d5-8c5ec88e88d1@i-love.sakura.ne.jp>
Date: Wed, 7 Nov 2018 19:52:53 +0900
MIME-Version: 1.0
In-Reply-To: <20181106143502.GA32748@tigerII.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On 2018/11/06 23:35, Sergey Senozhatsky wrote:
>> Since we want to remove "struct cont" eventually, we will try to remove
>> both "implicit printk() users who are expecting KERN_CONT behavior" and
>> "explicit pr_cont()/printk(KERN_CONT) users". Therefore, converting to
>> this API is recommended.
> 
> - The printk-fallback sounds like a hint that the existing 'cont' handling
>   better stay in the kernel. I don't see how the existing 'cont' is
>   significantly worse than
> 		bpr_warn(NULL, ...)->printk() // no 'cont' support
>   I don't see why would we want to do it, sorry. I don't see "it takes 16
>   printk-buffers to make a thing go right" as a sure thing.

Existing 'cont' handling will stay for a while. After majority of
pr_cont()/KERN_CONT users are converted, 'cont' support will be removed
(e.g. KERN_CONT becomes "").

> 
> A question.
> 
> How bad would it actually be to:
> 
> - Allocate seq_buf 512-bytes buffer (GFP_ATOMIC) just-in-time, when we
>   need it.
>     // How often systems cannot allocate a 512-byte buffer? //

It is a very bad thing to do GFP_ATOMIC without __GFP_NOWARN. See
"[PATCH 2/3] mm: Use line-buffered printk() for show_free_areas()."
which helps exactly when GFP_ATOMIC without __GFP_NOWARN failed.
Without __GFP_NOWARN, GFP_ATOMIC for printk() can trigger infinite
recursion and kernel stack overflow.

Even without recursion, doing kmalloc(GFP_ATOMIC | __GFP_NOWARN) temporarily
consumes some kernel stack. I don't know the exact amount needed for
kmalloc(GFP_ATOMIC | __GFP_NOWARN), but it might still emit memory allocation
fault injection messages. What GFP_ATOMIC can guarantee is nothing but
"it does not sleep". Not suitable for printk() which might be called from
critically dangerous situations.

> 
> - OK, assuming that systems around the world are so badly OOM like all the
>   time and even kmalloc(512) is absolutely impossible, then have a fallback
>   to the existing 'cont' handling; it just looks to me better than a plain
>   printk()-fallback with removed 'cont' support.

Since I want to eventually remove 'cont' support inside printk(),
I dropped KERN_CONT in patch [2/3] and [3/3].

> 
> - Do not allocate seq_buf if we are in printk-safe or in printk-nmi mode.
>   To avoid "buffering for the sake of buffering". IOW, when in printk-safe
>   use printk-safe.

Why? Since printk_safe_flush_buffer() forcibly flushes the partial line,
calling printk_safe_log_store() after line buffering can reduce possibility of
flushing partial lines, can't it?
