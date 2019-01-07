Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E57648E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 00:58:15 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id x3so6359154itb.6
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 21:58:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor12706234iol.146.2019.01.06.21.58.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 21:58:14 -0800 (PST)
MIME-Version: 1.0
References: <1546771139-9349-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <e1a38e21-d5fe-dee3-7081-bc1a12965a68@i-love.sakura.ne.jp> <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
In-Reply-To: <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 7 Jan 2019 06:58:01 +0100
Message-ID: <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
Subject: Re: [PATCH] lockdep: Add debug printk() for downgrade_write() warning.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Mon, Jan 7, 2019 at 5:19 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Sun, 6 Jan 2019 19:56:59 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> > syzbot is frequently hitting downgrade_write(&mm->mmap_sem) warning from
> > munmap() request, but I don't know why it is happening. Since lockdep is
> > not printing enough information, let's print more. This patch is meant for
> > linux-next.git only and will be removed after the problem is solved.
> >
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -50,6 +50,7 @@
> >  #include <linux/random.h>
> >  #include <linux/jhash.h>
> >  #include <linux/nmi.h>
> > +#include <linux/rwsem.h>
> >
> >  #include <asm/sections.h>
> >
> > @@ -3550,6 +3551,24 @@ static int __lock_downgrade(struct lockdep_map *lock, unsigned long ip)
> >       curr->lockdep_depth = i;
> >       curr->curr_chain_key = hlock->prev_chain_key;
> >
> > +#if defined(CONFIG_RWSEM_XCHGADD_ALGORITHM) && defined(CONFIG_DEBUG_AID_FOR_SYZBOT)
> > +     if (hlock->read && curr->mm) {
> > +             struct rw_semaphore *sem = container_of(lock,
> > +                                                     struct rw_semaphore,
> > +                                                     dep_map);
> > +
> > +             if (sem == &curr->mm->mmap_sem) {
> > +#if defined(CONFIG_RWSEM_SPIN_ON_OWNER)
> > +                     pr_warn("mmap_sem: hlock->read=%d count=%ld current=%px, owner=%px\n",
> > +                             hlock->read, atomic_long_read(&sem->count),
> > +                             curr, READ_ONCE(sem->owner));
> > +#else
> > +                     pr_warn("mmap_sem: hlock->read=%d count=%ld\n",
> > +                             hlock->read, atomic_long_read(&sem->count));
> > +#endif
> > +             }
> > +     }
> > +#endif
> >       WARN(hlock->read, "downgrading a read lock");
> >       hlock->read = 1;
> >       hlock->acquire_ip = ip;
>
> I tossed it in there.
>
> But I wonder if anyone is actually running this code.  Because
>
> --- a/lib/Kconfig.debug~info-task-hung-in-generic_file_write_iter
> +++ a/lib/Kconfig.debug
> @@ -2069,6 +2069,12 @@ config IO_STRICT_DEVMEM
>
>           If in doubt, say Y.
>
> +config DEBUG_AID_FOR_SYZBOT
> +       bool "Additional debug code for syzbot"
> +       default n
> +       help
> +         This option is intended for testing by syzbot.
> +


Yes, syzbot always defines this option:

https://github.com/google/syzkaller/blob/master/dashboard/config/upstream-kasan.config#L14
https://github.com/google/syzkaller/blob/master/dashboard/config/upstream-kmsan.config#L9

It's meant specifically for such cases.

Tetsuo already got some useful information for past bugs using this feature.
