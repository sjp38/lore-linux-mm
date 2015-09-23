Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 947D96B0254
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 16:59:27 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so225419064wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 13:59:27 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id fa4si3463805wib.45.2015.09.23.13.59.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 13:59:26 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so1992603wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 13:59:26 -0700 (PDT)
Date: Wed, 23 Sep 2015 22:59:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150923205923.GB19054@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
 <20150920125642.GA2104@redhat.com>
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com>
 <20150921142423.GC19811@dhcp22.suse.cz>
 <20150921153252.GA21988@redhat.com>
 <20150921161203.GD19811@dhcp22.suse.cz>
 <20150922160608.GA2716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150922160608.GA2716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue 22-09-15 18:06:08, Oleg Nesterov wrote:
> On 09/21, Michal Hocko wrote:
> >
> > On Mon 21-09-15 17:32:52, Oleg Nesterov wrote:
[...]
> > > We probably need a
> > > dedicated kernel thread, but I still think (although I am not sure) that
> > > initial change can use workueue. In the likely case system_unbound_wq pool
> > > should have an idle thread, if not - OK, this change won't help in this
> > > case. This is minor.
> >
> > The point is that the implementation should be robust from the very
> > beginning.
> 
> OK, let it be a kthread from the very beginning, I won't argue. This
> is really minor compared to other problems.

I am still not sure how you want to implement that kernel thread but I
am quite skeptical it would be very much useful because all the current
allocations which end up in the OOM killer path cannot simply back off
and drop the locks with the current allocator semantic.  So they will
be sitting on top of unknown pile of locks whether you do an additional
reclaim (unmap the anon memory) in the direct OOM context or looping
in the allocator and waiting for kthread/workqueue to do its work. The
only argument that I can see is the stack usage but I haven't seen stack
overflows in the OOM path AFAIR.

> > > > So I think we probably need to do this in the OOM killer context (with
> > > > try_lock)
> > >
> > > Yes we should try to do this in the OOM killer context, and in this case
> > > (of course) we need trylock. Let me quote my previous email:
> > >
> > > 	And we want to avoid using workqueues when the caller can do this
> > > 	directly. And in this case we certainly need trylock. But this needs
> > > 	some refactoring: we do not want to do this under oom_lock,
> >
> > Why do you think oom_lock would be a big deal?
> 
> I don't really know... This doesn't look sane to me, but perhaps this
> is just because I don't understand this code enough.

Well one of the purpose of this lock is to throttle all the concurrent
allocators to not step on each other toes because only one task is
allowed to get killed currently. So they wouldn't be any useful anyway.

> And note that the caller can held other locks we do not even know about.
> Most probably we should not deadlock, at least if we only unmap the anon
> pages, but still this doesn't look safe.

The unmapper cannot fall back to reclaim and/or trigger the OOM so
we should be indeed very careful and mark the allocation context
appropriately. I can remember mmu_gather but it is only doing
opportunistic allocation AFAIR.

> But I agree, this probably needs more discussion.
> 
> > Address space of the
> > victim might be really large but we can back off after a batch of
> > unmapped pages.
> 
> Hmm. If we already have mmap_sem and started zap_page_range() then
> I do not think it makes sense to stop until we free everything we can.

Zapping a huge address space can take quite some time and we really do
not have to free it all on behalf of the killer when enough memory is
freed to allow for further progress and the rest can be done by the
victim. If one batch doesn't seem sufficient then another retry can
continue.

I do not think that a limited scan would make the implementation more
complicated but I will leave the decision to you of course.

> > I definitely agree with the simplicity for the first iteration. That
> > means only unmap private exclusive pages and release at most few megs of
> > them.
> 
> See above, I am not sure this makes sense. And in any case this will
> complicate the initial changes, not simplify.
> 
> > I am still not sure about some details, e.g. futex sitting in such
> > a memory. Wouldn't threads blow up when they see an unmapped futex page,
> > try to page it in and it would be in an uninitialized state? Maybe this
> > is safe
> 
> But this must be safe.
> 
> We do not care about userspace (assuming that all mm users have a
> pending SIGKILL).
> 
> If this can (say) crash the kernel somehow, then we have a bug which
> should be fixed. Simply because userspace can exploit this bug doing
> MADV_DONTEED from another thread or CLONE_VM process.

OK, that makes perfect sense. I should have realized that an in-kernel
state for a futex must not be controlled from the userspace. So you are
right and futex shouldn't be a big deal.

> Finally. Whatever we do, we need to change oom_kill_process() first,
> and I think we should do this regardless. The "Kill all user processes
> sharing victim->mm" logic looks wrong and suboptimal/overcomplicated.
> I'll try to make some patches tomorrow if I have time...

That would be appreciated. I do not like that part either. At least we
shouldn't go over the whole list when we have a good chance that the mm
is not shared with other processes.

> But. Can't we just remove another ->oom_score_adj check when we try
> to kill all mm users (the last for_each_process loop). If yes, this
> all can be simplified.
> 
> I guess we can't and its a pity. Because it looks simply pointless
> to not kill all mm users. This just means the select_bad_process()
> picked the wrong task.

Yes I am not really sure why oom_score_adj is not per-mm and we are
doing that per signal struct to be honest. It doesn't make much sense as
the mm_struct is the primary source of information for the oom victim
selection. And the fact that mm might be shared withtout sharing signals
make it double the reason to have it in mm.

It seems David has already tried that 2ff05b2b4eac ("oom: move oom_adj
value from task_struct to mm_struct") but it was later reverted by
0753ba01e126 ("mm: revert "oom: move oom_adj value""). I do not agree
with the reasoning there because vfork is documented to have undefined
behavior
"
       if the process created by vfork() either modifies any data other
       than a variable of type pid_t used to store the return value
       from vfork(), or returns from the function in which vfork() was
       called, or calls any other function before successfully calling
       _exit(2) or one of the exec(3) family of functions.
"
Maybe we can revisit this... It would make the whole semantic much more
straightforward. The current situation when you kill a task which might
share the mm with OOM unkillable task is clearly suboptimal and
confusing.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
