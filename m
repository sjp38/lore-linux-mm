Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CAFD56B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 01:22:26 -0400 (EDT)
Received: by vws4 with SMTP id 4so2565919vws.14
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 22:22:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
	<20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 10 Jun 2011 13:21:46 +0800
Message-ID: <BANLkTi=_-md7tes5GPcYh5Bpd=g_FVaagw@mail.gmail.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
From: Xiaotian Feng <xtfeng@gmail.com>
Content-Type: multipart/alternative; boundary=20cf307f37b6fb030704a554befa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

--20cf307f37b6fb030704a554befa
Content-Type: text/plain; charset=UTF-8

On Fri, Jun 10, 2011 at 12:30 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> I think this can be a fix.
> maybe good to CC Oleg.

==
> From dff52fb35af0cf36486965d19ee79e04b59f1dc4 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 10 Jun 2011 13:15:14 +0900
> Subject: [PATCH] [BUGFIX] update mm->owner even if no next owner.
>
> A panic is reported.
>
> > Call Trace:
> >  [<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> >  [<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> >  [<ffffffff810493f3>] ? need_resched+0x23/0x2d
> >  [<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> >  [<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> >  [<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> >  [<ffffffff81134024>] khugepaged+0x5da/0xfaf
> >  [<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> >  [<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> >  [<ffffffff81078625>] kthread+0xa8/0xb0
> >  [<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> >  [<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> >  [<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> >  [<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a
>
> The code is.
> >         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
> >                                 struct mem_cgroup, css);
>
>
> What happens here is accssing a freed task struct "p" from mm->owner.
> So, it's doubtful that mm->owner points to freed task struct.
>
>
But from the bug itself, it looks more likely kernel is hitting a freed
p->cgroups, right?
If p is already freed, the kernel will fault on
781cc62d: 8b 82 fc 08 00 00       mov    0x8fc(%edx),%eax

Then you will not get a value of 6b6b6b87, right?

--20cf307f37b6fb030704a554befa
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Jun 10, 2011 at 12:30 PM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wr=
ote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<br>
I think this can be a fix.<br>
maybe good to CC Oleg.=C2=A0</blockquote><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
=3D=3D<br>
>From dff52fb35af0cf36486965d19ee79e04b59f1dc4 Mon Sep 17 00:00:00 2001<br>
From: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.co=
m" target=3D"_blank">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
Date: Fri, 10 Jun 2011 13:15:14 +0900<br>
Subject: [PATCH] [BUGFIX] update mm-&gt;owner even if no next owner.<br>
<br>
A panic is reported.<br>
<br>
&gt; Call Trace:<br>
&gt; =C2=A0[&lt;ffffffff81139792&gt;] mem_cgroup_from_task+0x15/0x17<br>
&gt; =C2=A0[&lt;ffffffff8113a75a&gt;] __mem_cgroup_try_charge+0x148/0x4b4<b=
r>
&gt; =C2=A0[&lt;ffffffff810493f3&gt;] ? need_resched+0x23/0x2d<br>
&gt; =C2=A0[&lt;ffffffff814cbf43&gt;] ? preempt_schedule+0x46/0x4f<br>
&gt; =C2=A0[&lt;ffffffff8113afe8&gt;] mem_cgroup_charge_common+0x9a/0xce<br=
>
&gt; =C2=A0[&lt;ffffffff8113b6d1&gt;] mem_cgroup_newpage_charge+0x5d/0x5f<b=
r>
&gt; =C2=A0[&lt;ffffffff81134024&gt;] khugepaged+0x5da/0xfaf<br>
&gt; =C2=A0[&lt;ffffffff81078ea0&gt;] ? __init_waitqueue_head+0x4b/0x4b<br>
&gt; =C2=A0[&lt;ffffffff81133a4a&gt;] ? add_mm_counter.constprop.5+0x13/0x1=
3<br>
&gt; =C2=A0[&lt;ffffffff81078625&gt;] kthread+0xa8/0xb0<br>
&gt; =C2=A0[&lt;ffffffff814d13e8&gt;] ? sub_preempt_count+0xa1/0xb4<br>
&gt; =C2=A0[&lt;ffffffff814d5664&gt;] kernel_thread_helper+0x4/0x10<br>
&gt; =C2=A0[&lt;ffffffff814ce858&gt;] ? retint_restore_args+0x13/0x13<br>
&gt; =C2=A0[&lt;ffffffff8107857d&gt;] ? __init_kthread_worker+0x5a/0x5a<br>
<br>
The code is.<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 return container_of(task_subsys_state(p, m=
em_cgroup_subsys_id),<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup, css);<br>
<br>
<br>
What happens here is accssing a freed task struct &quot;p&quot; from mm-&gt=
;owner.<br>
So, it&#39;s doubtful that mm-&gt;owner points to freed task struct.<br>
<br></blockquote><div><br></div><div>But from the bug itself, it looks more=
 likely kernel is hitting a freed p-&gt;cgroups, right?</div><div>If p is a=
lready freed, the kernel will fault on=C2=A0</div><div>781cc62d: 8b 82 fc 0=
8 00 00 =C2=A0 =C2=A0 =C2=A0 mov =C2=A0 =C2=A00x8fc(%edx),%eax</div>
</div><div><br></div><div>Then you will not get a value of 6b6b6b87, right?=
</div>

--20cf307f37b6fb030704a554befa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
