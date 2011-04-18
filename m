Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE2F0900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:02:55 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3IH2pjm026955
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:02:51 -0700
Received: from qwf6 (qwf6.prod.google.com [10.241.194.70])
	by wpaz5.hot.corp.google.com with ESMTP id p3IH0eI1003607
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:02:50 -0700
Received: by qwf6 with SMTP id 6so3835362qwf.16
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:02:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110418091351.GC8925@tiehlicka.suse.cz>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<20110415094040.GC8828@tiehlicka.suse.cz>
	<BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
	<20110418091351.GC8925@tiehlicka.suse.cz>
Date: Mon, 18 Apr 2011 10:01:20 -0700
Message-ID: <BANLkTimkPasX8AA=HCOgVeSyPBSivz8pMg@mail.gmail.com>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee03f234f04a134574c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee03f234f04a134574c
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 18, 2011 at 2:13 AM, Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 15-04-11 09:40:54, Ying Han wrote:
> > On Fri, Apr 15, 2011 at 2:40 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > > Hi Ying,
> > > sorry that I am jumping into game that late but I was quite busy after
> > > returning back from LSF and LFCS.
> > >
> >
> > Sure. Nice meeting you guys there and thank you for looking into this
> patch
> > :)
>
> Yes, nice meeting.
>
> >
> > >
> > > On Thu 14-04-11 15:54:19, Ying Han wrote:
> > > > The current implementation of memcg supports targeting reclaim when
> the
> > > > cgroup is reaching its hard_limit and we do direct reclaim per
> cgroup.
> > > > Per cgroup background reclaim is needed which helps to spread out
> memory
> > > > pressure over longer period of time and smoothes out the cgroup
> > > performance.
> > > >
> > > > If the cgroup is configured to use per cgroup background reclaim, a
> > > kswapd
> > > > thread is created which only scans the per-memcg LRU list.
> > >
> > > Hmm, I am wondering if this fits into the get-rid-of-the-global-LRU
> > > strategy. If we make the background reclaim per-cgroup how do we
> balance
> > > from the global/zone POV? We can end up with all groups over the high
> > > limit while a memory zone is under this watermark. Or am I missing
> > > something?
> > > I thought that plans for the background reclaim were same as for direct
> > > reclaim so that kswapd would just evict pages from groups in the
> > > round-robin fashion (in first round just those that are under limit and
> > > proportionally when it cannot reach high watermark after it got through
> > > all groups).
> > >
> >
> > I think you are talking about the soft_limit reclaim which I am gonna
> look
> > at next.
>
> I see. I am just concerned whether 3rd level of reclaim is a good idea.
> We would need to do background reclaim anyway (and to preserve the
> original semantic it has to be somehow watermark controlled). I am just
> wondering why we have to implement it separately from kswapd. Cannot we
> just simply trigger global kswapd which would reclaim all cgroups that
> are under watermarks? [I am sorry for my ignorance if that is what is
> implemented in the series - I haven't got to the patches yes]
>

They are different on per-zone reclaim vs per-memcg reclaim. The first one
is triggered if the zone is under
memory pressure and we need to free pages to serve further page allocations.
The second one is triggered
if the memcg is under memory pressure and we need to free pages to leave
room (limit - usage) for the memcg
to grow.

Both of them are needed and that is how it is implemented on the direct
reclaim path. The kswapd batches only try to
smooth out the system and memcg performance by reclaiming pages proactively.
It doesn't affecting the functionality.

>
> > The soft_limit reclaim
> > is triggered under global memory pressure and doing round-robin across
> > memcgs. I will also cover the
> > zone-balancing by having second list of memgs under their soft_limit.
> >
> > Here is the summary of our LSF discussion :)
> > http://permalink.gmane.org/gmane.linux.kernel.mm/60966
>
> Yes, I have read it and thanks for putting it together.
>
sure.

>
> > > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > > background reclaim and stop it. The watermarks are calculated based
> on
> > > > the cgroup's limit_in_bytes.
> > >
> > > I didn't have time to look at the patch how does the calculation work
> > > yet but we should be careful to match the zone's watermark
> expectations.
> > >
> >
> > I have API on the following patch which provide high/low_wmark_distance
> to
> > tune wmarks individually individually.  By default, they are set to 0
> which
> > turn off the per-memcg kswapd. For now, we are ok since the global kswapd
> is
> > still doing per-zone scanning and reclaiming :)
> >
> > >
> > > > By default, the per-memcg kswapd threads are running under root
> cgroup.
> > > There
> > > > is a per-memcg API which exports the pid of each kswapd thread, and
> > > userspace
> > > > can configure cpu cgroup seperately.
> > > >
> > > > I run through dd test on large file and then cat the file. Then I
> > > compared
> > > > the reclaim related stats in memory.stat.
> > > >
> > > > Step1: Create a cgroup with 500M memory_limit.
> > > > $ mkdir /dev/cgroup/memory/A
> > > > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > > > $ echo $$ >/dev/cgroup/memory/A/tasks
> > > >
> > > > Step2: Test and set the wmarks.
> > > > $ cat /dev/cgroup/memory/A/memory.low_wmark_distance
> > > > 0
> > > > $ cat /dev/cgroup/memory/A/memory.high_wmark_distance
> > > > 0
> > >
> > >
> > They are used to tune the high/low_marks based on the hard_limit. We
> might
> > need to export that configuration to user admin especially on machines
> where
> > they over-commit by hard_limit.
>
> I remember there was some resistance against tuning watermarks
> separately.
>

This API is based on KAMEZAWA's request. :)

>
> > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > > low_wmark 524288000
> > > > high_wmark 524288000
> > > >
> > > > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > > > $ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance
> > > >
> > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > > low_wmark  482344960
> > > > high_wmark 471859200
> > >
> > > low_wmark is higher than high_wmark?
> > >
> >
> > hah, it is confusing. I have them documented. Basically, low_wmark
> triggers
> > reclaim and high_wmark stop the reclaim. And we have
> >
> > high_wmark < usage < low_wmark.
>
> OK, I will look at it.
>
> [...]
>
> > > I am not sure how much orthogonal per-cgroup-per-thread vs. zone
> > > approaches are, though.  Maybe it makes some sense to do both
> per-cgroup
> > > and zone background reclaim.  Anyway I think that we should start with
> > > the zone reclaim first.
> > >
> >
> > I missed the point here. Can you clarify the zone reclaim here?
>
> kswapd does the background zone reclaim and you are trying to do
> per-cgroup reclaim, right? I am concerned about those two fighting with
> slightly different goal.
>
> I am still thinking whether backgroup reclaim would be sufficient,
> though. We would get rid of per-cgroup thread and wouldn't create a new
> reclaim interface.
>

The per-zone reclaim will look at memcg and their soft_limits, and
the criteria is different from per-memcg background reclaim where we look at
the hard_limit. This is how the direct reclaim works on both side, and
kswapd is just doing the
work proactively.

Later when we change the soft_limit reclaim on the per-zone memory pressure,
the same logic will be changed in the per-zone try_to_free_pages().

Thanks

--Ying

> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--000e0cd68ee03f234f04a134574c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 18, 2011 at 2:13 AM, Michal =
Hocko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.c=
z</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Fri 15-04-11 09:40:54, Ying Han wrote:<br>
&gt; On Fri, Apr 15, 2011 at 2:40 AM, Michal Hocko &lt;<a href=3D"mailto:mh=
ocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Hi Ying,<br>
&gt; &gt; sorry that I am jumping into game that late but I was quite busy =
after<br>
&gt; &gt; returning back from LSF and LFCS.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Sure. Nice meeting you guys there and thank you for looking into this =
patch<br>
&gt; :)<br>
<br>
</div>Yes, nice meeting.<br>
<div class=3D"im"><br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; On Thu 14-04-11 15:54:19, Ying Han wrote:<br>
&gt; &gt; &gt; The current implementation of memcg supports targeting recla=
im when the<br>
&gt; &gt; &gt; cgroup is reaching its hard_limit and we do direct reclaim p=
er cgroup.<br>
&gt; &gt; &gt; Per cgroup background reclaim is needed which helps to sprea=
d out memory<br>
&gt; &gt; &gt; pressure over longer period of time and smoothes out the cgr=
oup<br>
&gt; &gt; performance.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; If the cgroup is configured to use per cgroup background rec=
laim, a<br>
&gt; &gt; kswapd<br>
&gt; &gt; &gt; thread is created which only scans the per-memcg LRU list.<b=
r>
&gt; &gt;<br>
&gt; &gt; Hmm, I am wondering if this fits into the get-rid-of-the-global-L=
RU<br>
&gt; &gt; strategy. If we make the background reclaim per-cgroup how do we =
balance<br>
&gt; &gt; from the global/zone POV? We can end up with all groups over the =
high<br>
&gt; &gt; limit while a memory zone is under this watermark. Or am I missin=
g<br>
&gt; &gt; something?<br>
&gt; &gt; I thought that plans for the background reclaim were same as for =
direct<br>
&gt; &gt; reclaim so that kswapd would just evict pages from groups in the<=
br>
&gt; &gt; round-robin fashion (in first round just those that are under lim=
it and<br>
&gt; &gt; proportionally when it cannot reach high watermark after it got t=
hrough<br>
&gt; &gt; all groups).<br>
&gt; &gt;<br>
&gt;<br>
&gt; I think you are talking about the soft_limit reclaim which I am gonna =
look<br>
&gt; at next.<br>
<br>
</div>I see. I am just concerned whether 3rd level of reclaim is a good ide=
a.<br>
We would need to do background reclaim anyway (and to preserve the<br>
original semantic it has to be somehow watermark controlled). I am just<br>
wondering why we have to implement it separately from kswapd. Cannot we<br>
just simply trigger global kswapd which would reclaim all cgroups that<br>
are under watermarks? [I am sorry for my ignorance if that is what is<br>
implemented in the series - I haven&#39;t got to the patches yes]<br></bloc=
kquote><div><br></div><div>They are different on per-zone reclaim vs per-me=
mcg reclaim. The first one is triggered if the zone is under</div><div>
memory pressure and we need to free pages to serve further page allocations=
. The second one is triggered=A0</div><div>if the memcg is under memory pre=
ssure and we need to free pages to leave room (limit - usage) for the memcg=
</div>
<div>to grow.=A0</div><div><br></div><div>Both of them are needed and that =
is how it is implemented on the direct reclaim path. The kswapd batches onl=
y try to</div><div>smooth out the system and memcg performance by reclaimin=
g pages proactively. It doesn&#39;t affecting the=A0functionality.=A0=A0</d=
iv>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; The soft_limit reclaim<br>
&gt; is triggered under global memory pressure and doing round-robin across=
<br>
&gt; memcgs. I will also cover the<br>
&gt; zone-balancing by having second list of memgs under their soft_limit.<=
br>
&gt;<br>
&gt; Here is the summary of our LSF discussion :)<br>
&gt; <a href=3D"http://permalink.gmane.org/gmane.linux.kernel.mm/60966" tar=
get=3D"_blank">http://permalink.gmane.org/gmane.linux.kernel.mm/60966</a><b=
r>
<br>
</div>Yes, I have read it and thanks for putting it together.<br></blockquo=
te><div>sure.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
&gt; &gt; &gt; Two watermarks (&quot;high_wmark&quot;, &quot;low_wmark&quot=
;) are added to trigger the<br>
&gt; &gt; &gt; background reclaim and stop it. The watermarks are calculate=
d based on<br>
&gt; &gt; &gt; the cgroup&#39;s limit_in_bytes.<br>
&gt; &gt;<br>
&gt; &gt; I didn&#39;t have time to look at the patch how does the calculat=
ion work<br>
&gt; &gt; yet but we should be careful to match the zone&#39;s watermark ex=
pectations.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I have API on the following patch which provide high/low_wmark_distanc=
e to<br>
&gt; tune wmarks individually individually. =A0By default, they are set to =
0 which<br>
&gt; turn off the per-memcg kswapd. For now, we are ok since the global ksw=
apd is<br>
&gt; still doing per-zone scanning and reclaiming :)<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; &gt; By default, the per-memcg kswapd threads are running under r=
oot cgroup.<br>
&gt; &gt; There<br>
&gt; &gt; &gt; is a per-memcg API which exports the pid of each kswapd thre=
ad, and<br>
&gt; &gt; userspace<br>
&gt; &gt; &gt; can configure cpu cgroup seperately.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I run through dd test on large file and then cat the file. T=
hen I<br>
&gt; &gt; compared<br>
&gt; &gt; &gt; the reclaim related stats in memory.stat.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step1: Create a cgroup with 500M memory_limit.<br>
&gt; &gt; &gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; &gt; &gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<b=
r>
&gt; &gt; &gt; $ echo $$ &gt;/dev/cgroup/memory/A/tasks<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Step2: Test and set the wmarks.<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.low_wmark_distance<br>
&gt; &gt; &gt; 0<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.high_wmark_distance<br>
&gt; &gt; &gt; 0<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; They are used to tune the high/low_marks based on the hard_limit. We m=
ight<br>
&gt; need to export that configuration to user admin especially on machines=
 where<br>
&gt; they over-commit by hard_limit.<br>
<br>
</div></div>I remember there was some resistance against tuning watermarks<=
br>
separately.<br></blockquote><div><br></div><div>This API is based on KAMEZA=
WA&#39;s request. :)=A0</div><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; &gt; &gt; low_wmark 524288000<br>
&gt; &gt; &gt; high_wmark 524288000<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ echo 50m &gt;/dev/cgroup/memory/A/memory.high_wmark_distan=
ce<br>
&gt; &gt; &gt; $ echo 40m &gt;/dev/cgroup/memory/A/memory.low_wmark_distanc=
e<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; &gt; &gt; low_wmark =A0482344960<br>
&gt; &gt; &gt; high_wmark 471859200<br>
&gt; &gt;<br>
&gt; &gt; low_wmark is higher than high_wmark?<br>
&gt; &gt;<br>
&gt;<br>
&gt; hah, it is confusing. I have them documented. Basically, low_wmark tri=
ggers<br>
&gt; reclaim and high_wmark stop the reclaim. And we have<br>
&gt;<br>
&gt; high_wmark &lt; usage &lt; low_wmark.<br>
<br>
</div>OK, I will look at it.<br>
<br>
[...]<br>
<div class=3D"im"><br>
&gt; &gt; I am not sure how much orthogonal per-cgroup-per-thread vs. zone<=
br>
&gt; &gt; approaches are, though. =A0Maybe it makes some sense to do both p=
er-cgroup<br>
&gt; &gt; and zone background reclaim. =A0Anyway I think that we should sta=
rt with<br>
&gt; &gt; the zone reclaim first.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I missed the point here. Can you clarify the zone reclaim here?<br>
<br>
</div>kswapd does the background zone reclaim and you are trying to do<br>
per-cgroup reclaim, right? I am concerned about those two fighting with<br>
slightly different goal.<br>
<br>
I am still thinking whether backgroup reclaim would be sufficient,<br>
though. We would get rid of per-cgroup thread and wouldn&#39;t create a new=
<br>
reclaim interface.<br></blockquote><div><br></div><div>The per-zone reclaim=
 will look at memcg and their soft_limits, and the=A0criteria is different =
from per-memcg background reclaim where we look at the hard_limit. This is =
how the direct reclaim works on both side, and kswapd is just doing the</di=
v>
<div>work proactively.</div><div><br></div><div>Later when we change the so=
ft_limit reclaim on the per-zone memory pressure, the same logic will be ch=
anged in the per-zone try_to_free_pages().</div><div><br></div><div>Thanks<=
/div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<font color=3D"#888888">--<br>
</font><div><div></div><div class=3D"h5">Michal Hocko<br>
SUSE Labs<br>
SUSE LINUX s.r.o.<br>
Lihovarska 1060/12<br>
190 00 Praha 9<br>
Czech Republic<br>
</div></div></blockquote></div><br>

--000e0cd68ee03f234f04a134574c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
