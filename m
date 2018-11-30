Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8380A6B5903
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 11:01:51 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so3098558edc.9
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 08:01:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9-v6si2326527ejh.47.2018.11.30.08.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 08:01:49 -0800 (PST)
Date: Fri, 30 Nov 2018 17:01:47 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181130160147.r6idgsr2biy5rwap@pathway.suse.cz>
References: <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
 <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
 <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
 <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
 <20181123105634.4956c255@vmware.local.home>
 <d630011ed50140b082e15ddc05d0c640@AcuMS.aculab.com>
 <1d29f61a-8f36-ab1c-bb92-402ee9ad161d@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d29f61a-8f36-ab1c-bb92-402ee9ad161d@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Laight <David.Laight@ACULAB.COM>, 'Steven Rostedt' <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Thu 2018-11-29 19:09:26, Tetsuo Handa wrote:
> On 2018/11/28 22:29, David Laight wrote:
> > I also spent a week trying to work out why a customer kernel was
> > locking up - only to finally find out that the distro they were
> > using set 'panic on opps' - making it almost impossible to find
> > out what was happening.

Did the machine rebooted before the messages reached console or
did it produced crash-dump or frozen?

panic() tries relatively hard to flush the messages to the console,
see printk_safe_flush_on_panic() and console_flush_on_panic().
It is less aggressive when crashdump is called. It might deadlock
in console drivers.

Hmm, it might also fail when another CPU is still running and
steals console_lock. We might want to disable
console_trylock_spinning() if the caller is not
panic_cpu.


> On 2018/11/26 13:34, Sergey Senozhatsky wrote:
> > Or... Instead.
> > We can just leave pr_cont() alone for now. And make it possible to
> > reconstruct messages - IOW, inject some info to printk messages. We
> > do this at Samsung (inject CPU number at the beginning of every
> > message. `cat serial.0 | grep "\[1\]"` to grep for all messages from
> > CPU1). Probably this would be the simplest thing.
> 
> Yes, I sent a patch which helps reconstructing messages at
> http://lkml.kernel.org/r/1543045075-3008-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

All the buffering approaches have problems that cannot be solved
easily. The prefix-based approach looks like the best alternative
at the moment.

Best Regards,
Petr
