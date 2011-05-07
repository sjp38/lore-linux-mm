Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D57E26B0022
	for <linux-mm@kvack.org>; Sat,  7 May 2011 17:59:02 -0400 (EDT)
Received: by vxk20 with SMTP id 20so6862715vxk.14
        for <linux-mm@kvack.org>; Sat, 07 May 2011 14:59:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110502224838.GB10278@cmpxchg.org>
References: <1304366849.15370.27.camel@mulgrave.site>
	<20110502224838.GB10278@cmpxchg.org>
Date: Sun, 8 May 2011 03:29:00 +0530
Message-ID: <BANLkTikKhjmPJKHiJa2hRBdUF2=oe8HZzg@mail.gmail.com>
Subject: Re: memcg: fix fatal livelock in kswapd
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: multipart/alternative; boundary=bcaec53f2ae7bfda0e04a2b6b606
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

--bcaec53f2ae7bfda0e04a2b6b606
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 3, 2011 at 4:18 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi,
>
> On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:
> > The fatal livelock in kswapd, reported in this thread:
> >
> > http://marc.info/?t=130392066000001
> >
> > Is mitigateable if we prevent the cgroups code being so aggressive in
> > its zone shrinking (by reducing it's default shrink from 0 [everything]
> > to DEF_PRIORITY [some things]).  This will have an obvious knock on
> > effect to cgroup accounting, but it's better than hanging systems.
>
> Actually, it's not that obvious.  At least not to me.  I added Balbir,
> who added said comment and code in the first place, to CC: Here is the
> comment in full quote:
>
>
I missed this email in my inbox, just saw it and responding


>        /*
>         * NOTE: Although we can get the priority field, using it
>         * here is not a good idea, since it limits the pages we can scan.
>          * if we don't reclaim here, the shrink_zone from balance_pgdat
>         * will pick up pages from other mem cgroup's as well. We hack
>         * the priority and make it zero.
>          */
>
> The idea is that if one memcg is above its softlimit, we prefer
> reducing pages from this memcg over reclaiming random other pages,
> including those of other memcgs.
>
>
My comment and code were based on the observations I saw during my tests.
With DEF_PRIORITY we see scan >> priority in get_scan_count(), since we know
how much exactly we are over the soft limit, it makes sense to go after the
pages, so that normal balancing can be restored.


> But the code flow looks like this:
>
>        balance_pgdat
>          mem_cgroup_soft_limit_reclaim
>             mem_cgroup_shrink_node_zone
>               shrink_zone(0, zone, &sc)
>           shrink_zone(prio, zone, &sc)
>
> so the success of the inner memcg shrink_zone does at least not
> explicitely result in the outer, global shrink_zone steering clear of
> other memcgs' pages.


Yes, but it allows soft reclaim to know what to target first for success


>  It just tries to move the pressure of balancing
> the zones to the memcg with the biggest soft limit excess.  That can
> only really work if the memcg is a large enough contributor to the
> zone's total number of lru pages, though, and looks very likely to hit
> the exceeding memcg too hard in other cases.
>
> I am very much for removing this hack.  There is still more scan
> pressure applied to memcgs in excess of their soft limit even if the
> extra scan is happening at a sane priority level.  And the fact that
> global reclaim operates completely unaware of memcgs is a different
> story.
>
> However, this code came into place with v2.6.31-8387-g4e41695.  Why is
> it only now showing up?
>
> You also wrote in that thread that this happens on a standard F15
> installation.  On the F15 I am running here, systemd does not
> configure memcgs, however.  Did you manually configure memcgs and set
> soft limits?  Because I wonder how it ended up in soft limit reclaim
> in the first place.
>
>
I am running F15 as well, but never hit the problem so far. I am surprised
to see the stack posted on the thread, it seemed like you
never explicitly enabled anything to wake up the memcg beast :)

Balbir

--bcaec53f2ae7bfda0e04a2b6b606
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 3, 2011 at 4:18 AM, Johannes=
 Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@=
cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi,<br>
<div class=3D"im"><br>
On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:<br>
&gt; The fatal livelock in kswapd, reported in this thread:<br>
&gt;<br>
&gt; <a href=3D"http://marc.info/?t=3D130392066000001" target=3D"_blank">ht=
tp://marc.info/?t=3D130392066000001</a><br>
&gt;<br>
&gt; Is mitigateable if we prevent the cgroups code being so aggressive in<=
br>
&gt; its zone shrinking (by reducing it&#39;s default shrink from 0 [everyt=
hing]<br>
&gt; to DEF_PRIORITY [some things]). =A0This will have an obvious knock on<=
br>
&gt; effect to cgroup accounting, but it&#39;s better than hanging systems.=
<br>
<br>
</div>Actually, it&#39;s not that obvious. =A0At least not to me. =A0I adde=
d Balbir,<br>
who added said comment and code in the first place, to CC: Here is the<br>
comment in full quote:<br>
<br></blockquote><div><br></div><div>I missed this email in my inbox, just =
saw it and responding</div><div>=A0</div><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * NOTE: Although we can get the priority field, using it<b=
r>
 =A0 =A0 =A0 =A0 * here is not a good idea, since it limits the pages we ca=
n scan.<br>
<div class=3D"im"> =A0 =A0 =A0 =A0 * if we don&#39;t reclaim here, the shri=
nk_zone from balance_pgdat<br>
 =A0 =A0 =A0 =A0 * will pick up pages from other mem cgroup&#39;s as well. =
We hack<br>
 =A0 =A0 =A0 =A0 * the priority and make it zero.<br>
</div> =A0 =A0 =A0 =A0 */<br>
<br>
The idea is that if one memcg is above its softlimit, we prefer<br>
reducing pages from this memcg over reclaiming random other pages,<br>
including those of other memcgs.<br>
<br></blockquote><div><br></div><div>My comment and code were based on the =
observations I saw during my tests. With DEF_PRIORITY we see scan &gt;&gt; =
priority in get_scan_count(), since we know how much exactly we are over th=
e soft limit, it makes sense to go after the pages, so that normal balancin=
g can be restored.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
But the code flow looks like this:<br>
<br>
 =A0 =A0 =A0 =A0balance_pgdat<br>
 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_limit_reclaim<br>
<div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_shrink_node_zone<br>
</div><div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone(0, zone, &a=
mp;sc)<br>
</div> =A0 =A0 =A0 =A0 =A0shrink_zone(prio, zone, &amp;sc)<br>
<br>
so the success of the inner memcg shrink_zone does at least not<br>
explicitely result in the outer, global shrink_zone steering clear of<br>
other memcgs&#39; pages. </blockquote><div><br></div><div>Yes, but it allow=
s soft reclaim to know what to target first for success</div><div>=A0</div>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
=A0It just tries to move the pressure of balancing<br>
the zones to the memcg with the biggest soft limit excess. =A0That can<br>
only really work if the memcg is a large enough contributor to the<br>
zone&#39;s total number of lru pages, though, and looks very likely to hit<=
br>
the exceeding memcg too hard in other cases.<br>
<br>
I am very much for removing this hack. =A0There is still more scan<br>
pressure applied to memcgs in excess of their soft limit even if the<br>
extra scan is happening at a sane priority level. =A0And the fact that<br>
global reclaim operates completely unaware of memcgs is a different<br>
story.<br>
<br>
However, this code came into place with v2.6.31-8387-g4e41695. =A0Why is<br=
>
it only now showing up?<br>
<br>
You also wrote in that thread that this happens on a standard F15<br>
installation. =A0On the F15 I am running here, systemd does not<br>
configure memcgs, however. =A0Did you manually configure memcgs and set<br>
soft limits? =A0Because I wonder how it ended up in soft limit reclaim<br>
in the first place.<br><br></blockquote><div><br></div><div>I am running F1=
5 as well, but never hit the problem so far. I am surprised to see the stac=
k posted on the thread, it seemed like you never=A0explicitly=A0enabled any=
thing to wake up the memcg beast :)</div>
<div><br></div><div>Balbir=A0</div></div>

--bcaec53f2ae7bfda0e04a2b6b606--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
