Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BEB9E6B0519
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 10:19:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x14-v6so7460826edr.7
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 07:19:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h24-v6si567636ejp.77.2018.11.07.07.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 07:19:03 -0800 (PST)
Date: Wed, 7 Nov 2018 16:19:00 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri 2018-11-02 22:31:57, Tetsuo Handa wrote:
> syzbot is sometimes getting mixed output like below due to concurrent
> printk(). Mitigate such output by using line-buffered printk() API.
> 
> @@ -2421,18 +2458,20 @@ static void check_chain_key(struct task_struct *curr)
>  print_usage_bug_scenario(struct held_lock *lock)
>  {
>  	struct lock_class *class = hlock_class(lock);
> +	struct printk_buffer *buf = get_printk_buffer();
>  
>  	printk(" Possible unsafe locking scenario:\n\n");
>  	printk("       CPU0\n");
>  	printk("       ----\n");
> -	printk("  lock(");
> -	__print_lock_name(class);
> -	printk(KERN_CONT ");\n");
> +	printk_buffered(buf, "  lock(");
> +	__print_lock_name(class, buf);
> +	printk_buffered(buf, ");\n");
>  	printk("  <Interrupt>\n");
> -	printk("    lock(");
> -	__print_lock_name(class);
> -	printk(KERN_CONT ");\n");
> +	printk_buffered(buf, "    lock(");
> +	__print_lock_name(class, buf);
> +	printk_buffered(buf, ");\n");
>  	printk("\n *** DEADLOCK ***\n\n");
> +	put_printk_buffer(buf);
>  }
>  
>  static int

I really hope that the maze of pr_cont() calls in lockdep.c is the most
complicated one that we would meet.

Anyway, the following comes to my mind:

1. The mixing of normal and buffered printk calls is a bit confusing
   and error prone. It would make sense to use the buffered printk
   everywhere in the given section of code even when it is not
   strictly needed.

2. I would replace "buf" with "pbuf" or "prbuf" to distinguish it a
   bit from other eventual buffers.


Best Regards,
Petr
