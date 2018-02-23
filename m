Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7CC6B000E
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:09:20 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p11so1006308itc.5
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:09:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c7sor850395iog.11.2018.02.22.18.09.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 18:09:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180223020130.GA115990@rodete-desktop-imager.corp.google.com>
References: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
 <20180222024620.47691-1-dancol@google.com> <20180223020130.GA115990@rodete-desktop-imager.corp.google.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 22 Feb 2018 18:09:17 -0800
Message-ID: <CAKOZuesZPy8rgo_pPy=cUtGcGhLzCq4X46ns7h7ta7ihrJSPWA@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on demand
Content-Type: multipart/alternative; boundary="001a113944dadbb24f0565d7a567"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

--001a113944dadbb24f0565d7a567
Content-Type: text/plain; charset="UTF-8"

Thanks for taking a look.

On Feb 22, 2018 6:01 PM, "Minchan Kim" <minchan@kernel.org> wrote:

Hi Daniel,

On Wed, Feb 21, 2018 at 06:46:20PM -0800, Daniel Colascione wrote:
> When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
> generally speaking), we buffer certain changes to mm-wide counters
> through counters local to the current struct task, flushing them to
> the mm after seeing 64 page faults, as well as on task exit and
> exec. This scheme can leave a large amount of memory unaccounted-for
> in process memory counters, especially for processes with many threads
> (each of which gets 64 "free" faults), and it produces an
> inconsistency with the same memory counters scanned VMA-by-VMA using
> smaps. This inconsistency can persist for an arbitrarily long time,
> since there is no way to force a task to flush its counters to its mm.
>
> This patch flushes counters on get_mm_counter. This way, readers
> always have an up-to-date view of the counters for a particular
> task. It adds a spinlock-acquire to the add_mm_counter_fast path, but
> this spinlock should almost always be uncontended.
>
> Signed-off-by: Daniel Colascione <dancol@google.com>
> ---
>  fs/proc/task_mmu.c            |  2 +-
>  include/linux/mm.h            | 16 ++++++++-
>  include/linux/mm_types_task.h | 13 +++++--
>  kernel/fork.c                 |  1 +
>  mm/memory.c                   | 64 ++++++++++++++++++++++-------------
>  5 files changed, 67 insertions(+), 29 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index ec6d2983a5cb..ac9e86452ca4 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -852,7 +852,7 @@ static int show_smap(struct seq_file *m, void *v, int
is_pid)
>                          mss->private_hugetlb >> 10,
>                          mss->swap >> 10,
>                          (unsigned long)(mss->swap_pss >> (10 +
PSS_SHIFT)),
> -                        (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
> +                        (unsigned long)(mss->pss_locked >> (10 +
PSS_SHIFT)));

It seems you mixed with other patch.


Yep.


> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..f8129afebbdd 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struct
*vma,
>   */
>  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>                         struct page **pages);
> +
> +#ifdef SPLIT_RSS_COUNTING
> +/* Flush all task-buffered MM counters to the mm */
> +void sync_mm_rss_all_users(struct mm_struct *mm);

Really heavy functioin iterates all of processes and threads.


Just all processes and the threads of each process attached to the mm.
Maybe that's not much better.


> +#endif
> +
>  /*
>   * per-process(per-mm_struct) statistics.
>   */
>  static inline unsigned long get_mm_counter(struct mm_struct *mm, int
member)
>  {
> -     long val = atomic_long_read(&mm->rss_stat.count[member]);
> +     long val;
>
>  #ifdef SPLIT_RSS_COUNTING
> +     if (atomic_xchg(&mm->rss_stat.dirty, 0))
> +             sync_mm_rss_all_users(mm);

So, if we dirty _a_ page, should we iterate all of processes and threads?
Even, get_mm_counter would be used places without requiring accurate
numbers. I think you can sync stats on place you really need to rather
than adding this.

I'd like to see all_threads_sync_mm_rss(mm_struct mm_struct *mm) which
iterates
just current's thread group(unless others are against) suggested by peterz.
And then let's put it on places where you really need(e.g.,
fs/proc/task_mmu.c
somewhere).


I thought about doing it that way, but it seemed odd that reading stats
from proc should have the side effect of updating counters that things like
the OOM killer and page scanning might use for their decisions.

OTOH, in task_mmu, we know both the task and the mm, so we can skip the
process scan of the mm is attached only to that one process.

Otherwise, if you want to make all of path where get that rss accurate,
I don't think iterating current's thread group is a good solution because
getting rss is used for many places. We don't need to make them trouble.

Thanks.

> +#endif
> +
> +     val = atomic_long_read(&mm->rss_stat.count[member]);
> +
> +#ifdef SPLIT_RSS_COUNTING
> +
>       /*
>        * counter is updated in asynchronous manner and may go to minus.
>        * But it's never be expected number for users.
> diff --git a/include/linux/mm_types_task.h b/include/linux/mm_types_task.h
> index 5fe87687664c..7e027b2b3ef6 100644
> --- a/include/linux/mm_types_task.h
> +++ b/include/linux/mm_types_task.h
> @@ -12,6 +12,7 @@
>  #include <linux/threads.h>
>  #include <linux/atomic.h>
>  #include <linux/cpumask.h>
> +#include <linux/spinlock.h>
>
>  #include <asm/page.h>
>
> @@ -46,14 +47,20 @@ enum {
>
>  #if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
>  #define SPLIT_RSS_COUNTING
> -/* per-thread cached information, */
> +/* per-thread cached information */
>  struct task_rss_stat {
> -     int events;     /* for synchronization threshold */
> -     int count[NR_MM_COUNTERS];
> +     spinlock_t lock;
> +     bool marked_mm_dirty;
> +     long count[NR_MM_COUNTERS];
>  };
>  #endif /* USE_SPLIT_PTE_PTLOCKS */
>
>  struct mm_rss_stat {
> +#ifdef SPLIT_RSS_COUNTING
> +     /* When true, indicates that we need to flush task counters to
> +      * the mm structure.  */
> +     atomic_t dirty;
> +#endif
>       atomic_long_t count[NR_MM_COUNTERS];
>  };
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index be8aa5b98666..d7a5daa7d7d0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1710,6 +1710,7 @@ static __latent_entropy struct task_struct
*copy_process(
>
>  #if defined(SPLIT_RSS_COUNTING)
>       memset(&p->rss_stat, 0, sizeof(p->rss_stat));
> +     spin_lock_init(&p->rss_stat.lock);
>  #endif
>
>       p->default_timer_slack_ns = current->timer_slack_ns;
> diff --git a/mm/memory.c b/mm/memory.c
> index 5fcfc24904d1..a31d28a61ebe 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -44,6 +44,7 @@
>  #include <linux/sched/coredump.h>
>  #include <linux/sched/numa_balancing.h>
>  #include <linux/sched/task.h>
> +#include <linux/sched/signal.h>
>  #include <linux/hugetlb.h>
>  #include <linux/mman.h>
>  #include <linux/swap.h>
> @@ -141,49 +142,67 @@ core_initcall(init_zero_pfn);
>
>  #if defined(SPLIT_RSS_COUNTING)
>
> -void sync_mm_rss(struct mm_struct *mm)
> +static void sync_mm_rss_task(struct task_struct *task, struct mm_struct
*mm)
>  {
>       int i;
> +     if (unlikely(task->mm != mm))
> +             return;
> +     spin_lock(&task->rss_stat.lock);
> +     if (task->rss_stat.marked_mm_dirty) {
> +             task->rss_stat.marked_mm_dirty = false;
> +             for (i = 0; i < NR_MM_COUNTERS; ++i) {
> +                     add_mm_counter(mm, i, task->rss_stat.count[i]);
> +                     task->rss_stat.count[i] = 0;
> +             }
> +     }
> +     spin_unlock(&task->rss_stat.lock);
> +}
>
> -     for (i = 0; i < NR_MM_COUNTERS; i++) {
> -             if (current->rss_stat.count[i]) {
> -                     add_mm_counter(mm, i, current->rss_stat.count[i]);
> -                     current->rss_stat.count[i] = 0;
> +void sync_mm_rss(struct mm_struct *mm)
> +{
> +     sync_mm_rss_task(current, mm);
> +}
> +
> +void sync_mm_rss_all_users(struct mm_struct *mm)
> +{
> +     struct task_struct *p, *t;
> +     rcu_read_lock();
> +     for_each_process(p) {
> +             if (p->mm != mm)
> +                     continue;
> +             for_each_thread(p, t) {
> +                     task_lock(t);  /* Stop t->mm changing */
> +                     sync_mm_rss_task(t, mm);
> +                     task_unlock(t);
>               }
>       }
> -     current->rss_stat.events = 0;
> +     rcu_read_unlock();
>  }
>
>  static void add_mm_counter_fast(struct mm_struct *mm, int member, int
val)
>  {
>       struct task_struct *task = current;
>
> -     if (likely(task->mm == mm))
> +     if (likely(task->mm == mm)) {
> +             spin_lock(&task->rss_stat.lock);
>               task->rss_stat.count[member] += val;
> -     else
> +             if (!task->rss_stat.marked_mm_dirty) {
> +                     task->rss_stat.marked_mm_dirty = true;
> +                     atomic_set(&mm->rss_stat.dirty, 1);
> +             }
> +             spin_unlock(&task->rss_stat.lock);
> +     } else {
>               add_mm_counter(mm, member, val);
> +     }
>  }
>  #define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,
1)
>  #define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,
-1)
>
> -/* sync counter once per 64 page faults */
> -#define TASK_RSS_EVENTS_THRESH       (64)
> -static void check_sync_rss_stat(struct task_struct *task)
> -{
> -     if (unlikely(task != current))
> -             return;
> -     if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
> -             sync_mm_rss(task->mm);
> -}
>  #else /* SPLIT_RSS_COUNTING */
>
>  #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
>  #define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
>
> -static void check_sync_rss_stat(struct task_struct *task)
> -{
> -}
> -
>  #endif /* SPLIT_RSS_COUNTING */
>
>  #ifdef HAVE_GENERIC_MMU_GATHER
> @@ -4119,9 +4138,6 @@ int handle_mm_fault(struct vm_area_struct *vma,
unsigned long address,
>       count_vm_event(PGFAULT);
>       count_memcg_event_mm(vma->vm_mm, PGFAULT);
>
> -     /* do counter updates before entering really critical section. */
> -     check_sync_rss_stat(current);
> -
>       if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
>                                           flags & FAULT_FLAG_INSTRUCTION,
>                                           flags & FAULT_FLAG_REMOTE))
> --
> 2.16.1.291.g4437f3f132-goog
>

--001a113944dadbb24f0565d7a567
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_extra"><div class=3D"gmail_quote=
" dir=3D"auto">Thanks for taking a look.</div><div class=3D"gmail_quote" di=
r=3D"auto"><br></div><div class=3D"gmail_quote">On Feb 22, 2018 6:01 PM, &q=
uot;Minchan Kim&quot; &lt;<a href=3D"mailto:minchan@kernel.org">minchan@ker=
nel.org</a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Hi =
Daniel,<br>
<div class=3D"elided-text"><br>
On Wed, Feb 21, 2018 at 06:46:20PM -0800, Daniel Colascione wrote:<br>
&gt; When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,<br>
&gt; generally speaking), we buffer certain changes to mm-wide counters<br>
&gt; through counters local to the current struct task, flushing them to<br=
>
&gt; the mm after seeing 64 page faults, as well as on task exit and<br>
&gt; exec. This scheme can leave a large amount of memory unaccounted-for<b=
r>
&gt; in process memory counters, especially for processes with many threads=
<br>
&gt; (each of which gets 64 &quot;free&quot; faults), and it produces an<br=
>
&gt; inconsistency with the same memory counters scanned VMA-by-VMA using<b=
r>
&gt; smaps. This inconsistency can persist for an arbitrarily long time,<br=
>
&gt; since there is no way to force a task to flush its counters to its mm.=
<br>
&gt;<br>
&gt; This patch flushes counters on get_mm_counter. This way, readers<br>
&gt; always have an up-to-date view of the counters for a particular<br>
&gt; task. It adds a spinlock-acquire to the add_mm_counter_fast path, but<=
br>
&gt; this spinlock should almost always be uncontended.<br>
&gt;<br>
&gt; Signed-off-by: Daniel Colascione &lt;<a href=3D"mailto:dancol@google.c=
om">dancol@google.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 fs/proc/task_mmu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 2 +-<br>
&gt;=C2=A0 include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 16=
 ++++++++-<br>
&gt;=C2=A0 include/linux/mm_types_task.h | 13 +++++--<br>
&gt;=C2=A0 kernel/fork.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 1 +<br>
&gt;=C2=A0 mm/memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| 64 ++++++++++++++++++++++--------<wbr>-----<br>
&gt;=C2=A0 5 files changed, 67 insertions(+), 29 deletions(-)<br>
&gt;<br>
&gt; diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c<br>
&gt; index ec6d2983a5cb..ac9e86452ca4 100644<br>
&gt; --- a/fs/proc/task_mmu.c<br>
&gt; +++ b/fs/proc/task_mmu.c<br>
&gt; @@ -852,7 +852,7 @@ static int show_smap(struct seq_file *m, void *v, =
int is_pid)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 mss-&gt;private_hugetlb &gt;&gt; 10,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 mss-&gt;swap &gt;&gt; 10,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 (unsigned long)(mss-&gt;swap_pss &gt;&gt; (10 + PSS_SH=
IFT)),<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 (unsigned long)(mss-&gt;pss &gt;&gt; (10 + PSS_SHIFT)));<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 (unsigned long)(mss-&gt;pss_locked &gt;&gt; (10 + PSS_SHIFT)=
));<br>
<br>
</div>It seems you mixed with other patch.<br></blockquote></div></div></di=
v><div dir=3D"auto"><br></div><div dir=3D"auto">Yep.</div><div dir=3D"auto"=
><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote class=3D=
"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex"><div class=3D"quoted-text"><br>
&gt; diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
&gt; index ad06d42adb1a..f8129afebbdd 100644<br>
&gt; --- a/include/linux/mm.h<br>
&gt; +++ b/include/linux/mm.h<br>
&gt; @@ -1507,14 +1507,28 @@ extern int mprotect_fixup(struct vm_area_struc=
t *vma,<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt;=C2=A0 int __get_user_pages_fast(unsigned long start, int nr_pages, int=
 write,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct page **pages);<br>
&gt; +<br>
&gt; +#ifdef SPLIT_RSS_COUNTING<br>
&gt; +/* Flush all task-buffered MM counters to the mm */<br>
&gt; +void sync_mm_rss_all_users(struct mm_struct *mm);<br>
<br>
</div>Really heavy functioin iterates all of processes and threads.<br></bl=
ockquote></div></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">Ju=
st all processes and the threads of each process attached to the mm. Maybe =
that&#39;s not much better.</div><div dir=3D"auto"><div class=3D"gmail_extr=
a"><div class=3D"gmail_quote"><blockquote class=3D"quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div class=3D"quoted=
-text"><br>
&gt; +#endif<br>
&gt; +<br>
&gt;=C2=A0 /*<br>
&gt;=C2=A0 =C2=A0* per-process(per-mm_struct) statistics.<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt;=C2=A0 static inline unsigned long get_mm_counter(struct mm_struct *mm,=
 int member)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0long val =3D atomic_long_read(&amp;mm-&gt;rss_<wb=
r>stat.count[member]);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0long val;<br>
&gt;<br>
&gt;=C2=A0 #ifdef SPLIT_RSS_COUNTING<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (atomic_xchg(&amp;mm-&gt;rss_stat.<wbr>dirty, =
0))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_mm_rss_all_users=
(mm);<br>
<br>
</div>So, if we dirty _a_ page, should we iterate all of processes and thre=
ads?<br>
Even, get_mm_counter would be used places without requiring accurate<br>
numbers. I think you can sync stats on place you really need to rather<br>
than adding this.<br>
<br>
I&#39;d like to see all_threads_sync_mm_rss(mm_<wbr>struct mm_struct *mm) w=
hich iterates<br>
just current&#39;s thread group(unless others are against) suggested by pet=
erz.<br>
And then let&#39;s put it on places where you really need(e.g., fs/proc/tas=
k_mmu.c<br>
somewhere).<br></blockquote></div></div></div><div dir=3D"auto"><br></div><=
div dir=3D"auto">I thought about doing it that way, but it seemed odd that =
reading stats from proc should have the side effect of updating counters th=
at things like the OOM killer and page scanning might use for their decisio=
ns.</div><div dir=3D"auto"><br></div><div dir=3D"auto">OTOH, in task_mmu, w=
e know both the task and the mm, so we can skip the process scan of the mm =
is attached only to that one process.</div><div dir=3D"auto"><br></div><div=
 dir=3D"auto"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockq=
uote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">
Otherwise, if you want to make all of path where get that rss accurate,<br>
I don&#39;t think iterating current&#39;s thread group is a good solution b=
ecause<br>
getting rss is used for many places. We don&#39;t need to make them trouble=
.<br>
<br>
Thanks.<br>
<div class=3D"elided-text"><br>
&gt; +#endif<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0val =3D atomic_long_read(&amp;mm-&gt;rss_<wbr>sta=
t.count[member]);<br>
&gt; +<br>
&gt; +#ifdef SPLIT_RSS_COUNTING<br>
&gt; +<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * counter is updated in asynchronous manner=
 and may go to minus.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * But it&#39;s never be expected number for=
 users.<br>
&gt; diff --git a/include/linux/mm_types_task.<wbr>h b/include/linux/mm_typ=
es_task.<wbr>h<br>
&gt; index 5fe87687664c..7e027b2b3ef6 100644<br>
&gt; --- a/include/linux/mm_types_task.<wbr>h<br>
&gt; +++ b/include/linux/mm_types_task.<wbr>h<br>
&gt; @@ -12,6 +12,7 @@<br>
&gt;=C2=A0 #include &lt;linux/threads.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/atomic.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/cpumask.h&gt;<br>
&gt; +#include &lt;linux/spinlock.h&gt;<br>
&gt;<br>
&gt;=C2=A0 #include &lt;asm/page.h&gt;<br>
&gt;<br>
&gt; @@ -46,14 +47,20 @@ enum {<br>
&gt;<br>
&gt;=C2=A0 #if USE_SPLIT_PTE_PTLOCKS &amp;&amp; defined(CONFIG_MMU)<br>
&gt;=C2=A0 #define SPLIT_RSS_COUNTING<br>
&gt; -/* per-thread cached information, */<br>
&gt; +/* per-thread cached information */<br>
&gt;=C2=A0 struct task_rss_stat {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0int events;=C2=A0 =C2=A0 =C2=A0/* for synchroniza=
tion threshold */<br>
&gt; -=C2=A0 =C2=A0 =C2=A0int count[NR_MM_COUNTERS];<br>
&gt; +=C2=A0 =C2=A0 =C2=A0spinlock_t lock;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0bool marked_mm_dirty;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0long count[NR_MM_COUNTERS];<br>
&gt;=C2=A0 };<br>
&gt;=C2=A0 #endif /* USE_SPLIT_PTE_PTLOCKS */<br>
&gt;<br>
&gt;=C2=A0 struct mm_rss_stat {<br>
&gt; +#ifdef SPLIT_RSS_COUNTING<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/* When true, indicates that we need to flush tas=
k counters to<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * the mm structure.=C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0atomic_t dirty;<br>
&gt; +#endif<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_long_t count[NR_MM_COUNTERS];<br>
&gt;=C2=A0 };<br>
&gt;<br>
&gt; diff --git a/kernel/fork.c b/kernel/fork.c<br>
&gt; index be8aa5b98666..d7a5daa7d7d0 100644<br>
&gt; --- a/kernel/fork.c<br>
&gt; +++ b/kernel/fork.c<br>
&gt; @@ -1710,6 +1710,7 @@ static __latent_entropy struct task_struct *copy=
_process(<br>
&gt;<br>
&gt;=C2=A0 #if defined(SPLIT_RSS_COUNTING)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0memset(&amp;p-&gt;rss_stat, 0, sizeof(p-&gt;=
rss_stat));<br>
&gt; +=C2=A0 =C2=A0 =C2=A0spin_lock_init(&amp;p-&gt;rss_stat.<wbr>lock);<br=
>
&gt;=C2=A0 #endif<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0p-&gt;default_timer_slack_ns =3D current-&gt=
;timer_slack_ns;<br>
&gt; diff --git a/mm/memory.c b/mm/memory.c<br>
&gt; index 5fcfc24904d1..a31d28a61ebe 100644<br>
&gt; --- a/mm/memory.c<br>
&gt; +++ b/mm/memory.c<br>
&gt; @@ -44,6 +44,7 @@<br>
&gt;=C2=A0 #include &lt;linux/sched/coredump.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/sched/numa_balancing.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/sched/task.h&gt;<br>
&gt; +#include &lt;linux/sched/signal.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/hugetlb.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/mman.h&gt;<br>
&gt;=C2=A0 #include &lt;linux/swap.h&gt;<br>
&gt; @@ -141,49 +142,67 @@ core_initcall(init_zero_pfn);<br>
&gt;<br>
&gt;=C2=A0 #if defined(SPLIT_RSS_COUNTING)<br>
&gt;<br>
&gt; -void sync_mm_rss(struct mm_struct *mm)<br>
&gt; +static void sync_mm_rss_task(struct task_struct *task, struct mm_stru=
ct *mm)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0int i;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (unlikely(task-&gt;mm !=3D mm))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0spin_lock(&amp;task-&gt;rss_stat.<wbr>lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (task-&gt;rss_stat.marked_mm_<wbr>dirty) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task-&gt;rss_stat.mar=
ked_mm_dirty =3D false;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i &lt; =
NR_MM_COUNTERS; ++i) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0add_mm_counter(mm, i, task-&gt;rss_stat.count[i]);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0task-&gt;rss_stat.count[i] =3D 0;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;task-&gt;rss_stat.<wbr>lock);<br=
>
&gt; +}<br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0for (i =3D 0; i &lt; NR_MM_COUNTERS; i++) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (current-&gt;rss_s=
tat.count[i]) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0add_mm_counter(mm, i, current-&gt;rss_stat.count[i]);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0current-&gt;rss_stat.count[i] =3D 0;<br>
&gt; +void sync_mm_rss(struct mm_struct *mm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0sync_mm_rss_task(current, mm);<br>
&gt; +}<br>
&gt; +<br>
&gt; +void sync_mm_rss_all_users(struct mm_struct *mm)<br>
&gt; +{<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct task_struct *p, *t;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0rcu_read_lock();<br>
&gt; +=C2=A0 =C2=A0 =C2=A0for_each_process(p) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (p-&gt;mm !=3D mm)=
<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0continue;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_thread(p, t)=
 {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0task_lock(t);=C2=A0 /* Stop t-&gt;mm changing */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0sync_mm_rss_task(t, mm);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0task_unlock(t);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; -=C2=A0 =C2=A0 =C2=A0current-&gt;rss_stat.events =3D 0;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0rcu_read_unlock();<br>
&gt;=C2=A0 }<br>
&gt;<br>
&gt;=C2=A0 static void add_mm_counter_fast(struct mm_struct *mm, int member=
, int val)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *task =3D current;<br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (likely(task-&gt;mm =3D=3D mm))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (likely(task-&gt;mm =3D=3D mm)) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&amp;task-&=
gt;rss_stat.<wbr>lock);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task-&gt;rss_sta=
t.count[member] +=3D val;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0else<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!task-&gt;rss_sta=
t.marked_mm_<wbr>dirty) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0task-&gt;rss_stat.marked_mm_dirty =3D true;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0atomic_set(&amp;mm-&gt;rss_stat.<wbr>dirty, 1);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;task=
-&gt;rss_stat.<wbr>lock);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0} else {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0add_mm_counter(m=
m, member, val);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0}<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 #define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, =
member, 1)<br>
&gt;=C2=A0 #define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, =
member, -1)<br>
&gt;<br>
&gt; -/* sync counter once per 64 page faults */<br>
&gt; -#define TASK_RSS_EVENTS_THRESH=C2=A0 =C2=A0 =C2=A0 =C2=A0(64)<br>
&gt; -static void check_sync_rss_stat(struct task_struct *task)<br>
&gt; -{<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (unlikely(task !=3D current))<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (unlikely(task-&gt;rss_stat.<wbr>events++ &gt;=
 TASK_RSS_EVENTS_THRESH))<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_mm_rss(task-&gt;=
mm);<br>
&gt; -}<br>
&gt;=C2=A0 #else /* SPLIT_RSS_COUNTING */<br>
&gt;<br>
&gt;=C2=A0 #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, membe=
r)<br>
&gt;=C2=A0 #define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, membe=
r)<br>
&gt;<br>
&gt; -static void check_sync_rss_stat(struct task_struct *task)<br>
&gt; -{<br>
&gt; -}<br>
&gt; -<br>
&gt;=C2=A0 #endif /* SPLIT_RSS_COUNTING */<br>
&gt;<br>
&gt;=C2=A0 #ifdef HAVE_GENERIC_MMU_GATHER<br>
&gt; @@ -4119,9 +4138,6 @@ int handle_mm_fault(struct vm_area_struct *vma, =
unsigned long address,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0count_vm_event(PGFAULT);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0count_memcg_event_mm(vma-&gt;vm_<wbr>mm, PGF=
AULT);<br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0/* do counter updates before entering really crit=
ical section. */<br>
&gt; -=C2=A0 =C2=A0 =C2=A0check_sync_rss_stat(current);<br>
&gt; -<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!arch_vma_access_permitted(<wbr>vma, fla=
gs &amp; FAULT_FLAG_WRITE,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0flags &amp; FAULT_FLAG_INSTRUCTION,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0flags &amp; FAULT_FLAG_REMOTE))<br>
&gt; --<br>
&gt; 2.16.1.291.g4437f3f132-goog<br>
&gt;<br>
</div></blockquote></div><br></div></div></div>

--001a113944dadbb24f0565d7a567--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
