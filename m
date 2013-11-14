Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7DE6B003B
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 12:04:00 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fa1so2350286pad.2
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 09:03:59 -0800 (PST)
Received: from psmtp.com ([74.125.245.177])
        by mx.google.com with SMTP id kn3si28181721pbc.154.2013.11.14.09.03.55
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 09:03:57 -0800 (PST)
Received: by mail-we0-f170.google.com with SMTP id p61so2329012wes.15
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 09:03:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMw+i9hi9pBPkfWHo3mh0=PATQFzbNOCSPaLkw+zqUvwK2wbxA@mail.gmail.com>
References: <CANMivWaXE=bn4fhvGdz3cPwN+CZpWwrWqmU1BKX8o+vE2JawOw@mail.gmail.com>
 <1384363093-8025-1-git-send-email-snanda@chromium.org> <CAMw+i9hi9pBPkfWHo3mh0=PATQFzbNOCSPaLkw+zqUvwK2wbxA@mail.gmail.com>
From: Sameer Nanda <snanda@chromium.org>
Date: Thu, 14 Nov 2013 09:03:33 -0800
Message-ID: <CANMivWbNTev3vq6fys5Rexrzh1So9CgVKmtG1L5heE6N6TMiAg@mail.gmail.com>
Subject: Re: [PATCH v6] mm, oom: Fix race when selecting process to kill
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dserrg <dserrg@gmail.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Johannes Weiner <hannes@cmpxchg.org>, "msb@chromium.org" <msb@chromium.org>, Oleg Nesterov <oleg@redhat.com>, =?UTF-8?B?0JzRg9GA0LfQuNC9INCS0LvQsNC00LjQvNC40YA=?= <murzin.v@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org

On Thu, Nov 14, 2013 at 5:43 AM, dserrg <dserrg@gmail.com> wrote:
> (sorry for html)
>
> Why do we even bother with locking?
> Why not just merge my original patch? (The link is in Vladimir's message)
> It provides much more elegant (and working!) solution for this problem.

As Oleg alluded to in that thread, that patch makes the race window
smaller, but doesn't close it completely.  Imagine if a SIGKILL gets
sent to the task p immediately after the fatal_signal_pending check.
In that case, the infinite loop in while_each_thread will still happen
since  __unhash_process would delete the task p from the thread_group
list while while_each_thread loop is in progress on another CPU.  This
is precisely why we need to hold read_lock(&tasklist_lock) _before_
checking the state of the process p and entering the while_each_thread
loop.

> David, how did you miss it in the first place?
>
> Oh.. and by the way. I was hitting the same bug in other
> while_each_thread loops in oom_kill.c.

> Anyway, goodluck ;)

Thanks!

>
> 14 =D0=BD=D0=BE=D1=8F=D0=B1. 2013 =D0=B3. 2:18 =D0=BF=D0=BE=D0=BB=D1=8C=
=D0=B7=D0=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C "Sameer Nanda" <snanda@chr=
omium.org>
> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB:
>
>> The selection of the process to be killed happens in two spots:
>> first in select_bad_process and then a further refinement by
>> looking for child processes in oom_kill_process. Since this is
>> a two step process, it is possible that the process selected by
>> select_bad_process may get a SIGKILL just before oom_kill_process
>> executes. If this were to happen, __unhash_process deletes this
>> process from the thread_group list. This results in oom_kill_process
>> getting stuck in an infinite loop when traversing the thread_group
>> list of the selected process.
>>
>> Fix this race by adding a pid_alive check for the selected process
>> with tasklist_lock held in oom_kill_process.
>>
>> Signed-off-by: Sameer Nanda <snanda@chromium.org>
>> ---
>>  include/linux/sched.h |  5 +++++
>>  mm/oom_kill.c         | 34 +++++++++++++++++++++-------------
>>  2 files changed, 26 insertions(+), 13 deletions(-)
>>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index e27baee..8975dbb 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -2156,6 +2156,11 @@ extern bool current_is_single_threaded(void);
>>  #define do_each_thread(g, t) \
>>         for (g =3D t =3D &init_task ; (g =3D t =3D next_task(g)) !=3D &i=
nit_task ; )
>> do
>>
>> +/*
>> + * Careful: while_each_thread is not RCU safe. Callers should hold
>> + * read_lock(tasklist_lock) across while_each_thread loops.
>> + */
>> +
>>  #define while_each_thread(g, t) \
>>         while ((t =3D next_thread(t)) !=3D g)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 6738c47..0d1f804 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -412,31 +412,33 @@ void oom_kill_process(struct task_struct *p, gfp_t
>> gfp_mask, int order,
>>         static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL=
,
>>                                               DEFAULT_RATELIMIT_BURST);
>>
>> +       if (__ratelimit(&oom_rs))
>> +               dump_header(p, gfp_mask, order, memcg, nodemask);
>> +
>> +       task_lock(p);
>> +       pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
>> +               message, task_pid_nr(p), p->comm, points);
>> +       task_unlock(p);
>> +
>> +       read_lock(&tasklist_lock);
>> +
>>         /*
>>          * If the task is already exiting, don't alarm the sysadmin or
>> kill
>>          * its children or threads, just set TIF_MEMDIE so it can die
>> quickly
>>          */
>> -       if (p->flags & PF_EXITING) {
>> +       if (p->flags & PF_EXITING || !pid_alive(p)) {
>>                 set_tsk_thread_flag(p, TIF_MEMDIE);
>>                 put_task_struct(p);
>> +               read_unlock(&tasklist_lock);
>>                 return;
>>         }
>>
>> -       if (__ratelimit(&oom_rs))
>> -               dump_header(p, gfp_mask, order, memcg, nodemask);
>> -
>> -       task_lock(p);
>> -       pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
>> -               message, task_pid_nr(p), p->comm, points);
>> -       task_unlock(p);
>> -
>>         /*
>>          * If any of p's children has a different mm and is eligible for
>> kill,
>>          * the one with the highest oom_badness() score is sacrificed fo=
r
>> its
>>          * parent.  This attempts to lose the minimal amount of work don=
e
>> while
>>          * still freeing memory.
>>          */
>> -       read_lock(&tasklist_lock);
>>         do {
>>                 list_for_each_entry(child, &t->children, sibling) {
>>                         unsigned int child_points;
>> @@ -456,12 +458,17 @@ void oom_kill_process(struct task_struct *p, gfp_t
>> gfp_mask, int order,
>>                         }
>>                 }
>>         } while_each_thread(p, t);
>> -       read_unlock(&tasklist_lock);
>>
>> -       rcu_read_lock();
>>         p =3D find_lock_task_mm(victim);
>> +
>> +       /*
>> +        * Since while_each_thread is currently not RCU safe, this unloc=
k
>> of
>> +        * tasklist_lock may need to be moved further down if any
>> additional
>> +        * while_each_thread loops get added to this function.
>> +        */
>> +       read_unlock(&tasklist_lock);
>> +
>>         if (!p) {
>> -               rcu_read_unlock();
>>                 put_task_struct(victim);
>>                 return;
>>         } else if (victim !=3D p) {
>> @@ -487,6 +494,7 @@ void oom_kill_process(struct task_struct *p, gfp_t
>> gfp_mask, int order,
>>          * That thread will now get access to memory reserves since it h=
as
>> a
>>          * pending fatal signal.
>>          */
>> +       rcu_read_lock();
>>         for_each_process(p)
>>                 if (p->mm =3D=3D mm && !same_thread_group(p, victim) &&
>>                     !(p->flags & PF_KTHREAD)) {
>> --
>> 1.8.4.1
>>
>



--=20
Sameer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
