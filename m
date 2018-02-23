Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0826B0025
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:28:17 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so3193814plo.11
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:28:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor374535pgp.16.2018.02.22.18.28.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 18:28:16 -0800 (PST)
Date: Fri, 23 Feb 2018 11:28:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Synchronize task mm counters on demand
Message-ID: <20180223022810.GB115990@rodete-desktop-imager.corp.google.com>
References: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <20180222024620.47691-1-dancol@google.com>
 <20180223020130.GA115990@rodete-desktop-imager.corp.google.com>
 <CAKOZuesZPy8rgo_pPy=cUtGcGhLzCq4X46ns7h7ta7ihrJSPWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesZPy8rgo_pPy=cUtGcGhLzCq4X46ns7h7ta7ihrJSPWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Thu, Feb 22, 2018 at 06:09:17PM -0800, Daniel Colascione wrote:
> Thanks for taking a look.
> 
> On Feb 22, 2018 6:01 PM, "Minchan Kim" <minchan@kernel.org> wrote:
> 
> Hi Daniel,
> 
> On Wed, Feb 21, 2018 at 06:46:20PM -0800, Daniel Colascione wrote:
> > When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
> > generally speaking), we buffer certain changes to mm-wide counters
> > through counters local to the current struct task, flushing them to
> > the mm after seeing 64 page faults, as well as on task exit and
> > exec. This scheme can leave a large amount of memory unaccounted-for
> > in process memory counters, especially for processes with many threads
> > (each of which gets 64 "free" faults), and it produces an
> > inconsistency with the same memory counters scanned VMA-by-VMA using
> > smaps. This inconsistency can persist for an arbitrarily long time,
> > since there is no way to force a task to flush its counters to its mm.
> >
> > This patch flushes counters on get_mm_counter. This way, readers
> > always have an up-to-date view of the counters for a particular
> > task. It adds a spinlock-acquire to the add_mm_counter_fast path, but
> > this spinlock should almost always be uncontended.
> >
> > Signed-off-by: Daniel Colascione <dancol@google.com>
> > ---
> >  fs/proc/task_mmu.c            |  2 +-
> >  include/linux/mm.h            | 16 ++++++++-
> >  include/linux/mm_types_task.h | 13 +++++--
> >  kernel/fork.c                 |  1 +
> >  mm/memory.c                   | 64 ++++++++++++++++++++++-------------
> >  5 files changed, 67 insertions(+), 29 deletions(-)
> >
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index ec6d2983a5cb..ac9e86452ca4 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -852,7 +852,7 @@ static int show_smap(struct seq_file *m, void *v, int
> is_pid)
> >                          mss->private_hugetlb >> 10,
> >                          mss->swap >> 10,
> >                          (unsigned long)(mss->swap_pss >> (10 +
> PSS_SHIFT)),
> > -                        (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
> > +                        (unsigned long)(mss->pss_locked >> (10 +
> PSS_SHIFT)));
> 
> It seems you mixed with other patch.
> 
> 
> Yep.

Plese don't include things not related to this patch.
Furthermore, please use plain-text mail client.
You mangled all of text. It makes communication hard in LKML.

> 
> 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index ad06d42adb1a..f8129afebbdd 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struct
> *vma,
> >   */
> >  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >                         struct page **pages);
> > +
> > +#ifdef SPLIT_RSS_COUNTING
> > +/* Flush all task-buffered MM counters to the mm */
> > +void sync_mm_rss_all_users(struct mm_struct *mm);
> 
> Really heavy functioin iterates all of processes and threads.
> 
> 
> Just all processes and the threads of each process attached to the mm.
> Maybe that's not much better.
> 
> 
> > +#endif
> > +
> >  /*
> >   * per-process(per-mm_struct) statistics.
> >   */
> >  static inline unsigned long get_mm_counter(struct mm_struct *mm, int
> member)
> >  {
> > -     long val = atomic_long_read(&mm->rss_stat.count[member]);
> > +     long val;
> >
> >  #ifdef SPLIT_RSS_COUNTING
> > +     if (atomic_xchg(&mm->rss_stat.dirty, 0))
> > +             sync_mm_rss_all_users(mm);
> 
> So, if we dirty _a_ page, should we iterate all of processes and threads?
> Even, get_mm_counter would be used places without requiring accurate
> numbers. I think you can sync stats on place you really need to rather
> than adding this.
> 
> I'd like to see all_threads_sync_mm_rss(mm_struct mm_struct *mm) which
> iterates
> just current's thread group(unless others are against) suggested by peterz.
> And then let's put it on places where you really need(e.g.,
> fs/proc/task_mmu.c
> somewhere).
> 
> 
> I thought about doing it that way, but it seemed odd that reading stats
> from proc should have the side effect of updating counters that things like
> the OOM killer and page scanning might use for their decisions.

I understand your concern but sync is not cheap if we should iterate all of
tasks. So each call site need to be reviewed which is more critical between
performance and accuracy. If we _really_ should be accurate in all of places,
then we should consider other way to avoid iterating of task_structs, IMO.
I guess it could make a long discussion thread about _it's really worth to do_.

> 
> OTOH, in task_mmu, we know both the task and the mm, so we can skip the
> process scan of the mm is attached only to that one process.
> 
> Otherwise, if you want to make all of path where get that rss accurate,
> I don't think iterating current's thread group is a good solution because
> getting rss is used for many places. We don't need to make them trouble.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
