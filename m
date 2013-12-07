Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id E9F636B00B2
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 11:38:22 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so1424651yha.21
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 08:38:22 -0800 (PST)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id r49si2623469yho.267.2013.12.07.08.38.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 08:38:21 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so2825417pbc.11
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 08:38:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131206173438.GE21724@cmpxchg.org>
References: <20131120152251.GA18809@dhcp22.suse.cz>
	<alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
	<20131128115458.GK2761@dhcp22.suse.cz>
	<alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
	<20131204054533.GZ3556@cmpxchg.org>
	<alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
	<20131205025026.GA26777@htj.dyndns.org>
	<alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
	<20131206173438.GE21724@cmpxchg.org>
Date: Sat, 7 Dec 2013 08:38:20 -0800
Message-ID: <CAAAKZwsh3erB7PyG6FnvJRgrZhf2hDQCZDx3rMM7NdOdYNCzJw@mail.gmail.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
From: Tim Hockin <thockin@hockin.org>
Content-Type: multipart/alternative; boundary=bcaec520ea03f803a304ecf46301
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

--bcaec520ea03f803a304ecf46301
Content-Type: text/plain; charset=UTF-8

We actually started with kernel patches all h these lines - per-memcg
scores and all of our crazy policy requirements.

It turns out that changing policies is hard.

When David offered the opportunity to manage it all in user space it
sounded like a great idea.

If this can be made to work as a high prio daemon with access to reserves,
we would like it.

Tim
On Dec 6, 2013 9:36 AM, "Johannes Weiner" <hannes@cmpxchg.org> wrote:

> On Thu, Dec 05, 2013 at 03:49:57PM -0800, David Rientjes wrote:
> > On Wed, 4 Dec 2013, Tejun Heo wrote:
> >
> > > Hello,
> > >
> >
> > Tejun, how are you?
> >
> > > Umm.. without delving into details, aren't you basically creating a
> > > memory cgroup inside a memory cgroup?  Doesn't sound like a
> > > particularly well thought-out plan to me.
> > >
> >
> > I agree that we wouldn't need such support if we are only addressing
> memcg
> > oom conditions.  We could do things like A/memory.limit_in_bytes == 128M
> > and A/b/memory.limit_in_bytes == 126MB and then attach the process
> waiting
> > on A/b/memory.oom_control to A and that would work perfect.
> >
> > However, we also need to discuss system oom handling.  We have an
> interest
> > in being able to allow userspace to handle system oom conditions since
> the
> > policy will differ depending on machine and we can't encode every
> possible
> > mechanism into the kernel.  For example, on system oom we want to kill a
> > process from the lowest priority top-level memcg.  We lack that ability
> > entirely in the kernel and since the sum of our top-level memcgs
> > memory.limit_in_bytes exceeds the amount of present RAM, we run into
> these
> > oom conditions a _lot_.
>
> A simple and natural solution to this is to have the global OOM killer
> respect cgroups.  You go through all the effort of carefully grouping
> tasks into bigger entities that you then arrange hierarchically.  The
> global OOM killer should not just treat all tasks as equal peers.
>
> We can add a per-cgroup OOM priority knob and have the global OOM
> handler pick victim tasks from the one or more groups that have the
> lowest priority.
>
> Out of the box, every cgroup has the same priority, which means we can
> add this feature without changing the default behavior.
>
> > So the first step, in my opinion, is to add a system oom notification on
> > the root memcg's memory.oom_control which currently allows registering an
> > eventfd() notification but never actually triggers.  I did that in a
> patch
> > and it is was merged into -mm but was pulled out for later discussion.
> >
> > Then, we need to ensure that the userspace that is registered to handle
> > such events and that is difficult to do when the system is oom.  The
> > proposal is to allow such processes, now marked as PF_OOM_HANDLER, to be
> > able to access pre-defined per-zone memory reserves in the page
> allocator.
> > The only special handling for PF_OOM_HANDLER in the page allocator itself
> > would be under such oom conditions (memcg oom conditions have no problem
> > allocating the memory, only charging it).  The amount of reserves would
> be
> > defined as memory.oom_reserve_in_bytes from within the root memcg as
> > defined by this patch, i.e. allow this amount of memory to be allocated
> in
> > the page allocator for PF_OOM_HANDLER below the per-zone min watermarks.
> >
> > This, I believe, is the cleanest interface for users who choose to use a
> > non-default policy by setting memory.oom_reserve_in_bytes and constrains
> > all of the code to memcg which you have to configure for such support.
> >
> > The system oom condition is not addressed in this patch series, although
> > the PF_OOM_HANDLER bit can be used for that purpose.  I didn't post that
> > patch because the notification on the root memcg's memory.oom_control in
> > such conditions is currently being debated, so we need to solve that
> issue
> > first.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--bcaec520ea03f803a304ecf46301
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">We actually started with kernel patches all h these lines - =
per-memcg scores and all of our crazy policy requirements.</p>
<p dir=3D"ltr">It turns out that changing policies is hard.</p>
<p dir=3D"ltr">When David offered the opportunity to manage it all in user =
space it sounded like a great idea.</p>
<p dir=3D"ltr">If this can be made to work as a high prio daemon with acces=
s to reserves, we would like it.</p>
<p dir=3D"ltr">Tim</p>
<div class=3D"gmail_quote">On Dec 6, 2013 9:36 AM, &quot;Johannes Weiner&qu=
ot; &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wr=
ote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Thu, Dec 05, 2013 at 03:49:57PM -0800, David Rientjes wrote:<br>
&gt; On Wed, 4 Dec 2013, Tejun Heo wrote:<br>
&gt;<br>
&gt; &gt; Hello,<br>
&gt; &gt;<br>
&gt;<br>
&gt; Tejun, how are you?<br>
&gt;<br>
&gt; &gt; Umm.. without delving into details, aren&#39;t you basically crea=
ting a<br>
&gt; &gt; memory cgroup inside a memory cgroup? =C2=A0Doesn&#39;t sound lik=
e a<br>
&gt; &gt; particularly well thought-out plan to me.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I agree that we wouldn&#39;t need such support if we are only addressi=
ng memcg<br>
&gt; oom conditions. =C2=A0We could do things like A/memory.limit_in_bytes =
=3D=3D 128M<br>
&gt; and A/b/memory.limit_in_bytes =3D=3D 126MB and then attach the process=
 waiting<br>
&gt; on A/b/memory.oom_control to A and that would work perfect.<br>
&gt;<br>
&gt; However, we also need to discuss system oom handling. =C2=A0We have an=
 interest<br>
&gt; in being able to allow userspace to handle system oom conditions since=
 the<br>
&gt; policy will differ depending on machine and we can&#39;t encode every =
possible<br>
&gt; mechanism into the kernel. =C2=A0For example, on system oom we want to=
 kill a<br>
&gt; process from the lowest priority top-level memcg. =C2=A0We lack that a=
bility<br>
&gt; entirely in the kernel and since the sum of our top-level memcgs<br>
&gt; memory.limit_in_bytes exceeds the amount of present RAM, we run into t=
hese<br>
&gt; oom conditions a _lot_.<br>
<br>
A simple and natural solution to this is to have the global OOM killer<br>
respect cgroups. =C2=A0You go through all the effort of carefully grouping<=
br>
tasks into bigger entities that you then arrange hierarchically. =C2=A0The<=
br>
global OOM killer should not just treat all tasks as equal peers.<br>
<br>
We can add a per-cgroup OOM priority knob and have the global OOM<br>
handler pick victim tasks from the one or more groups that have the<br>
lowest priority.<br>
<br>
Out of the box, every cgroup has the same priority, which means we can<br>
add this feature without changing the default behavior.<br>
<br>
&gt; So the first step, in my opinion, is to add a system oom notification =
on<br>
&gt; the root memcg&#39;s memory.oom_control which currently allows registe=
ring an<br>
&gt; eventfd() notification but never actually triggers. =C2=A0I did that i=
n a patch<br>
&gt; and it is was merged into -mm but was pulled out for later discussion.=
<br>
&gt;<br>
&gt; Then, we need to ensure that the userspace that is registered to handl=
e<br>
&gt; such events and that is difficult to do when the system is oom. =C2=A0=
The<br>
&gt; proposal is to allow such processes, now marked as PF_OOM_HANDLER, to =
be<br>
&gt; able to access pre-defined per-zone memory reserves in the page alloca=
tor.<br>
&gt; The only special handling for PF_OOM_HANDLER in the page allocator its=
elf<br>
&gt; would be under such oom conditions (memcg oom conditions have no probl=
em<br>
&gt; allocating the memory, only charging it). =C2=A0The amount of reserves=
 would be<br>
&gt; defined as memory.oom_reserve_in_bytes from within the root memcg as<b=
r>
&gt; defined by this patch, i.e. allow this amount of memory to be allocate=
d in<br>
&gt; the page allocator for PF_OOM_HANDLER below the per-zone min watermark=
s.<br>
&gt;<br>
&gt; This, I believe, is the cleanest interface for users who choose to use=
 a<br>
&gt; non-default policy by setting memory.oom_reserve_in_bytes and constrai=
ns<br>
&gt; all of the code to memcg which you have to configure for such support.=
<br>
&gt;<br>
&gt; The system oom condition is not addressed in this patch series, althou=
gh<br>
&gt; the PF_OOM_HANDLER bit can be used for that purpose. =C2=A0I didn&#39;=
t post that<br>
&gt; patch because the notification on the root memcg&#39;s memory.oom_cont=
rol in<br>
&gt; such conditions is currently being debated, so we need to solve that i=
ssue<br>
&gt; first.<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/" target=3D=
"_blank">http://www.tux.org/lkml/</a><br>
</blockquote></div>

--bcaec520ea03f803a304ecf46301--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
