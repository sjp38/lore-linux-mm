Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 995DA6B401C
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 23:34:52 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id m16so7090581pgd.0
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 20:34:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w17sor15732567pga.2.2018.11.25.20.34.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 20:34:51 -0800 (PST)
Date: Mon, 26 Nov 2018 13:34:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181126043445.GB540@jagdpanzerIV>
References: <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
 <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
 <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
 <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
 <20181123105634.4956c255@vmware.local.home>
 <6422717f-db27-8ba8-1183-ccb9f0400fc3@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6422717f-db27-8ba8-1183-ccb9f0400fc3@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/24/18 09:24), Tetsuo Handa wrote:
> >> Steven told me on Plumbers conference that even few initial
> >> characters saved him a day few times.
> > 
> > Yes, and that has happened more than once. I would reboot and retest
> > code that is crashing, and due to a triple fault, the machine would
> > reboot because of some race, and the little output I get from the
> > console would help tremendously.
> > 
> > Remember, debugging the kernel is a lot like forensics, especially when
> > it's from a customer's site. You look at all the evidence that you can
> > get, and sometimes it's just 10 characters in the output that gives you
> > an idea of where things went wrong. I'm really not liking the buffering
> > idea because of this.
> 
> Then, we should not enforce buffering in a way that requires modification of
> printk() callers. That is, we should not ask printk() callers to use their
> private buffer. What we can do is to enable/disable line buffering inside
> printk() depending on the problem the user wants to debug.

Right; overall I tend to agree with what you guys are saying and
I like Petr's "I am more and more wondering if the buffered printk
is worth the effort" comment; and I like Steven's comment on flushes;
and admire Tetsuo's efforts.

I think that printk_seq_buf/printk_buffer was never going to replace
pr_cont() and I never liked the idea. The printk_safe proposal for
lockdep had one OK thing about it - it would pass our normal marshaling
before it would reach the buffering stage. Which means - no buffering
for people who "detest" printk buffering.

This looks better:
	printk->vprint_func->{early_printk/printk_safe/vprintk_emit}->buffering

Than this:
	pr_buffer->buffering->vprintk_func->{early_printk/printk_safe/vprintk_emit}

Another thing is - printk seq_buf/printk_buffer doesn't really solve any
problem. People, who can use seq_buf/char buf[256]/etc. buffering, already
can do so; people who cannot - won't switch to a new buffering printk
anyway.

The bad thing about printk_safe proposal is that it's per-CPU; which
is OK for some paths (like lockdep), but not OK in general (e.g. OOM).

IMO, try_buffered_printk() attempts to solve the problem at the right
place - printk. And it does not break our normal marshaling, so we don't
"fix" printk users and we keep people, who does vprintk_func->early_printk
thing, happy. So I don't dislike try_buffered_printk() approach. And unlike
before, now we are talking about a single line buffering.

If we'd walk this way, I would prefer to NOT introduce any structs and
any new code, or any new "split and log_store() in the middle" rules. Just
a bunch of "struct cont" buffers:

	static struct cont conts[N];

and cont_add()/cont_flush() to handle pr_cont, with all the flushes it
does; but on a per-context basis.
conts[0] should serve as a fallback cont buffer, in case if there are
no available cont buffers left. flush_on_panic() is still miserable,
for sure; probably we can do something about it.

Or... Instead.
We can just leave pr_cont() alone for now. And make it possible to
reconstruct messages - IOW, inject some info to printk messages. We
do this at Samsung (inject CPU number at the beginning of every
message. `cat serial.0 | grep "\[1\]"` to grep for all messages from
CPU1). Probably this would be the simplest thing.

> Also, we should allow disabling "struct cont" depending on the problem (in
> order to allow flushing the 10 characters in the "cont" buffer).
>
> By the way, is the comment
>
>   /*
>    * Continuation lines are buffered, and not committed to the record buffer
>    * until the line is complete, or a race forces it. The line fragments
>    * though, are printed immediately to the consoles to ensure everything has
>    * reached the console in case of a kernel crash.
>    */

printk does not do this anymore; you are right.

> appropriate despite we don't call cont_flush() upon a kernel crash?

I tend to count on flush_on_panic more than on a "last moment"
pr_cont->cont_flush(), which was guaranteed to happen immediately
only with early_con.

A kernel crash usually has enough pr_emerg/printk-s to force cont flush.
Even pr_info() will do. We look at the loglevel much later; so even
messages which never make it to the consoles still flush cont buffer.

	-ss
