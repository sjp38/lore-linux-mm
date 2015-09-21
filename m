Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 63D7A6B0256
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:47:16 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so117421644pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:47:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id vm6si37893037pab.128.2015.09.21.06.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 06:47:15 -0700 (PDT)
Date: Mon, 21 Sep 2015 15:44:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150921134414.GA15974@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/20, Linus Torvalds wrote:
>
> On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > In this case the workqueue thread will block.
>
> What workqueue thread?

I must have missed something. I can't understand your and Michal's
concerns.

>    pagefault_out_of_memory ->
>       out_of_memory ->
>          oom_kill_process
>
> as far as I can tell, this can be called by any task. Now, that
> pagefault case should only happen when the page fault comes from user
> space, but we also have
>
>    __alloc_pages_slowpath ->
>       __alloc_pages_may_oom ->
>          out_of_memory ->
>             oom_kill_process
>
> which can be called from just about any context (but atomic
> allocations will never get here, so it can schedule etc).

So yes, in general oom_kill_process() can't call oom_unmap_func() directly.
That is why the patch uses queue_work(oom_unmap_func). The workqueue thread
takes mmap_sem and frees the memory allocated by user space.

If this can lead to deadlock somehow, then we can hit the same deadlock
when an oom-killed thread calls exit_mm().

> So what's your point?

This can help if the killed process refuse to die and (of course) it
doesn't hold the mmap_sem for writing. Say, it waits for some mutex
held by the task which tries to alloc the memory and triggers oom.

> Explain again just how do you guarantee that you
> can take the mmap_sem.

This is not guaranteed, down_read(mmap_sem) can block forever. But this
means that the (killed) victim never drops mmap_sem / never exits, so
we lose anyway. We have no memory, oom-killer is blocked, etc.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
