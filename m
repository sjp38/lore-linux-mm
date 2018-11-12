Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52CE96B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 02:59:27 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so3923509pgq.9
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 23:59:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor8363706pgl.57.2018.11.11.23.59.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 23:59:25 -0800 (PST)
Date: Mon, 12 Nov 2018 16:59:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181112075920.GA497@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
 <20181108022138.GA2343@jagdpanzerIV>
 <20181108112443.huqkju4uwrenvtnu@pathway.suse.cz>
 <20181108123049.GA30440@jagdpanzerIV>
 <20181109141012.accx62deekzq5gh5@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109141012.accx62deekzq5gh5@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/09/18 15:10), Petr Mladek wrote:
> > 
> > If I'm not mistaken, this is for the futute "printk injection" work.
> 
> The above code only tries to push complete lines to the main log buffer
> and consoles ASAP. It sounds like a Good Idea(tm).

Probably it is. So *quite likely* I'm wrong here.

Hmm... Thinking out loud.
At the same time, splitting a single logbuf entry gives a chance to other
events to mix in. Example:
	pr_cont("Foo:");
	pr_cont("\nbar");
	pr_cont("\n");

Previously it could been stored in one logbuf entry (one logstore,
one console_trylock_spinning), which means that it could have been
printed in one go:

	call_console_drivers()
		spin_trylock_irqsave(&port->lock, flags);
		uart_console_write(.... "Foo:\nbar\n");
		spin_unlock_irqrestore(&port->lock, flags);

While with buffered printk, it will be store in two logbuf entries,
and printed in two goes:

	call_console_drivers()
		spin_trylock_irqsave(&port->lock, flags);
		uart_console_write(.... "Foo:\nbar\n");
		spin_unlock_irqrestore(&port->lock, flags);

	<< ... console driver IRQ, TX port->state->xmit chars ... >>>

	call_console_drivers()
		spin_trylock_irqsave(&port->lock, flags);
		uart_console_write(.... "Foo:\nbar\n");
		spin_unlock_irqrestore(&port->lock, flags);

So, *technically*, we now let more events to happens between printk-s.

But, let's look at some of pr_cont() usage examples.
E.g. dump() from arch/h8300/kernel/traps.c. The code in question looks
as follows:

	pr_info("\nKERNEL STACK:");
	tp = ((unsigned char *) fp) - 0x40;
	for (sp = (unsigned long *) tp, i = 0; (i < 0x40);  i += 4) {
		if ((i % 0x10) == 0)
			pr_info("\n%08x: ", (int) (tp + i));
		pr_info("%08x ", (int) *sp++);
	}
	pr_info("\n");

dmesg

[   15.260099] 0000:    00000000  00000010  00000040  00000090
               0010:    00000100  00000190  00000240  00000310
               0020:    00000400  00000510  00000640  00000790
               0030:    00000900  00000a90  00000c40  00000e10

So we have the entire KERNEL STACK stored as a single line, in
a single logbuf entry.

cat /dev/kmsg

4,687,15260099,c;\x0a0000:    00000000  00000010  00000040  00000090  \x0a0010:    00000100  00000190  00000240  00000310  \x0a0020:    00000400  00000510  00000640  00000790  \x0a0030:    00000900  00000a90  00000c40  00000e10

Shall we consider this as a "reference" representation: data that
pr_cont(), ideally, would have stored as a single logbuf entry? And
then compare the "reference" representation and what buffered printk
does.

Buffered printk always stores this as several lines, IOW several
logbuf entries.

cat /dev/kmsg

4,690,15260152,-;0000:    00000000  00000010  00000040  00000090  
4,691,15260154,-;0010:    00000100  00000190  00000240  00000310  
4,692,15260157,-;0020:    00000400  00000510  00000640  00000790  
4,694,15260161,-;0030:    00000900  00000a90  00000c40  00000e10  

So if we will have concurrent printk()-s happening on other CPUs,
then the KERNEL STACK data block still can be a bit hard to read:

[   15.260152] 0000:    00000000  00000010  00000040  00000090  
<printk CPU1> ... foo bar foo bar
<printk CPU2> ... foo bar foo bar
...
[   15.260154] 0010:    00000100  00000190  00000240  00000310  
<printk CPU3> ... foo bar foo bar
<printk CPU2> ... foo bar foo bar
...
              ... and so on; you got the idea.

> No, please note that the for cycle searches for '\n' from the end
> of the string.

You are right, I didn't notice that. Indeed.


Tetsuo, lockdep report with buffered printks looks a bit different:

 kernel:  Possible unsafe locking scenario:
 kernel:        CPU0                    CPU1
 kernel:        ----                    ----
 kernel:   lock(bar_lock);
 kernel:                                lock(
 kernel: foo_lock);
 kernel:                                lock(bar_lock);
 kernel:   lock(foo_lock);
 kernel: 


> > 	len = vsprintf();
> > 	if (len && text[len - 1] == '\n' || overflow)
> > 		flush();
> 
> I had the same idea. Tetsuo ignored it. I looked for more arguments
> and found that '\n' is used in the middle of several pr_cont()
> calls

OK, so we probably can have that new semantics. But we might split
something that possibly was meant to be a single line with a bunch
of \n in the middle.

	-ss
