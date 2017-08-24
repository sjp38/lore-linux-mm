Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F80B440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:59:39 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t3so109063pgt.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:59:39 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i128si3132176pfg.54.2017.08.24.09.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:59:37 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id a7so42801pgn.4
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:59:37 -0700 (PDT)
Date: Thu, 24 Aug 2017 09:59:35 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fork: fix incorrect fput of ->exe_file causing
 use-after-free
Message-ID: <20170824165935.GA21624@gmail.com>
References: <20170823211408.31198-1-ebiggers3@gmail.com>
 <20170824132041.GA22882@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824132041.GA22882@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>

On Thu, Aug 24, 2017 at 03:20:41PM +0200, Oleg Nesterov wrote:
> On 08/23, Eric Biggers wrote:
> >
> > From: Eric Biggers <ebiggers@google.com>
> >
> > Commit 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for
> > write killable") made it possible to kill a forking task while it is
> > waiting to acquire its ->mmap_sem for write, in dup_mmap().  However, it
> > was overlooked that this introduced an new error path before a reference
> > is taken on the mm_struct's ->exe_file.
> 
> Hmm. Unless I am totally confused, the same problem with mm->exol_area?
> I'll recheck....

I'm not sure what you mean by ->exol_area.

> 
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -806,6 +806,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
> >  	mm_init_cpumask(mm);
> >  	mm_init_aio(mm);
> >  	mm_init_owner(mm, p);
> > +	RCU_INIT_POINTER(mm->exe_file, NULL);
> 
> Can't we simply move
> 
> 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
> 
> from dup_mmap() here? Afaics this doesn't need mmap_sem.
> 

Two problems, even assuming that get_mm_exe_file() doesn't require mmap_sem:

- If mm_alloc_pgd() or init_new_context() in mm_init() fails, mm_init() doesn't
  do the full mmput(), so the file reference would not be dropped.  So it would
  need to be changed to drop the file reference too.

- The file would also be set when called from mm_alloc() which is used when
  exec'ing a new task.  *Maybe* it would be safe to do temporarily, but it's
  pointless because ->exe_file will be set later by flush_old_exec().

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
