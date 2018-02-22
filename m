Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 266886B0283
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 21:49:39 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n11so3420254ioc.15
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:49:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q133sor17798505ioe.69.2018.02.21.18.49.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 18:49:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
References: <20180205220325.197241-1-dancol@google.com> <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com> <20180222020633.GC27147@rodete-desktop-imager.corp.google.com>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 21 Feb 2018 18:49:35 -0800
Message-ID: <CAKOZuev67HPpK5x4zS88x0C2AysvSk5wcFS0DuT3A_04p1HpSQ@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Content-Type: multipart/alternative; boundary="001a113fc1b82e3ef30565c41825"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>

--001a113fc1b82e3ef30565c41825
Content-Type: text/plain; charset="UTF-8"

On Wed, Feb 21, 2018 at 6:06 PM, Minchan Kim <minchan@kernel.org> wrote:

> On Wed, Feb 21, 2018 at 04:23:43PM -0800, Daniel Colascione wrote:
> > Thanks for taking a look.
> >
> > On Wed, Feb 21, 2018 at 4:16 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > > Hi Daniel,
> > >
> > > On Wed, Feb 21, 2018 at 11:05:04AM -0800, Daniel Colascione wrote:
> > > > On Mon, Feb 5, 2018 at 2:03 PM, Daniel Colascione <dancol@google.com
> >
> > > wrote:
> > > >
> > > > > When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
> > > > > generally speaking), we buffer certain changes to mm-wide counters
> > > > > through counters local to the current struct task, flushing them to
> > > > > the mm after seeing 64 page faults, as well as on task exit and
> > > > > exec. This scheme can leave a large amount of memory
> unaccounted-for
> > > > > in process memory counters, especially for processes with many
> threads
> > > > > (each of which gets 64 "free" faults), and it produces an
> > > > > inconsistency with the same memory counters scanned VMA-by-VMA
> using
> > > > > smaps. This inconsistency can persist for an arbitrarily long time,
> > > > > since there is no way to force a task to flush its counters to its
> mm.
> > >
> > > Nice catch. Incosistency is bad but we usually have done it for
> > > performance.
> > > So, FWIW, it would be much better to describe what you are suffering
> from
> > > for matainter to take it.
> > >
> >
> > The problem is that the per-process counters in /proc/pid/status lag
> behind
> > the actual memory allocations, leading to an inaccurate view of overall
> > memory consumed by each process.
>
> Yub, true. The key of question was why you need a such accurate count.
>

For more context: on Android, we've historically scanned each processes's
address space using /proc/pid/smaps (and /proc/pid/smaps_rollup more
recently) to extract memory management statistics. We're looking at
replacing this mechanism with the new /proc/pid/status per-memory-type
(e.g., anonymous, file-backed) counters so that we can be even more
efficient, but we'd like the counts we collect to be accurate.


> Don't get me wrong. I'm not saying we don't need it.
> I was just curious why it becomes important now because we have been with
> such inaccurate count for a decade.


> >
> >
> > > > > This patch flushes counters on context switch. This way, we bound
> the
> > > > > amount of unaccounted memory without forcing tasks to flush to the
> > > > > mm-wide counters on each minor page fault. The flush operation
> should
> > > > > be cheap: we only have a few counters, adjacent in struct task,
> and we
> > > > > don't atomically write to the mm counters unless we've changed
> > > > > something since the last flush.
> > > > >
> > > > > Signed-off-by: Daniel Colascione <dancol@google.com>
> > > > > ---
> > > > >  kernel/sched/core.c | 3 +++
> > > > >  1 file changed, 3 insertions(+)
> > > > >
> > > > > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > > > > index a7bf32aabfda..7f197a7698ee 100644
> > > > > --- a/kernel/sched/core.c
> > > > > +++ b/kernel/sched/core.c
> > > > > @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched
> schedule(void)
> > > > >         struct task_struct *tsk = current;
> > > > >
> > > > >         sched_submit_work(tsk);
> > > > > +       if (tsk->mm)
> > > > > +               sync_mm_rss(tsk->mm);
> > > > > +
> > > > >         do {
> > > > >                 preempt_disable();
> > > > >                 __schedule(false);
> > > > >
> > > >
> > > >
> > > > Ping? Is this approach just a bad idea? We could instead just
> manually
> > > sync
> > > > all mm-attached tasks at counter-retrieval time.
> > >
> > > IMHO, yes, it should be done when user want to see which would be
> really
> > > cold path while this shecule function is hot.
> > >
> >
> > The problem with doing it that way is that we need to look at each task
> > attached to a particular mm. AFAIK (and please tell me if I'm wrong), the
> > only way to do that is to iterate over all processes, and for each
> process
> > attached to the mm we want, iterate over all its tasks (since each one
> has
> > to have the same mm, I think). Does that sound right?
>
> Hmm, it seems you're right. I spent some time to think over but cannot
> reach
> a better idea. One of option was to change RSS_EVENT_THRESH to per-mm and
> control it dynamically with the count of mm_users when forking time.
> However, it makes the process with many thread harmful without reason.
>
> So, I support your idea at this moment. But let's hear other's opinions.
>

FWIW, I just sent a patch that does the same thing a different way. It has
the virtue of not increasing context-switch path length, but it adds a
spinlock (almost never contended) around the per-task mm counter struct.
I'd be happy with either this version or my previous version.

--001a113fc1b82e3ef30565c41825
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On W=
ed, Feb 21, 2018 at 6:06 PM, Minchan Kim <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:minchan@kernel.org" target=3D"_blank">minchan@kernel.org</a>&gt;</spa=
n> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;b=
order-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Wed, Feb 21=
, 2018 at 04:23:43PM -0800, Daniel Colascione wrote:<br>
&gt; Thanks for taking a look.<br>
&gt;<br>
&gt; On Wed, Feb 21, 2018 at 4:16 PM, Minchan Kim &lt;<a href=3D"mailto:min=
chan@kernel.org">minchan@kernel.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Hi Daniel,<br>
&gt; &gt;<br>
&gt; &gt; On Wed, Feb 21, 2018 at 11:05:04AM -0800, Daniel Colascione wrote=
:<br>
&gt; &gt; &gt; On Mon, Feb 5, 2018 at 2:03 PM, Daniel Colascione &lt;<a hre=
f=3D"mailto:dancol@google.com">dancol@google.com</a>&gt;<br>
&gt; &gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; When SPLIT_RSS_COUNTING is in use (which it is on SMP s=
ystems,<br>
&gt; &gt; &gt; &gt; generally speaking), we buffer certain changes to mm-wi=
de counters<br>
&gt; &gt; &gt; &gt; through counters local to the current struct task, flus=
hing them to<br>
&gt; &gt; &gt; &gt; the mm after seeing 64 page faults, as well as on task =
exit and<br>
&gt; &gt; &gt; &gt; exec. This scheme can leave a large amount of memory un=
accounted-for<br>
&gt; &gt; &gt; &gt; in process memory counters, especially for processes wi=
th many threads<br>
&gt; &gt; &gt; &gt; (each of which gets 64 &quot;free&quot; faults), and it=
 produces an<br>
&gt; &gt; &gt; &gt; inconsistency with the same memory counters scanned VMA=
-by-VMA using<br>
&gt; &gt; &gt; &gt; smaps. This inconsistency can persist for an arbitraril=
y long time,<br>
&gt; &gt; &gt; &gt; since there is no way to force a task to flush its coun=
ters to its mm.<br>
&gt; &gt;<br>
&gt; &gt; Nice catch. Incosistency is bad but we usually have done it for<b=
r>
&gt; &gt; performance.<br>
&gt; &gt; So, FWIW, it would be much better to describe what you are suffer=
ing from<br>
&gt; &gt; for matainter to take it.<br>
&gt; &gt;<br>
&gt;<br>
&gt; The problem is that the per-process counters in /proc/pid/status lag b=
ehind<br>
&gt; the actual memory allocations, leading to an inaccurate view of overal=
l<br>
&gt; memory consumed by each process.<br>
<br>
</span>Yub, true. The key of question was why you need a such accurate coun=
t.<br></blockquote><div><br></div><div>For more context: on Android, we&#39=
;ve historically scanned each processes&#39;s address space using /proc/pid=
/smaps (and /proc/pid/smaps_rollup more recently) to extract memory managem=
ent statistics. We&#39;re looking at replacing this mechanism with the new =
/proc/pid/status per-memory-type (e.g., anonymous, file-backed) counters so=
 that we can be even more efficient, but we&#39;d like the counts we collec=
t to be accurate.</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Don&#39;t get me wrong. I&#39;m not saying we don&#39;t need it.<br>
I was just curious why it becomes important now because we have been with<b=
r>
such inaccurate count for a decade.=C2=A0</blockquote><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex">
<div><div class=3D"h5"><br>
&gt;<br>
&gt;<br>
&gt; &gt; &gt; &gt; This patch flushes counters on context switch. This way=
, we bound the<br>
&gt; &gt; &gt; &gt; amount of unaccounted memory without forcing tasks to f=
lush to the<br>
&gt; &gt; &gt; &gt; mm-wide counters on each minor page fault. The flush op=
eration should<br>
&gt; &gt; &gt; &gt; be cheap: we only have a few counters, adjacent in stru=
ct task, and we<br>
&gt; &gt; &gt; &gt; don&#39;t atomically write to the mm counters unless we=
&#39;ve changed<br>
&gt; &gt; &gt; &gt; something since the last flush.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Signed-off-by: Daniel Colascione &lt;<a href=3D"mailto:=
dancol@google.com">dancol@google.com</a>&gt;<br>
&gt; &gt; &gt; &gt; ---<br>
&gt; &gt; &gt; &gt;=C2=A0 kernel/sched/core.c | 3 +++<br>
&gt; &gt; &gt; &gt;=C2=A0 1 file changed, 3 insertions(+)<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; diff --git a/kernel/sched/core.c b/kernel/sched/core.c<=
br>
&gt; &gt; &gt; &gt; index a7bf32aabfda..7f197a7698ee 100644<br>
&gt; &gt; &gt; &gt; --- a/kernel/sched/core.c<br>
&gt; &gt; &gt; &gt; +++ b/kernel/sched/core.c<br>
&gt; &gt; &gt; &gt; @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched=
 schedule(void)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *ts=
k =3D current;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sched_submit_work(tsk)=
;<br>
&gt; &gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tsk-&gt;mm)<br>
&gt; &gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0sync_mm_rss(tsk-&gt;mm);<br>
&gt; &gt; &gt; &gt; +<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do {<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0preempt_disable();<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0__schedule(false);<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Ping? Is this approach just a bad idea? We could instead jus=
t manually<br>
&gt; &gt; sync<br>
&gt; &gt; &gt; all mm-attached tasks at counter-retrieval time.<br>
&gt; &gt;<br>
&gt; &gt; IMHO, yes, it should be done when user want to see which would be=
 really<br>
&gt; &gt; cold path while this shecule function is hot.<br>
&gt; &gt;<br>
&gt;<br>
&gt; The problem with doing it that way is that we need to look at each tas=
k<br>
&gt; attached to a particular mm. AFAIK (and please tell me if I&#39;m wron=
g), the<br>
&gt; only way to do that is to iterate over all processes, and for each pro=
cess<br>
&gt; attached to the mm we want, iterate over all its tasks (since each one=
 has<br>
&gt; to have the same mm, I think). Does that sound right?<br>
<br>
</div></div>Hmm, it seems you&#39;re right. I spent some time to think over=
 but cannot reach<br>
a better idea. One of option was to change RSS_EVENT_THRESH to per-mm and<b=
r>
control it dynamically with the count of mm_users when forking time.<br>
However, it makes the process with many thread harmful without reason.<br>
<br>
So, I support your idea at this moment. But let&#39;s hear other&#39;s opin=
ions.<br></blockquote><div><br></div><div>FWIW, I just sent a patch that do=
es the same thing a different way. It has the virtue of not increasing cont=
ext-switch path length, but it adds a spinlock (almost never contended) aro=
und the per-task mm counter struct. I&#39;d be happy with either this versi=
on or my previous version.</div></div></div></div>

--001a113fc1b82e3ef30565c41825--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
