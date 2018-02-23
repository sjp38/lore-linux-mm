Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AECB36B002A
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:43:57 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id w17so6264448iow.23
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:43:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t66sor869552ioe.46.2018.02.22.18.43.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 18:43:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180223022810.GB115990@rodete-desktop-imager.corp.google.com>
References: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <20180222024620.47691-1-dancol@google.com> <20180223020130.GA115990@rodete-desktop-imager.corp.google.com>
 <CAKOZuesZPy8rgo_pPy=cUtGcGhLzCq4X46ns7h7ta7ihrJSPWA@mail.gmail.com> <20180223022810.GB115990@rodete-desktop-imager.corp.google.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 22 Feb 2018 18:43:55 -0800
Message-ID: <CAKOZuetSpMMv7PP14cus=RrTcyNy3pOdAjCsww5X07N8Bt3U1g@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on demand
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Thu, Feb 22, 2018 at 6:28 PM, Minchan Kim <minchan@kernel.org> wrote:
> Plese don't include things not related to this patch.

Of course. The inclusion of the stray hunk was unintentional; I didn't
mean to suggest that bundling unrelated changes was somehow a good
thing.

> Furthermore, please use plain-text mail client.
> You mangled all of text. It makes communication hard in LKML.

Sorry about that. I'll avoid using that email client in the future.

>> > diff --git a/include/linux/mm.h b/include/linux/mm.h
>> > index ad06d42adb1a..f8129afebbdd 100644
>> > --- a/include/linux/mm.h
>> > +++ b/include/linux/mm.h
>> > @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struct
>> *vma,
>> >   */
>> >  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>> >                         struct page **pages);
>> > +
>> > +#ifdef SPLIT_RSS_COUNTING
>> > +/* Flush all task-buffered MM counters to the mm */
>> > +void sync_mm_rss_all_users(struct mm_struct *mm);
>>
>> Really heavy functioin iterates all of processes and threads.
>>
>>
>> Just all processes and the threads of each process attached to the mm.
>> Maybe that's not much better.
>>
>>
>> > +#endif
>> > +
>> >  /*
>> >   * per-process(per-mm_struct) statistics.
>> >   */
>> >  static inline unsigned long get_mm_counter(struct mm_struct *mm, int
>> member)
>> >  {
>> > -     long val = atomic_long_read(&mm->rss_stat.count[member]);
>> > +     long val;
>> >
>> >  #ifdef SPLIT_RSS_COUNTING
>> > +     if (atomic_xchg(&mm->rss_stat.dirty, 0))
>> > +             sync_mm_rss_all_users(mm);
>>
>> So, if we dirty _a_ page, should we iterate all of processes and threads?
>> Even, get_mm_counter would be used places without requiring accurate
>> numbers. I think you can sync stats on place you really need to rather
>> than adding this.
>>
>> I'd like to see all_threads_sync_mm_rss(mm_struct mm_struct *mm) which
>> iterates
>> just current's thread group(unless others are against) suggested by peterz.
>> And then let's put it on places where you really need(e.g.,
>> fs/proc/task_mmu.c
>> somewhere).
>>
>>
>> I thought about doing it that way, but it seemed odd that reading stats
>> from proc should have the side effect of updating counters that things like
>> the OOM killer and page scanning might use for their decisions.
>
> I understand your concern but sync is not cheap if we should iterate all of
> tasks. So each call site need to be reviewed which is more critical between
> performance and accuracy. If we _really_ should be accurate in all of places,
> then we should consider other way to avoid iterating of task_structs, IMO.
> I guess it could make a long discussion thread about _it's really worth to do_.

I'm thinking that *in general*, stale values can have unforeseen
undesired effects, especially if the values become up-to-date when you
try to view them, making it hard to debug the source of the problem
--- so if it's at all possible to make everyone see up-to-date values,
we should do that. If it's not possible, sure, we can tolerate stale
values. Do you think my list-of-dirty-tasks proposal would be cheap
enough? In that scheme, if you dirty one page, you look at only that
one task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
