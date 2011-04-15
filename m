Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7D43B900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:41:12 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p3FGf0jK001996
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:41:00 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by wpaz1.hot.corp.google.com with ESMTP id p3FGetA5029877
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:40:59 -0700
Received: by qwi4 with SMTP id 4so2478116qwi.15
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:40:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415094040.GC8828@tiehlicka.suse.cz>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<20110415094040.GC8828@tiehlicka.suse.cz>
Date: Fri, 15 Apr 2011 09:40:54 -0700
Message-ID: <BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84caa2839d04a0f7b479
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--00248c6a84caa2839d04a0f7b479
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 15, 2011 at 2:40 AM, Michal Hocko <mhocko@suse.cz> wrote:

> Hi Ying,
> sorry that I am jumping into game that late but I was quite busy after
> returning back from LSF and LFCS.
>

Sure. Nice meeting you guys there and thank you for looking into this patch
:)

>
> On Thu 14-04-11 15:54:19, Ying Han wrote:
> > The current implementation of memcg supports targeting reclaim when the
> > cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> > Per cgroup background reclaim is needed which helps to spread out memory
> > pressure over longer period of time and smoothes out the cgroup
> performance.
> >
> > If the cgroup is configured to use per cgroup background reclaim, a
> kswapd
> > thread is created which only scans the per-memcg LRU list.
>
> Hmm, I am wondering if this fits into the get-rid-of-the-global-LRU
> strategy. If we make the background reclaim per-cgroup how do we balance
> from the global/zone POV? We can end up with all groups over the high
> limit while a memory zone is under this watermark. Or am I missing
> something?
> I thought that plans for the background reclaim were same as for direct
> reclaim so that kswapd would just evict pages from groups in the
> round-robin fashion (in first round just those that are under limit and
> proportionally when it cannot reach high watermark after it got through
> all groups).
>

I think you are talking about the soft_limit reclaim which I am gonna look
at next. The soft_limit reclaim
is triggered under global memory pressure and doing round-robin across
memcgs. I will also cover the
zone-balancing by having second list of memgs under their soft_limit.

Here is the summary of our LSF discussion :)
http://permalink.gmane.org/gmane.linux.kernel.mm/60966

>
> > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > background reclaim and stop it. The watermarks are calculated based on
> > the cgroup's limit_in_bytes.
>
> I didn't have time to look at the patch how does the calculation work
> yet but we should be careful to match the zone's watermark expectations.
>

I have API on the following patch which provide high/low_wmark_distance to
tune wmarks individually individually.  By default, they are set to 0 which
turn off the per-memcg kswapd. For now, we are ok since the global kswapd is
still doing per-zone scanning and reclaiming :)

>
> > By default, the per-memcg kswapd threads are running under root cgroup.
> There
> > is a per-memcg API which exports the pid of each kswapd thread, and
> userspace
> > can configure cpu cgroup seperately.
> >
> > I run through dd test on large file and then cat the file. Then I
> compared
> > the reclaim related stats in memory.stat.
> >
> > Step1: Create a cgroup with 500M memory_limit.
> > $ mkdir /dev/cgroup/memory/A
> > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > $ echo $$ >/dev/cgroup/memory/A/tasks
> >
> > Step2: Test and set the wmarks.
> > $ cat /dev/cgroup/memory/A/memory.low_wmark_distance
> > 0
> > $ cat /dev/cgroup/memory/A/memory.high_wmark_distance
> > 0
>
>
They are used to tune the high/low_marks based on the hard_limit. We might
need to export that configuration to user admin especially on machines where
they over-commit by hard_limit.

>
> >
> > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > low_wmark 524288000
> > high_wmark 524288000
> >
> > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > $ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance
> >
> > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > low_wmark  482344960
> > high_wmark 471859200
>
> low_wmark is higher than high_wmark?
>

hah, it is confusing. I have them documented. Basically, low_wmark triggers
reclaim and high_wmark stop the reclaim. And we have

high_wmark < usage < low_wmark.

>
> [...]
> > Note:
> > This is the first effort of enhancing the target reclaim into memcg. Here
> are
> > the existing known issues and our plan:
> >
> > 1. there are one kswapd thread per cgroup. the thread is created when the
> > cgroup changes its limit_in_bytes and is deleted when the cgroup is being
> > removed. In some enviroment when thousand of cgroups are being configured
> on
> > a single host, we will have thousand of kswapd threads. The memory
> consumption
> > would be 8k*100 = 8M. We don't see a big issue for now if the host can
> host
> > that many of cgroups.
>
> I think that zone background reclaim is much bigger issue than 8k per
> kernel thread and too many threads...
>

yes.


> I am not sure how much orthogonal per-cgroup-per-thread vs. zone
> approaches are, though.  Maybe it makes some sense to do both per-cgroup
> and zone background reclaim.  Anyway I think that we should start with
> the zone reclaim first.
>

I missed the point here. Can you clarify the zone reclaim here?

>
> [...]
>
> > 4. no hierarchical reclaim support in this patchset. I would like to get
> to
> > after the basic stuff are being accepted.
>
> Just an idea.
> If we did that from zone's POV then we could call
> mem_cgroup_hierarchical_reclaim,
> right?
>
> Maybe. I need to think through that, for this verion I don't plan to
put hierarchical reclaim.

--Ying

> [...]
>
> Thanks
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--00248c6a84caa2839d04a0f7b479
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 15, 2011 at 2:40 AM, Michal =
Hocko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.c=
z</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi Ying,<br>
sorry that I am jumping into game that late but I was quite busy after<br>
returning back from LSF and LFCS.<br></blockquote><div><br></div><div>Sure.=
 Nice meeting you guys there and thank you for looking into this patch :)=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
On Thu 14-04-11 15:54:19, Ying Han wrote:<br>
&gt; The current implementation of memcg supports targeting reclaim when th=
e<br>
&gt; cgroup is reaching its hard_limit and we do direct reclaim per cgroup.=
<br>
&gt; Per cgroup background reclaim is needed which helps to spread out memo=
ry<br>
&gt; pressure over longer period of time and smoothes out the cgroup perfor=
mance.<br>
&gt;<br>
&gt; If the cgroup is configured to use per cgroup background reclaim, a ks=
wapd<br>
&gt; thread is created which only scans the per-memcg LRU list.<br>
<br>
</div>Hmm, I am wondering if this fits into the get-rid-of-the-global-LRU<b=
r>
strategy. If we make the background reclaim per-cgroup how do we balance<br=
>
from the global/zone POV? We can end up with all groups over the high<br>
limit while a memory zone is under this watermark. Or am I missing<br>
something?<br>
I thought that plans for the background reclaim were same as for direct<br>
reclaim so that kswapd would just evict pages from groups in the<br>
round-robin fashion (in first round just those that are under limit and<br>
proportionally when it cannot reach high watermark after it got through<br>
all groups).<br></blockquote><div><br></div><div>I think you are talking ab=
out the soft_limit reclaim which I am gonna look at next. The soft_limit re=
claim</div><div>is triggered under global memory pressure and doing round-r=
obin across memcgs. I will also cover the=A0</div>
<div>zone-balancing by having second list of memgs under their soft_limit.<=
/div><div><br></div><div>Here is the summary of our LSF discussion :)</div>=
<meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8"><d=
iv>
<a href=3D"http://permalink.gmane.org/gmane.linux.kernel.mm/60966">http://p=
ermalink.gmane.org/gmane.linux.kernel.mm/60966</a>=A0=A0</div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">

<div class=3D"im"><br>
&gt; Two watermarks (&quot;high_wmark&quot;, &quot;low_wmark&quot;) are add=
ed to trigger the<br>
&gt; background reclaim and stop it. The watermarks are calculated based on=
<br>
&gt; the cgroup&#39;s limit_in_bytes.<br>
<br>
</div>I didn&#39;t have time to look at the patch how does the calculation =
work<br>
yet but we should be careful to match the zone&#39;s watermark expectations=
.<br></blockquote><div><br></div><div>I have API on the following patch whi=
ch provide=A0high/low_wmark_distance to tune wmarks individually individual=
ly.=A0=A0By default, they are set to 0 which turn off the per-memcg kswapd.=
 For now, we are ok since the global kswapd is still doing per-zone scannin=
g and reclaiming :)</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; By default, the per-memcg kswapd threads are running under root cgroup=
. There<br>
&gt; is a per-memcg API which exports the pid of each kswapd thread, and us=
erspace<br>
&gt; can configure cpu cgroup seperately.<br>
&gt;<br>
&gt; I run through dd test on large file and then cat the file. Then I comp=
ared<br>
&gt; the reclaim related stats in memory.stat.<br>
&gt;<br>
&gt; Step1: Create a cgroup with 500M memory_limit.<br>
&gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<br>
&gt; $ echo $$ &gt;/dev/cgroup/memory/A/tasks<br>
&gt;<br>
&gt; Step2: Test and set the wmarks.<br>
&gt; $ cat /dev/cgroup/memory/A/memory.low_wmark_distance<br>
&gt; 0<br>
&gt; $ cat /dev/cgroup/memory/A/memory.high_wmark_distance<br>
&gt; 0<br><br>
</div></blockquote><div><br></div><div>They are used to tune the high/low_m=
arks based on the hard_limit. We might need to export that configuration to=
 user admin especially on machines where they over-commit by hard_limit.</d=
iv>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; low_wmark 524288000<br>
&gt; high_wmark 524288000<br>
&gt;<br>
&gt; $ echo 50m &gt;/dev/cgroup/memory/A/memory.high_wmark_distance<br>
&gt; $ echo 40m &gt;/dev/cgroup/memory/A/memory.low_wmark_distance<br>
&gt;<br>
&gt; $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks<br>
&gt; low_wmark =A0482344960<br>
&gt; high_wmark 471859200<br>
<br>
</div>low_wmark is higher than high_wmark?<br></blockquote><div><br></div><=
div>hah, it is confusing. I have them documented. Basically, low_wmark trig=
gers reclaim and high_wmark stop the reclaim. And we have=A0</div><div><br>
</div><div>high_wmark &lt; usage &lt; low_wmark.=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">
<br>
[...]<br>
<div class=3D"im">&gt; Note:<br>
&gt; This is the first effort of enhancing the target reclaim into memcg. H=
ere are<br>
&gt; the existing known issues and our plan:<br>
&gt;<br>
&gt; 1. there are one kswapd thread per cgroup. the thread is created when =
the<br>
&gt; cgroup changes its limit_in_bytes and is deleted when the cgroup is be=
ing<br>
&gt; removed. In some enviroment when thousand of cgroups are being configu=
red on<br>
&gt; a single host, we will have thousand of kswapd threads. The memory con=
sumption<br>
&gt; would be 8k*100 =3D 8M. We don&#39;t see a big issue for now if the ho=
st can host<br>
&gt; that many of cgroups.<br>
<br>
</div>I think that zone background reclaim is much bigger issue than 8k per=
<br>
kernel thread and too many threads...<br></blockquote><div><br></div><div>y=
es.</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 =
0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
I am not sure how much orthogonal per-cgroup-per-thread vs. zone<br>
approaches are, though. =A0Maybe it makes some sense to do both per-cgroup<=
br>
and zone background reclaim. =A0Anyway I think that we should start with<br=
>
the zone reclaim first.<br></blockquote><div><br></div><div>I missed the po=
int here. Can you clarify the zone reclaim here?=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">

<br>
[...]<br>
<div class=3D"im"><br>
&gt; 4. no hierarchical reclaim support in this patchset. I would like to g=
et to<br>
&gt; after the basic stuff are being accepted.<br>
<br>
</div>Just an idea.<br>
If we did that from zone&#39;s POV then we could call mem_cgroup_hierarchic=
al_reclaim,<br>
right?<br>
<br></blockquote><div>Maybe. I need to think through that, for this verion =
I don&#39;t plan to put=A0hierarchical=A0reclaim.=A0</div><div><br></div><d=
iv>--Ying</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">

[...]<br>
<br>
Thanks<br>
<font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
SUSE LINUX s.r.o.<br>
Lihovarska 1060/12<br>
190 00 Praha 9<br>
Czech Republic<br>
</font></blockquote></div><br>

--00248c6a84caa2839d04a0f7b479--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
