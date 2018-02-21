Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33DDE6B0008
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:05:07 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r1so2496393ioa.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:05:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n144sor9505232iod.244.2018.02.21.11.05.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 11:05:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180205220325.197241-1-dancol@google.com>
References: <20180205220325.197241-1-dancol@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 21 Feb 2018 11:05:04 -0800
Message-ID: <CAKOZues_C1BUh82Qyd2AA1==JA8v+ahzVzJQsTDKVOJMSRVGRw@mail.gmail.com>
Subject: Re: [PATCH] Synchronize task mm counters on context switch
Content-Type: multipart/alternative; boundary="94eb2c189b8ce24b120565bd9ac2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Daniel Colascione <dancol@google.com>

--94eb2c189b8ce24b120565bd9ac2
Content-Type: text/plain; charset="UTF-8"

On Mon, Feb 5, 2018 at 2:03 PM, Daniel Colascione <dancol@google.com> wrote:

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
> This patch flushes counters on context switch. This way, we bound the
> amount of unaccounted memory without forcing tasks to flush to the
> mm-wide counters on each minor page fault. The flush operation should
> be cheap: we only have a few counters, adjacent in struct task, and we
> don't atomically write to the mm counters unless we've changed
> something since the last flush.
>
> Signed-off-by: Daniel Colascione <dancol@google.com>
> ---
>  kernel/sched/core.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index a7bf32aabfda..7f197a7698ee 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(void)
>         struct task_struct *tsk = current;
>
>         sched_submit_work(tsk);
> +       if (tsk->mm)
> +               sync_mm_rss(tsk->mm);
> +
>         do {
>                 preempt_disable();
>                 __schedule(false);
>


Ping? Is this approach just a bad idea? We could instead just manually sync
all mm-attached tasks at counter-retrieval time.

--94eb2c189b8ce24b120565bd9ac2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On M=
on, Feb 5, 2018 at 2:03 PM, Daniel Colascione <span dir=3D"ltr">&lt;<a href=
=3D"mailto:dancol@google.com" target=3D"_blank">dancol@google.com</a>&gt;</=
span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex">When SPLIT_RSS_COUNTING is i=
n use (which it is on SMP systems,<br>
generally speaking), we buffer certain changes to mm-wide counters<br>
through counters local to the current struct task, flushing them to<br>
the mm after seeing 64 page faults, as well as on task exit and<br>
exec. This scheme can leave a large amount of memory unaccounted-for<br>
in process memory counters, especially for processes with many threads<br>
(each of which gets 64 &quot;free&quot; faults), and it produces an<br>
inconsistency with the same memory counters scanned VMA-by-VMA using<br>
smaps. This inconsistency can persist for an arbitrarily long time,<br>
since there is no way to force a task to flush its counters to its mm.<br>
<br>
This patch flushes counters on context switch. This way, we bound the<br>
amount of unaccounted memory without forcing tasks to flush to the<br>
mm-wide counters on each minor page fault. The flush operation should<br>
be cheap: we only have a few counters, adjacent in struct task, and we<br>
don&#39;t atomically write to the mm counters unless we&#39;ve changed<br>
something since the last flush.<br>
<br>
Signed-off-by: Daniel Colascione &lt;<a href=3D"mailto:dancol@google.com">d=
ancol@google.com</a>&gt;<br>
---<br>
=C2=A0kernel/sched/core.c | 3 +++<br>
=C2=A01 file changed, 3 insertions(+)<br>
<br>
diff --git a/kernel/sched/core.c b/kernel/sched/core.c<br>
index a7bf32aabfda..7f197a7698ee 100644<br>
--- a/kernel/sched/core.c<br>
+++ b/kernel/sched/core.c<br>
@@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(void)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct task_struct *tsk =3D current;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 sched_submit_work(tsk);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (tsk-&gt;mm)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_mm_rss(tsk-&gt=
;mm);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 do {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 preempt_disable();<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __schedule(false);<=
br></blockquote><div><br></div><div>=C2=A0</div><div>Ping? Is this approach=
 just a bad idea? We could instead just manually sync all mm-attached tasks=
 at counter-retrieval time.</div></div><br></div></div>

--94eb2c189b8ce24b120565bd9ac2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
