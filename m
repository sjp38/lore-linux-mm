Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 668536B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 13:24:05 -0500 (EST)
Received: by qyk29 with SMTP id 29so2791856qyk.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 10:24:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111109090919.C2D538AD27@mx2.suse.de>
References: <20111109090919.C2D538AD27@mx2.suse.de>
Date: Wed, 9 Nov 2011 10:24:01 -0800
Message-ID: <CALWz4ixzXXueAn_hMKiC-BRc-cRbFkmCbDgy=VJjsuXRZD_qDg@mail.gmail.com>
Subject: Re: [PATCH resend] oom: do not kill tasks with oom_score_adj OOM_SCORE_ADJ_MIN
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016367f956c60e92a04b151646a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>

--0016367f956c60e92a04b151646a
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Nov 4, 2011 at 4:59 AM, Michal Hocko <mhocko@suse.cz> wrote:

> c9f01245 (oom: remove oom_disable_count) has removed oom_disable_count
> counter which has been used for early break out from oom_badness so we
> could never select a task with oom_score_adj set to OOM_SCORE_ADJ_MIN
> (oom disabled).
>
> Now that the counter is gone we are always going through heuristics
> calculation and we always return a non zero positive value.  This
> means that we can end up killing a task with OOM disabled because it is
> indistinguishable from regular tasks with 1% resp. CAP_SYS_ADMIN tasks
> with 3% usage of memory or tasks with oom_score_adj set but OOM enabled.
>
> Let's break out early if the task should have OOM disabled.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index e916168..4465fb8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -185,6 +185,11 @@ unsigned int oom_badness(struct task_struct *p,
> struct mem_cgroup *mem,
>         if (!p)
>                return 0;
>
> +       if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +               task_unlock(p);
> +               return 0;
> +       }
> +
>        /*
>         * The memory controller may have a limit of 0 bytes, so avoid a
> divide
>         * by zero, if necessary.
>


This might be late, but still:

Acked-by: Ying Han <yinghan@google.com>

Thanks for fixing this up.

--Ying

> --
> 1.7.7.1
>
>

--0016367f956c60e92a04b151646a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Nov 4, 2011 at 4:59 AM, Michal H=
ocko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">c9f01245 (oom: remove oom_disable_count) has removed oom_=
disable_count<br>
counter which has been used for early break out from oom_badness so we<br>
could never select a task with oom_score_adj set to OOM_SCORE_ADJ_MIN<br>
(oom disabled).<br>
<br>
Now that the counter is gone we are always going through heuristics<br>
calculation and we always return a non zero positive value. =A0This<br>
means that we can end up killing a task with OOM disabled because it is<br>
indistinguishable from regular tasks with 1% resp. CAP_SYS_ADMIN tasks<br>
with 3% usage of memory or tasks with oom_score_adj set but OOM enabled.<br=
>
<br>
Let&#39;s break out early if the task should have OOM disabled.<br>
<br>
Signed-off-by: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@su=
se.cz</a>&gt;<br>
Acked-by: David Rientjes &lt;<a href=3D"mailto:rientjes@google.com">rientje=
s@google.com</a>&gt;<br>
</div>Acked-by: KOSAKI Motohiro &lt;<a href=3D"mailto:kosaki.motohiro@jp.fu=
jitsu.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;<br>
<div class=3D"im">---<br>
=A0mm/oom_kill.c | =A0 =A05 +++++<br>
=A01 files changed, 5 insertions(+), 0 deletions(-)<br>
<br>
</div>diff --git a/mm/oom_kill.c b/mm/oom_kill.c<br>
index e916168..4465fb8 100644<br>
--- a/mm/oom_kill.c<br>
+++ b/mm/oom_kill.c<br>
@@ -185,6 +185,11 @@ unsigned int oom_badness(struct task_struct *p, struct=
 mem_cgroup *mem,<br>
<div class=3D"im HOEnZb"> =A0 =A0 =A0 =A0if (!p)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
<br>
+ =A0 =A0 =A0 if (p-&gt;signal-&gt;oom_score_adj =3D=3D OOM_SCORE_ADJ_MIN) =
{<br>
</div><div class=3D"im HOEnZb">+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(p)=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
+ =A0 =A0 =A0 }<br>
</div><div class=3D"HOEnZb"><div class=3D"h5">+<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * The memory controller may have a limit of 0 bytes, so av=
oid a divide<br>
 =A0 =A0 =A0 =A0 * by zero, if necessary.<br></div></div></blockquote><div>=
<br></div><div><br></div><div>This might be late, but still:</div><div><br>=
</div><div><span class=3D"Apple-style-span" style=3D"color: rgb(34, 34, 34)=
; font-family: arial, sans-serif; font-size: 13px; background-color: rgba(2=
55, 255, 255, 0.917969); ">Acked-by: Ying Han &lt;<a href=3D"mailto:yinghan=
@google.com">yinghan@google.com</a>&gt;</span>=A0</div>
<div><br></div><div>Thanks for fixing this up.</div><div><br></div><div>--Y=
ing</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex;"><div class=3D"HOEnZb"><div class=
=3D"h5">

</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.7.7.1<br>
<br>
</font></span></blockquote></div><br>

--0016367f956c60e92a04b151646a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
