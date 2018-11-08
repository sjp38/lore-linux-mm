Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57D196B0580
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 21:21:45 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so7749061pgs.13
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 18:21:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor2996650pgp.79.2018.11.07.18.21.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 18:21:43 -0800 (PST)
Date: Thu, 8 Nov 2018 11:21:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Message-ID: <20181108022138.GA2343@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181106143502.GA32748@tigerII.localdomain>
 <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107102154.pobr7yrl5il76be6@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/07/18 11:21), Petr Mladek wrote:
> > [..]
> > - The printk-fallback sounds like a hint that the existing 'cont' handling
> >   better stay in the kernel. I don't see how the existing 'cont' is
> >   significantly worse than
> > 		bpr_warn(NULL, ...)->printk() // no 'cont' support
> >   I don't see why would we want to do it, sorry. I don't see "it takes 16
> >   printk-buffers to make a thing go right" as a sure thing.
> 
> I see it the following way:
> 
>    + mixed cont lines are very rare but they happen
> 
>    + 16 buffers are more than 1 so it could only be better [*]

Right, so this is where things go a bit shady. I'll try to explain.

What is the problem:
- we have tons of CPUs, with tons of tasks running on them, with preemption,
  and interrupts, and potentially printk-s coming from various
  contexts/CPUs/tasks etc. so one 'cont' buffer is not enough.

What is the proposed solution:
- if 1 is not enough then 16 will do. And if 16 is not enough then this
  is not our problem anymore, it's a kernel misconfiguration and users'
  fault.

So, maybe it is a "common" kernel development pattern, I really don't know;
but it looks like we are just throwing the issue over the fence; and atop
of that we are killing off the existing 'cont'.

> Anyway, I do not think that both implementations are worth it.
> We could keep both for some transition period but we should
> remove the old one later.
>
[..]
>
> This would prevent removing the fallback to struct cont. OOM is
> one important scenario where continuous lines are used.

Let's have one more look at what we will fix and what we will break.

'cont' has premature flushes.

- it's annoying in some cases
- it's good otherwise

  Why is it good.
  It preserves the correct order of events.

  pr_cont("calling foo->init()....");
  foo->init()
   printk("Can't allocate buffer\n");    // premature flush
  pr_cont("...blah\h");

 Will end up in the logbuf as:
 [12345.123] calling foo->init()....
 [12345.124] Can't allocate buffer
 [12345.125] ...blah

 Where buffered printk will endup as:
 [12345.123] Can't allocate buffer
 [12345.124] calling foo->init().......blah

It's very different.

Not to mention that buffered printk does not flush on panic.
So, frankly, as of now, I don't see buffered printk as a 'cont'
replacement.

If our problem is OOM and lockdep print outs, then let's address only
those two; let's not "fix" the rest of the kernel, especially the early
boot, - we can break more things than we can mend.

[..]
> I opened this problem once and it got lost. So I did not want to
> complicate it at this moment.

Right, I saw it. We have similar points; I raised those in private talks:

- we don't need buffered printk in printk_safe/printk_nmi

- we don't need br_cont()

- unlike 'cont' buffer there is no way for us to flush buffered printk
  buffers on panic

- I don't exactly like the completely of the vprintk_buffered. If
  buffered printk is for single line, then it must be for single
  line only. And I'm not buying the "we will need this for printk
  origin info injection" argument.
  Linus was very clear about this whole idea:

  Linus Torvalds wrote:
  :  Sergey Senozhatsky wrote:
  :  >
  :  > so... I think we don't have to update 'struct printk_log'. we can store
  :  > that "extended data" at the beginning of every message, right after the
  :  > prefix.
  :
  :   No, we really can't. That just means that all the tools would have to
  :   be changed to get the normal messages without the extra crud. And
  :   since it will have lost the difference, that's not even easy to do.
  :
  :   So this is exactly the wrong way around.
  :
  :   If people want to see the extra data, it really should be extra data
  :   that you can get with a new interface from the kernel logs. Not a
  :   "let's just a add it to all lines and make every line uglier and
  :   harder to read.

  So the "we need all that complexity to inject printk info in later
  patches" push doesn't look right.

- It seems that buffered printk attempts to solve too many problems.
  I'd prefer it to address just one.

	-ss
