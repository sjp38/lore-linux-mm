Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 202FA6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 13:45:28 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y4so20157567iod.5
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 10:45:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m23sor2283568iob.292.2018.04.04.10.45.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 10:45:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180404162433.GB16142@bombadil.infradead.org>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <20180404093254.GC3881@phenom.ffwll.local> <20180404143900.GA1777@bombadil.infradead.org>
 <CAKMK7uEb0e4ifxMkqbp4DBNFnuWk0T5k8z0SU=U95Y6pe39Z+g@mail.gmail.com> <20180404162433.GB16142@bombadil.infradead.org>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Wed, 4 Apr 2018 19:45:23 +0200
Message-ID: <CAKMK7uGb=G=6r0gntqGxev8cMemYqjpJurRjXbf1F5pKmrtMvg@mail.gmail.com>
Subject: Re: Signal handling in a page fault handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Apr 4, 2018 at 6:24 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, Apr 04, 2018 at 05:15:46PM +0200, Daniel Vetter wrote:
>> On Wed, Apr 4, 2018 at 4:39 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> > I actually have plans to allow mutex_lock_{interruptible,killable} to
>> > return -EWOULDBLOCK if a flag is set.  So this doesn't seem entirely
>> > unrelated.  Something like this perhaps:
>> >
>> >  struct task_struct {
>> > +       unsigned int sleep_state;
>> >  };
>> >
>> >  static noinline int __sched
>> > -__mutex_lock_interruptible_slowpath(struct mutex *lock)
>> > +__mutex_lock_slowpath(struct mutex *lock, long state)
>> >  {
>> > -       return __mutex_lock(lock, TASK_INTERRUPTIBLE, 0, NULL, _RET_IP_);
>> > +       if (state == TASK_NOBLOCK)
>> > +               return -EWOULDBLOCK;
>> > +       return __mutex_lock(lock, state, 0, NULL, _RET_IP_);
>> >  }
>> >
>> > +int __sched mutex_lock_state(struct mutex *lock, long state)
>> > +{
>> > +       might_sleep();
>> > +
>> > +       if (__mutex_trylock_fast(lock))
>> > +               return 0;
>> > +
>> > +       return __mutex_lock_slowpath(lock, state);
>> > +}
>> > +EXPORT_SYMBOL(mutex_lock_state);
>> >
>> > Then the page fault handler can do something like:
>> >
>> >         old_state = current->sleep_state;
>> >         current->sleep_state = TASK_INTERRUPTIBLE;
>> >         ...
>> >         current->sleep_state = old_state;
>> >
>> >
>> > This has the page-fault-in-a-signal-handler problem.  I don't know if
>> > there's a way to determine if we're already in a signal handler and use
>> > a different sleep_state ...?
>>
>> Not sure what problem you're trying to solve, but I don't think that's
>> the one we have. The only way what we do goes wrong is if the fault
>> originates from kernel context. For faults from the signal handler I
>> think you just get to keep the pieces. Faults form kernel we can
>> detect through FAULT_FLAG_USER.
>
> Gah, I didn't explain well enough ;-(
>
> From the get_user_pages (and similar) handlers, we'd do
>
>          old_state = current->sleep_state;
>          current->sleep_state = TASK_KILLABLE;
>          ...
>          current->sleep_state = old_state;
>
> So you wouldn't need to discriminate on whether FAULT_FLAG_USER was set,
> but could just use current->sleep_state.
>
>> The issue I'm seeing is the following:
>> 1. Some kernel code does copy_*_user, and it points at a gpu mmap region.
>> 2. We fault and go into the gpu driver fault handler. That refuses to
>> insert the pte because a signal is pending (because of all the
>> interruptible waits and locks).
>> 3. Fixup section runs, which afaict tries to do the copy once more
>> using copy_user_handle_tail.
>> 4. We fault again, because the pte is still not present.
>> 5. GPU driver is still refusing to install the pte because signals are pending.
>> 6. Fixup section for copy_user_handle_tail just bails out.
>> 7. copy_*_user returns and indicates that that not all bytes have been copied.
>> 8. syscall (or whatever it is) bails out and returns to userspace,
>> most likely with -EFAULT (but this ofc depends upon the syscall and
>> what it should do when userspace access faults.
>> 9. Signal finally gets handled, but the syscall already failed, and no
>> one will restart it. If userspace is prudent, it might fail (or maybe
>> hit an assert or something).
>
> I think my patch above fixes this.  It makes the syscall killable rather
> than interruptible, so it can never observe the short read / -EFAULT
> return if it gets a fatal signal, and the non-fatal signal will be held
> off until the syscall completes.
>
>> Or maybe I'm confused by your diff, since nothing seems to use
>> current->sleep_state. The problem is also that it's any sleep we do
>> (they all tend to be interruptible, at least when waiting for the gpu
>> or taking any locks that might be held while waiting for the gpu, or
>> anything else that might be blocked waiting for the gpu really). So
>> only patching mutex_lock won't fix this.
>
> Sure, I was only patching mutex_lock_state in as an illustration.
> I've also got a 'state' equivalent for wait_on_page_bit() (although
> I'm not sure you care ...).
>
> Looks like you'd need wait_for_completion_state() and
> wait_event_state_timeout() as well.

Yeah, plus ww_mutex_lock_state, and same for the dma_fence wait
functions, but we can patch those once the core stuff has landed.

The part I'm wondering about, that you didn't really illustrate: Are
mutex_lock_interruptible&friends supposed to automatically use
current->sleep_state, or are we somehow supposed to pass that through
the call stack? Or is the idea that we'd mass-convert all the gpu code
that can be reached from the fault handlers to use the new _state
variants, which will internally consult sleep_state?

Asking since the former would be best for us: Most paths can do
interruptible, but some can't, so changing the current->state logic to
take the most limiting of both the explicitly passed sleep_state and
the one set in current->sleep_state would be best. Otrherwise if you
have a path that can at most do killable waits, but it's context might
either allow fully interruptible or killable or even neither, then
there's still some fragile code around.

Bonus points if you could even nest assignemtns to
current->sleep_state (even when there's not really all that many
options), similar to how preempt_disable and other atomic sections
nest.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch
