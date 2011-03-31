Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC728D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 01:41:57 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p2V5fsXw000495
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:41:54 -0700
Received: from qwg5 (qwg5.prod.google.com [10.241.194.133])
	by hpaq2.eem.corp.google.com with ESMTP id p2V5fqf7025747
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:41:52 -0700
Received: by qwg5 with SMTP id 5so1238403qwg.3
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331112532.82ed25ad.kamezawa.hiroyu@jp.fujitsu.com>
References: <1301532498-20309-1-git-send-email-yinghan@google.com>
	<20110331112532.82ed25ad.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 30 Mar 2011 22:41:51 -0700
Message-ID: <BANLkTimiwObEvRLv8pmmcy8v31FN2y_VOg@mail.gmail.com>
Subject: Re: [RFC][PATCH] memcg: isolate pages in memcg lru from global lru
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd0820f080f049fc0c027
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd0820f080f049fc0c027
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Mar 30, 2011 at 7:25 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 30 Mar 2011 17:48:18 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > In memory controller, we do both targeting reclaim and global reclaim.
> The
> > later one walks through the global lru which links all the allocated
> pages
> > on the system. It breaks the memory isolation since pages are evicted
> > regardless of their memcg owners. This patch takes pages off global lru
> > as long as they are added to per-memcg lru.
> >
> > Memcg and cgroup together provide the solution of memory isolation where
> > multiple cgroups run in parallel without interfering with each other. In
> > vm, memory isolation requires changes in both page allocation and page
> > reclaim. The current memcg provides good user page accounting, but need
> > more work on the page reclaim.
> >
> > In an over-committed machine w/ 32G ram, here is the configuration:
> >
> > cgroup-A/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> > cgroup-B/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> >
> > 1) limit_in_bytes is the hard_limit where process will be throttled or
> OOM
> > killed by going over the limit.
> > 2) memory between soft_limit and limit_in_bytes are best-effort.
> soft_limit
> > provides "guarantee" in some sense.
> >
> > Then, it is easy to generate the following senario where:
> >
> > cgroup-A/  -- usage_in_bytes = 20G
> > cgroup-B/  -- usage_in_bytes = 12G
> >
> > The global memory pressure triggers while cgroup-A keep allocating
> memory. At
> > this point, pages belongs to cgroup-B can be evicted from global LRU.
> >
> > We do have per-memcg targeting reclaim including per-memcg background
> reclaim
> > and soft_limit reclaim. Both of them need some improvement, and
> regardless we
> > still need this patch since it breaks isolation.
> >
> > Besides, here is to-do list I have on memcg page reclaim and they are
> sorted.
> > a) per-memcg background reclaim. to reclaim pages proactively
> agree,
>
> > b) skipping global lru reclaim if soft_limit reclaim does enough work.
> this is
> > both for global background reclaim and global ttfp reclaim.
>
> agree. but zone-balancing cannot be avoidalble for now. So, I think we need
> a
> inter-zone-page-migration to balancing memory between zones...if necessary.
>

thank you for your comments, and can you clarify a bit on this? Actually I
was thinking about the zone balancing within memcg, but haven't thought it
through yet. I would like to learn more on the cases that we can not avoid
global zone-balancing totally.

>
>
> > c) improve the soft_limit reclaim to be efficient.
>
> must be done.
>

The current design of soft_limit is more on the correctness rather than
efficiency. If we are talking about to improve the efficiency of target
reclaim, there are quite a lot to change. The first thing might be improving
the per-zone RB tree. They are currently based on per-memcg
(usage_limit-soft_limit) regardless of how much pages landed on the zone.


>
> > d) isolate pages in memcg from global list since it breaks memory
> isolation.
>



> >
>
> I never agree this until about a),b),c) is fixed and we can go nowhere.
>
> BTW, in other POV, for reducing size of page_cgroup, we must remove ->lru
> on page_cgroup. If divide-and-conquer memory reclaim works enough,
> we can do that. But this is a big global VM change, so we need enough
> justification.
>

I can agree on that. The change looks big, especially without efficient
target reclaim. However
I do believe we need this to have isolation guarantee.

>
>
>
> > I have some basic test on this patch and more tests definitely are
> needed:
> >
>
> > Functional:
> > two memcgs under root. cgroup-A is reading 20g file with 2g limit,
> > cgroup-B is running random stuff with 500m limit. Check the counters for
> > per-memcg lru and global lru, and they should add-up.
> >
> > 1) total file pages
> > $ cat /proc/meminfo | grep Cache
> > Cached:          6032128 kB
> >
> > 2) file lru on global lru
> > $ cat /proc/vmstat | grep file
> > nr_inactive_file 0
> > nr_active_file 963131
> >
> > 3) file lru on root cgroup
> > $ cat /dev/cgroup/memory.stat | grep file
> > inactive_file 0
> > active_file 0
> >
> > 4) file lru on cgroup-A
> > $ cat /dev/cgroup/A/memory.stat | grep file
> > inactive_file 2145759232
> > active_file 0
> >
> > 5) file lru on cgroup-B
> > $ cat /dev/cgroup/B/memory.stat | grep file
> > inactive_file 401408
> > active_file 143360
> >
> > Performance:
> > run page fault test(pft) with 16 thread on faulting in 15G anon pages
> > in 16G cgroup. There is no regression noticed on "flt/cpu/s"
> >
>
> You need a fix for /proc/meminfo, /proc/vmstat to count memcg's ;)
>

Yes. :) Since this is RFC prototype, i took the shortcut by reusing the
existing stat by only count the pages on global LRU.

>
> Anyway, this seems too aggresive to me, for now. Please do a), b), c), at
> first.
>


>
> IIUC, this patch itself can cause a livelock when softlimit is
> misconfigured.
> What is the protection against wrong softlimit ?
>

Hmm, can you help to clarify on that?

>



> If we do this kind of LRU isolation, we'll need some limitation of the sum
> of
> limits of all memcg for avoiding wrong configuration. That may change UI,
> dramatically.
> (As RT-class cpu limiting cgroup does.....)
>

This sounds related the question above, so I just wait for my question being
answered :)


Anyway, thank you for data.
>
> sure

--Ying


> Thanks,
> -Kame
>
>
>

--000e0cdfd0820f080f049fc0c027
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Mar 30, 2011 at 7:25 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Wed, 30 Mar 2011 17:48:18 -0700<br>
</div><div><div></div><div class=3D"h5">Ying Han &lt;<a href=3D"mailto:ying=
han@google.com">yinghan@google.com</a>&gt; wrote:<br>
<br>
&gt; In memory controller, we do both targeting reclaim and global reclaim.=
 The<br>
&gt; later one walks through the global lru which links all the allocated p=
ages<br>
&gt; on the system. It breaks the memory isolation since pages are evicted<=
br>
&gt; regardless of their memcg owners. This patch takes pages off global lr=
u<br>
&gt; as long as they are added to per-memcg lru.<br>
&gt;<br>
&gt; Memcg and cgroup together provide the solution of memory isolation whe=
re<br>
&gt; multiple cgroups run in parallel without interfering with each other. =
In<br>
&gt; vm, memory isolation requires changes in both page allocation and page=
<br>
&gt; reclaim. The current memcg provides good user page accounting, but nee=
d<br>
&gt; more work on the page reclaim.<br>
&gt;<br>
&gt; In an over-committed machine w/ 32G ram, here is the configuration:<br=
>
&gt;<br>
&gt; cgroup-A/ =A0-- limit_in_bytes =3D 20G, soft_limit_in_bytes =3D 15G<br=
>
&gt; cgroup-B/ =A0-- limit_in_bytes =3D 20G, soft_limit_in_bytes =3D 15G<br=
>
&gt;<br>
&gt; 1) limit_in_bytes is the hard_limit where process will be throttled or=
 OOM<br>
&gt; killed by going over the limit.<br>
&gt; 2) memory between soft_limit and limit_in_bytes are best-effort. soft_=
limit<br>
&gt; provides &quot;guarantee&quot; in some sense.<br>
&gt;<br>
&gt; Then, it is easy to generate the following senario where:<br>
&gt;<br>
&gt; cgroup-A/ =A0-- usage_in_bytes =3D 20G<br>
&gt; cgroup-B/ =A0-- usage_in_bytes =3D 12G<br>
&gt;<br>
&gt; The global memory pressure triggers while cgroup-A keep allocating mem=
ory. At<br>
&gt; this point, pages belongs to cgroup-B can be evicted from global LRU.<=
br>
&gt;<br>
&gt; We do have per-memcg targeting reclaim including per-memcg background =
reclaim<br>
&gt; and soft_limit reclaim. Both of them need some improvement, and regard=
less we<br>
&gt; still need this patch since it breaks isolation.<br>
&gt;<br>
&gt; Besides, here is to-do list I have on memcg page reclaim and they are =
sorted.<br>
&gt; a) per-memcg background reclaim. to reclaim pages proactively<br>
</div></div>agree,<br>
<div class=3D"im"><br>
&gt; b) skipping global lru reclaim if soft_limit reclaim does enough work.=
 this is<br>
&gt; both for global background reclaim and global ttfp reclaim.<br>
<br>
</div>agree. but zone-balancing cannot be avoidalble for now. So, I think w=
e need a<br>
inter-zone-page-migration to balancing memory between zones...if necessary.=
<br></blockquote><div><br></div><div>thank you for your comments, and can y=
ou clarify a bit on this? Actually I was thinking=A0about the zone balancin=
g within memcg, but haven&#39;t thought it through yet.=A0I would like to l=
earn=A0more on the cases that we can not avoid global zone-balancing totall=
y.</div>
<meta charset=3D"utf-8"><blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
<br>
&gt; c) improve the soft_limit reclaim to be efficient.<br>
<br>
</div>must be done.<br></blockquote><div><br></div><div>The current design =
of soft_limit is more on the correctness rather than efficiency. If we are =
talking about to improve the=A0efficiency=A0of target reclaim, there are qu=
ite a lot to change. The first thing might be improving the per-zone RB tre=
e. They are currently based on per-memcg (usage_limit-soft_limit) regardles=
s of how much pages landed on the zone.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; d) isolate pages in memcg from global list since it breaks memory isol=
ation.<br></div></blockquote><div><br></div><div>=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">
<div class=3D"im">
&gt;<br>
<br>
</div>I never agree this until about a),b),c) is fixed and we can go nowher=
e.<br>
<br>
BTW, in other POV, for reducing size of page_cgroup, we must remove -&gt;lr=
u<br>
on page_cgroup. If divide-and-conquer memory reclaim works enough,<br>
we can do that. But this is a big global VM change, so we need enough<br>
justification.<br></blockquote><div><br></div><div>I can agree on that. The=
 change looks big, especially without efficient target reclaim. However</di=
v><div>I do believe we need this to have isolation=A0guarantee.=A0</div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex;">

<div><div></div><div class=3D"h5"><br>
<br>
<br>
&gt; I have some basic test on this patch and more tests definitely are nee=
ded:<br>
&gt;<br>
<br>
&gt; Functional:<br>
&gt; two memcgs under root. cgroup-A is reading 20g file with 2g limit,<br>
&gt; cgroup-B is running random stuff with 500m limit. Check the counters f=
or<br>
&gt; per-memcg lru and global lru, and they should add-up.<br>
&gt;<br>
&gt; 1) total file pages<br>
&gt; $ cat /proc/meminfo | grep Cache<br>
&gt; Cached: =A0 =A0 =A0 =A0 =A06032128 kB<br>
&gt;<br>
&gt; 2) file lru on global lru<br>
&gt; $ cat /proc/vmstat | grep file<br>
&gt; nr_inactive_file 0<br>
&gt; nr_active_file 963131<br>
&gt;<br>
&gt; 3) file lru on root cgroup<br>
&gt; $ cat /dev/cgroup/memory.stat | grep file<br>
&gt; inactive_file 0<br>
&gt; active_file 0<br>
&gt;<br>
&gt; 4) file lru on cgroup-A<br>
&gt; $ cat /dev/cgroup/A/memory.stat | grep file<br>
&gt; inactive_file 2145759232<br>
&gt; active_file 0<br>
&gt;<br>
&gt; 5) file lru on cgroup-B<br>
&gt; $ cat /dev/cgroup/B/memory.stat | grep file<br>
&gt; inactive_file 401408<br>
&gt; active_file 143360<br>
&gt;<br>
&gt; Performance:<br>
&gt; run page fault test(pft) with 16 thread on faulting in 15G anon pages<=
br>
&gt; in 16G cgroup. There is no regression noticed on &quot;flt/cpu/s&quot;=
<br>
&gt;<br>
<br>
</div></div>You need a fix for /proc/meminfo, /proc/vmstat to count memcg&#=
39;s ;)<br></blockquote><div><br></div><div>Yes. :) Since this is RFC proto=
type, i took the shortcut by reusing the existing stat by only count the pa=
ges on global LRU.=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
Anyway, this seems too aggresive to me, for now. Please do a), b), c), at f=
irst.<br></blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
IIUC, this patch itself can cause a livelock when softlimit is misconfigure=
d.<br>
What is the protection against wrong softlimit ?<br></blockquote><div><br><=
/div><div>Hmm, can you help to clarify on that?</div><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex;">
=A0</blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
If we do this kind of LRU isolation, we&#39;ll need some limitation of the =
sum of<br>
limits of all memcg for avoiding wrong configuration. That may change UI, d=
ramatically.<br>
(As RT-class cpu limiting cgroup does.....)<br></blockquote><div><br></div>=
<div>This sounds related the question above, so I just wait for my question=
 being answered :)</div><div><br></div><div><br></div><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex;">
Anyway, thank you for data.<br>
<br></blockquote><div>sure</div><div><br></div><div>--Ying</div><div>=A0</d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>

--000e0cdfd0820f080f049fc0c027--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
