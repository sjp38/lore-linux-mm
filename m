Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 647026B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:09:12 -0400 (EDT)
Received: by ioii196 with SMTP id i196so19324673ioi.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 09:09:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x75si3266820ioi.11.2015.09.22.09.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 09:09:11 -0700 (PDT)
Date: Tue, 22 Sep 2015 18:06:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150922160608.GA2716@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com> <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com> <20150921161203.GD19811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921161203.GD19811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/21, Michal Hocko wrote:
>
> On Mon 21-09-15 17:32:52, Oleg Nesterov wrote:
> > On 09/21, Michal Hocko wrote:
> > >
> > > On Mon 21-09-15 15:44:14, Oleg Nesterov wrote:
> > > [...]
> > > > So yes, in general oom_kill_process() can't call oom_unmap_func() directly.
> > > > That is why the patch uses queue_work(oom_unmap_func). The workqueue thread
> > > > takes mmap_sem and frees the memory allocated by user space.
> > >
> > > OK, this might have been a bit confusing. I didn't mean you cannot use
> > > mmap_sem directly from the workqueue context. You _can_ AFAICS. But I've
> > > mentioned that you _shouldn't_ use workqueue context in the first place
> > > because all the workers might be blocked on locks and new workers cannot
> > > be created due to memory pressure.
> >
> > Yes, yes, and I already tried to comment this part.
>
> OK then we are on the same page, good.

Yes, yes.

> > We probably need a
> > dedicated kernel thread, but I still think (although I am not sure) that
> > initial change can use workueue. In the likely case system_unbound_wq pool
> > should have an idle thread, if not - OK, this change won't help in this
> > case. This is minor.
>
> The point is that the implementation should be robust from the very
> beginning.

OK, let it be a kthread from the very beginning, I won't argue. This
is really minor compared to other problems.

> > > So I think we probably need to do this in the OOM killer context (with
> > > try_lock)
> >
> > Yes we should try to do this in the OOM killer context, and in this case
> > (of course) we need trylock. Let me quote my previous email:
> >
> > 	And we want to avoid using workqueues when the caller can do this
> > 	directly. And in this case we certainly need trylock. But this needs
> > 	some refactoring: we do not want to do this under oom_lock,
>
> Why do you think oom_lock would be a big deal?

I don't really know... This doesn't look sane to me, but perhaps this
is just because I don't understand this code enough.

And note that the caller can held other locks we do not even know about.
Most probably we should not deadlock, at least if we only unmap the anon
pages, but still this doesn't look safe.

But I agree, this probably needs more discussion.

> Address space of the
> victim might be really large but we can back off after a batch of
> unmapped pages.

Hmm. If we already have mmap_sem and started zap_page_range() then
I do not think it makes sense to stop until we free everything we can.

> I definitely agree with the simplicity for the first iteration. That
> means only unmap private exclusive pages and release at most few megs of
> them.

See above, I am not sure this makes sense. And in any case this will
complicate the initial changes, not simplify.

> I am still not sure about some details, e.g. futex sitting in such
> a memory. Wouldn't threads blow up when they see an unmapped futex page,
> try to page it in and it would be in an uninitialized state? Maybe this
> is safe

But this must be safe.

We do not care about userspace (assuming that all mm users have a
pending SIGKILL).

If this can (say) crash the kernel somehow, then we have a bug which
should be fixed. Simply because userspace can exploit this bug doing
MADV_DONTEED from another thread or CLONE_VM process.



Finally. Whatever we do, we need to change oom_kill_process() first,
and I think we should do this regardless. The "Kill all user processes
sharing victim->mm" logic looks wrong and suboptimal/overcomplicated.
I'll try to make some patches tomorrow if I have time...

But. Can't we just remove another ->oom_score_adj check when we try
to kill all mm users (the last for_each_process loop). If yes, this
all can be simplified.

I guess we can't and its a pity. Because it looks simply pointless
to not kill all mm users. This just means the select_bad_process()
picked the wrong task.


Say, vfork(). OK, it is possible that parent is OOM_SCORE_ADJ_MIN and
the child has already updated its oom_score_adj before exec. Now if
we to kill the child we will only upset the parent for no reason, this
won't help to free the memory.



And while this completely offtopic... why does it take task_lock()
to protect ->comm? Sure, without task_lock() we can print garbage.
Is it really that important? I am asking because sometime people
think that it is not safe to use ->comm lockless, but this is not
true.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
