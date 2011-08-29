Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D0EC6900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 16:36:58 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p7TKaqPt005470
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 13:36:53 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz5.hot.corp.google.com with ESMTP id p7TKai3j006492
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 13:36:51 -0700
Received: by qyk7 with SMTP id 7so4503969qyk.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 13:36:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110829190426.GC1434@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
	<20110811210914.GB31229@cmpxchg.org>
	<CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
	<CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
	<20110829190426.GC1434@cmpxchg.org>
Date: Mon, 29 Aug 2011 13:36:48 -0700
Message-ID: <CALWz4ix1X8=L0HzQpdGd=XVbjZuMCtYngzdG+hLMoeJJCUEjrg@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00163628429eb5e3dc04abaada73
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

--00163628429eb5e3dc04abaada73
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 29, 2011 at 12:04 PM, Johannes Weiner <hannes@cmpxchg.org>wrote=
:

> On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
> > On Mon, Aug 29, 2011 at 12:15 AM, Ying Han <yinghan@google.com> wrote:
> > > On Thu, Aug 11, 2011 at 2:09 PM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> > >>
> > >> On Thu, Aug 11, 2011 at 01:39:45PM -0700, Ying Han wrote:
> > >> > Please consider including the following patch for the next post. I=
t
> causes
> > >> > crash on some of the tests where sc->mem_cgroup is NULL (global
> kswapd).
> > >> >
> > >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > >> > index b72a844..12ab25d 100644
> > >> > --- a/mm/vmscan.c
> > >> > +++ b/mm/vmscan.c
> > >> > @@ -2768,7 +2768,8 @@ loop_again:
> > >> >                          * Do some background aging of the anon
> list, to
> > >> > give
> > >> >                          * pages a chance to be referenced before
> > >> > reclaiming.
> > >> >                          */
> > >> > -                       if (inactive_anon_is_low(zone, &sc))
> > >> > +                       if (scanning_global_lru(&sc) &&
> > >> > +                                       inactive_anon_is_low(zone,
> &sc))
> > >> >                                 shrink_active_list(SWAP_CLUSTER_MA=
X,
> zone,
> > >> >                                                         &sc,
> priority, 0);
> > >>
> > >> Thanks!  I completely overlooked this one and only noticed it after
> > >> changing the arguments to shrink_active_list().
> > >>
> > >> On memcg configurations, scanning_global_lru() will essentially neve=
r
> > >> be true again, so I moved the anon pre-aging to a separate function
> > >> that also does a hierarchy loop to preage the per-memcg anon lists.
> > >>
> > >> I hope to send out the next revision soon.
> > >
> > > Also, please consider to fold in the following patch as well. It fixe=
s
> > > the root cgroup lru accounting and we could easily trigger OOM while
> > > doing some swapoff test w/o it.
> > >
> > > mm:fix the lru accounting for root cgroup.
> > >
> > > This patch is applied on top of:
> > > "
> > > mm: memcg-aware global reclaim
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > "
> > >
> > > This patch fixes the lru accounting for root cgroup.
> > >
> > > After the "memcg-aware global reclaim" patch, one of the changes is t=
o
> have
> > > lru pages linked back to root. Under the global memory pressure, we
> start from
> > > the root cgroup lru and walk through the memcg hierarchy of the syste=
m.
> For
> > > each memcg, we reclaim pages based on the its lru size.
> > >
> > > However for root cgroup, we used not having a seperate lru and only
> counting
> > > the pages charged to root as part of root lru size. Without this patc=
h,
> all
> > > the pages which are linked to root lru but not charged to root like
> swapcache
> > > readahead are not visible to page reclaim code and we are easily to g=
et
> OOM.
> > >
> > > After this patch, all the pages linked under root lru are counted in
> the lru
> > > size, including Used and !Used.
> > >
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > Signed-off-by: Ying Han <yinghan@google.com>
> > >
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 5518f54..f6c5f29 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *page,
> > > enum lru_list lru)
> > >  {
> > >  >------struct page_cgroup *pc;
> > >  >------struct mem_cgroup_per_zone *mz;
> > > +>------struct mem_cgroup *mem;
> > > =B7
> > >  >------if (mem_cgroup_disabled())
> > >  >------>-------return;
> > >  >------pc =3D lookup_page_cgroup(page);
> > > ->------/* can happen while we handle swapcache. */
> > > ->------if (!TestClearPageCgroupAcctLRU(pc))
> > > ->------>-------return;
> > > ->------VM_BUG_ON(!pc->mem_cgroup);
> > > ->------/*
> > > ->------ * We don't check PCG_USED bit. It's cleared when the "page" =
is
> finally
> > > ->------ * removed from global LRU.
> > > ->------ */
> > > ->------mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> > > +
> > > +>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {
>
> This PageCgroupUsed part confuses me.  A page that is being isolated
> shortly after being charged while on the LRU may reach here, and then
> it is unaccounted from pc->mem_cgroup, which it never was accounted
> to.
>
> Could you explain why you added it?
>

To be honest, i don't have very good reason for that. The PageCgroupUsed
check is put there after running some tests and some fixes seems help the
test, including this one.

The one case I can think of for page !AcctLRU | Used is in the pagevec.
However, we shouldn't get to the mem_cgroup_del_lru_list() for a page in
pagevec at the first place.

I now made it so that PageCgroupAcctLRU on the LRU means accounted to
> pc->mem_cgroup,


this is the same logic currently.


> and !PageCgroupAcctLRU on the LRU means accounted to
> and babysitted by root_mem_cgroup.


this seems to be different from what it is now, especially for swapcache
page. So, the page here is linked to root cgroup LRU or not?

Anyway, the AcctLRU flags still seems confusing to me:

what this flag tells me is that whether or not the page is on a PRIVATE lru
and being accounted, i used private here to differentiate from the per zone
lru, where it also has PageLRU flag.  The two flags are separate since page=
s
could be on one lru not the other ( I guess ) , but this is changed after
having the root cgroup lru back. For example, AcctLRU is used to keep track
of the accounted lru pages, especially for root ( we didn't account the
!Used pages to root like readahead swapcache). Now we account the full size
of lru list of root including Used and !Used, but only mark the Used pages
w/ AcctLRU flag.

So in general, i am wondering we should be able to replace that eventually
with existing Used and LRU bit.  Sorry this seems to be something we like t=
o
consider later, not necessarily now :)

Always.  Which also means that

> before_commit now ensures an LRU page is moved to root_mem_cgroup for
> babysitting during the charge, so that concurrent isolations/putbacks
> are always accounted correctly.  Is this what you had in mind?  Did I
> miss something?
>

In my tree, the before->commit->after protocol is folded into one function.
I didn't post it since I know you also have patch doing that.  So guess I
don't understand why we need to move the page to root while it is gonna be
charged to a memcg by commit_charge shortly after.

My understanding is that in before_commit, we uncharge the page from
previous memcg lru if AcctLRU was set, then in the commit_charge we update
the new owner of it. And in after_commit we update the memcg lru for the ne=
w
owner after linking the page in the lru.

--Ying

--00163628429eb5e3dc04abaada73
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Aug 29, 2011 at 12:04 PM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hanne=
s@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:=
<br>
</div><div><div></div><div class=3D"h5">&gt; On Mon, Aug 29, 2011 at 12:15 =
AM, Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</=
a>&gt; wrote:<br>
&gt; &gt; On Thu, Aug 11, 2011 at 2:09 PM, Johannes Weiner &lt;<a href=3D"m=
ailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; On Thu, Aug 11, 2011 at 01:39:45PM -0700, Ying Han wrote:<br>
&gt; &gt;&gt; &gt; Please consider including the following patch for the ne=
xt post. It causes<br>
&gt; &gt;&gt; &gt; crash on some of the tests where sc-&gt;mem_cgroup is NU=
LL (global kswapd).<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; &gt;&gt; &gt; index b72a844..12ab25d 100644<br>
&gt; &gt;&gt; &gt; --- a/mm/vmscan.c<br>
&gt; &gt;&gt; &gt; +++ b/mm/vmscan.c<br>
&gt; &gt;&gt; &gt; @@ -2768,7 +2768,8 @@ loop_again:<br>
&gt; &gt;&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do =
some background aging of the anon list, to<br>
&gt; &gt;&gt; &gt; give<br>
&gt; &gt;&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pag=
es a chance to be referenced before<br>
&gt; &gt;&gt; &gt; reclaiming.<br>
&gt; &gt;&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br=
>
&gt; &gt;&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inacti=
ve_anon_is_low(zone, &amp;sc))<br>
&gt; &gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scanni=
ng_global_lru(&amp;sc) &amp;&amp;<br>
&gt; &gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 inactive_anon_is_low(zone, &amp;sc))<br>
&gt; &gt;&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 shrink_active_list(SWAP_CLUSTER_MAX, zone,<br>
&gt; &gt;&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;sc, priority, =
0);<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Thanks! =A0I completely overlooked this one and only noticed =
it after<br>
&gt; &gt;&gt; changing the arguments to shrink_active_list().<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; On memcg configurations, scanning_global_lru() will essential=
ly never<br>
&gt; &gt;&gt; be true again, so I moved the anon pre-aging to a separate fu=
nction<br>
&gt; &gt;&gt; that also does a hierarchy loop to preage the per-memcg anon =
lists.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; I hope to send out the next revision soon.<br>
&gt; &gt;<br>
&gt; &gt; Also, please consider to fold in the following patch as well. It =
fixes<br>
&gt; &gt; the root cgroup lru accounting and we could easily trigger OOM wh=
ile<br>
&gt; &gt; doing some swapoff test w/o it.<br>
&gt; &gt;<br>
&gt; &gt; mm:fix the lru accounting for root cgroup.<br>
&gt; &gt;<br>
&gt; &gt; This patch is applied on top of:<br>
&gt; &gt; &quot;<br>
&gt; &gt; mm: memcg-aware global reclaim<br>
&gt; &gt; Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxc=
hg.org">hannes@cmpxchg.org</a>&gt;<br>
&gt; &gt; &quot;<br>
&gt; &gt;<br>
&gt; &gt; This patch fixes the lru accounting for root cgroup.<br>
&gt; &gt;<br>
&gt; &gt; After the &quot;memcg-aware global reclaim&quot; patch, one of th=
e changes is to have<br>
&gt; &gt; lru pages linked back to root. Under the global memory pressure, =
we start from<br>
&gt; &gt; the root cgroup lru and walk through the memcg hierarchy of the s=
ystem. For<br>
&gt; &gt; each memcg, we reclaim pages based on the its lru size.<br>
&gt; &gt;<br>
&gt; &gt; However for root cgroup, we used not having a seperate lru and on=
ly counting<br>
&gt; &gt; the pages charged to root as part of root lru size. Without this =
patch, all<br>
&gt; &gt; the pages which are linked to root lru but not charged to root li=
ke swapcache<br>
&gt; &gt; readahead are not visible to page reclaim code and we are easily =
to get OOM.<br>
&gt; &gt;<br>
&gt; &gt; After this patch, all the pages linked under root lru are counted=
 in the lru<br>
&gt; &gt; size, including Used and !Used.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Hugh Dickins &lt;<a href=3D"mailto:hughd@google.co=
m">hughd@google.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com"=
>yinghan@google.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; &gt; index 5518f54..f6c5f29 100644<br>
&gt; &gt; --- a/mm/memcontrol.c<br>
&gt; &gt; +++ b/mm/memcontrol.c<br>
&gt; &gt; @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *p=
age,<br>
&gt; &gt; enum lru_list lru)<br>
&gt; &gt; =A0{<br>
&gt; &gt; =A0&gt;------struct page_cgroup *pc;<br>
&gt; &gt; =A0&gt;------struct mem_cgroup_per_zone *mz;<br>
&gt; &gt; +&gt;------struct mem_cgroup *mem;<br>
&gt; &gt; =B7<br>
&gt; &gt; =A0&gt;------if (mem_cgroup_disabled())<br>
&gt; &gt; =A0&gt;------&gt;-------return;<br>
&gt; &gt; =A0&gt;------pc =3D lookup_page_cgroup(page);<br>
&gt; &gt; -&gt;------/* can happen while we handle swapcache. */<br>
&gt; &gt; -&gt;------if (!TestClearPageCgroupAcctLRU(pc))<br>
&gt; &gt; -&gt;------&gt;-------return;<br>
&gt; &gt; -&gt;------VM_BUG_ON(!pc-&gt;mem_cgroup);<br>
&gt; &gt; -&gt;------/*<br>
&gt; &gt; -&gt;------ * We don&#39;t check PCG_USED bit. It&#39;s cleared w=
hen the &quot;page&quot; is finally<br>
&gt; &gt; -&gt;------ * removed from global LRU.<br>
&gt; &gt; -&gt;------ */<br>
&gt; &gt; -&gt;------mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<=
br>
&gt; &gt; +<br>
&gt; &gt; +&gt;------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(p=
c)) {<br>
<br>
</div></div>This PageCgroupUsed part confuses me. =A0A page that is being i=
solated<br>
shortly after being charged while on the LRU may reach here, and then<br>
it is unaccounted from pc-&gt;mem_cgroup, which it never was accounted<br>
to.<br>
<br>
Could you explain why you added it?<br></blockquote><div><br></div><div>To =
be honest, i don&#39;t have very good reason for that. The PageCgroupUsed c=
heck is put there after running some tests and some fixes seems help the te=
st, including this one.</div>
<div><br></div><div>The one case I can think of for page !AcctLRU | Used is=
 in the pagevec. However, we shouldn&#39;t get to the=A0mem_cgroup_del_lru_=
list() for a page in pagevec at the first place.</div><div><br></div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex;">
I now made it so that PageCgroupAcctLRU on the LRU means accounted to<br>
pc-&gt;mem_cgroup, </blockquote><div><br></div><div>this is the same logic =
currently.=A0</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">and !PageC=
groupAcctLRU on the LRU means accounted to<br>

and babysitted by root_mem_cgroup. =A0</blockquote><div><br></div><div>this=
 seems to be different from what it is now, especially for swapcache page. =
So, the page here is linked to root cgroup LRU or not?</div><div><br></div>
<div>Anyway, the AcctLRU flags still seems confusing to me:</div><div><br><=
/div><div><span class=3D"Apple-style-span" style=3D"color: rgb(51, 51, 51);=
 font-family: arial, sans-serif; font-size: 13px; background-color: rgb(255=
, 255, 255); ">what this flag tells me is that whether or not the page is o=
n a PRIVATE lru and being accounted, i used private here to differentiate f=
rom the per zone lru, where it also has PageLRU flag. =A0The two flags are=
=A0separate since pages could be on one lru not the other ( I guess ) , but=
 this is changed after having the root cgroup lru back. For example,=A0</sp=
an><span class=3D"Apple-style-span" style=3D"color: rgb(51, 51, 51); font-f=
amily: arial, sans-serif; font-size: 13px; background-color: rgb(255, 255, =
255); ">AcctLRU is used to keep track of the accounted lru pages, especiall=
y for root ( we didn&#39;t account the !Used pages to root like readahead s=
wapcache). Now we account the full size of lru list of root including Used =
and !Used, but only mark the Used pages w/ AcctLRU flag.=A0</span></div>
<div><span class=3D"Apple-style-span" style=3D"color: rgb(51, 51, 51); font=
-family: arial, sans-serif; font-size: 13px; background-color: rgb(255, 255=
, 255); "><br></span></div><div><span class=3D"Apple-style-span" style=3D"c=
olor: rgb(51, 51, 51); font-family: arial, sans-serif; font-size: 13px; bac=
kground-color: rgb(255, 255, 255); ">So in general, i am wondering we shoul=
d be able to replace that eventually with existing Used and LRU bit. =A0Sor=
ry this seems to be something we like to consider later, not necessarily no=
w :)</span></div>
<div><font class=3D"Apple-style-span" color=3D"#333333" face=3D"arial, sans=
-serif"><br></font></div><div>Always. =A0Which also means that</div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex;">

before_commit now ensures an LRU page is moved to root_mem_cgroup for<br>
babysitting during the charge, so that concurrent isolations/putbacks<br>
are always accounted correctly. =A0Is this what you had in mind? =A0Did I<b=
r>
miss something?<br></blockquote><div><br></div><div>In my tree, the before-=
&gt;commit-&gt;after=A0protocol=A0is folded into one function. I didn&#39;t=
 post it since I know you also have patch doing that. =A0So guess I don&#39=
;t understand why we need to move the page to root while it is gonna be cha=
rged to a memcg by commit_charge shortly after.</div>
<div><br></div><div>My understanding is that in before_commit, we uncharge =
the page from previous memcg lru if AcctLRU was set, then in the commit_cha=
rge we update the new owner of it. And in after_commit we update the memcg =
lru for the new owner after linking the page in the lru.=A0</div>
<div><br></div><div>--Ying</div><div>=A0</div></div><br>

--00163628429eb5e3dc04abaada73--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
