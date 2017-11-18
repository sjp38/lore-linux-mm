Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 627366B0253
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 23:45:05 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id s28so2030982uag.6
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 20:45:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 45sor2052392uar.243.2017.11.17.20.45.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 20:45:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
References: <20171101053244.5218-1-slandden@gmail.com> <20171103063544.13383-1-slandden@gmail.com>
 <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
From: Shawn Landden <slandden@gmail.com>
Date: Fri, 17 Nov 2017 20:45:03 -0800
Message-ID: <CA+49okqZ8CME0EN1xS_cCTc5Q-fGRreg0makhzNNuRpGs3mjfw@mail.gmail.com>
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
Content-Type: multipart/alternative; boundary="f403045f90d041d9e7055e3a84a0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

--f403045f90d041d9e7055e3a84a0
Content-Type: text/plain; charset="UTF-8"

On Fri, Nov 3, 2017 at 2:09 AM, Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 02-11-17 23:35:44, Shawn Landden wrote:
> > It is common for services to be stateless around their main event loop.
> > If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
> > signals to the kernel that epoll_wait() and friends may not complete,
> > and the kernel may send SIGKILL if resources get tight.
> >
> > See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
> >
> > Android uses this memory model for all programs, and having it in the
> > kernel will enable integration with the page cache (not in this
> > series).
> >
> > 16 bytes per process is kinda spendy, but I want to keep
> > lru behavior, which mem_score_adj does not allow. When a supervisor,
> > like Android's user input is keeping track this can be done in
> user-space.
> > It could be pulled out of task_struct if an cross-indexing additional
> > red-black tree is added to support pid-based lookup.
>
> This is still an abuse and the patch is wrong. We really do have an API
> to use I fail to see why you do not use it.
>
When I looked at wait_queue_head_t it was 20 byes.

>
> [...]
> > @@ -1018,6 +1060,24 @@ bool out_of_memory(struct oom_control *oc)
> >                       return true;
> >       }
> >
> > +     /*
> > +      * Check death row for current memcg or global.
> > +      */
> > +     l = oom_target_get_queue(current);
> > +     if (!list_empty(l)) {
> > +             struct task_struct *ts = list_first_entry(l,
> > +                             struct task_struct, se.oom_target_queue);
> > +
> > +             pr_debug("Killing pid %u from EPOLL_KILLME death row.",
> > +                      ts->pid);
> > +
> > +             /* We use SIGKILL instead of the oom killer
> > +              * so as to cleanly interrupt ep_poll()
> > +              */
> > +             send_sig(SIGKILL, ts, 1);
> > +             return true;
> > +     }
>
> Still not NUMA aware and completely backwards. If this is a memcg OOM
> then it is _memcg_ to evaluate not the current. The oom might happen up
> the hierarchy due to hard limit.
>
> But still, you should be very clear _why_ the existing oom tuning is not
> appropropriate and we can think of a way to hanle it better but cramming
> the oom selection this way is simply not acceptable.
> --
> Michal Hocko
> SUSE Labs
>

--f403045f90d041d9e7055e3a84a0
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On F=
ri, Nov 3, 2017 at 2:09 AM, Michal Hocko <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt;</span>=
 wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bor=
der-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Thu 02-11-17 =
23:35:44, Shawn Landden wrote:<br>
&gt; It is common for services to be stateless around their main event loop=
.<br>
&gt; If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it<br>
&gt; signals to the kernel that epoll_wait() and friends may not complete,<=
br>
&gt; and the kernel may send SIGKILL if resources get tight.<br>
&gt;<br>
&gt; See my systemd patch: <a href=3D"https://github.com/shawnl/systemd/tre=
e/prctl" rel=3D"noreferrer" target=3D"_blank">https://github.com/shawnl/<wb=
r>systemd/tree/prctl</a><br>
&gt;<br>
&gt; Android uses this memory model for all programs, and having it in the<=
br>
&gt; kernel will enable integration with the page cache (not in this<br>
&gt; series).<br>
&gt;<br>
&gt; 16 bytes per process is kinda spendy, but I want to keep<br>
&gt; lru behavior, which mem_score_adj does not allow. When a supervisor,<b=
r>
&gt; like Android&#39;s user input is keeping track this can be done in use=
r-space.<br>
&gt; It could be pulled out of task_struct if an cross-indexing additional<=
br>
&gt; red-black tree is added to support pid-based lookup.<br>
<br>
</span>This is still an abuse and the patch is wrong. We really do have an =
API<br>
to use I fail to see why you do not use it.<br></blockquote><div>When I loo=
ked at wait_queue_head_t it was 20 byes.<br></div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">
<br>
[...]<br>
<span class=3D"">&gt; @@ -1018,6 +1060,24 @@ bool out_of_memory(struct oom_=
control *oc)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0return true;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * Check death row for current memcg or global.<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0l =3D oom_target_get_queue(current);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!list_empty(l)) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *t=
s =3D list_first_entry(l,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct, se.oom_target_queue)=
;<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_debug(&quot;Killin=
g pid %u from EPOLL_KILLME death row.&quot;,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ts-&gt;pid);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We use SIGKILL ins=
tead of the oom killer<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * so as to cleanly i=
nterrupt ep_poll()<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0send_sig(SIGKILL, ts,=
 1);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return true;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0}<br>
<br>
</span>Still not NUMA aware and completely backwards. If this is a memcg OO=
M<br>
then it is _memcg_ to evaluate not the current. The oom might happen up<br>
the hierarchy due to hard limit.<br>
<br>
But still, you should be very clear _why_ the existing oom tuning is not<br=
>
appropropriate and we can think of a way to hanle it better but cramming<br=
>
the oom selection this way is simply not acceptable.<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div></div>

--f403045f90d041d9e7055e3a84a0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
