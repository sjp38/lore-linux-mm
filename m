Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04E146B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 19:23:46 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o22so3279173itc.9
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 16:23:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f2sor731588itg.11.2018.02.21.16.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 16:23:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
References: <20180205220325.197241-1-dancol@google.com> <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 21 Feb 2018 16:23:43 -0800
Message-ID: <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Content-Type: multipart/alternative; boundary="94eb2c05ff96764bca0565c20e5d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

--94eb2c05ff96764bca0565c20e5d
Content-Type: text/plain; charset="UTF-8"

Thanks for taking a look.

On Wed, Feb 21, 2018 at 4:16 PM, Minchan Kim <minchan@kernel.org> wrote:

> Hi Daniel,
>
> On Wed, Feb 21, 2018 at 11:05:04AM -0800, Daniel Colascione wrote:
> > On Mon, Feb 5, 2018 at 2:03 PM, Daniel Colascione <dancol@google.com>
> wrote:
> >
> > > When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
> > > generally speaking), we buffer certain changes to mm-wide counters
> > > through counters local to the current struct task, flushing them to
> > > the mm after seeing 64 page faults, as well as on task exit and
> > > exec. This scheme can leave a large amount of memory unaccounted-for
> > > in process memory counters, especially for processes with many threads
> > > (each of which gets 64 "free" faults), and it produces an
> > > inconsistency with the same memory counters scanned VMA-by-VMA using
> > > smaps. This inconsistency can persist for an arbitrarily long time,
> > > since there is no way to force a task to flush its counters to its mm.
>
> Nice catch. Incosistency is bad but we usually have done it for
> performance.
> So, FWIW, it would be much better to describe what you are suffering from
> for matainter to take it.
>

The problem is that the per-process counters in /proc/pid/status lag behind
the actual memory allocations, leading to an inaccurate view of overall
memory consumed by each process.


> > > This patch flushes counters on context switch. This way, we bound the
> > > amount of unaccounted memory without forcing tasks to flush to the
> > > mm-wide counters on each minor page fault. The flush operation should
> > > be cheap: we only have a few counters, adjacent in struct task, and we
> > > don't atomically write to the mm counters unless we've changed
> > > something since the last flush.
> > >
> > > Signed-off-by: Daniel Colascione <dancol@google.com>
> > > ---
> > >  kernel/sched/core.c | 3 +++
> > >  1 file changed, 3 insertions(+)
> > >
> > > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > > index a7bf32aabfda..7f197a7698ee 100644
> > > --- a/kernel/sched/core.c
> > > +++ b/kernel/sched/core.c
> > > @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(void)
> > >         struct task_struct *tsk = current;
> > >
> > >         sched_submit_work(tsk);
> > > +       if (tsk->mm)
> > > +               sync_mm_rss(tsk->mm);
> > > +
> > >         do {
> > >                 preempt_disable();
> > >                 __schedule(false);
> > >
> >
> >
> > Ping? Is this approach just a bad idea? We could instead just manually
> sync
> > all mm-attached tasks at counter-retrieval time.
>
> IMHO, yes, it should be done when user want to see which would be really
> cold path while this shecule function is hot.
>

The problem with doing it that way is that we need to look at each task
attached to a particular mm. AFAIK (and please tell me if I'm wrong), the
only way to do that is to iterate over all processes, and for each process
attached to the mm we want, iterate over all its tasks (since each one has
to have the same mm, I think). Does that sound right?

--94eb2c05ff96764bca0565c20e5d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">Than=
ks for taking a look.</div><div class=3D"gmail_quote"><br></div><div class=
=3D"gmail_quote">On Wed, Feb 21, 2018 at 4:16 PM, Minchan Kim <span dir=3D"=
ltr">&lt;<a href=3D"mailto:minchan@kernel.org" target=3D"_blank">minchan@ke=
rnel.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Hi Danie=
l,<br>
<span class=3D""><br>
On Wed, Feb 21, 2018 at 11:05:04AM -0800, Daniel Colascione wrote:<br>
&gt; On Mon, Feb 5, 2018 at 2:03 PM, Daniel Colascione &lt;<a href=3D"mailt=
o:dancol@google.com">dancol@google.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,<br=
>
&gt; &gt; generally speaking), we buffer certain changes to mm-wide counter=
s<br>
&gt; &gt; through counters local to the current struct task, flushing them =
to<br>
&gt; &gt; the mm after seeing 64 page faults, as well as on task exit and<b=
r>
&gt; &gt; exec. This scheme can leave a large amount of memory unaccounted-=
for<br>
&gt; &gt; in process memory counters, especially for processes with many th=
reads<br>
&gt; &gt; (each of which gets 64 &quot;free&quot; faults), and it produces =
an<br>
&gt; &gt; inconsistency with the same memory counters scanned VMA-by-VMA us=
ing<br>
&gt; &gt; smaps. This inconsistency can persist for an arbitrarily long tim=
e,<br>
&gt; &gt; since there is no way to force a task to flush its counters to it=
s mm.<br>
<br>
</span>Nice catch. Incosistency is bad but we usually have done it for perf=
ormance.<br>
So, FWIW, it would be much better to describe what you are suffering from<b=
r>
for matainter to take it.<br></blockquote><div><br></div><div>The problem i=
s that the per-process counters in /proc/pid/status lag behind the actual m=
emory allocations, leading to an inaccurate view of overall memory consumed=
 by each process.</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div=
><div class=3D"h5">&gt; &gt; This patch flushes counters on context switch.=
 This way, we bound the<br>
&gt; &gt; amount of unaccounted memory without forcing tasks to flush to th=
e<br>
&gt; &gt; mm-wide counters on each minor page fault. The flush operation sh=
ould<br>
&gt; &gt; be cheap: we only have a few counters, adjacent in struct task, a=
nd we<br>
&gt; &gt; don&#39;t atomically write to the mm counters unless we&#39;ve ch=
anged<br>
&gt; &gt; something since the last flush.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Daniel Colascione &lt;<a href=3D"mailto:dancol@goo=
gle.com">dancol@google.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 kernel/sched/core.c | 3 +++<br>
&gt; &gt;=C2=A0 1 file changed, 3 insertions(+)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/kernel/sched/core.c b/kernel/sched/core.c<br>
&gt; &gt; index a7bf32aabfda..7f197a7698ee 100644<br>
&gt; &gt; --- a/kernel/sched/core.c<br>
&gt; &gt; +++ b/kernel/sched/core.c<br>
&gt; &gt; @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(=
void)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *tsk =3D curr=
ent;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sched_submit_work(tsk);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tsk-&gt;mm)<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_mm_r=
ss(tsk-&gt;mm);<br>
&gt; &gt; +<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pree=
mpt_disable();<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__sc=
hedule(false);<br>
&gt; &gt;<br>
&gt;<br>
&gt;<br>
&gt; Ping? Is this approach just a bad idea? We could instead just manually=
 sync<br>
&gt; all mm-attached tasks at counter-retrieval time.<br>
<br>
</div></div>IMHO, yes, it should be done when user want to see which would =
be really<br>
cold path while this shecule function is hot.<br></blockquote><div><br></di=
v><div>The problem with doing it that way is that we need to look at each t=
ask attached to a particular mm. AFAIK (and please tell me if I&#39;m wrong=
), the only way to do that is to iterate over all processes, and for each p=
rocess attached to the mm we want, iterate over all its tasks (since each o=
ne has to have the same mm, I think). Does that sound right?</div><div><br>=
</div><div><br></div></div></div></div>

--94eb2c05ff96764bca0565c20e5d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
