Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1EE36B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:50:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so25889062wrb.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:50:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b31si18502844wrd.66.2017.07.26.23.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 23:50:27 -0700 (PDT)
Date: Thu, 27 Jul 2017 08:50:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170727065023.GB20970@dhcp22.suse.cz>
References: <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
 <20170725160359.GO26723@dhcp22.suse.cz>
 <20170725191952.GR29716@redhat.com>
 <20170726054557.GB960@dhcp22.suse.cz>
 <20170726162912.GA29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726162912.GA29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 26-07-17 18:29:12, Andrea Arcangeli wrote:
> On Wed, Jul 26, 2017 at 07:45:57AM +0200, Michal Hocko wrote:
> > On Tue 25-07-17 21:19:52, Andrea Arcangeli wrote:
> > > On Tue, Jul 25, 2017 at 06:04:00PM +0200, Michal Hocko wrote:
> > > > -	down_write(&mm->mmap_sem);
> > > > +	if (tsk_is_oom_victim(current))
> > > > +		down_write(&mm->mmap_sem);
> > > >  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> > > >  	tlb_finish_mmu(&tlb, 0, -1);
> > > >  
> > > > @@ -3012,7 +3014,8 @@ void exit_mmap(struct mm_struct *mm)
> > > >  	}
> > > >  	mm->mmap = NULL;
> > > >  	vm_unacct_memory(nr_accounted);
> > > > -	up_write(&mm->mmap_sem);
> > > > +	if (tsk_is_oom_victim(current))
> > > > +		up_write(&mm->mmap_sem);
> > > 
> > > How is this possibly safe? mark_oom_victim can run while exit_mmap is
> > > running.
> > 
> > I believe it cannot. We always call mark_oom_victim (on !current) with
> > task_lock held and check task->mm != NULL and we call do_exit->mmput after
> > mm is set to NULL under the same lock.
> 
> Holding the mmap_sem for writing and setting mm->mmap to NULL to
> filter which tasks already released the mmap_sem for writing post
> free_pgtables still look unnecessary to solve this.
> 
> Using MMF_OOM_SKIP as flag had side effects of oom_badness() skipping
> it, but we can use the same tsk_is_oom_victim instead and relay on the
> locking in mark_oom_victim you pointed out above instead of the
> test_and_set_bit of my patch, because current->mm is already NULL at
> that point.
> 
> A race at the light of the above now is, because current->mm is NULL by the
> time mmput is called, how can you start the oom_reap_task on a process
> with current->mm NULL that called the last mmput and is blocked
> in exit_aio?

Because we have that mm available. See tsk->signal->oom_mm in
oom_reap_task

> It looks like no false positive can get fixed until this
> is solved first because 
> 
> Isn't this enough? If this is enough it avoids other modification to
> the exit_mmap runtime that looks unnecessary: mm->mmap = NULL replaced
> by MMF_OOM_SKIP that has to be set anyway by __mmput later and one
> unnecessary branch to call the up_write.
> 
[...]
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f19efcf75418..bdab595ce25c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2993,6 +2993,23 @@ void exit_mmap(struct mm_struct *mm)
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
> +	set_bit(MMF_OOM_SKIP, &mm->flags);
> +	if (tsk_is_oom_victim(current)) {
> +		/*
> +		 * Wait for oom_reap_task() to stop working on this
> +		 * mm. Because MMF_OOM_SKIP is already set before
> +		 * calling down_read(), oom_reap_task() will not run
> +		 * on this "mm" post up_write().
> +		 *
> +		 * tsk_is_oom_victim() cannot be set from under us
> +		 * either because current->mm is already set to NULL
> +		 * under task_lock before calling mmput and oom_mm is
> +		 * set not NULL by the OOM killer only if current->mm
> +		 * is found not NULL while holding the task_lock.
> +		 */
> +		down_write(&mm->mmap_sem);
> +		up_write(&mm->mmap_sem);
> +	}
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);

Yes this will work and it won't depend on the oom_lock. But isn't it
just more ugly than simply doing

	if (tsk_is_oom_victim) {
		down_write(&mm->mmap_sem);
		locked = true;
	}
	free_pgtables(...)
	[...]
	if (locked)
		down_up(&mm->mmap_sem);

in general I do not like empty locked sections much, to be honest. Now
with the conditional locking my patch looks as follows. It should be
pretty much equivalent to your patch. Would that be acceptable for you
or do you think there is a strong reason to go with yours?
---
