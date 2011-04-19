Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0405C900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 22:42:47 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3J2gdqS025678
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 19:42:39 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz37.hot.corp.google.com with ESMTP id p3J2ftti023484
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 19:42:38 -0700
Received: by qyk7 with SMTP id 7so1683364qyk.5
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 19:42:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=pyRWb9npHe_SJdYXR-TbrtVtLRg@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-7-git-send-email-yinghan@google.com>
	<BANLkTi=2yQZXhHrDxjPvpKJ-KpmQ242cVQ@mail.gmail.com>
	<BANLkTikZcTj9GAGrsTnMMCq1b9HjnDnGWA@mail.gmail.com>
	<BANLkTi=pyRWb9npHe_SJdYXR-TbrtVtLRg@mail.gmail.com>
Date: Mon, 18 Apr 2011 19:42:37 -0700
Message-ID: <BANLkTi=3VOJCr+xc8Z9zOYznP7m8Lyy9ag@mail.gmail.com>
Subject: Re: [PATCH V5 06/10] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd08213747d04a13c765b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd08213747d04a13c765b
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 18, 2011 at 4:32 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Apr 19, 2011 at 6:38 AM, Ying Han <yinghan@google.com> wrote:
> >
> >
> > On Sun, Apr 17, 2011 at 8:51 PM, Minchan Kim <minchan.kim@gmail.com>
> wrote:
> >>
> >> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> >> > +
> >> > +               sc->nr_scanned = 0;
> >> > +               shrink_zone(priority, zone, sc);
> >> > +               total_scanned += sc->nr_scanned;
> >> > +
> >> > +               /*
> >> > +                * If we've done a decent amount of scanning and
> >> > +                * the reclaim ratio is low, start doing writepage
> >> > +                * even in laptop mode
> >> > +                */
> >> > +               if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> >> > +                   total_scanned > sc->nr_reclaimed +
> sc->nr_reclaimed
> >> > / 2) {
> >> > +                       sc->may_writepage = 1;
> >>
> >> I don't want to add more random write any more although we don't have
> >> a trouble of real memory shortage.
> >
> >
> >>
> >> Do you have any reason to reclaim memory urgently as writing dirty
> pages?
> >> Maybe if we wait a little bit of time, flusher would write out the page.
> >
> > We would like to reduce the writing dirty pages from page reclaim,
> > especially from direct reclaim. AFAIK, the try_to_free_mem_cgroup_pages()
> > still need to write dirty pages when there is a need. removing this from
> the
> > per-memcg kswap will only add more pressure to the per-memcg direct
> reclaim,
> > which seems to be worse. (stack overflow as one example which we would
> like
> > to get rid of)
> >
>
> Stack overflow would be another topic.
>
> Normal situation :
>
> The softlimit memory pressure of memcg isn't real memory shortage and
> if we have gap between hardlimit and softlimit, periodic writeback of
> flusher would write it out before reaching the hardlimit. In the end,
> direct reclaim don't need to write it out.
>
> Exceptional situation :
>
> Of course, it doesn't work well in congestion of bdi, sudden big
> memory consumption in memcg in wrong [hard/soft]limit(small gap)
> configuration of administrator.
>
> I think we have to design it by normal situation.
> The point is that softlimit isn't real memory shortage so that we are
> not urgent.
>

This patch is not dealing with soft_limit, but hard_limit. The soft_limit
reclaim which we talked about during LSF
is something i am currently looking at right now. This patch is doing the
per-memcg background reclaim which
based on the watermarks calculated on the hard_limit. We don't have the
memcg entering the direct reclaim each
time it is reaching the hard_limit, so we add the background reclaim which
reclaiming pages proactively.


> How about adding new function which checks global memory pressure and
> if we have a trouble by global memory pressure, we can change
> may_write with 1 dynamically in memcg_kswapd?
>

Like I mentioned, the may_write is still needed in this case otherwise we
are just put this further to per-memcg
direct reclaim.


Thanks

--Ying

> --
> Kind regards,
> Minchan Kim
>

--000e0cdfd08213747d04a13c765b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 18, 2011 at 4:32 PM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Tue, Apr 19, 2011 at 6:38 AM, Ying Han &lt;<a href=3D"=
mailto:yinghan@google.com">yinghan@google.com</a>&gt; wrote:<br>
&gt;<br>
&gt;<br>
&gt; On Sun, Apr 17, 2011 at 8:51 PM, Minchan Kim &lt;<a href=3D"mailto:min=
chan.kim@gmail.com">minchan.kim@gmail.com</a>&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; On Sat, Apr 16, 2011 at 8:23 AM, Ying Han &lt;<a href=3D"mailto:yi=
nghan@google.com">yinghan@google.com</a>&gt; wrote:<br>
</div><div class=3D"im">&gt;&gt; &gt; +<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc)=
;<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_sc=
anned;<br>
&gt;&gt; &gt; +<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent=
 amount of scanning and<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, =
start doing writepage<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLU=
STER_MAX * 2 &amp;&amp;<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&=
gt;nr_reclaimed + sc-&gt;nr_reclaimed<br>
&gt;&gt; &gt; / 2) {<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writ=
epage =3D 1;<br>
&gt;&gt;<br>
&gt;&gt; I don&#39;t want to add more random write any more although we don=
&#39;t have<br>
&gt;&gt; a trouble of real memory shortage.<br>
&gt;<br>
&gt;<br>
&gt;&gt;<br>
&gt;&gt; Do you have any reason to reclaim memory urgently as writing dirty=
 pages?<br>
&gt;&gt; Maybe if we wait a little bit of time, flusher would write out the=
 page.<br>
&gt;<br>
&gt; We would like to reduce the writing dirty pages from page reclaim,<br>
&gt; especially from direct reclaim. AFAIK, the=A0try_to_free_mem_cgroup_pa=
ges()<br>
&gt; still need to write dirty pages when there is a need. removing this fr=
om the<br>
&gt; per-memcg kswap will only add more pressure to the per-memcg direct re=
claim,<br>
&gt; which seems to be worse. (stack overflow as one example which we would=
 like<br>
&gt; to get rid of)<br>
&gt;<br>
<br>
</div>Stack overflow would be another topic.<br>
<br>
Normal situation :<br>
<br>
The softlimit memory pressure of memcg isn&#39;t real memory shortage and<b=
r>
if we have gap between hardlimit and softlimit, periodic writeback of<br>
flusher would write it out before reaching the hardlimit. In the end,<br>
direct reclaim don&#39;t need to write it out.<br>
<br>
Exceptional situation :<br>
<br>
Of course, it doesn&#39;t work well in congestion of bdi, sudden big<br>
memory consumption in memcg in wrong [hard/soft]limit(small gap)<br>
configuration of administrator.<br>
<br>
I think we have to design it by normal situation.<br>
The point is that softlimit isn&#39;t real memory shortage so that we are<b=
r>
not urgent.<br></blockquote><div><br></div><div>This patch is not dealing w=
ith soft_limit, but hard_limit. The soft_limit reclaim which we talked abou=
t during LSF</div><div>is something i am currently looking at right now. Th=
is patch is doing the per-memcg background reclaim which</div>
<div>based on the watermarks calculated on the hard_limit. We don&#39;t hav=
e the memcg entering the direct reclaim each</div><div>time it is reaching =
the hard_limit, so we add the background reclaim which reclaiming pages pro=
actively.</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;"><br>
How about adding new function which checks global memory pressure and<br>
if we have a trouble by global memory pressure, we can change<br>
may_write with 1 dynamically in memcg_kswapd?<br></blockquote><div>=A0</div=
><div><meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf=
-8"><div>Like I mentioned, the may_write is still needed in this case other=
wise we are just put this further to per-memcg</div>
<div>direct reclaim.</div></div><div><br></div><div><br></div><div>Thanks</=
div><div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--000e0cdfd08213747d04a13c765b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
