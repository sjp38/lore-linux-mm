Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C61426B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 05:32:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o70so3974899wrb.19
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 02:32:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t12sor2742858edi.31.2018.04.04.02.32.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 02:32:57 -0700 (PDT)
Date: Wed, 4 Apr 2018 11:32:54 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: Signal handling in a page fault handler
Message-ID: <20180404093254.GC3881@phenom.ffwll.local>
References: <20180402141058.GL13332@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180402141058.GL13332@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Apr 02, 2018 at 07:10:58AM -0700, Matthew Wilcox wrote:
> 
> Souptick and I have been auditing the various page fault handler routines
> and we've noticed that graphics drivers assume that a signal should be
> able to interrupt a page fault.  In contrast, the page cache takes great
> care to allow only fatal signals to interrupt a page fault.
> 
> I believe (but have not verified) that a non-fatal signal being delivered
> to a task which is in the middle of a page fault may well end up in an
> infinite loop, attempting to handle the page fault and failing forever.
> 
> Here's one of the simpler ones:
> 
>         ret = mutex_lock_interruptible(&etnaviv_obj->lock);
>         if (ret)
>                 return VM_FAULT_NOPAGE;
> 
> (many other drivers do essentially the same thing including i915)
> 
> On seeing NOPAGE, the fault handler believes the PTE is in the page
> table, so does nothing before it returns to arch code at which point
> I get lost in the magic assembler macros.  I believe it will end up
> returning to userspace if the signal is non-fatal, at which point it'll
> go right back into the page fault handler, and mutex_lock_interruptible()
> will immediately fail.  So we've converted a sleeping lock into the most
> expensive spinlock.
> 
> I don't think the graphics drivers really want to be interrupted by
> any signal.  I think they want to be interruptible by fatal signals
> and should use the mutex_lock_killable / fatal_signal_pending family of
> functions.  That's going to be a bit of churn, funnelling TASK_KILLABLE
> / TASK_INTERRUPTIBLE all the way down into the dma-fence code.  Before
> anyone gets started on that, I want to be sure that my analysis is
> correct, and the drivers are doing the wrong thing by using interruptible
> waits in a page fault handler.

So we've done some experiments for the case where the fault originated
from kernel context (copy_to|from_user and friends). The fixup code seems
to retry the copy once after the fault (in copy_user_handle_tail), if that
fails again we get a short read/write. This might result in an -EFAULT,
short read()/write() or anything else really, depending upon the syscall
api.

Except in some code paths in gpu drivers where we convert anything into
-ERESTARTSYS/EINTR if there's a signal pending it won't ever result in the
syscall getting restarted (well except maybe short read/writes if
userspace bothers with that).

So I guess gpu fault handlers indeed break the kernel's expectations, but
then I think we're getting away with that because the inner workings of
gpu memory objects is all heavily abstracted away by opengl/vulkan and
friends.

I guess what we could do is try to only do killable sleeps if it's a
kernel fault, but that means wiring a flag through all the callchains. Not
pretty. Except when there's a magic set of functions that would convert
all interruptible sleeps to killable ones only for us.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
