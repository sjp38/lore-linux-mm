Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EDB186B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 23:45:20 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p583jA3m028920
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 20:45:15 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by kpbe14.cbf.corp.google.com with ESMTP id p583j9Dn006932
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 20:45:09 -0700
Received: by qyk29 with SMTP id 29so1766483qyk.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 20:45:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602175142.GH28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
	<BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
	<20110602075028.GB20630@cmpxchg.org>
	<BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
	<20110602175142.GH28684@cmpxchg.org>
Date: Tue, 7 Jun 2011 20:45:08 -0700
Message-ID: <BANLkTin+V=qg46o-UJNWuu31KDw3+M2EYQ@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5cb549b404a52b2923
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

--0016360e3f5cb549b404a52b2923
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jun 2, 2011 at 10:51 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Jun 02, 2011 at 08:51:39AM -0700, Ying Han wrote:
> > On Thu, Jun 2, 2011 at 12:50 AM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> > > On Wed, Jun 01, 2011 at 09:05:18PM -0700, Ying Han wrote:
> > >> On Wed, Jun 1, 2011 at 4:52 PM, Hiroyuki Kamezawa
> > >> <kamezawa.hiroyuki@gmail.com> wrote:
> > >> > 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > >> >> Hi,
> > >> >>
> > >> >> this is the second version of the memcg naturalization series.  The
> > >> >> notable changes since the first submission are:
> > >> >>
> > >> >>    o the hierarchy walk is now intermittent and will abort and
> > >> >>      remember the last scanned child after sc->nr_to_reclaim pages
> > >> >>      have been reclaimed during the walk in one zone (Rik)
> > >> >>
> > >> >>    o the global lru lists are never scanned when memcg is enabled
> > >> >>      after #2 'memcg-aware global reclaim', which makes this patch
> > >> >>      self-sufficient and complete without requiring the per-memcg
> lru
> > >> >>      lists to be exclusive (Michal)
> > >> >>
> > >> >>    o renamed sc->memcg and sc->current_memcg to
> sc->target_mem_cgroup
> > >> >>      and sc->mem_cgroup and fixed their documentation, I hope this
> is
> > >> >>      better understandable now (Rik)
> > >> >>
> > >> >>    o the reclaim statistic counters have been renamed.  there is no
> > >> >>      more distinction between 'pgfree' and 'pgsteal', it is now
> > >> >>      'pgreclaim' in both cases; 'kswapd' has been replaced by
> > >> >>      'background'
> > >> >>
> > >> >>    o fixed a nasty crash in the hierarchical soft limit check that
> > >> >>      happened during global reclaim in memcgs that are hierarchical
> > >> >>      but have no hierarchical parents themselves
> > >> >>
> > >> >>    o properly implemented the memcg-aware unevictable page rescue
> > >> >>      scanner, there were several blatant bugs in there
> > >> >>
> > >> >>    o documentation on new public interfaces
> > >> >>
> > >> >> Thanks for your input on the first version.
> > >> >>
> > >> >> I ran microbenchmarks (sparse file catting, essentially) to stress
> > >> >> reclaim and LRU operations.  There is no measurable overhead for
> > >> >> !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
> > >> >> configured groups, and hard limit reclaim.
> > >> >>
> > >> >> I also ran single-threaded kernbenchs in four unlimited memcgs in
> > >> >> parallel, contained in a hard-limited hierarchical parent that put
> > >> >> constant pressure on the workload.  There is no measurable
> difference
> > >> >> in runtime, the pgpgin/pgpgout counters, and fairness among memcgs
> in
> > >> >> this test compared to an unpatched kernel.  Needs more evaluation,
> > >> >> especially with a higher number of memcgs.
> > >> >>
> > >> >> The soft limit changes are also proven to work in so far that it is
> > >> >> possible to prioritize between children in a hierarchy under
> pressure
> > >> >> and that runtime differences corresponded directly to the soft
> limit
> > >> >> settings in the previously described kernbench setup with staggered
> > >> >> soft limits on the groups, but this needs quantification.
> > >> >>
> > >> >> Based on v2.6.39.
> > >> >>
> > >> >
> > >> > Hmm, I welcome and will review this patches but.....some points I
> want to say.
> > >> >
> > >> > 1. No more conflict with Ying's work ?
> > >> >    Could you explain what she has and what you don't in this v2 ?
> > >> >    If Ying's one has something good to be merged to your set, please
> > >> > include it.
> > >>
> > >> My patch I sent out last time was doing rework of soft_limit reclaim.
> > >> It convert the RB-tree based to
> > >> a linked list round-robin fashion of all memcgs across their soft
> > >> limit per-zone.
> > >>
> > >> I will apply this patch and try to test it. After that i will get
> > >> better idea whether or not it is being covered here.
> > >
> > > Thanks!!
> > >
> > >> > 4. This work can be splitted into some small works.
> > >> >     a) fix for current code and clean ups
> > >>
> > >> >     a') statistics
> > >>
> > >> >     b) soft limit rework
> > >>
> > >> >     c) change global reclaim
> > >>
> > >> My last patchset starts with a patch reverting the RB-tree
> > >> implementation of the soft_limit
> > >> reclaim, and then the new round-robin implementation comes on the
> > >> following patches.
> > >>
> > >> I like the ordering here, and that is consistent w/ the plan we
> > >> discussed earlier in LSF. Changing
> > >> the global reclaim would be the last step when the changes before that
> > >> have been well understood
> > >> and tested.
> > >>
> > >> Sorry If that is how it is done here. I will read through the
> patchset.
> > >
> > > It's not.  The way I implemented soft limits depends on global reclaim
> > > performing hierarchical reclaim.  I don't see how I can reverse the
> > > order with this dependency.
> >
> > That is something I don't quite get yet, and maybe need a closer look
> > into the patchset. The current design of
> > soft_limit doesn't do reclaim hierarchically but instead links the
> > memcgs together on per-zone basis.
> >
> > However on this patchset, we changed that design and doing
> > hierarchy_walk of the memcg tree. Can we clarify more on why we made
> > the design change? I can see the current design provides a efficient
> > way to pick the one memcg over-their-soft-limit under shrink_zone().
>
> The question is whether we even want it to work that way.  I outlined
> that in the changelog of the soft limit rework patch.
>
> As I see it, the soft limit should not exist solely to punish a memcg,
> but to prioritize memcgs in case hierarchical pressure exists.  I am
> arguing that the focus should be on relieving the pressure, rather
> than beating the living crap out of the single-biggest offender.  Keep
> in mind the scenarios where the biggest offender has a lot of dirty,
> hard-to-reclaim pages while there are other, unsoftlimited groups that
> have large amounts of easily reclaimable cache of questionable future
> value.  I believe only going for soft-limit excessors is too extreme,
> only for the single-biggest one outright nuts.
>
> The second point I made last time already is that there is no
> hierarchy support with that current scheme.  If you have a group with
> two subgroups, it makes sense to soft limit one subgroup against the
> other when the parent hits its limit.  This is not possible otherwise.
>
> The third point was that the amount of code to actually support the
> questionable behaviour of picking the biggest offender is gigantic
> compared to naturally hooking soft limit reclaim into regular reclaim.
>

Ok, thank you for detailed clarification. After reading through the patchset
more closely, I do agree that it makes
better integration of memcg reclaim to the other part of vm reclaim code. So
I don't have objection at this point to
proceed w/ this direction. However, three of my concerns still remains:

1.  Whether or not we introduced extra overhead for each shrink_zone() under
global memory pressure. We used to have quick
access of memcgs to reclaim from who has pages charged on the zone. Now we
need to do hierarchy_walk for all memcgs on the system. This requires more
testing and more data results would be helpful

2. The way we treat the per-memcg soft_limit is changed in this patch. The
same comment I made on the following patch where we shouldn't change the
definition of user API (soft_limit_in_bytes in this case). So I attached the
patch to fix that where we should only go to the ones under their soft_limit
above certain reclaim priority. Please consider.

3. Please break this patchset into different patchsets. One way to break it
could be:

a) code which is less relevant to this effort and should be merged first
early regardless
b) code added in vm reclaim supporting the following changes
c) rework soft limit reclaim
d) make per-memcg lru lists exclusive

I should have the patch posted soon which breaks the zone->lru lock for
memcg reclaim. That patch should come after everything listed above.

Thanks
--Ying

>
> The implementation is not proven to be satisfactory, I only sent it
> out so early and with this particular series because I wanted people
> to stop merging reclaim statistics that may not even be supportable in
> the long run.
>
> I agree with Andrew: we either need to prove it's the way to go, or
> prove that we never want to do it like this.  Before we start adding
> statistics that commit us to one way or the other.
>
>

--0016360e3f5cb549b404a52b2923
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Jun 2, 2011 at 10:51 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Thu, Jun 02, 2011 at 08:51:39AM -0700,=
 Ying Han wrote:<br>
&gt; On Thu, Jun 2, 2011 at 12:50 AM, Johannes Weiner &lt;<a href=3D"mailto=
:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt; &gt; On Wed, Jun 01, 2011 at 09:05:18PM -0700, Ying Han wrote:<br>
&gt; &gt;&gt; On Wed, Jun 1, 2011 at 4:52 PM, Hiroyuki Kamezawa<br>
&gt; &gt;&gt; &lt;<a href=3D"mailto:kamezawa.hiroyuki@gmail.com">kamezawa.h=
iroyuki@gmail.com</a>&gt; wrote:<br>
&gt; &gt;&gt; &gt; 2011/6/1 Johannes Weiner &lt;<a href=3D"mailto:hannes@cm=
pxchg.org">hannes@cmpxchg.org</a>&gt;:<br>
&gt; &gt;&gt; &gt;&gt; Hi,<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; this is the second version of the memcg naturalizati=
on series. =A0The<br>
&gt; &gt;&gt; &gt;&gt; notable changes since the first submission are:<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o the hierarchy walk is now intermittent and =
will abort and<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0remember the last scanned child after sc-=
&gt;nr_to_reclaim pages<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0have been reclaimed during the walk in on=
e zone (Rik)<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o the global lru lists are never scanned when=
 memcg is enabled<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0after #2 &#39;memcg-aware global reclaim&=
#39;, which makes this patch<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0self-sufficient and complete without requ=
iring the per-memcg lru<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0lists to be exclusive (Michal)<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o renamed sc-&gt;memcg and sc-&gt;current_mem=
cg to sc-&gt;target_mem_cgroup<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0and sc-&gt;mem_cgroup and fixed their doc=
umentation, I hope this is<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0better understandable now (Rik)<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o the reclaim statistic counters have been re=
named. =A0there is no<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0more distinction between &#39;pgfree&#39;=
 and &#39;pgsteal&#39;, it is now<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0&#39;pgreclaim&#39; in both cases; &#39;k=
swapd&#39; has been replaced by<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0&#39;background&#39;<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o fixed a nasty crash in the hierarchical sof=
t limit check that<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0happened during global reclaim in memcgs =
that are hierarchical<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0but have no hierarchical parents themselv=
es<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o properly implemented the memcg-aware unevic=
table page rescue<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0 =A0scanner, there were several blatant bugs =
in there<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; =A0 =A0o documentation on new public interfaces<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; Thanks for your input on the first version.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; I ran microbenchmarks (sparse file catting, essentia=
lly) to stress<br>
&gt; &gt;&gt; &gt;&gt; reclaim and LRU operations. =A0There is no measurabl=
e overhead for<br>
&gt; &gt;&gt; &gt;&gt; !CONFIG_MEMCG, memcg disabled during boot, memcg ena=
bled but no<br>
&gt; &gt;&gt; &gt;&gt; configured groups, and hard limit reclaim.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; I also ran single-threaded kernbenchs in four unlimi=
ted memcgs in<br>
&gt; &gt;&gt; &gt;&gt; parallel, contained in a hard-limited hierarchical p=
arent that put<br>
&gt; &gt;&gt; &gt;&gt; constant pressure on the workload. =A0There is no me=
asurable difference<br>
&gt; &gt;&gt; &gt;&gt; in runtime, the pgpgin/pgpgout counters, and fairnes=
s among memcgs in<br>
&gt; &gt;&gt; &gt;&gt; this test compared to an unpatched kernel. =A0Needs =
more evaluation,<br>
&gt; &gt;&gt; &gt;&gt; especially with a higher number of memcgs.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; The soft limit changes are also proven to work in so=
 far that it is<br>
&gt; &gt;&gt; &gt;&gt; possible to prioritize between children in a hierarc=
hy under pressure<br>
&gt; &gt;&gt; &gt;&gt; and that runtime differences corresponded directly t=
o the soft limit<br>
&gt; &gt;&gt; &gt;&gt; settings in the previously described kernbench setup=
 with staggered<br>
&gt; &gt;&gt; &gt;&gt; soft limits on the groups, but this needs quantifica=
tion.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; Based on v2.6.39.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; Hmm, I welcome and will review this patches but.....some=
 points I want to say.<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; 1. No more conflict with Ying&#39;s work ?<br>
&gt; &gt;&gt; &gt; =A0 =A0Could you explain what she has and what you don&#=
39;t in this v2 ?<br>
&gt; &gt;&gt; &gt; =A0 =A0If Ying&#39;s one has something good to be merged=
 to your set, please<br>
&gt; &gt;&gt; &gt; include it.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; My patch I sent out last time was doing rework of soft_limit =
reclaim.<br>
&gt; &gt;&gt; It convert the RB-tree based to<br>
&gt; &gt;&gt; a linked list round-robin fashion of all memcgs across their =
soft<br>
&gt; &gt;&gt; limit per-zone.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; I will apply this patch and try to test it. After that i will=
 get<br>
&gt; &gt;&gt; better idea whether or not it is being covered here.<br>
&gt; &gt;<br>
&gt; &gt; Thanks!!<br>
&gt; &gt;<br>
&gt; &gt;&gt; &gt; 4. This work can be splitted into some small works.<br>
&gt; &gt;&gt; &gt; =A0 =A0 a) fix for current code and clean ups<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt; =A0 =A0 a&#39;) statistics<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt; =A0 =A0 b) soft limit rework<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt; =A0 =A0 c) change global reclaim<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; My last patchset starts with a patch reverting the RB-tree<br=
>
&gt; &gt;&gt; implementation of the soft_limit<br>
&gt; &gt;&gt; reclaim, and then the new round-robin implementation comes on=
 the<br>
&gt; &gt;&gt; following patches.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; I like the ordering here, and that is consistent w/ the plan =
we<br>
&gt; &gt;&gt; discussed earlier in LSF. Changing<br>
&gt; &gt;&gt; the global reclaim would be the last step when the changes be=
fore that<br>
&gt; &gt;&gt; have been well understood<br>
&gt; &gt;&gt; and tested.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Sorry If that is how it is done here. I will read through the=
 patchset.<br>
&gt; &gt;<br>
&gt; &gt; It&#39;s not. =A0The way I implemented soft limits depends on glo=
bal reclaim<br>
&gt; &gt; performing hierarchical reclaim. =A0I don&#39;t see how I can rev=
erse the<br>
&gt; &gt; order with this dependency.<br>
&gt;<br>
&gt; That is something I don&#39;t quite get yet, and maybe need a closer l=
ook<br>
&gt; into the patchset. The current design of<br>
&gt; soft_limit doesn&#39;t do reclaim hierarchically but instead links the=
<br>
&gt; memcgs together on per-zone basis.<br>
&gt;<br>
&gt; However on this patchset, we changed that design and doing<br>
&gt; hierarchy_walk of the memcg tree. Can we clarify more on why we made<b=
r>
&gt; the design change? I can see the current design provides a efficient<b=
r>
&gt; way to pick the one memcg over-their-soft-limit under shrink_zone().<b=
r>
<br>
</div></div>The question is whether we even want it to work that way. =A0I =
outlined<br>
that in the changelog of the soft limit rework patch.<br>
<br>
As I see it, the soft limit should not exist solely to punish a memcg,<br>
but to prioritize memcgs in case hierarchical pressure exists. =A0I am<br>
arguing that the focus should be on relieving the pressure, rather<br>
than beating the living crap out of the single-biggest offender. =A0Keep<br=
>
in mind the scenarios where the biggest offender has a lot of dirty,<br>
hard-to-reclaim pages while there are other, unsoftlimited groups that<br>
have large amounts of easily reclaimable cache of questionable future<br>
value. =A0I believe only going for soft-limit excessors is too extreme,<br>
only for the single-biggest one outright nuts.<br>
<br>
The second point I made last time already is that there is no<br>
hierarchy support with that current scheme. =A0If you have a group with<br>
two subgroups, it makes sense to soft limit one subgroup against the<br>
other when the parent hits its limit. =A0This is not possible otherwise.<br=
>
<br>
The third point was that the amount of code to actually support the<br>
questionable behaviour of picking the biggest offender is gigantic<br>
compared to naturally hooking soft limit reclaim into regular reclaim.<br><=
/blockquote><div><br></div><div>Ok, thank you for detailed clarification. A=
fter reading through the patchset more closely, I do agree that it makes</d=
iv>
<div>better integration of memcg reclaim to the other part of vm reclaim co=
de. So I don&#39;t have objection at this point to</div><div>proceed w/ thi=
s direction. However,=A0three of my concerns still remains:</div><div><br>
</div><div>1. =A0Whether or not we introduced extra overhead for each shrin=
k_zone() under global memory pressure. We used to have quick</div><div>acce=
ss of memcgs to reclaim from who has pages charged on the zone. Now we need=
 to do=A0hierarchy_walk for all memcgs on the system.=A0This requires more =
testing and more data results would be helpful</div>
<div><br></div><div>2. The way we treat the per-memcg soft_limit is changed=
 in this patch. The same comment I made on the following patch where we sho=
uldn&#39;t change the definition of user API (soft_limit_in_bytes in this c=
ase). So I attached the patch to fix that where we should only go to the on=
es under their soft_limit above certain reclaim priority. Please consider.<=
/div>
<div><br></div><div>3. Please break this patchset into different patchsets.=
 One way to break it could be:</div><div><br></div><div>a) code which is le=
ss=A0relevant=A0to this effort and should be merged first early regardless<=
/div>
<div>b) code added in vm reclaim supporting the following changes</div><div=
>c) rework soft limit reclaim=A0</div><div>d) make per-memcg lru lists excl=
usive</div><div>=A0</div><div>I should have the patch posted soon which bre=
aks the zone-&gt;lru lock for memcg reclaim. That patch should come after e=
verything listed above.</div>
<div><br></div><div>Thanks</div><div>--Ying</div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
<br>
The implementation is not proven to be satisfactory, I only sent it<br>
out so early and with this particular series because I wanted people<br>
to stop merging reclaim statistics that may not even be supportable in<br>
the long run.<br>
<br>
I agree with Andrew: we either need to prove it&#39;s the way to go, or<br>
prove that we never want to do it like this. =A0Before we start adding<br>
statistics that commit us to one way or the other.<br>
<br></blockquote><div>=A0</div></div><br>

--0016360e3f5cb549b404a52b2923--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
