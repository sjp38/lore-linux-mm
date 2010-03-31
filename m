Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 146C66B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 21:57:21 -0400 (EDT)
Received: by pwi2 with SMTP id 2so4757407pwi.14
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 18:57:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100316170808.GA29400@redhat.com>
	 <20100330135634.09e6b045.akpm@linux-foundation.org>
	 <20100331092815.c8b9d89c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100330173721.cbd442cb.akpm@linux-foundation.org>
	 <20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 31 Mar 2010 10:57:18 +0900
Message-ID: <z2t28c262361003301857l77db88dbv7d025b5c5947ad72@mail.gmail.com>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Troels Liebe Bentsen <tlb@rapanden.dk>, linux-bluetooth@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 9:41 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 30 Mar 2010 17:37:21 -0400
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Wed, 31 Mar 2010 09:28:15 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp=
.fujitsu.com> wrote:
>>
>> > On Tue, 30 Mar 2010 13:56:34 -0700
>> > Andrew Morton <akpm@linux-foundation.org> wrote:
>> >
>> > > That new BUG_ON() is triggering in Troels's machine when a bluetooth
>> > > keyboard is enabled or disabled. =C2=A0See
>> > > (https://bugzilla.kernel.org/show_bug.cgi?id=3D15648.
>> > >
>> > > I guess the question is: how did a kernel thread get a non-zero
>> > > task->rss_stat.count[i]? =C2=A0If that's expected and OK then we wil=
l need
>> > > to take some kernel-thread-avoidance action there.
>> > >
>> > It seems my fault that it's not initialized to be 0 at do_fork(), copy=
_process.
>> >
>> > About do_exit, do_exit() does this check. So, tsk->mm can be NULL.
>> >
>> > =C2=A0949 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (group_dead) {
>> > =C2=A0950 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hrti=
mer_cancel(&tsk->signal->real_timer);
>> > =C2=A0951 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 exit=
_itimers(tsk->signal);
>> > =C2=A0952 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (=
tsk->mm)
>> > =C2=A0953 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->m=
m);
>> > =C2=A0954 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > > Could whoever fixes this please also make __sync_task_rss_stat()
>> > > static.
>> > >
>> > Ah, yes. I should do so.
>> >
>> > > I'll toss this over to Rafael/Maciej for tracking as a post-2.6.33
>> > > regression.
>> > >
>> > > Thanks.
>> > >
>> >
>> >
>> > =3D=3D
>> >
>> > task->rss_stat wasn't initialized to 0 at copy_process().
>> > at exit, tsk->mm may be NULL.
>> > And __sync_task_rss_stat() should be static.
>> >
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > ---
>> > =C2=A0kernel/exit.c | =C2=A0 =C2=A03 ++-
>> > =C2=A0kernel/fork.c | =C2=A0 =C2=A03 +++
>> > =C2=A0mm/memory.c =C2=A0 | =C2=A0 =C2=A02 +-
>> > =C2=A03 files changed, 6 insertions(+), 2 deletions(-)
>> >
>> > Index: mmotm-2.6.34-Mar24/kernel/exit.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.34-Mar24.orig/kernel/exit.c
>> > +++ mmotm-2.6.34-Mar24/kernel/exit.c
>> > @@ -950,7 +950,8 @@ NORET_TYPE void do_exit(long code)
>> >
>> > =C2=A0 =C2=A0 acct_update_integrals(tsk);
>> > =C2=A0 =C2=A0 /* sync mm's RSS info before statistics gathering */
>> > - =C2=A0 sync_mm_rss(tsk, tsk->mm);
>> > + =C2=A0 if (tsk->mm)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sync_mm_rss(tsk, tsk->mm);
>> > =C2=A0 =C2=A0 group_dead =3D atomic_dec_and_test(&tsk->signal->live);
>> > =C2=A0 =C2=A0 if (group_dead) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hrtimer_cancel(&tsk->signal-=
>real_timer);
>> > Index: mmotm-2.6.34-Mar24/mm/memory.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.34-Mar24.orig/mm/memory.c
>> > +++ mmotm-2.6.34-Mar24/mm/memory.c
>> > @@ -124,7 +124,7 @@ core_initcall(init_zero_pfn);
>> >
>> > =C2=A0#if defined(SPLIT_RSS_COUNTING)
>> >
>> > -void __sync_task_rss_stat(struct task_struct *task, struct mm_struct =
*mm)
>> > +static void __sync_task_rss_stat(struct task_struct *task, struct mm_=
struct *mm)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 int i;
>> >
>> > Index: mmotm-2.6.34-Mar24/kernel/fork.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.34-Mar24.orig/kernel/fork.c
>> > +++ mmotm-2.6.34-Mar24/kernel/fork.c
>> > @@ -1060,6 +1060,9 @@ static struct task_struct *copy_process(
>> > =C2=A0 =C2=A0 p->prev_utime =3D cputime_zero;
>> > =C2=A0 =C2=A0 p->prev_stime =3D cputime_zero;
>> > =C2=A0#endif
>> > +#if defined(SPLIT_RSS_COUNTING)
>> > + =C2=A0 memset(&p->rss_stat, 0, sizeof(p->rss_stat));
>> > +#endif
>> >
>> > =C2=A0 =C2=A0 p->default_timer_slack_ns =3D current->timer_slack_ns;
>>
>> OK, so the kenrel thread inherited a non-zero rss_stat from a userspace
>> parent?
>>
> I think so.
>
>> With this fixed, the test for non-zero tsk->mm is't really needed in
>> do_exit(), is it? =C2=A0I guess it makes sense though - sync_mm_rss() on=
ly
>> really works for kernel threads by luck..
>
> At first, I considered so, too. But I changed my mind to show
> "we know tsk->mm can be NULL here!" by code.
> Because __sync_mm_rss_stat() has BUG_ON(!mm), the code reader will think
> tsk->mm shouldn't be NULL always.
>
> Doesn't make sense ?
>

Nitpick.
How about moving sync_mm_rss into after check !mm of exit_mm?



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
