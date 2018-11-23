Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 926C56B303A
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:46:50 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so5808919ede.19
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:46:50 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4-v6si2654983eju.61.2018.11.23.04.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:46:48 -0800 (PST)
Date: Fri, 23 Nov 2018 13:46:47 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
 <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
 <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Sat 2018-11-10 11:42:03, Tetsuo Handa wrote:
> On 2018/11/10 0:43, Petr Mladek wrote:
> >> + * Line buffered printk() tries to assign a buffer when printk() from a new
> >> + * context identifier comes in. And it automatically releases that buffer when
> >> + * one of three conditions listed below became true.
> >> + *
> >> + *   (1) printk() from that context identifier emitted '\n' as the last
> >> + *       character of output.
> >> + *   (2) printk() from that context identifier tried to print a too long line
> >> + *       which cannot be stored into a buffer.
> >> + *   (3) printk() from a new context identifier noticed that some context
> >> + *       identifier is reserving a buffer for more than 10 seconds without
> >> + *       emitting '\n'.
> >> + *
> >> + * Since (3) is based on a heuristic that somebody forgot to emit '\n' as the
> >> + * last character of output(), pr_cont()/KERN_CONT users are expected to emit
> >> + * '\n' within 10 seconds even if they reserved a buffer.
> > 
> > This is my main concern about this approach. It is so easy to omit
> > the final '\n'.
> 
> If it is so easy to forget the final '\n', there will be a lot of implicit
> pr_cont() users (because pr_cont() assumes that previous printk() omitted the
> final '\n'), and "I am going to investigate much more pr_cont() users." will
> be insufficient for getting meaningful conclusion.
> 
> Checking "lack of the the final '\n'" means that we need to check
> "all printk() users who are not emitting the final '\n'" and evaluate
> "whether there is a possibility that subsequent printk() will not be
>  called from that context due to e.g. conditional branches". That is an
> impossible task for anybody, for there might be out-of-tree code doing it.
> > 
> > They are currently delayed until another printk(). Even this is bad.
> > Unfortunately we could not setup timer from printk() because it
> > would add more locks into the game.
> 
> We could use interval timer for flushing incomplete line.

I am more and more wondering if the buffered printk is worth
the effort. The more buffers we use the more we risk that nobody
would see some important message. Even a part of the line
might be crucial in some situations.

Steven told me on Plumbers conference that even few initial
characters saved him a day few times.


> But updating printk() users to always end with '\n' will be preferable.

This sounds like a whack a mole game. If I get it correctly, you write
that it is "an impossible task for anybody" just few lines above.

Best Regards,
Petr
