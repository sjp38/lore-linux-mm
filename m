Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8FA828DF
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 13:35:30 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id w75so52570470oie.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:35:30 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id z2si6917697oek.73.2016.01.22.10.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 10:35:29 -0800 (PST)
Received: by mail-ob0-x233.google.com with SMTP id ba1so70731741obb.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:35:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160122163324.GH26192@esperanza>
References: <CAKB58ikDkzc8REt31WBkD99+hxNzjK4+FBmhkgS+NVrC9vjMSg@mail.gmail.com>
	<20160122135042.GF26192@esperanza>
	<20160122144854.GA14432@cmpxchg.org>
	<20160122155104.GG32380@htj.duckdns.org>
	<20160122163324.GH26192@esperanza>
Date: Fri, 22 Jan 2016 10:35:29 -0800
Message-ID: <CAKB58ikCDFJbtkV7XZyNam2s4wrND-N2RH6Jt0=gPg13RvQfrw@mail.gmail.com>
Subject: Re: PROBLEM: BUG when using memory.kmem.limit_in_bytes
From: Brian Christiansen <brian.o.christiansen@gmail.com>
Content-Type: multipart/alternative; boundary=089e0149d21ccb76300529f07bc1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

--089e0149d21ccb76300529f07bc1
Content-Type: text/plain; charset=UTF-8

On Fri, Jan 22, 2016 at 8:33 AM, Vladimir Davydov <vdavydov@virtuozzo.com>
wrote:

> On Fri, Jan 22, 2016 at 10:51:04AM -0500, Tejun Heo wrote:
> > On Fri, Jan 22, 2016 at 09:48:54AM -0500, Johannes Weiner wrote:
> > > On Fri, Jan 22, 2016 at 04:50:42PM +0300, Vladimir Davydov wrote:
> > > > From first glance, it looks like the bug was triggered, because
> > > > mem_cgroup_css_offline was run for a child cgroup earlier than for
> its
> > > > parent. This couldn't happen for sure before the cgroup was switched
> to
> > > > percpu_ref, because cgroup_destroy_wq has always had max_active == 1.
> > > > Now, however, it looks like this is perfectly possible for
> > > > css_killed_ref_fn is called from an rcu callback - see kill_css ->
> > > > percpu_ref_kill_and_confirm. This breaks kmemcg assumptions.
> > > >
> > > > I'll take a look what can be done about that.
> > >
> > > It's an acknowledged problem in the cgroup core then, and not an issue
> > > with kmemcg. Tejun sent a fix to correct the offlining order here:
> > >
> > >
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1056544.html
> >
> > Patche descriptions updated and applied to cgroup/for-4.5-fixes.
> >
> >  http://lkml.kernel.org/g/20160122154503.GD32380@htj.duckdns.org
> >  http://lkml.kernel.org/g/20160122154552.GE32380@htj.duckdns.org
>
> I couldn't reproduce the issue with the two patches applied. Looks like
> they fix it.
>
> Thanks,
> Vladimir
>

Thanks for the quick turn around! I'll test it when it gets into the
mainline. Do you know what versions the fixes will go into?

Thanks,
Brian

--089e0149d21ccb76300529f07bc1
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On F=
ri, Jan 22, 2016 at 8:33 AM, Vladimir Davydov <span dir=3D"ltr">&lt;<a href=
=3D"mailto:vdavydov@virtuozzo.com" target=3D"_blank">vdavydov@virtuozzo.com=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">O=
n Fri, Jan 22, 2016 at 10:51:04AM -0500, Tejun Heo wrote:<br>
&gt; On Fri, Jan 22, 2016 at 09:48:54AM -0500, Johannes Weiner wrote:<br>
&gt; &gt; On Fri, Jan 22, 2016 at 04:50:42PM +0300, Vladimir Davydov wrote:=
<br>
&gt; &gt; &gt; From first glance, it looks like the bug was triggered, beca=
use<br>
&gt; &gt; &gt; mem_cgroup_css_offline was run for a child cgroup earlier th=
an for its<br>
&gt; &gt; &gt; parent. This couldn&#39;t happen for sure before the cgroup =
was switched to<br>
&gt; &gt; &gt; percpu_ref, because cgroup_destroy_wq has always had max_act=
ive =3D=3D 1.<br>
&gt; &gt; &gt; Now, however, it looks like this is perfectly possible for<b=
r>
&gt; &gt; &gt; css_killed_ref_fn is called from an rcu callback - see kill_=
css -&gt;<br>
&gt; &gt; &gt; percpu_ref_kill_and_confirm. This breaks kmemcg assumptions.=
<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I&#39;ll take a look what can be done about that.<br>
&gt; &gt;<br>
&gt; &gt; It&#39;s an acknowledged problem in the cgroup core then, and not=
 an issue<br>
&gt; &gt; with kmemcg. Tejun sent a fix to correct the offlining order here=
:<br>
&gt; &gt;<br>
&gt; &gt; <a href=3D"https://www.mail-archive.com/linux-kernel@vger.kernel.=
org/msg1056544.html" rel=3D"noreferrer" target=3D"_blank">https://www.mail-=
archive.com/linux-kernel@vger.kernel.org/msg1056544.html</a><br>
&gt;<br>
&gt; Patche descriptions updated and applied to cgroup/for-4.5-fixes.<br>
&gt;<br>
&gt;=C2=A0 <a href=3D"http://lkml.kernel.org/g/20160122154503.GD32380@htj.d=
uckdns.org" rel=3D"noreferrer" target=3D"_blank">http://lkml.kernel.org/g/2=
0160122154503.GD32380@htj.duckdns.org</a><br>
&gt;=C2=A0 <a href=3D"http://lkml.kernel.org/g/20160122154552.GE32380@htj.d=
uckdns.org" rel=3D"noreferrer" target=3D"_blank">http://lkml.kernel.org/g/2=
0160122154552.GE32380@htj.duckdns.org</a><br>
<br>
</span>I couldn&#39;t reproduce the issue with the two patches applied. Loo=
ks like<br>
they fix it.<br>
<br>
Thanks,<br>
Vladimir<br>
</blockquote></div><br></div><div class=3D"gmail_extra">Thanks for the quic=
k turn around! I&#39;ll test it when it gets into the mainline. Do you know=
 what versions the fixes will go into?</div><div class=3D"gmail_extra"><br>=
</div><div class=3D"gmail_extra">Thanks,<br>Brian</div></div>

--089e0149d21ccb76300529f07bc1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
