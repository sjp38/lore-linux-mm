Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD3876810B7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 10:40:41 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q7so41358qta.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 07:40:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o2si6082863qkc.93.2017.08.25.07.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 07:40:40 -0700 (PDT)
Date: Fri, 25 Aug 2017 16:40:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] fork: fix incorrect fput of ->exe_file causing
 use-after-free
Message-ID: <20170825144036.GA26620@redhat.com>
References: <20170823211408.31198-1-ebiggers3@gmail.com>
 <20170824132041.GA22882@redhat.com>
 <20170824165935.GA21624@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824165935.GA21624@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>

On 08/24, Eric Biggers wrote:
>
> On Thu, Aug 24, 2017 at 03:20:41PM +0200, Oleg Nesterov wrote:
> > On 08/23, Eric Biggers wrote:
> > >
> > > From: Eric Biggers <ebiggers@google.com>
> > >
> > > Commit 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for
> > > write killable") made it possible to kill a forking task while it is
> > > waiting to acquire its ->mmap_sem for write, in dup_mmap().  However, it
> > > was overlooked that this introduced an new error path before a reference
> > > is taken on the mm_struct's ->exe_file.
> >
> > Hmm. Unless I am totally confused, the same problem with mm->exol_area?
> > I'll recheck....
>
> I'm not sure what you mean by ->exol_area.

I meant mm->uprobes_state.xol_area, sorry

> > > --- a/kernel/fork.c
> > > +++ b/kernel/fork.c
> > > @@ -806,6 +806,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> > >  	mm_init_cpumask(mm);
> > >  	mm_init_aio(mm);
> > >  	mm_init_owner(mm, p);
> > > +	RCU_INIT_POINTER(mm->exe_file, NULL);
> > 
> > Can't we simply move
> > 
> > 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
> > 
> > from dup_mmap() here? Afaics this doesn't need mmap_sem.
> > 
> 
> Two problems, even assuming that get_mm_exe_file() doesn't require mmap_sem:
> 
> - If mm_alloc_pgd() or init_new_context() in mm_init() fails, mm_init() doesn't
>   do the full mmput(), so the file reference would not be dropped.  So it would
>   need to be changed to drop the file reference too.

Ah yes, I forgot that mm_init() can fail after that, thanks for correcting me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
