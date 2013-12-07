Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 396106B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 16:04:39 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so1532806yha.40
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 13:04:38 -0800 (PST)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id z48si3217367yha.81.2013.12.07.13.04.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 13:04:38 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id md12so3026641pbc.21
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 13:04:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131207190653.GI21724@cmpxchg.org>
References: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
	<20131204054533.GZ3556@cmpxchg.org>
	<alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
	<20131205025026.GA26777@htj.dyndns.org>
	<alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
	<20131206173438.GE21724@cmpxchg.org>
	<CAAAKZwsh3erB7PyG6FnvJRgrZhf2hDQCZDx3rMM7NdOdYNCzJw@mail.gmail.com>
	<20131207174039.GH21724@cmpxchg.org>
	<CAAAKZwvanMiz8QZVOU0-SUKYzqcaJAXn0HxYs5+=Zakmnbcfbg@mail.gmail.com>
	<20131207190653.GI21724@cmpxchg.org>
Date: Sat, 7 Dec 2013 13:04:36 -0800
Message-ID: <CAAAKZwvL-Mz3wPRoA61_qyrLKMHF=f+T3drDEhMJXWLj7c+BzQ@mail.gmail.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
From: Tim Hockin <thockin@hockin.org>
Content-Type: multipart/alternative; boundary=047d7b6d8d963c7c9004ecf81c6a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

--047d7b6d8d963c7c9004ecf81c6a
Content-Type: text/plain; charset=UTF-8

We have hierarchical "containers".  Jobs exist in these containers.  The
containers can hold sub-containers.

In case of system OOM we want to kill in strict priority order.  From the
root of the hierarchy, choose the lowest priority.  This could be a task or
a memcg.  If a memcg, recurse.

We CAN do it in kernel (in fact we do, and I argued for that, and David
acquiesced).  But doing it in kernel means changes are slow and risky.

What we really have is a bunch of features that we offer to our users that
need certain OOM-time behaviors and guarantees to be implemented.  I don't
expect that most of our changes are useful for anyone outside of Google,
really. They come with a lot of environmental assumptions.  This is why
David finally convinced me it was easier to release changes, to fix bugs,
and to update kernels if we do this in userspace.

I apologize if I am not giving you what you want.  I am typing on a phone
at the moment.  If this still doesn't help I can try from a computer later.

Tim
On Dec 7, 2013 11:07 AM, "Johannes Weiner" <hannes@cmpxchg.org> wrote:

> On Sat, Dec 07, 2013 at 10:12:19AM -0800, Tim Hockin wrote:
> > You more or less described the fundamental change - a score per memcg,
> with
> > a recursive OOM killer which evaluates scores between siblings at the
> same
> > level.
> >
> > It gets a bit complicated because we have need if wider scoring ranges
> than
> > are provided by default
>
> If so, I'm sure you can make a convincing case to widen the internal
> per-task score ranges.  The per-memcg score ranges have not even be
> defined, so this is even easier.
>
> > and because we score PIDs against mcgs at a given scope.
>
> You are describing bits of a solution, not a problem.  And I can't
> possibly infer a problem from this.
>
> > We also have some tiebreaker heuristic (age).
>
> Either periodically update the per-memcg score from userspace or
> implement this in the kernel.  We have considered CPU usage
> history/runtime etc. in the past when picking an OOM victim task.
>
> But I'm again just speculating what your problem is, so this may or
> may not be a feasible solution.
>
> > We also have a handful of features that depend on OOM handling like the
> > aforementioned automatically growing and changing the actual OOM score
> > depending on usage in relation to various thresholds ( e.g. we sold you
> X,
> > and we allow you to go over X but if you do, your likelihood of death in
> > case of system OOM goes up.
>
> You can trivially monitor threshold events from userspace with the
> existing infrastructure and accordingly update the per-memcg score.
>
> > Do you really want us to teach the kernel policies like this?  It would
> be
> > way easier to do and test in userspace.
>
> Maybe.  Providing fragments of your solution is not an efficient way
> to communicate the problem.  And you have to sell the problem before
> anybody can be expected to even consider your proposal as one of the
> possible solutions.
>

--047d7b6d8d963c7c9004ecf81c6a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">We have hierarchical &quot;containers&quot;.=C2=A0 Jobs exis=
t in these containers.=C2=A0 The containers can hold sub-containers.</p>
<p dir=3D"ltr">In case of system OOM we want to kill in strict priority ord=
er.=C2=A0 From the root of the hierarchy, choose the lowest priority.=C2=A0=
 This could be a task or a memcg.=C2=A0 If a memcg, recurse.=C2=A0 </p>
<p dir=3D"ltr">We CAN do it in kernel (in fact we do, and I argued for that=
, and David acquiesced).=C2=A0 But doing it in kernel means changes are slo=
w and risky.</p>
<p dir=3D"ltr">What we really have is a bunch of features that we offer to =
our users that need certain OOM-time behaviors and guarantees to be impleme=
nted.=C2=A0 I don&#39;t expect that most of our changes are useful for anyo=
ne outside of Google, really. They come with a lot of environmental assumpt=
ions.=C2=A0 This is why David finally convinced me it was easier to release=
 changes, to fix bugs, and to update kernels if we do this in userspace.</p=
>

<p dir=3D"ltr">I apologize if I am not giving you what you want.=C2=A0 I am=
 typing on a phone at the moment.=C2=A0 If this still doesn&#39;t help I ca=
n try from a computer later.</p>
<p dir=3D"ltr">Tim</p>
<div class=3D"gmail_quote">On Dec 7, 2013 11:07 AM, &quot;Johannes Weiner&q=
uot; &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; w=
rote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Sat, Dec 07, 2013 at 10:12:19AM -0800, Tim Hockin wrote:<br>
&gt; You more or less described the fundamental change - a score per memcg,=
 with<br>
&gt; a recursive OOM killer which evaluates scores between siblings at the =
same<br>
&gt; level.<br>
&gt;<br>
&gt; It gets a bit complicated because we have need if wider scoring ranges=
 than<br>
&gt; are provided by default<br>
<br>
If so, I&#39;m sure you can make a convincing case to widen the internal<br=
>
per-task score ranges. =C2=A0The per-memcg score ranges have not even be<br=
>
defined, so this is even easier.<br>
<br>
&gt; and because we score PIDs against mcgs at a given scope.<br>
<br>
You are describing bits of a solution, not a problem. =C2=A0And I can&#39;t=
<br>
possibly infer a problem from this.<br>
<br>
&gt; We also have some tiebreaker heuristic (age).<br>
<br>
Either periodically update the per-memcg score from userspace or<br>
implement this in the kernel. =C2=A0We have considered CPU usage<br>
history/runtime etc. in the past when picking an OOM victim task.<br>
<br>
But I&#39;m again just speculating what your problem is, so this may or<br>
may not be a feasible solution.<br>
<br>
&gt; We also have a handful of features that depend on OOM handling like th=
e<br>
&gt; aforementioned automatically growing and changing the actual OOM score=
<br>
&gt; depending on usage in relation to various thresholds ( e.g. we sold yo=
u X,<br>
&gt; and we allow you to go over X but if you do, your likelihood of death =
in<br>
&gt; case of system OOM goes up.<br>
<br>
You can trivially monitor threshold events from userspace with the<br>
existing infrastructure and accordingly update the per-memcg score.<br>
<br>
&gt; Do you really want us to teach the kernel policies like this? =C2=A0It=
 would be<br>
&gt; way easier to do and test in userspace.<br>
<br>
Maybe. =C2=A0Providing fragments of your solution is not an efficient way<b=
r>
to communicate the problem. =C2=A0And you have to sell the problem before<b=
r>
anybody can be expected to even consider your proposal as one of the<br>
possible solutions.<br>
</blockquote></div>

--047d7b6d8d963c7c9004ecf81c6a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
