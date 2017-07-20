Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA516B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:05:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s79so2684261wma.15
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:05:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v194si1611950wmv.209.2017.07.20.06.05.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:05:43 -0700 (PDT)
Date: Thu, 20 Jul 2017 15:05:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170720130541.GH9058@dhcp22.suse.cz>
References: <20170626130346.26314-1-mhocko@kernel.org>
 <20170629084621.GE31603@dhcp22.suse.cz>
 <20170719055542.GA22162@dhcp22.suse.cz>
 <alpine.LSU.2.11.1707191716030.2055@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1707191716030.2055@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <andrea@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 19-07-17 18:18:27, Hugh Dickins wrote:
> On Wed, 19 Jul 2017, Michal Hocko wrote:
> > On Thu 29-06-17 10:46:21, Michal Hocko wrote:
> > > Forgot to CC Hugh.
> > > 
> > > Hugh, Andrew, do you see this could cause any problem wrt.
> > > ksm/khugepaged exit path?
> > 
> > ping. I would really appreciate some help here. I would like to resend
> > the patch soon.
> 
> Sorry, Michal, I've been hiding from everyone.
> 
> No, I don't think your patch will cause any trouble for the ksm or
> khugepaged exit path; but we'll find out for sure when akpm puts it
> in mmotm - I doubt I'll get to trying it out in advance of that.
> 
> On the contrary, I think it will allow us to remove the peculiar
> "down_write(mmap_sem); up_write(mmap_sem);" from those exit paths:
> which were there to serialize, precisely because exit_mmap() did
> not otherwise take mmap_sem; but you're now changing it to do so.

I was actually suspecting this could be done but didn't get to study the
code to be sure enough, your words are surely encouraging...

> You could add a patch to remove those yourself, or any of us add
> that on afterwards.

I will add it on my todo list and let's see when I get there.
 
> But I don't entirely agree (or disagree) with your placement:
> see comment below.
[...]
> > > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > > index 3bd5ecd20d4d..253808e716dc 100644
> > > > --- a/mm/mmap.c
> > > > +++ b/mm/mmap.c
> > > > @@ -2962,6 +2962,11 @@ void exit_mmap(struct mm_struct *mm)
> > > >  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> > > >  	unmap_vmas(&tlb, vma, 0, -1);
> > > >  
> > > > +	/*
> > > > +	 * oom reaper might race with exit_mmap so make sure we won't free
> > > > +	 * page tables or unmap VMAs under its feet
> > > > +	 */
> > > > +	down_write(&mm->mmap_sem);
> 
> Hmm.  I'm conflicted about this.  From a design point of view, I would
> very much prefer you to take the mmap_sem higher up, maybe just before
> or after the mmu_notifier_release() or arch_exit_mmap() (depends on
> what those actually do): anyway before the unmap_vmas().

This thing is that I _want_ unmap_vmas to race with the oom reaper so I
cannot take the write log before unmap_vmas... If this whole area should
be covered by the write lock then I would need a handshake mechanism
between the oom reaper and the final unmap_vmas to know that oom reaper
won't set MMF_OOM_SKIP prematurely (see more on that below).

> Because the things which go on in exit_mmap() are things which we expect
> mmap_sem to be held across, and we get caught out when it is not: it's
> awkard and error-prone enough that MADV_DONTNEED and MADV_FREE (for
> very good reason) do things with only down_read(mmap_sem).  But there's
> a number of times (ksm exit being only one of them) when I've found it
> a nuisance that we had no proper way of serializing against exit_mmap().
> 
> I'm conflicted because, on the other hand, I'm staunchly against adding
> obstructions ("robust" futexes? gah!) into the exit patch, or widening
> the use of locks that are not strictly needed.  But wouldn't it be the
> case here, that most contenders on the mmap_sem must hold a reference
> to mm_users, and that prevents any possibility of racing exit_mmap();
> only ksm and khugepaged, and any others who already need such mmap_sem
> tricks to serialize against exit_mmap(), could offer any contention.
> 
> But I haven't looked at the oom_kill or oom_reaper end of it at all,
> perhaps you have an overriding argument on the placement from that end.

Well, the main problem here is that the oom_reaper tries to
MADV_DONTNEED the oom victim and then hide it from the oom killer (by
setting MMF_OOM_SKIP) to guarantee a forward progress. In order to do
that it needs mmap_sem for read. Currently we try to avoid races with
the eixt path by checking mm->mm_users and that can lead to premature
MMF_OOM_SKIP and that in turn to additional oom victim(s) selection
while the current one is still tearing the address space down.

One way around that is to allow final unmap race with the oom_reaper
tear down.

I hope this clarify the motivation

> Hugh
> 
> [Not strictly relevant here, but a related note: I was very surprised
> to discover, only quite recently, how handle_mm_fault() may be called
> without down_read(mmap_sem) - when core dumping.  That seems a
> misguided optimization to me, which would also be nice to correct;
> but again I might not appreciate the full picture.]

shrug
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
