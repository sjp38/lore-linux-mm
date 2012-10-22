Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 831BF6B0062
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 22:16:44 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so2907699vbk.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 19:16:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121019160425.GA10175@dhcp22.suse.cz>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
	<20121019160425.GA10175@dhcp22.suse.cz>
Date: Mon, 22 Oct 2012 10:16:43 +0800
Message-ID: <CAKWKT+Z-SZb1=3rwLm+urs3fghQ3M6pdOR_rzXKCevoad11a5g@mail.gmail.com>
Subject: Re: process hangs on do_exit when oom happens
From: Qiang Gao <gaoqiangscut@gmail.com>
Content-Type: multipart/alternative; boundary=20cf3071c812d2c6b304cc9c7134
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org

--20cf3071c812d2c6b304cc9c7134
Content-Type: text/plain; charset=ISO-8859-1

I don't know whether  the process will exit finally, bug this stack lasts
for hours, which is obviously unnormal.
The situation:  we use a command calld "cglimit" to fork-and-exec the
worker process,and the "cglimit" will
set some limitation on the worker with cgroup. for now,we limit the
memory,and we also use cpu cgroup,but with
no limiation,so when the worker is running, the cgroup directory looks like
following:

/cgroup/memory/worker : this directory limit the memory
/cgroup/cpu/worker :with no limit,but worker process is in.

for some reason(some other process we didn't consider),  the worker process
invoke global oom-killer,
not cgroup-oom-killer.  then the worker process hangs there.

Actually, if we didn't set the worker process into the cpu cgroup, this
will never happens.



On Sat, Oct 20, 2012 at 12:04 AM, Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 17-10-12 18:23:34, gaoqiang wrote:
> > I looked up nothing useful with google,so I'm here for help..
> >
> > when this happens:  I use memcg to limit the memory use of a
> > process,and when the memcg cgroup was out of memory,
> > the process was oom-killed   however,it cannot really complete the
> > exiting. here is the some information
>
> How many tasks are in the group and what kind of memory do they use?
> Is it possible that you were hit by the same issue as described in
> 79dfdacc memcg: make oom_lock 0 and 1 based rather than counter.
>
> > OS version:  centos6.2    2.6.32.220.7.1
>
> Your kernel is quite old and you should be probably asking your
> distribution to help you out. There were many fixes since 2.6.32.
> Are you able to reproduce the same issue with the current vanila kernel?
>
> > /proc/pid/stack
> > ---------------------------------------------------------------
> >
> > [<ffffffff810597ca>] __cond_resched+0x2a/0x40
> > [<ffffffff81121569>] unmap_vmas+0xb49/0xb70
> > [<ffffffff8112822e>] exit_mmap+0x7e/0x140
> > [<ffffffff8105b078>] mmput+0x58/0x110
> > [<ffffffff81061aad>] exit_mm+0x11d/0x160
> > [<ffffffff81061c9d>] do_exit+0x1ad/0x860
> > [<ffffffff81062391>] do_group_exit+0x41/0xb0
> > [<ffffffff81077cd8>] get_signal_to_deliver+0x1e8/0x430
> > [<ffffffff8100a4c4>] do_notify_resume+0xf4/0x8b0
> > [<ffffffff8100b281>] int_signal+0x12/0x17
> > [<ffffffffffffffff>] 0xffffffffffffffff
>
> This looks strange because this is just an exit part which shouldn't
> deadlock or anything. Is this stack stable? Have you tried to take check
> it more times?
>
> --
> Michal Hocko
> SUSE Labs
>

--20cf3071c812d2c6b304cc9c7134
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div>I don&#39;t know whether=A0 the process will exit finally, bug this st=
ack lasts for hours, which is obviously unnormal.<br></div><div>The situati=
on: =A0we use a command calld &quot;cglimit&quot; to fork-and-exec the work=
er process,and the &quot;cglimit&quot; will=A0</div>
<div>set some limitation on the worker with cgroup. for now,we limit the me=
mory,and we also use cpu cgroup,but with</div><div>no limiation,so when the=
 worker is running, the cgroup directory looks like following:</div><div>
<br></div><div>/cgroup/memory/worker : this directory limit the memory</div=
><div>/cgroup/cpu/worker :with no limit,but worker process is in.</div><div=
><br></div><div>for some reason(some other process we didn&#39;t consider),=
 =A0the worker process invoke global oom-killer, </div>
<div>not cgroup-oom-killer. =A0then the worker process hangs there.</div><d=
iv><br></div><div>Actually, if we didn&#39;t set the worker process into th=
e cpu cgroup, this will never happens.</div><div><br></div><div><br></div>
<br><div class=3D"gmail_quote">On Sat, Oct 20, 2012 at 12:04 AM, Michal Hoc=
ko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz" target=3D"_blank=
">mhocko@suse.cz</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Wed 17-10-12 18:23:34, gaoqiang wrote:<br>
&gt; I looked up nothing useful with google,so I&#39;m here for help..<br>
&gt;<br>
&gt; when this happens: =A0I use memcg to limit the memory use of a<br>
&gt; process,and when the memcg cgroup was out of memory,<br>
&gt; the process was oom-killed =A0 however,it cannot really complete the<b=
r>
&gt; exiting. here is the some information<br>
<br>
How many tasks are in the group and what kind of memory do they use?<br>
Is it possible that you were hit by the same issue as described in<br>
79dfdacc memcg: make oom_lock 0 and 1 based rather than counter.<br>
<br>
&gt; OS version: =A0centos6.2 =A0 =A02.6.32.220.7.1<br>
<br>
Your kernel is quite old and you should be probably asking your<br>
distribution to help you out. There were many fixes since 2.6.32.<br>
Are you able to reproduce the same issue with the current vanila kernel?<br=
>
<br>
&gt; /proc/pid/stack<br>
&gt; ---------------------------------------------------------------<br>
&gt;<br>
&gt; [&lt;ffffffff810597ca&gt;] __cond_resched+0x2a/0x40<br>
&gt; [&lt;ffffffff81121569&gt;] unmap_vmas+0xb49/0xb70<br>
&gt; [&lt;ffffffff8112822e&gt;] exit_mmap+0x7e/0x140<br>
&gt; [&lt;ffffffff8105b078&gt;] mmput+0x58/0x110<br>
&gt; [&lt;ffffffff81061aad&gt;] exit_mm+0x11d/0x160<br>
&gt; [&lt;ffffffff81061c9d&gt;] do_exit+0x1ad/0x860<br>
&gt; [&lt;ffffffff81062391&gt;] do_group_exit+0x41/0xb0<br>
&gt; [&lt;ffffffff81077cd8&gt;] get_signal_to_deliver+0x1e8/0x430<br>
&gt; [&lt;ffffffff8100a4c4&gt;] do_notify_resume+0xf4/0x8b0<br>
&gt; [&lt;ffffffff8100b281&gt;] int_signal+0x12/0x17<br>
&gt; [&lt;ffffffffffffffff&gt;] 0xffffffffffffffff<br>
<br>
This looks strange because this is just an exit part which shouldn&#39;t<br=
>
deadlock or anything. Is this stack stable? Have you tried to take check<br=
>
it more times?<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br>

--20cf3071c812d2c6b304cc9c7134--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
