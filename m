Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A416E6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 00:10:35 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p7O4AVca009874
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 21:10:31 -0700
Received: from ywf9 (ywf9.prod.google.com [10.192.6.9])
	by hpaq14.eem.corp.google.com with ESMTP id p7O4AH34019072
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 21:10:30 -0700
Received: by ywf9 with SMTP id 9so685991ywf.4
        for <linux-mm@kvack.org>; Tue, 23 Aug 2011 21:10:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110819135556.GA9662@redhat.com>
References: <1313000433-11537-1-git-send-email-abrestic@google.com>
	<20110819135556.GA9662@redhat.com>
Date: Tue, 23 Aug 2011 21:10:26 -0700
Message-ID: <CALWz4iw-2eejQeji2KTnNNOwuV6un+ZE60FnSWv-TrHrAA5PGA@mail.gmail.com>
Subject: Re: [PATCH] memcg: replace ss->id_lock with a rwlock
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd289baef338a04ab387d04
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Bresticker <abrestic@google.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

--000e0cd289baef338a04ab387d04
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Aug 19, 2011 at 6:55 AM, Johannes Weiner <jweiner@redhat.com> wrote:

> Hello Andrew,
>
> On Wed, Aug 10, 2011 at 11:20:33AM -0700, Andrew Bresticker wrote:
> > While back-porting Johannes Weiner's patch "mm: memcg-aware global
> reclaim"
> > for an internal effort, we noticed a significant performance regression
> > during page-reclaim heavy workloads due to high contention of the
> ss->id_lock.
> > This lock protects idr map, and serializes calls to idr_get_next() in
> > css_get_next() (which is used during the memcg hierarchy walk).  Since
> > idr_get_next() is just doing a look up, we need only serialize it with
> > respect to idr_remove()/idr_get_new().  By making the ss->id_lock a
> > rwlock, contention is greatly reduced and performance improves.
> >
> > Tested: cat a 256m file from a ramdisk in a 128m container 50 times
> > on each core (one file + container per core) in parallel on a NUMA
> > machine.  Result is the time for the test to complete in 1 of the
> > containers.  Both kernels included Johannes' memcg-aware global
> > reclaim patches.
> > Before rwlock patch: 1710.778s
> > After rwlock patch: 152.227s
>
> The reason why there is much more hierarchy walking going on is
> because there was actually a design bug in the hierarchy reclaim.
>
> The old code would pick one memcg and scan it at decreasing priority
> levels until SCAN_CLUSTER_MAX pages were reclaimed.  For each memcg
> scanned with priority level 12, there were SWAP_CLUSTER_MAX pages
> reclaimed.
>
> My last revision would bail the whole hierarchy walk once it reclaimed
> SWAP_CLUSTER_MAX.  Also, at the time, small memcgs were not
> force-scanned yet.  So 128m containers would force the priority level
> to 10 before scanning anything at all (128M / pagesize >> priority),
> and then bail after one or two scanned memcgs.  This means that for
> each SWAP_CLUSTER_MAX reclaimed pages there was a nr_of_containers * 2
> overhead of just walking the hierarchy to no avail.
>

Good point.

To make it a bit clear, the revision which bails out the hierarchy_walk
based on nr_reclaimed is that we are looking at right now.

>
> I changed this and removed the bail condition based on the number of
> reclaimed pages.  Instead, the cycle ends when all reclaimers together
> made a full round-trip through the hierarchy.  The more cgroups, the
> more likely that there are several tasks going into reclaim
> concurrently, it should be a reasonable share of work for each one.
>

The number of reclaim invocations, thus the number of hierarchy walks,
> is back to sane levels again and the id_lock contention should be less
> of an issue.
>

looking forward to see the change.

>
> Your patch still makes sense, but it's probably less urgent.
>

I think the patch itself make senses regardless of the global reclaim
change. It seems to be a
optimization in general.

--Ying

--000e0cd289baef338a04ab387d04
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Aug 19, 2011 at 6:55 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:jweiner@redhat.com">jweine=
r@redhat.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hello Andrew,<br>
<div class=3D"im"><br>
On Wed, Aug 10, 2011 at 11:20:33AM -0700, Andrew Bresticker wrote:<br>
&gt; While back-porting Johannes Weiner&#39;s patch &quot;mm: memcg-aware g=
lobal reclaim&quot;<br>
&gt; for an internal effort, we noticed a significant performance regressio=
n<br>
&gt; during page-reclaim heavy workloads due to high contention of the ss-&=
gt;id_lock.<br>
&gt; This lock protects idr map, and serializes calls to idr_get_next() in<=
br>
&gt; css_get_next() (which is used during the memcg hierarchy walk). =A0Sin=
ce<br>
&gt; idr_get_next() is just doing a look up, we need only serialize it with=
<br>
&gt; respect to idr_remove()/idr_get_new(). =A0By making the ss-&gt;id_lock=
 a<br>
&gt; rwlock, contention is greatly reduced and performance improves.<br>
&gt;<br>
&gt; Tested: cat a 256m file from a ramdisk in a 128m container 50 times<br=
>
&gt; on each core (one file + container per core) in parallel on a NUMA<br>
&gt; machine. =A0Result is the time for the test to complete in 1 of the<br=
>
&gt; containers. =A0Both kernels included Johannes&#39; memcg-aware global<=
br>
&gt; reclaim patches.<br>
&gt; Before rwlock patch: 1710.778s<br>
&gt; After rwlock patch: 152.227s<br>
<br>
</div>The reason why there is much more hierarchy walking going on is<br>
because there was actually a design bug in the hierarchy reclaim.<br>
<br>
The old code would pick one memcg and scan it at decreasing priority<br>
levels until SCAN_CLUSTER_MAX pages were reclaimed. =A0For each memcg<br>
scanned with priority level 12, there were SWAP_CLUSTER_MAX pages<br>
reclaimed.<br>
<br>
My last revision would bail the whole hierarchy walk once it reclaimed<br>
SWAP_CLUSTER_MAX. =A0Also, at the time, small memcgs were not<br>
force-scanned yet. =A0So 128m containers would force the priority level<br>
to 10 before scanning anything at all (128M / pagesize &gt;&gt; priority),<=
br>
and then bail after one or two scanned memcgs. =A0This means that for<br>
each SWAP_CLUSTER_MAX reclaimed pages there was a nr_of_containers * 2<br>
overhead of just walking the hierarchy to no avail.<br></blockquote><div><b=
r></div><div>Good point.</div><div><br></div><div>To make it a bit clear, t=
he revision which bails out the hierarchy_walk based on nr_reclaimed is tha=
t we are looking at right now.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
I changed this and removed the bail condition based on the number of<br>
reclaimed pages. =A0Instead, the cycle ends when all reclaimers together<br=
>
made a full round-trip through the hierarchy. =A0The more cgroups, the<br>
more likely that there are several tasks going into reclaim<br>
concurrently, it should be a reasonable share of work for each one.<br></bl=
ockquote><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">The number of recla=
im invocations, thus the number of hierarchy walks,<br>

is back to sane levels again and the id_lock contention should be less<br>
of an issue.<br></blockquote><div><br></div><div>looking forward to see the=
 change.=A0=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Your patch still makes sense, but it&#39;s probably less urgent.<br></block=
quote><div><br></div><div>I think the patch itself make senses regardless o=
f the global reclaim change. It seems to be a=A0</div><div>optimization in =
general.</div>
<div><br></div><div>--Ying =A0</div></div><br>

--000e0cd289baef338a04ab387d04--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
