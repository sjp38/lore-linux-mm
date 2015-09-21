Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 693F56B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:12:07 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so122935927wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:12:06 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id ma1si32194249wjb.20.2015.09.21.09.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:12:06 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so118854074wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:12:05 -0700 (PDT)
Date: Mon, 21 Sep 2015 18:12:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150921161203.GD19811@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
 <20150920125642.GA2104@redhat.com>
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com>
 <20150921142423.GC19811@dhcp22.suse.cz>
 <20150921153252.GA21988@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921153252.GA21988@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Mon 21-09-15 17:32:52, Oleg Nesterov wrote:
> On 09/21, Michal Hocko wrote:
> >
> > On Mon 21-09-15 15:44:14, Oleg Nesterov wrote:
> > [...]
> > > So yes, in general oom_kill_process() can't call oom_unmap_func() directly.
> > > That is why the patch uses queue_work(oom_unmap_func). The workqueue thread
> > > takes mmap_sem and frees the memory allocated by user space.
> >
> > OK, this might have been a bit confusing. I didn't mean you cannot use
> > mmap_sem directly from the workqueue context. You _can_ AFAICS. But I've
> > mentioned that you _shouldn't_ use workqueue context in the first place
> > because all the workers might be blocked on locks and new workers cannot
> > be created due to memory pressure.
> 
> Yes, yes, and I already tried to comment this part.

OK then we are on the same page, good.

> We probably need a
> dedicated kernel thread, but I still think (although I am not sure) that
> initial change can use workueue. In the likely case system_unbound_wq pool
> should have an idle thread, if not - OK, this change won't help in this
> case. This is minor.

The point is that the implementation should be robust from the very
beginning. I am not sure what you mean by the idle thread here but the
rescuer can get stuck the very same way other workers. So I think that
we cannot rely on WQ for a real solution here.

> > So I think we probably need to do this in the OOM killer context (with
> > try_lock)
> 
> Yes we should try to do this in the OOM killer context, and in this case
> (of course) we need trylock. Let me quote my previous email:
> 
> 	And we want to avoid using workqueues when the caller can do this
> 	directly. And in this case we certainly need trylock. But this needs
> 	some refactoring: we do not want to do this under oom_lock,

Why do you think oom_lock would be a big deal? Address space of the
victim might be really large but we can back off after a batch of
unmapped pages.

>       otoh it
> 	makes sense to do this from mark_oom_victim() if current && killed,
> 	and a lot more details.
> 
> and probably this is another reason why do we need MMF_MEMDIE. But again,
> I think the initial change should be simple.

I definitely agree with the simplicity for the first iteration. That
means only unmap private exclusive pages and release at most few megs of
them. I am still not sure about some details, e.g. futex sitting in such
a memory. Wouldn't threads blow up when they see an unmapped futex page,
try to page it in and it would be in an uninitialized state? Maybe this
is safe because they will die anyway but I am not familiar with that
code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
