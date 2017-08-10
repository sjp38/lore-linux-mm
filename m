Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 725F16B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 14:51:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w63so2124015wrc.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 11:51:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61si5689324wrf.313.2017.08.10.11.51.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 11:51:42 -0700 (PDT)
Date: Thu, 10 Aug 2017 20:51:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170810185138.GA8269@dhcp22.suse.cz>
References: <20170810081632.31265-1-mhocko@kernel.org>
 <20170810180554.GT25347@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810180554.GT25347@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 10-08-17 20:05:54, Andrea Arcangeli wrote:
> On Thu, Aug 10, 2017 at 10:16:32AM +0200, Michal Hocko wrote:
> > Andrea has proposed and alternative solution [4] which should be
> > equivalent functionally similar to {ksm,khugepaged}_exit. I have to
> > confess I really don't like that approach but I can live with it if
> > that is a preferred way (to be honest I would like to drop the empty
> 
> Well you added two branches, when only one is necessary. It's more or
> less like preferring a rwsem when a mutex is enough, because you're
> more used to use rwsems.
> 
> > down_write();up_write() from the other two callers as well). In fact I
> > have asked Andrea to post his patch [5] but that hasn't happened. I do
> > not think we should wait much longer and finally merge some fix. 
> 
> It's posted in [4] already below I didn't think it was necessary to
> resend it.

it was deep in the email thread and I've asked you explicitly to repost
which I've done for the same reason.

> The only other improvement I can think of is an unlikely
> around tsk_is_oom_victim() in exit_mmap, but your patch below would
> need it too, and two of them.

with
diff --git a/mm/mmap.c b/mm/mmap.c
index 822e8860b9d2..9d4a5a488f72 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3002,7 +3002,7 @@ void exit_mmap(struct mm_struct *mm)
 	 * with tsk->mm != NULL checked on !current tasks which synchronizes
 	 * with exit_mm and so we cannot race here.
 	 */
-	if (tsk_is_oom_victim(current)) {
+	if (unlikely(tsk_is_oom_victim(current))) {
 		down_write(&mm->mmap_sem);
 		locked = true;
 	}
@@ -3020,7 +3020,7 @@ void exit_mmap(struct mm_struct *mm)
 	}
 	mm->mmap = NULL;
 	vm_unacct_memory(nr_accounted);
-	if (locked)
+	if (unlikely(locked))
 		up_write(&mm->mmap_sem);
 }
 
The generated code is identical. But I do not have any objection of
course.

> > [1] http://lkml.kernel.org/r/20170724072332.31903-1-mhocko@kernel.org
> > [2] http://lkml.kernel.org/r/20170725142626.GJ26723@dhcp22.suse.cz
> > [3] http://lkml.kernel.org/r/20170725160359.GO26723@dhcp22.suse.cz
> > [4] http://lkml.kernel.org/r/20170726162912.GA29716@redhat.com
> > [5] http://lkml.kernel.org/r/20170728062345.GA2274@dhcp22.suse.cz
> > 
> > +	if (tsk_is_oom_victim(current)) {
> > +		down_write(&mm->mmap_sem);
> > +		locked = true;
> > +	}
> >  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  
> > @@ -3005,7 +3018,10 @@ void exit_mmap(struct mm_struct *mm)
> >  			nr_accounted += vma_pages(vma);
> >  		vma = remove_vma(vma);
> >  	}
> > +	mm->mmap = NULL;
> >  	vm_unacct_memory(nr_accounted);
> > +	if (locked)
> > +		up_write(&mm->mmap_sem);
> 
> I wouldn't normally repost to add an unlikely when I'm not sure if it
> gets merged, but if it gets merged I would immediately tell to Andrew
> about the microoptimization being missing there so he can fold it
> later.
> 
> Before reposting about the unlikely I thought we should agree which
> version to merge: [4] or the above double branch (for no good as far
> as I tangibly can tell).
> 
> I think down_write;up_write is the correct thing to do here because
> holding the lock for any additional instruction has zero benefits, and
> if it has zero benefits it only adds up confusion and makes the code
> partly senseless, and that ultimately hurts the reader when it tries
> to understand why you're holding the lock for so long when it's not
> needed.

OK, let's agree to disagree. As I've said I like when the critical
section is explicit and we _know_ what it protects. In this case it is
clear that we have to protect from the page tables tear down and the
vma destructions. But as I've said I am not going to argue about this
more. It is more important to finally fix this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
