Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB57D6B02F3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:46:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v31so30602353wrc.7
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 22:46:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si12768512wrb.494.2017.07.25.22.45.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 22:45:59 -0700 (PDT)
Date: Wed, 26 Jul 2017 07:45:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170726054557.GB960@dhcp22.suse.cz>
References: <20170724140008.sd2n6af6izjyjtda@node.shutemov.name>
 <20170724141526.GM25221@dhcp22.suse.cz>
 <20170724145142.i5xqpie3joyxbnck@node.shutemov.name>
 <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
 <20170725160359.GO26723@dhcp22.suse.cz>
 <20170725191952.GR29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725191952.GR29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 21:19:52, Andrea Arcangeli wrote:
> On Tue, Jul 25, 2017 at 06:04:00PM +0200, Michal Hocko wrote:
> > -	down_write(&mm->mmap_sem);
> > +	if (tsk_is_oom_victim(current))
> > +		down_write(&mm->mmap_sem);
> >  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  
> > @@ -3012,7 +3014,8 @@ void exit_mmap(struct mm_struct *mm)
> >  	}
> >  	mm->mmap = NULL;
> >  	vm_unacct_memory(nr_accounted);
> > -	up_write(&mm->mmap_sem);
> > +	if (tsk_is_oom_victim(current))
> > +		up_write(&mm->mmap_sem);
> 
> How is this possibly safe? mark_oom_victim can run while exit_mmap is
> running.

I believe it cannot. We always call mark_oom_victim (on !current) with
task_lock held and check task->mm != NULL and we call do_exit->mmput after
mm is set to NULL under the same lock.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
