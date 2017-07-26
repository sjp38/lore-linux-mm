Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 519216B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:29:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p48so47676776qtf.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:29:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m21si14086551qkm.345.2017.07.26.09.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 09:29:16 -0700 (PDT)
Date: Wed, 26 Jul 2017 18:29:12 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170726162912.GA29716@redhat.com>
References: <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
 <20170725160359.GO26723@dhcp22.suse.cz>
 <20170725191952.GR29716@redhat.com>
 <20170726054557.GB960@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726054557.GB960@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 26, 2017 at 07:45:57AM +0200, Michal Hocko wrote:
> On Tue 25-07-17 21:19:52, Andrea Arcangeli wrote:
> > On Tue, Jul 25, 2017 at 06:04:00PM +0200, Michal Hocko wrote:
> > > -	down_write(&mm->mmap_sem);
> > > +	if (tsk_is_oom_victim(current))
> > > +		down_write(&mm->mmap_sem);
> > >  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> > >  	tlb_finish_mmu(&tlb, 0, -1);
> > >  
> > > @@ -3012,7 +3014,8 @@ void exit_mmap(struct mm_struct *mm)
> > >  	}
> > >  	mm->mmap = NULL;
> > >  	vm_unacct_memory(nr_accounted);
> > > -	up_write(&mm->mmap_sem);
> > > +	if (tsk_is_oom_victim(current))
> > > +		up_write(&mm->mmap_sem);
> > 
> > How is this possibly safe? mark_oom_victim can run while exit_mmap is
> > running.
> 
> I believe it cannot. We always call mark_oom_victim (on !current) with
> task_lock held and check task->mm != NULL and we call do_exit->mmput after
> mm is set to NULL under the same lock.

Holding the mmap_sem for writing and setting mm->mmap to NULL to
filter which tasks already released the mmap_sem for writing post
free_pgtables still look unnecessary to solve this.

Using MMF_OOM_SKIP as flag had side effects of oom_badness() skipping
it, but we can use the same tsk_is_oom_victim instead and relay on the
locking in mark_oom_victim you pointed out above instead of the
test_and_set_bit of my patch, because current->mm is already NULL at
that point.

A race at the light of the above now is, because current->mm is NULL by the
time mmput is called, how can you start the oom_reap_task on a process
with current->mm NULL that called the last mmput and is blocked
in exit_aio? It looks like no false positive can get fixed until this
is solved first because 

Isn't this enough? If this is enough it avoids other modification to
the exit_mmap runtime that looks unnecessary: mm->mmap = NULL replaced
by MMF_OOM_SKIP that has to be set anyway by __mmput later and one
unnecessary branch to call the up_write.
