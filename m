Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCAA06B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 15:37:58 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id w39so401400189qtw.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:37:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e30si48494539qtd.47.2017.01.05.12.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 12:37:58 -0800 (PST)
Date: Thu, 5 Jan 2017 14:37:55 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: x86: warning in unwind_get_return_address
Message-ID: <20170105203755.ai3ida5p2twwtvx6@treble>
References: <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
 <20161220233640.pc4goscldmpkvtqa@treble>
 <CAAeHK+yPSeO2PWQtsQs_7FQ0PeGzs4PgK_89UM8G=hFJrVzH1g@mail.gmail.com>
 <20161222051701.soqwh47frxwsbkni@treble>
 <CACT4Y+ZxTLcpwQOBCyMZGFuXeDrbu9-RBaqzgnE57UPeDSPE+g@mail.gmail.com>
 <20170105144942.whqucdwmeqybng3s@treble>
 <CACT4Y+agcezesdRUKtrho6sRmoRiCH6q4GU1J2QrTYqVkmJpKA@mail.gmail.com>
 <20170105151700.4n7wpynvsv2yjotp@treble>
 <20170105170352.4i57lv6ka2k6nqsk@treble>
 <CACT4Y+ZCygxJdKCe+OzUyXndAkupdZwGpRBKnROvgfXoggY5tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZCygxJdKCe+OzUyXndAkupdZwGpRBKnROvgfXoggY5tw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Kostya Serebryany <kcc@google.com>

On Thu, Jan 05, 2017 at 09:23:14PM +0100, Dmitry Vyukov wrote:
> On Thu, Jan 5, 2017 at 6:03 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> > On Thu, Jan 05, 2017 at 09:17:00AM -0600, Josh Poimboeuf wrote:
> >> On Thu, Jan 05, 2017 at 03:59:52PM +0100, Dmitry Vyukov wrote:
> >> > On Thu, Jan 5, 2017 at 3:49 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >> > > On Tue, Dec 27, 2016 at 05:38:59PM +0100, Dmitry Vyukov wrote:
> >> > >> On Thu, Dec 22, 2016 at 6:17 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >> > >> > On Wed, Dec 21, 2016 at 01:46:36PM +0100, Andrey Konovalov wrote:
> >> > >> >> On Wed, Dec 21, 2016 at 12:36 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >> > >> >> >
> >> > >> >> > Thanks.  Looking at the stack trace, my guess is that an interrupt hit
> >> > >> >> > while running in generated BPF code, and the unwinder got confused
> >> > >> >> > because regs->ip points to the generated code.  I may need to disable
> >> > >> >> > that warning until we figure out a better solution.
> >> > >> >> >
> >> > >> >> > Can you share your .config file?
> >> > >> >>
> >> > >> >> Sure, attached.
> >> > >> >
> >> > >> > Ok, I was able to recreate with your config.  The culprit was generated
> >> > >> > code, as I suspected, though it wasn't BPF, it was a kprobe (created by
> >> > >> > dccpprobe_init()).
> >> > >> >
> >> > >> > I'll make a patch to disable the warning.
> >> > >>
> >> > >> Hi,
> >> > >>
> >> > >> I am also seeing the following warnings:
> >> > >>
> >> > >> [  281.889259] WARNING: kernel stack regs at ffff8801c29a7ea8 in
> >> > >> syz-executor8:1302 has bad 'bp' value ffff8801c29a7f28
> >> > >> [  833.994878] WARNING: kernel stack regs at ffff8801c4e77ea8 in
> >> > >> syz-executor1:13094 has bad 'bp' value ffff8801c4e77f28
> >> > >>
> >> > >> Can it also be caused by bpf/kprobe?
> >> > >
> >> > > This is a different warning.  I suspect it's due to unwinding the stack
> >> > > of another CPU while it's running, which is still possible in a few
> >> > > places.  I'm going to have to disable all these warnings for now.
> >> >
> >> >
> >> > I also have the following diff locally. These loads trigger episodic
> >> > KASAN warnings about stack-of-bounds reads on rcu stall warnings when
> >> > it does backtrace of all cpus.
> >> > If it looks correct to you, can you please also incorporate it into your patch?
> >>
> >> Ok, will do.
> >>
> >> BTW, I think there's an issue with your mail client.  Your last two
> >> replies to me didn't have me on To/Cc.
> >
> > Would you mind testing if the following patch fixes it?  It's based on
> > the latest linus/master.
> >
> >
> > diff --git a/arch/x86/kernel/unwind_frame.c b/arch/x86/kernel/unwind_frame.c
> > index 4443e49..05adf9a 100644
> > --- a/arch/x86/kernel/unwind_frame.c
> > +++ b/arch/x86/kernel/unwind_frame.c
> > @@ -6,6 +6,21 @@
> >
> >  #define FRAME_HEADER_SIZE (sizeof(long) * 2)
> >
> > +/*
> > + * This disables KASAN checking when reading a value from another task's stack,
> > + * since the other task could be running on another CPU and could have poisoned
> > + * the stack in the meantime.
> > + */
> > +#define UNWIND_READ_ONCE(state, x)                     \
> > +({                                                     \
> > +       unsigned long val;                              \
> > +       if (state->task == current)                     \
> > +               val = READ_ONCE(x);                     \
> > +       else                                            \
> > +               val = READ_ONCE_NOCHECK(x);             \
> > +       val;                                            \
> > +})
> > +
> >  static void unwind_dump(struct unwind_state *state, unsigned long *sp)
> >  {
> >         static bool dumped_before = false;
> > @@ -48,7 +63,8 @@ unsigned long unwind_get_return_address(struct unwind_state *state)
> >         if (state->regs && user_mode(state->regs))
> >                 return 0;
> >
> > -       addr = ftrace_graph_ret_addr(state->task, &state->graph_idx, *addr_p,
> > +       addr = UNWIND_READ_ONCE(state, *addr_p);
> > +       addr = ftrace_graph_ret_addr(state->task, &state->graph_idx, addr,
> >                                      addr_p);
> >
> >         return __kernel_text_address(addr) ? addr : 0;
> > @@ -162,7 +178,7 @@ bool unwind_next_frame(struct unwind_state *state)
> >         if (state->regs)
> >                 next_bp = (unsigned long *)state->regs->bp;
> >         else
> > -               next_bp = (unsigned long *)*state->bp;
> > +               next_bp = (unsigned long *)UNWIND_READ_ONCE(state, *state->bp);
> >
> >         /* is the next frame pointer an encoded pointer to pt_regs? */
> >         regs = decode_frame_pointer(next_bp);
> > @@ -207,6 +223,16 @@ bool unwind_next_frame(struct unwind_state *state)
> >         return true;
> >
> >  bad_address:
> > +       /*
> > +        * When dumping a task other than current, the task might actually be
> > +        * running on another CPU, in which case it could be modifying its
> > +        * stack while we're reading it.  This is generally not a problem and
> > +        * can be ignored as long as the caller understands that unwinding
> > +        * another task will not always succeed.
> > +        */
> > +       if (state->task != current)
> > +               goto the_end;
> > +
> >         if (state->regs) {
> >                 printk_deferred_once(KERN_WARNING
> >                         "WARNING: kernel stack regs at %p in %s:%d has bad 'bp' value %p\n",
> 
> 
> Applied locally for testing.
> 
> 
> What about this part?
> 
> diff --git a/arch/x86/include/asm/stacktrace.h
> b/arch/x86/include/asm/stacktrace.h
> index a3269c897ec5..d8d4fc66ffec 100644
> --- a/arch/x86/include/asm/stacktrace.h
> +++ b/arch/x86/include/asm/stacktrace.h
> @@ -58,7 +58,7 @@ get_frame_pointer(struct task_struct *task, struct
> pt_regs *regs)
>         if (task == current)
>                 return __builtin_frame_address(0);
> 
> -       return (unsigned long *)((struct
> inactive_task_frame*)task->thread.sp)->bp;
> +       return (unsigned long *)READ_ONCE_NOCHECK(((struct
> inactive_task_frame *)task->thread.sp)->bp);
>  }
>  #else
>  static inline unsigned long *

Oops, I missed that part.  That's needed too.

BTW, I'm still not on your email To: list.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
