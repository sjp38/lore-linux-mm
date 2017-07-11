Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE46B04F3
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:36:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 188so23354727itx.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:36:19 -0700 (PDT)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id 204si1406777ita.44.2017.07.11.04.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 04:36:18 -0700 (PDT)
Received: by mail-it0-x233.google.com with SMTP id m68so60411428ith.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:36:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711094852.GD4586@jagdpanzerIV.localdomain>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain> <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
 <20170710125935.GL23069@pathway.suse.cz> <CAKMK7uGQ9NgS3rTieqqop-2o7sWUv8QuG_DNkJn42iPyBkEeiw@mail.gmail.com>
 <20170711023150.GB4586@jagdpanzerIV.localdomain> <20170711045710.GC4586@jagdpanzerIV.localdomain>
 <20170711075054.vjmclcao4t5lzp3r@phenom.ffwll.local> <20170711094852.GD4586@jagdpanzerIV.localdomain>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Tue, 11 Jul 2017 13:36:16 +0200
Message-ID: <CAKMK7uGz92yHyPi=v2jXVJUnp+EKYT1y1R6t2P0smiP-i0MbqA@mail.gmail.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Andreas Mohr <andi@lisas.de>, Jan Kara <jack@suse.cz>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 11:48 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (07/11/17 09:50), Daniel Vetter wrote:
> [..]
>> > ok, obviously stupid.
>> >
>> > I meant to hold con->lock between console_disable() and console_enable().
>> > so no other CPU can unregister it, etc. printk->console_unlock(), thus,
>> > can either have a racy con->flags check (no con->lock taken) or try
>> > something like down_trylock(&con->lock): if it fails, continue.
>>
>> I don't think you need the CON_ENABLED flag, just holding the per-console
>> lock should be enough (I hope). Or what exactly is the idea behind this.
>> I'm also not sure whether dropping the main console_lock is a good idea.
>
> CON_ENABLED thing is completely broken, yes. my apologies.
> what I really wanted to think about was something as below
>
>         vprintk_emit()
>          down_trylock(console_sem)
>           console_unlock()
>
> console_unlock() runs under console_sem, but in order to ->write() it
> does down_trylock(con->lock) on every console.
>
> the functions that modify consoles do:
>
>     down(console_sem)
>     down(con->lock);
>     up(console_sem);
>
>     "do things to con"
>
>     up(con->lock);
>
>     down_trylock(console_sem) // if it fails then someone else will do the printing
>      console_unlock();
>
> so console_unlock() will "pass on" those "frozen" consoles. the next time
> we are in console_unlock() again, we will notice that console has its "seen
> message IDX" behind the current log idx and will flush the (if console
> semaphore will be available).

I think the problem with that is that console_sem is such a huge outer
lock that dropping it is currently not possible. At least not until
we've pushed it back down into register_console and friends, through
the entire fbcon layer. That's why I think adding console->lock as an
entirely inner lock is the only approach we can do right now. But that
means printk writing must be extremely careful, and stop relying on
console_sem completely. I think that is doable, but a bit of work
(mostly in annotating all the current stuff protected by console_sem).

> so the loop is
>
>         for_each_console (con) {
>                 if (!down_trylock(con->lock))
>                         continue;
>
>                 while (con->console_seq != log_next_seq) {
>                         msg_print_text();
>                         con->console_seq++;
>
>                         if (!(con->flags & CON_ENABLED))
>                                 break;
>                         if (!con->write)
>                                 break;
>                         if (!cpu_online(smp_processor_id()) &&
>                             !(con->flags & CON_ANYTIME))
>                                 break;

I think the above checks don't need to be done for every msg? Or do I
misunderstand something here? As long as we hold con->lock, things
shouldn't change.

>                         if (con->flags & CON_EXTENDED)
>                                 con->write(con, ext_text, ext_len);
>                         else
>                                 con->write(con, text, len);
>                 }
>
>                 up(con->lock);
>         }
>
>         up(console_sem);
>
>> What I had in mind for the printk look is to not even hold the main
>> console_lock, but only grab the individual console_locks (plus the printk
>> buffer spinlock ofc), so
>
> may be console_sem won't be needed for printk at all. need to think
> more. I think I just wanted to jump over all those "suspend all console
> drivers" etc for hibernate and other cases that we might be missing
> at the moment.
>
>
> so, no big and heavy console manipulations should be performed under
> console_sem. we take console_sem briefly, find the right console, take
> its ->lock, unlock console_sem. from now on the we the console, nothing
> else should be able to concurrently un-register it, etc. etc.

As-is (i.e. without rewriting fbcon/fbdev) you can't assume that
console_sem is only held briefly. That's why I think any printk
redesign needs to be entirely uncoupled from console_sem. And I think
that's doable (with enough care).

>>       for_each_console(con)
>>               if (!mutex_trylock(con->mutex))
>>                       continue;
>>
>>               /* pseudo-code, whatever we need to check to make sure
>>                * this console is real and fully registered. */
>>               if (!(con->flags & CON_ENABLED))
>>                       continue;
>>
>>               if (con_requires_kthread(con)) {
>>                       wake_up(con->printk_wq);
>>
>>                       /* this is for consoles that grab massive amounts
>>                        * of locks, like fbcon. We could repurpose klogd
>>                        * for this perhaps. */
>>
>>                       continue;
>>               }
>>
>>               /* do the actual printing business */
>>       }
>
> hm... ok. very close, but not exactly what I was thinking about.
> may be guys your ideas are better. per-console printing kthread,
> hm. interesting.

I don't think we want a per-console kthread for everything, because
that would delay serial console (and other very simple consoles that
don't drag in an entire locking tree). But if you have something like
fbcon in your console list there's a _very_ high chance that ->write
or ->unblank (not 100% on the exact callchains here) will grab some
random heavy-weight lock from a completely different subsystem and
either deadlock, or cause massive delays. Per-console kthread would
work around all these problems, as long as we make the critical path
of printk _never_ attempt to take the console_sem (not even with a
trylock imo, since then you'd get delays by retrying from klogd
eventually).

>> Very rough pseudo-code draft without looking at the details. The things
>> we'd need to do to get there:
>>
>> - Audit _all_ the places that use console_lock to protect global data
>>   structures. Excessively sprinkle lockdep_assert_held(&console_lock_map);
>>   over them to make sure we don't break stuff. We'll probably want to
>>   stuff that lockdep assert into for_each_console (and have a
>>   special/open-coded one for the printk loop).
>>
>> - Add con->mutex. Make sure that lock properly serializes against
>>   the last step in register_console and the first step in
>>   unregister_console. CON_ENABLED seems like the critical flag.
>
> a silly side-note,
> we must be able to console_unlock() from IRQ. mutex_trylock() cannot
> be used in atomic, because it might sleep, unlike semaphore.

TIL. mutex_trylock not working from atomic feels super-silly. Why is
that? That would mean all the locking for console->lock needs to be a
semaphore, and we also need to hand-roll the lockdep annotations.
Yuck.

We do need a lock that you can sleep under, because some console
drivers will have to do that while holding that lock (hence also
per-console kthread).

>> - Wrap all call to console callbacks in a mutex_lock(con->mutex) critical
>>   sections.
>>
>> - Sprinkle lockdep_assert_held(con->mutex) into all the console callbacks
>>   of a few common console backends (fbcon + serial should be enough), to
>>   make sure that part is solid.
>>
>> - Do the above changes in the printk loop. It also needs to be extracted
>>   from console_unlock so that we can replace the
>>
>>       if (console_try_lock())
>>               console_unlock();
>>
>>   pattern for pushing out the printk buffer with maybe a new
>>   printk_flush() function, which does _not_ try to acquire console_lock.
>>
>> - console_unlock() still needs to flush out the printk buffers, to make
>>   sure we haven't lost any lines. Or we'll rely on klogd to ensure
>>   everything gets printed, when the trylock path doesn't work out.
>>
>> I think this would give us a reasonable locking design, allows us to not
>> stall on slow consoles when trying to dump emergency output to serial, and
>> it would decouple printk entirely from the huge console_lock mess. And as
>> long as we carefully audit for global stuff (everywhere, not just in
>> printk.c) in the first step I think it should be a safe transition.
>
> many thanks for the inputs! I'll think more about it.

I'm super happy that finally someone is looking into fixing this chaos
for real. It has hurt us for a long time in gfx-land.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
