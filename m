Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id EA4936B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 11:18:32 -0400 (EDT)
Received: from mail-we0-f169.google.com ([74.125.82.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TQgFT-0007H1-TS
	for linux-mm@kvack.org; Tue, 23 Oct 2012 15:18:31 +0000
Received: by mail-we0-f169.google.com with SMTP id u3so2560055wey.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 08:18:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210231022230.1635-100000@iolanthe.rowland.org>
References: <CACVXFVMmszZWHaeNS6LSG4nHR4wWBLwM_BvynRwUW8X=nO+JWA@mail.gmail.com>
	<Pine.LNX.4.44L0.1210231022230.1635-100000@iolanthe.rowland.org>
Date: Tue, 23 Oct 2012 23:18:31 +0800
Message-ID: <CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 23, 2012 at 10:46 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> On Tue, 23 Oct 2012, Ming Lei wrote:
>
>> On Mon, Oct 22, 2012 at 10:33 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
>> >
>> > Tail recursion should be implemented as a loop, not as an explicit
>> > recursion.  That is, the function should be:
>> >
>> > void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
>> > {
>> >         do {
>> >                 dev->power.memalloc_noio_resume = enable;
>> >
>> >                 if (!enable) {
>> >                         /*
>> >                          * Don't clear the parent's flag if any of the
>> >                          * parent's children have their flag set.
>> >                          */
>> >                         if (device_for_each_child(dev->parent, NULL,
>> >                                           dev_memalloc_noio))
>> >                                 return;
>> >                 }
>> >                 dev = dev->parent;
>> >         } while (dev);
>> > }
>>
>> OK, will take the non-recursion implementation for saving kernel
>> stack space.
>>
>> >
>> > except that you need to add locking, for two reasons:
>> >
>> >         There's a race.  What happens if another child sets the flag
>> >         between the time device_for_each_child() runs and the next loop
>> >         iteration?
>>
>> Yes, I know the race, and not adding a lock because the function
>> is mostly called in .probe() or .remove() callback and its parent's device
>> lock is held to avoid this race.
>>
>> Considered that it may be called in async probe() (scsi disk), one lock
>> is needed, the simplest way is to add a global lock. Any suggestion?
>
> No.  Because of where you put the new flag, it must be protected by
> dev->power.lock.  And this means the iterative implementation shown
> above can't be used as is.  It will have to be more like this:
>
> void pm_runtime_set_memalloc_noio(struct device *dev, bool enable)
> {
>         spin_lock_irq(&dev->power.lock);
>         dev->power.memalloc_noio_resume = enable;
>
>         while (dev->parent) {
>                 spin_unlock_irq(&dev->power.lock);
>                 dev = dev->parent;
>
>                 spin_lock_irq(&dev->power.lock);
>                 /*
>                  * Don't clear the parent's flag if any of the
>                  * parent's children have their flag set.
>                  */
>                 if (!enable && device_for_each_child(dev->parent, NULL,

s/dev->parent/dev

>                                 dev_memalloc_noio))
>                         break;
>                 dev->power.memalloc_noio_resume = enable;
>         }
>         spin_unlock_irq(&dev->power.lock);
> }

With the problem of non-SMP-safe bitfields access, the power.lock should
be held, but that is not enough to prevent children from being probed or
disconnected. Looks another lock is still needed. I think a global lock
is OK in the infrequent path.

>
>> >         Even without a race, access to bitfields is not SMP-safe
>> >         without locking.
>>
>> You mean one ancestor device might not be in active when
>> one of its descendants is being probed or removed?
>
> No.  Consider this example:
>
>         struct foo {
>                 int a:1;
>                 int b:1;
>         } x;
>
> Consider what happens if CPU 0 does "x.a = 1" at the same time as
> another CPU 1 does "x.b = 1".  The compiler might produce object code
> looking like this for CPU 0:
>
>         move    x, reg1
>         or      0x1, reg1
>         move    reg1, x
>
> and this for CPU 1:
>
>         move    x, reg2
>         or      0x2, reg2
>         move    reg2, x
>
> With no locking, the two "or" instructions could execute
> simultaneously.  What will the final value of x be?
>
> The two CPUs will interfere, even though they are touching different
> bitfields.

Got it, thanks for your detailed explanation.

Looks the problem is worse than above, not only bitfields are affected, the
adjacent fields might be involved too, see:

           http://lwn.net/Articles/478657/


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
