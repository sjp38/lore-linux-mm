Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27EBE6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:15:49 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o187-v6so20107810ito.2
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:15:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 10-v6sor1646812ite.60.2018.04.04.08.15.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 08:15:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180404143900.GA1777@bombadil.infradead.org>
References: <20180402141058.GL13332@bombadil.infradead.org>
 <20180404093254.GC3881@phenom.ffwll.local> <20180404143900.GA1777@bombadil.infradead.org>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Wed, 4 Apr 2018 17:15:46 +0200
Message-ID: <CAKMK7uEb0e4ifxMkqbp4DBNFnuWk0T5k8z0SU=U95Y6pe39Z+g@mail.gmail.com>
Subject: Re: Signal handling in a page fault handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Apr 4, 2018 at 4:39 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, Apr 04, 2018 at 11:32:54AM +0200, Daniel Vetter wrote:
>> So we've done some experiments for the case where the fault originated
>> from kernel context (copy_to|from_user and friends). The fixup code seems
>> to retry the copy once after the fault (in copy_user_handle_tail), if that
>> fails again we get a short read/write. This might result in an -EFAULT,
>> short read()/write() or anything else really, depending upon the syscall
>> api.
>>
>> Except in some code paths in gpu drivers where we convert anything into
>> -ERESTARTSYS/EINTR if there's a signal pending it won't ever result in the
>> syscall getting restarted (well except maybe short read/writes if
>> userspace bothers with that).
>>
>> So I guess gpu fault handlers indeed break the kernel's expectations, but
>> then I think we're getting away with that because the inner workings of
>> gpu memory objects is all heavily abstracted away by opengl/vulkan and
>> friends.
>>
>> I guess what we could do is try to only do killable sleeps if it's a
>> kernel fault, but that means wiring a flag through all the callchains. Not
>> pretty. Except when there's a magic set of functions that would convert
>> all interruptible sleeps to killable ones only for us.
>
> I actually have plans to allow mutex_lock_{interruptible,killable} to
> return -EWOULDBLOCK if a flag is set.  So this doesn't seem entirely
> unrelated.  Something like this perhaps:
>
>  struct task_struct {
> +       unsigned int sleep_state;
>  };
>
>  static noinline int __sched
> -__mutex_lock_interruptible_slowpath(struct mutex *lock)
> +__mutex_lock_slowpath(struct mutex *lock, long state)
>  {
> -       return __mutex_lock(lock, TASK_INTERRUPTIBLE, 0, NULL, _RET_IP_);
> +       if (state == TASK_NOBLOCK)
> +               return -EWOULDBLOCK;
> +       return __mutex_lock(lock, state, 0, NULL, _RET_IP_);
>  }
>
> +int __sched mutex_lock_state(struct mutex *lock, long state)
> +{
> +       might_sleep();
> +
> +       if (__mutex_trylock_fast(lock))
> +               return 0;
> +
> +       return __mutex_lock_slowpath(lock, state);
> +}
> +EXPORT_SYMBOL(mutex_lock_state);
>
> Then the page fault handler can do something like:
>
>         old_state = current->sleep_state;
>         current->sleep_state = TASK_INTERRUPTIBLE;
>         ...
>         current->sleep_state = old_state;
>
>
> This has the page-fault-in-a-signal-handler problem.  I don't know if
> there's a way to determine if we're already in a signal handler and use
> a different sleep_state ...?

Not sure what problem you're trying to solve, but I don't think that's
the one we have. The only way what we do goes wrong is if the fault
originates from kernel context. For faults from the signal handler I
think you just get to keep the pieces. Faults form kernel we can
detect through FAULT_FLAG_USER.

The issue I'm seeing is the following:
1. Some kernel code does copy_*_user, and it points at a gpu mmap region.
2. We fault and go into the gpu driver fault handler. That refuses to
insert the pte because a signal is pending (because of all the
interruptible waits and locks).
3. Fixup section runs, which afaict tries to do the copy once more
using copy_user_handle_tail.
4. We fault again, because the pte is still not present.
5. GPU driver is still refusing to install the pte because signals are pending.
6. Fixup section for copy_user_handle_tail just bails out.
7. copy_*_user returns and indicates that that not all bytes have been copied.
8. syscall (or whatever it is) bails out and returns to userspace,
most likely with -EFAULT (but this ofc depends upon the syscall and
what it should do when userspace access faults.
9. Signal finally gets handled, but the syscall already failed, and no
one will restart it. If userspace is prudent, it might fail (or maybe
hit an assert or something).

Or maybe I'm confused by your diff, since nothing seems to use
current->sleep_state. The problem is also that it's any sleep we do
(they all tend to be interruptible, at least when waiting for the gpu
or taking any locks that might be held while waiting for the gpu, or
anything else that might be blocked waiting for the gpu really). So
only patching mutex_lock won't fix this.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch
