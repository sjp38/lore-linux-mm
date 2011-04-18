Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 59C2C900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 18:27:29 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3IMRL3P002450
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:27:25 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by kpbe15.cbf.corp.google.com with ESMTP id p3IMLTis000688
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:27:19 -0700
Received: by qyl38 with SMTP id 38so3403298qyl.8
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:27:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110418184240.GA11653@tiehlicka.suse.cz>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<20110415094040.GC8828@tiehlicka.suse.cz>
	<BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
	<20110418091351.GC8925@tiehlicka.suse.cz>
	<BANLkTimkPasX8AA=HCOgVeSyPBSivz8pMg@mail.gmail.com>
	<20110418184240.GA11653@tiehlicka.suse.cz>
Date: Mon, 18 Apr 2011 15:27:14 -0700
Message-ID: <BANLkTi=HotRcWiRc4qa1aN+NJ4H5vfCWWA@mail.gmail.com>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd082ba138304a138e415
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd082ba138304a138e415
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 18, 2011 at 11:42 AM, Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 18-04-11 10:01:20, Ying Han wrote:
> > On Mon, Apr 18, 2011 at 2:13 AM, Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > I see. I am just concerned whether 3rd level of reclaim is a good idea.
> > > We would need to do background reclaim anyway (and to preserve the
> > > original semantic it has to be somehow watermark controlled). I am just
> > > wondering why we have to implement it separately from kswapd. Cannot we
> > > just simply trigger global kswapd which would reclaim all cgroups that
> > > are under watermarks? [I am sorry for my ignorance if that is what is
> > > implemented in the series - I haven't got to the patches yes]
> > >
> >
> > They are different on per-zone reclaim vs per-memcg reclaim. The first
> > one is triggered if the zone is under memory pressure and we need
> > to free pages to serve further page allocations.  The second one is
> > triggered if the memcg is under memory pressure and we need to free
> > pages to leave room (limit - usage) for the memcg to grow.
>
> OK, I see.
>
>
> >
> > Both of them are needed and that is how it is implemented on the direct
> > reclaim path. The kswapd batches only try to
> > smooth out the system and memcg performance by reclaiming pages
> proactively.
> > It doesn't affecting the functionality.
>
> I am still wondering, isn't this just a nice to have feature rather
> than must to have in order to get rid of the global LRU?

The per-memcg kswapd is a must-have, and it is less related to the effort of
"get rid of global LRU" than the next patch I am looking at "enhance the
soft_limit reclaim". So this is the structure we will end up with

background reclaim:
1. per-memcg : this patch
2. global: targeting reclaim by replacing the per-zone to soft_limit reclaim

direct reclaim:
1. per-memcg: no change from today
2. global: targeting reclaim by replacing the per-zone to soft_limit
reclaim.


> Doesn't it make transition more complicated. I have noticed many if-else in
> kswapd path to
> distinguish per-cgroup from the traditional global background reclaim.
>





>
> [...]
>
> > > > > > Step1: Create a cgroup with 500M memory_limit.
> > > > > > $ mkdir /dev/cgroup/memory/A
> > > > > > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > > > > > $ echo $$ >/dev/cgroup/memory/A/tasks
> > > > > >
> > > > > > Step2: Test and set the wmarks.
> > > > > > $ cat /dev/cgroup/memory/A/memory.low_wmark_distance
> > > > > > 0
> > > > > > $ cat /dev/cgroup/memory/A/memory.high_wmark_distance
> > > > > > 0
> > > > >
> > > > >
> > > > They are used to tune the high/low_marks based on the hard_limit. We
> > > might
> > > > need to export that configuration to user admin especially on
> machines
> > > where
> > > > they over-commit by hard_limit.
> > >
> > > I remember there was some resistance against tuning watermarks
> > > separately.
> > >
> >
> > This API is based on KAMEZAWA's request. :)
>
> This was just as FYI. Watermarks were considered internal thing. So I
> wouldn't be surprised if this got somehow controversial.
>

We went back and forth on how to set the high/low wmarks for different
configurations (over-commit or not). So far, by
giving the user ability to set the wmarks seems the most feasible way of
fullfilling the requriment.

>
> >
> > >
> > > > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > > > > low_wmark 524288000
> > > > > > high_wmark 524288000
> > > > > >
> > > > > > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > > > > > $ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance
> > > > > >
> > > > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > > > > low_wmark  482344960
> > > > > > high_wmark 471859200
> > > > >
> > > > > low_wmark is higher than high_wmark?
> > > > >
> > > >
> > > > hah, it is confusing. I have them documented. Basically, low_wmark
> > > > triggers reclaim and high_wmark stop the reclaim. And we have
> > > >
> > > > high_wmark < usage < low_wmark.
>
> OK, I see how you calculate those watermarks now but it is really
> confusing for those who are used to traditional watermark semantic.
>

that is true.  I adopt the initial comment from Mel where we keep the same
logic of triggering and stopping kswapd with low/high_wmarks and also
comparing the usage_in_bytes to the wmarks. Either way is confusing and
guess we just need to document it well.

--Ying

--
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--000e0cdfd082ba138304a138e415
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 18, 2011 at 11:42 AM, Michal=
 Hocko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.=
cz</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Mon 18-04-11 10:01:20, Ying Han wrote:<br>
&gt; On Mon, Apr 18, 2011 at 2:13 AM, Michal Hocko &lt;<a href=3D"mailto:mh=
ocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>
</div>[...]<br>
<div class=3D"im">&gt; &gt; I see. I am just concerned whether 3rd level of=
 reclaim is a good idea.<br>
&gt; &gt; We would need to do background reclaim anyway (and to preserve th=
e<br>
&gt; &gt; original semantic it has to be somehow watermark controlled). I a=
m just<br>
&gt; &gt; wondering why we have to implement it separately from kswapd. Can=
not we<br>
&gt; &gt; just simply trigger global kswapd which would reclaim all cgroups=
 that<br>
&gt; &gt; are under watermarks? [I am sorry for my ignorance if that is wha=
t is<br>
&gt; &gt; implemented in the series - I haven&#39;t got to the patches yes]=
<br>
&gt; &gt;<br>
&gt;<br>
&gt; They are different on per-zone reclaim vs per-memcg reclaim. The first=
<br>
&gt; one is triggered if the zone is under memory pressure and we need<br>
&gt; to free pages to serve further page allocations. =A0The second one is<=
br>
&gt; triggered if the memcg is under memory pressure and we need to free<br=
>
&gt; pages to leave room (limit - usage) for the memcg to grow.<br>
<br>
</div>OK, I see.<br>
<div class=3D"im"><br>
<br>
&gt;<br>
&gt; Both of them are needed and that is how it is implemented on the direc=
t<br>
&gt; reclaim path. The kswapd batches only try to<br>
&gt; smooth out the system and memcg performance by reclaiming pages proact=
ively.<br>
&gt; It doesn&#39;t affecting the functionality.<br>
<br>
</div>I am still wondering, isn&#39;t this just a nice to have feature rath=
er than=A0must to have in order to get rid of the global LRU?</blockquote><=
div>The per-memcg kswapd is a must-have, and it is less related to the effo=
rt of &quot;get rid of global LRU&quot; than the next patch I am looking at=
 &quot;enhance the soft_limit reclaim&quot;. So this is the structure we wi=
ll end up with</div>
<div><br></div><div>background reclaim:</div><div>1. per-memcg : this patch=
</div><div>2. global: targeting reclaim by replacing the per-zone to soft_l=
imit reclaim</div><div><br></div><div>direct reclaim:</div><div>1. per-memc=
g: no change from today</div>
<div>2. global: targeting reclaim by replacing the per-zone to soft_limit r=
eclaim.</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">Doesn&#39;t it m=
ake=A0transition more complicated. I have noticed many if-else in kswapd pa=
th to<br>

distinguish per-cgroup from the traditional global background reclaim.<br><=
/blockquote><div><br></div><div>=A0</div><div><br></div><div>=A0</div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #cc=
c solid;padding-left:1ex;">

<br>
[...]<br>
<div class=3D"im"><br>
&gt; &gt; &gt; &gt; &gt; Step1: Create a cgroup with 500M memory_limit.<br>
&gt; &gt; &gt; &gt; &gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; &gt; &gt; &gt; &gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_=
in_bytes<br>
&gt; &gt; &gt; &gt; &gt; $ echo $$ &gt;/dev/cgroup/memory/A/tasks<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; Step2: Test and set the wmarks.<br>
&gt; &gt; &gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.low_wmark_distan=
ce<br>
&gt; &gt; &gt; &gt; &gt; 0<br>
&gt; &gt; &gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.high_wmark_dista=
nce<br>
&gt; &gt; &gt; &gt; &gt; 0<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; They are used to tune the high/low_marks based on the hard_l=
imit. We<br>
&gt; &gt; might<br>
&gt; &gt; &gt; need to export that configuration to user admin especially o=
n machines<br>
&gt; &gt; where<br>
&gt; &gt; &gt; they over-commit by hard_limit.<br>
&gt; &gt;<br>
&gt; &gt; I remember there was some resistance against tuning watermarks<br=
>
&gt; &gt; separately.<br>
&gt; &gt;<br>
&gt;<br>
&gt; This API is based on KAMEZAWA&#39;s request. :)<br>
<br>
</div>This was just as FYI. Watermarks were considered internal thing. So I=
<br>
wouldn&#39;t be surprised if this got somehow controversial.<br></blockquot=
e><div><br></div><div>We went back and forth on how to set the high/low wma=
rks for different configurations (over-commit or not). So far, by</div>
<div>giving the user ability to set the wmarks seems the most feasible way =
of fullfilling the requriment.=A0</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<b=
r>
&gt; &gt; &gt; &gt; &gt; low_wmark 524288000<br>
&gt; &gt; &gt; &gt; &gt; high_wmark 524288000<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; $ echo 50m &gt;/dev/cgroup/memory/A/memory.high_wm=
ark_distance<br>
&gt; &gt; &gt; &gt; &gt; $ echo 40m &gt;/dev/cgroup/memory/A/memory.low_wma=
rk_distance<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<b=
r>
&gt; &gt; &gt; &gt; &gt; low_wmark =A0482344960<br>
&gt; &gt; &gt; &gt; &gt; high_wmark 471859200<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; low_wmark is higher than high_wmark?<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; hah, it is confusing. I have them documented. Basically, low=
_wmark<br>
&gt; &gt; &gt; triggers reclaim and high_wmark stop the reclaim. And we hav=
e<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; high_wmark &lt; usage &lt; low_wmark.<br>
<br>
</div>OK, I see how you calculate those watermarks now but it is really<br>
confusing for those who are used to traditional watermark semantic.<br></bl=
ockquote><div><br></div><div>that is true. =A0I adopt the initial comment f=
rom Mel where we keep the same logic of triggering and stopping kswapd with=
 low/high_wmarks and also comparing the usage_in_bytes to the wmarks.=A0Eit=
her way is confusing and guess we just need to document it well.</div>
<div><br></div><div>--Ying</div><div><br></div><meta http-equiv=3D"content-=
type" content=3D"text/html; charset=3Dutf-8"><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;=
">
<font color=3D"#888888">--<br>
</font><div><div></div><div class=3D"h5">Michal Hocko<br>
SUSE Labs<br>
SUSE LINUX s.r.o.<br>
Lihovarska 1060/12<br>
190 00 Praha 9<br>
Czech Republic<br>
</div></div></blockquote></div><br>

--000e0cdfd082ba138304a138e415--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
