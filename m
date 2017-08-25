Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8A9B6810B7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 06:50:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q16so10005089pgc.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 03:50:59 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t77si4531955pfi.40.2017.08.25.03.50.58
        for <linux-mm@kvack.org>;
        Fri, 25 Aug 2017 03:50:58 -0700 (PDT)
Date: Fri, 25 Aug 2017 11:49:42 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] fork: fix incorrect fput of ->exe_file causing
 use-after-free
Message-ID: <20170825104941.GC3127@leverpostej>
References: <20170823211408.31198-1-ebiggers3@gmail.com>
 <20170824150110.GA29665@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824150110.GA29665@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>

On Thu, Aug 24, 2017 at 04:02:49PM +0100, Mark Rutland wrote:
> On Wed, Aug 23, 2017 at 02:14:08PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Commit 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for
> > write killable") made it possible to kill a forking task while it is
> > waiting to acquire its ->mmap_sem for write, in dup_mmap().  However, it
> > was overlooked that this introduced an new error path before a reference
> > is taken on the mm_struct's ->exe_file.  Since the ->exe_file of the new
> > mm_struct was already set to the old ->exe_file by the memcpy() in
> > dup_mm(), it was possible for the mmput() in the error path of dup_mm()
> > to drop a reference to ->exe_file which was never taken.  This caused
> > the struct file to later be freed prematurely.
> > 
> > Fix it by updating mm_init() to NULL out the ->exe_file, in the same
> > place it clears other things like the list of mmaps.
> 
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index e075b7780421..cbbea277b3fb 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -806,6 +806,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> >  	mm_init_cpumask(mm);
> >  	mm_init_aio(mm);
> >  	mm_init_owner(mm, p);
> > +	RCU_INIT_POINTER(mm->exe_file, NULL);
> >  	mmu_notifier_mm_init(mm);
> >  	init_tlb_flush_pending(mm);
> >  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> 
> I've been seeing similar issues on arm64 with use-after-free of a file
> and other memory corruption [1].
> 
> This patch seems to fix that; a test that normally fired in a few
> minutes has been happily running for hours with this applied.

Those haven't triggered after 24 hours, and in 16+ hours of fuzzing with
this applied, I haven't seen new issues. FWIW:

Tested-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
