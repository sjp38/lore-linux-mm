Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id F31B36B0259
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 14:48:23 -0400 (EDT)
Received: by iofh134 with SMTP id h134so232903834iof.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 11:48:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si14485363igx.98.2015.10.06.11.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 11:48:23 -0700 (PDT)
Date: Tue, 6 Oct 2015 20:45:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151006184502.GA15787@redhat.com>
References: <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com> <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com> <20150921161203.GD19811@dhcp22.suse.cz> <20150922160608.GA2716@redhat.com> <20150923205923.GB19054@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923205923.GB19054@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

Damn. I can't believe this, but I still can't make the initial change.
And no, it is not that I hit some technical problems, just I can't
decide what exactly the first step should do to be a) really simple
and b) useful. I am starting to think I'll just update my draft patch
which uses queue_work() and send it tomorrow (yes, tomorrow again ;).

But let me at least answer this email,

On 09/23, Michal Hocko wrote:
>
> On Tue 22-09-15 18:06:08, Oleg Nesterov wrote:
> >
> > OK, let it be a kthread from the very beginning, I won't argue. This
> > is really minor compared to other problems.
>
> I am still not sure how you want to implement that kernel thread but I
> am quite skeptical it would be very much useful because all the current
> allocations which end up in the OOM killer path cannot simply back off
> and drop the locks with the current allocator semantic.  So they will
> be sitting on top of unknown pile of locks whether you do an additional
> reclaim (unmap the anon memory) in the direct OOM context or looping
> in the allocator and waiting for kthread/workqueue to do its work. The
> only argument that I can see is the stack usage but I haven't seen stack
> overflows in the OOM path AFAIR.

Please see below,

> > And note that the caller can held other locks we do not even know about.
> > Most probably we should not deadlock, at least if we only unmap the anon
> > pages, but still this doesn't look safe.
>
> The unmapper cannot fall back to reclaim and/or trigger the OOM so
> we should be indeed very careful and mark the allocation context
> appropriately. I can remember mmu_gather but it is only doing
> opportunistic allocation AFAIR.

And I was going to make V1 which avoids queue_work/kthread and zaps the
memory in oom_kill_process() context.

But this can't work because we need to increment ->mm_users to avoid
the race with exit_mmap/etc. And this means that we need mmput() after
that, and as we recently discussed it can deadlock if mm_users goes
to zero, we can't do exit_mmap/etc in oom_kill_process().

> > Hmm. If we already have mmap_sem and started zap_page_range() then
> > I do not think it makes sense to stop until we free everything we can.
>
> Zapping a huge address space can take quite some time

Yes, and this is another reason we should do this asynchronously.

> and we really do
> not have to free it all on behalf of the killer when enough memory is
> freed to allow for further progress and the rest can be done by the
> victim. If one batch doesn't seem sufficient then another retry can
> continue.
>
> I do not think that a limited scan would make the implementation more
> complicated

But we can't even know much memory unmap_single_vma() actually frees.
Even if we could, how can we know we freed enough?

Anyway. Perhaps it makes sense to abort the for_each_vma() loop if
freed_enough_mem() == T. But it is absolutely not clear to me how we
should define this freed_enough_mem(), so I think we should do this
later.

> > But. Can't we just remove another ->oom_score_adj check when we try
> > to kill all mm users (the last for_each_process loop). If yes, this
> > all can be simplified.
> >
> > I guess we can't and its a pity. Because it looks simply pointless
> > to not kill all mm users. This just means the select_bad_process()
> > picked the wrong task.
>
> Yes I am not really sure why oom_score_adj is not per-mm and we are
> doing that per signal struct to be honest.

Heh ;) Yes, but I guess it is too late to move it back.

> Maybe we can revisit this...

I hope, but I am not going to try to remove this OOM_SCORE_ADJ_MIN
check now. Just we should not zap this mm if we find the OOM-unkillable
user.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
