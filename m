Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 271816B05F1
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 07:30:56 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id n5-v6so16472395pgv.6
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 04:30:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133sor4190791pga.67.2018.11.08.04.30.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 04:30:54 -0800 (PST)
Date: Thu, 8 Nov 2018 21:30:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181108123049.GA30440@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
 <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/08/18 12:24), Petr Mladek wrote:
> I believe that I mentioned this more times. 16 buffers is the first
> attempt. We could improve it later in several ways

Sure. Like I said - maybe it is a normal development pattern; I really
don't know.

> > Let's have one more look at what we will fix and what we will break.
> > 
> > 'cont' has premature flushes.
> > 
> >   Why is it good.
> >   It preserves the correct order of events.
> > 
> >   pr_cont("calling foo->init()....");
> >   foo->init()
> >    printk("Can't allocate buffer\n");    // premature flush
> >   pr_cont("...blah\h");
> > 
> >  Will end up in the logbuf as:
> >  [12345.123] calling foo->init()....
> >  [12345.124] Can't allocate buffer
> >  [12345.125] ...blah
> > 
> >  Where buffered printk will endup as:
> >  [12345.123] Can't allocate buffer
> >  [12345.124] calling foo->init().......blah
> 
> We will always have this problem with API using explicit buffers.

Exactly.

> What do you suggest instead, please?

So this is why "let's not remove 'cont'" thing. Buffered printk
is not 100% identical to 'cont'. And 'cont' does a good job sometimes,
Because 'cont' looks like a buffered printk, but it behaves like a
normal printk when things go bad. Buffered printk is always buffered;
and not even aware of the fact that things go bad around.

> > If our problem is OOM and lockdep print outs, then let's address only
> > those two; let's not "fix" the rest of the kernel, especially the early
> > boot, - we can break more things than we can mend.
> 
> Do you have any alternative proposal how to handle OOM and lockdep, please?

You misunderstood me. I'm not against the buffered printk in lockdep and
OOM. Albeit I must admit that lockdep patch looks quite big. I don't like
the idea of "we will remove 'cont' and replace it with buffered printk
through out the kernel".

[..]
> > - It seems that buffered printk attempts to solve too many problems.
> >   I'd prefer it to address just one.
> 
> This API tries to handle continuous lines more reliably.
> Do I miss anything, please?

This part:

+       /* Flush already completed lines if any. */
+       for (pos = ptr->len - 1; pos >= 0; pos--) {
+               if (ptr->buf[pos] != '\n')
+                       continue;
+               ptr->buf[pos++] = '\0';
+               printk("%s\n", ptr->buf);
+               ptr->len -= pos;
+               memmove(ptr->buf, ptr->buf + pos, ptr->len);
+               /* This '\0' will be overwritten by next vsnprintf() above. */
+               ptr->buf[ptr->len] = '\0';
+               break;
+       }
+       return r;

If I'm not mistaken, this is for the futute "printk injection" work.

Right now printk("foo\nbar\n") will end up to be a single logbuf
entry, with \n in the middle and at the end. So it will look like
two lines on the serial console:

	[123.123] foo
	          bar

Tetsuo does this \n lookup (on every vprintk_buffered) and split lines
(via memove) for "printk injection", so the output will be

	[123.123] foo
	[123.124] bar

Which makes it simpler to "inject" printk origin into every printed
line.

Without it we can just do

	len = vsprintf();
	if (len && text[len - 1] == '\n' || overflow)
		flush();

Can't we?

	-ss
