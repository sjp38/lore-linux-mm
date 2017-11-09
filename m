Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A46F6440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 22:51:04 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 82so3603795oid.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 19:51:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e29sor952872oth.163.2017.11.08.19.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 19:51:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net> <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com> <20171103134020.3hwquerifnc6k6qw@techsingularity.net>
 <b249f79a-a92e-f2ef-fdd5-3a9b8b6c3f48@mellanox.com> <20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 9 Nov 2017 11:51:02 +0800
Message-ID: <CAF7GXvpjFtB2LHan_FYbrGTP-j9D9xwQmH4smsTT4Tn_MFqtLA@mail.gmail.com>
Subject: Re: Page allocator bottleneck
Content-Type: multipart/alternative; boundary="001a113e55ec8eb87c055d84b66e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tariq Toukan <tariqt@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

--001a113e55ec8eb87c055d84b66e
Content-Type: text/plain; charset="UTF-8"

@Tariq, some ideas would steal from DPDK to improve the
high speed network card?
such as a physical CPU dedicated for the RX and TX thread (no
context switch and interrupt latency), and the
memory has prepared and allocated.

2017-11-08 17:35 GMT+08:00 Mel Gorman <mgorman@techsingularity.net>:

> On Wed, Nov 08, 2017 at 02:42:04PM +0900, Tariq Toukan wrote:
> > > > Hi all,
> > > >
> > > > After leaving this task for a while doing other tasks, I got back to
> it now
> > > > and see that the good behavior I observed earlier was not stable.
> > > >
> > > > Recall: I work with a modified driver that allocates a page (4K) per
> packet
> > > > (MTU=1500), in order to simulate the stress on page-allocator in
> 200Gbps
> > > > NICs.
> > > >
> > >
> > > There is almost new in the data that hasn't been discussed before. The
> > > suggestion to free on a remote per-cpu list would be expensive as it
> would
> > > require per-cpu lists to have a lock for safe remote access.
> >
> > That's right, but each such lock will be significantly less congested
> than
> > the buddy allocator lock.
>
> That is not necessarily true if all the allocations and frees always happen
> on the same CPUs. The contention will be equivalent to the zone lock.
> Your point will only hold true if there are also heavy allocation streams
> from other CPUs that are unrelated.
>
> > In the flow in subject two cores need to
> > synchronize (one allocates, one frees).
> > We also need to evaluate the cost of acquiring and releasing the lock in
> the
> > case of no congestion at all.
> >
>
> If the per-cpu structures have a lock, there will be a light amount of
> overhead. Nothing too severe, but it shouldn't be done lightly either.
>
> > >  However,
> > > I'd be curious if you could test the mm-pagealloc-irqpvec-v1r4 branch
> > > ttps://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git .  It's
> an
> > > unfinished prototype I worked on a few weeks ago. I was going to
> revisit
> > > in about a months time when 4.15-rc1 was out. I'd be interested in
> seeing
> > > if it has a postive gain in normal page allocations without destroying
> > > the performance of interrupt and softirq allocation contexts. The
> > > interrupt/softirq context testing is crucial as that is something that
> > > hurt us before when trying to improve page allocator performance.
> > >
> > Yes, I will test that once I get back in office (after netdev conference
> and
> > vacation).
>
> Thanks.
>
> > Can you please elaborate in a few words about the idea behind the
> prototype?
> > Does it address page-allocator scalability issues, or only the rate of
> > single core page allocations?
>
> Short answer -- maybe. All scalability issues or rates of allocation are
> context and workload dependant so the question is impossible to answer
> for the general case.
>
> Broadly speaking, the patch reintroduces the per-cpu lists being for !irq
> context allocations again. The last time we did this, hard and soft IRQ
> allocations went through the buddy allocator which couldn't scale and
> the patch was reverted. With this patch, it goes through a very large
> pagevec-like structure that is protected by a lock but the fast paths
> for alloc/free are extremely simple operations so the lock hold times are
> very small. Potentially, a development path is that the current per-cpu
> allocator is replaced with pagevec-like structures that are dynamically
> allocated which would also allow pages to be freed to remote CPU lists
> (if we could detect when that is appropriate which is unclear). We could
> also drain remote lists without using IPIs. The downside is that the memory
> footprint of the allocator would be higher and the size could no longer
> be tuned so there would need to be excellent justification for such a move.
>
> I haven't posted the patches properly yet because mmotm is carrying too
> many patches as it is and this patch indirectly depends on the contents. I
> also didn't write memory hot-remove support which would be a requirement
> before merging. I hadn't intended to put further effort into it until I
> had some evidence the approach had promise. My own testing indicated it
> worked but the drivers I was using for network tests did not allocate
> intensely enough to show any major gain/loss.
>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113e55ec8eb87c055d84b66e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">@<span style=3D"color:rgb(119,119,119);font-size:17.5px;wh=
ite-space:nowrap">Tariq, some=C2=A0ideas=C2=A0would=C2=A0steal=C2=A0from DP=
DK to improve the high=C2=A0speed=C2=A0network=C2=A0card?=C2=A0</span><div>=
<font color=3D"#777777"><span style=3D"font-size:17.5px;white-space:nowrap"=
>such=C2=A0as a physical CPU dedicated=C2=A0for=C2=A0the RX and TX=C2=A0thr=
ead (no context=C2=A0switch and interrupt latency), and the=C2=A0</span></f=
ont></div><div><font color=3D"#777777"><span style=3D"font-size:17.5px;whit=
e-space:nowrap">memory has prepared=C2=A0and allocated.</span></font></div>=
</div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">2017-11-08 =
17:35 GMT+08:00 Mel Gorman <span dir=3D"ltr">&lt;<a href=3D"mailto:mgorman@=
techsingularity.net" target=3D"_blank">mgorman@techsingularity.net</a>&gt;<=
/span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bor=
der-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Wed, Nov 08, =
2017 at 02:42:04PM +0900, Tariq Toukan wrote:<br>
&gt; &gt; &gt; Hi all,<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; After leaving this task for a while doing other tasks, I got=
 back to it now<br>
&gt; &gt; &gt; and see that the good behavior I observed earlier was not st=
able.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Recall: I work with a modified driver that allocates a page =
(4K) per packet<br>
&gt; &gt; &gt; (MTU=3D1500), in order to simulate the stress on page-alloca=
tor in 200Gbps<br>
&gt; &gt; &gt; NICs.<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; There is almost new in the data that hasn&#39;t been discussed be=
fore. The<br>
&gt; &gt; suggestion to free on a remote per-cpu list would be expensive as=
 it would<br>
&gt; &gt; require per-cpu lists to have a lock for safe remote access.<br>
&gt;<br>
&gt; That&#39;s right, but each such lock will be significantly less conges=
ted than<br>
&gt; the buddy allocator lock.<br>
<br>
</span>That is not necessarily true if all the allocations and frees always=
 happen<br>
on the same CPUs. The contention will be equivalent to the zone lock.<br>
Your point will only hold true if there are also heavy allocation streams<b=
r>
from other CPUs that are unrelated.<br>
<span class=3D""><br>
&gt; In the flow in subject two cores need to<br>
&gt; synchronize (one allocates, one frees).<br>
&gt; We also need to evaluate the cost of acquiring and releasing the lock =
in the<br>
&gt; case of no congestion at all.<br>
&gt;<br>
<br>
</span>If the per-cpu structures have a lock, there will be a light amount =
of<br>
overhead. Nothing too severe, but it shouldn&#39;t be done lightly either.<=
br>
<span class=3D""><br>
&gt; &gt;=C2=A0 However,<br>
&gt; &gt; I&#39;d be curious if you could test the mm-pagealloc-irqpvec-v1r=
4 branch<br>
&gt; &gt; ttps://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/=
mel/linux.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/scm/=
<wbr>linux/kernel/git/mel/linux.git</a> .=C2=A0 It&#39;s an<br>
&gt; &gt; unfinished prototype I worked on a few weeks ago. I was going to =
revisit<br>
&gt; &gt; in about a months time when 4.15-rc1 was out. I&#39;d be interest=
ed in seeing<br>
&gt; &gt; if it has a postive gain in normal page allocations without destr=
oying<br>
&gt; &gt; the performance of interrupt and softirq allocation contexts. The=
<br>
&gt; &gt; interrupt/softirq context testing is crucial as that is something=
 that<br>
&gt; &gt; hurt us before when trying to improve page allocator performance.=
<br>
&gt; &gt;<br>
&gt; Yes, I will test that once I get back in office (after netdev conferen=
ce and<br>
&gt; vacation).<br>
<br>
</span>Thanks.<br>
<span class=3D""><br>
&gt; Can you please elaborate in a few words about the idea behind the prot=
otype?<br>
&gt; Does it address page-allocator scalability issues, or only the rate of=
<br>
&gt; single core page allocations?<br>
<br>
</span>Short answer -- maybe. All scalability issues or rates of allocation=
 are<br>
context and workload dependant so the question is impossible to answer<br>
for the general case.<br>
<br>
Broadly speaking, the patch reintroduces the per-cpu lists being for !irq<b=
r>
context allocations again. The last time we did this, hard and soft IRQ<br>
allocations went through the buddy allocator which couldn&#39;t scale and<b=
r>
the patch was reverted. With this patch, it goes through a very large<br>
pagevec-like structure that is protected by a lock but the fast paths<br>
for alloc/free are extremely simple operations so the lock hold times are<b=
r>
very small. Potentially, a development path is that the current per-cpu<br>
allocator is replaced with pagevec-like structures that are dynamically<br>
allocated which would also allow pages to be freed to remote CPU lists<br>
(if we could detect when that is appropriate which is unclear). We could<br=
>
also drain remote lists without using IPIs. The downside is that the memory=
<br>
footprint of the allocator would be higher and the size could no longer<br>
be tuned so there would need to be excellent justification for such a move.=
<br>
<br>
I haven&#39;t posted the patches properly yet because mmotm is carrying too=
<br>
many patches as it is and this patch indirectly depends on the contents. I<=
br>
also didn&#39;t write memory hot-remove support which would be a requiremen=
t<br>
before merging. I hadn&#39;t intended to put further effort into it until I=
<br>
had some evidence the approach had promise. My own testing indicated it<br>
worked but the drivers I was using for network tests did not allocate<br>
intensely enough to show any major gain/loss.<br>
<span class=3D"im HOEnZb"><br>
--<br>
Mel Gorman<br>
SUSE Labs<br>
<br>
</span><div class=3D"HOEnZb"><div class=3D"h5">--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br></div>

--001a113e55ec8eb87c055d84b66e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
