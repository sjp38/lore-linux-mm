Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 728506B02F0
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:23:43 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id z2so5102640ite.5
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:23:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t21sor262419ioa.127.2018.02.22.08.23.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 08:23:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222094009.GO25201@hirez.programming.kicks-ass.net>
References: <20180205220325.197241-1-dancol@google.com> <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
 <20180222001635.GB27147@rodete-desktop-imager.corp.google.com>
 <CAKOZuetc7DepPPO6DmMp9APNz5+8+KansNBr_ijuuyCTu=v1mg@mail.gmail.com>
 <20180222020633.GC27147@rodete-desktop-imager.corp.google.com> <20180222094009.GO25201@hirez.programming.kicks-ass.net>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 22 Feb 2018 08:23:40 -0800
Message-ID: <CAKOZueuPh5OA_sBTNgHdx5+UYCGcUm_n3fwwVuYGXhi2C0jjqg@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Content-Type: multipart/alternative; boundary="001a113fc1b8842faa0565cf7704"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.com>

--001a113fc1b8842faa0565cf7704
Content-Type: text/plain; charset="UTF-8"

On Feb 22, 2018 1:40 AM, "Peter Zijlstra" <peterz@infradead.org> wrote:

On Thu, Feb 22, 2018 at 11:06:33AM +0900, Minchan Kim wrote:
> On Wed, Feb 21, 2018 at 04:23:43PM -0800, Daniel Colascione wrote:
> >  kernel/sched/core.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index a7bf32aabfda..7f197a7698ee 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(void)
> >         struct task_struct *tsk = current;
> >
> >         sched_submit_work(tsk);
> > +       if (tsk->mm)
> > +               sync_mm_rss(tsk->mm);
> > +
> >         do {
> >                 preempt_disable();
> >                 __schedule(false);
> >

Obviously I completely hate that; and you really _should_ have Cc'ed me
earlier ;-)


I thought I might get a reaction like that. :-)


That it still well over 100 cycles in the case when all counters did
change. Far _far_ more if the mm counters are contended (up to 150 times
more is quite possible).


I suppose it doesn't help to sync the counters only when dirty, detecting
this situation with a task status flag or something?

> > > > Ping? Is this approach just a bad idea? We could instead just
manually sync
> > > > all mm-attached tasks at counter-retrieval time.
> > >
> > > IMHO, yes, it should be done when user want to see which would be
really
> > > cold path while this shecule function is hot.
> > >
> >
> > The problem with doing it that way is that we need to look at each task
> > attached to a particular mm. AFAIK (and please tell me if I'm wrong),
the
> > only way to do that is to iterate over all processes, and for each
process
> > attached to the mm we want, iterate over all its tasks (since each one
has
> > to have the same mm, I think). Does that sound right?

You could just iterate the thread group and call it a day. Yes strictly
speaking its possible to have mm's shared outside the thread group,
practically that 'never' happens.

CLONE_VM without CLONE_THREAD just isn't a popular thing afaik.

So while its not perfect, it might well be good enough.


Take a look at the other patch I posted. Seems to work.

--001a113fc1b8842faa0565cf7704
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_extra"><div class=3D"gmail_quote=
">On Feb 22, 2018 1:40 AM, &quot;Peter Zijlstra&quot; &lt;<a href=3D"mailto=
:peterz@infradead.org">peterz@infradead.org</a>&gt; wrote:<br type=3D"attri=
bution"><blockquote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex"><div class=3D"quoted-text">On Thu, Feb 22,=
 2018 at 11:06:33AM +0900, Minchan Kim wrote:<br>
&gt; On Wed, Feb 21, 2018 at 04:23:43PM -0800, Daniel Colascione wrote:<br>
</div><div class=3D"quoted-text">&gt; &gt;=C2=A0 kernel/sched/core.c | 3 ++=
+<br>
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
<br>
</div>Obviously I completely hate that; and you really _should_ have Cc&#39=
;ed me<br>
earlier ;-)<br></blockquote></div></div></div><div dir=3D"auto"><br></div><=
div dir=3D"auto">I thought I might get a reaction like that. :-)</div><div =
dir=3D"auto"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockqu=
ote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex">
<br>
That it still well over 100 cycles in the case when all counters did<br>
change. Far _far_ more if the mm counters are contended (up to 150 times<br=
>
more is quite possible).<br></blockquote></div></div></div><div dir=3D"auto=
"><br></div><div dir=3D"auto">I suppose it doesn&#39;t help to sync the cou=
nters only when dirty, detecting this situation with a task status flag or =
something?</div><div dir=3D"auto"><br></div><div dir=3D"auto"><div class=3D=
"gmail_extra"><div class=3D"gmail_quote"><blockquote class=3D"quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div cla=
ss=3D"quoted-text">
&gt; &gt; &gt; &gt; Ping? Is this approach just a bad idea? We could instea=
d just manually sync<br>
&gt; &gt; &gt; &gt; all mm-attached tasks at counter-retrieval time.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; IMHO, yes, it should be done when user want to see which wou=
ld be really<br>
&gt; &gt; &gt; cold path while this shecule function is hot.<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; The problem with doing it that way is that we need to look at eac=
h task<br>
&gt; &gt; attached to a particular mm. AFAIK (and please tell me if I&#39;m=
 wrong), the<br>
&gt; &gt; only way to do that is to iterate over all processes, and for eac=
h process<br>
&gt; &gt; attached to the mm we want, iterate over all its tasks (since eac=
h one has<br>
&gt; &gt; to have the same mm, I think). Does that sound right?<br>
<br>
</div>You could just iterate the thread group and call it a day. Yes strict=
ly<br>
speaking its possible to have mm&#39;s shared outside the thread group,<br>
practically that &#39;never&#39; happens.=C2=A0<br>
<br>
CLONE_VM without CLONE_THREAD just isn&#39;t a popular thing afaik.<br>
<br>
So while its not perfect, it might well be good enough.<br></blockquote></d=
iv></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">Take a look at=
 the other patch I posted. Seems to work.=C2=A0</div><div dir=3D"auto"><div=
 class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote class=3D"quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
</blockquote></div><br></div></div></div>

--001a113fc1b8842faa0565cf7704--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
