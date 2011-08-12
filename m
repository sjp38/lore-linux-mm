Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D83F96B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:08:25 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p7CH8KVS006596
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 10:08:21 -0700
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by wpaz17.hot.corp.google.com with ESMTP id p7CH7Uqu028701
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 10:08:19 -0700
Received: by qyk34 with SMTP id 34so441417qyk.10
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 10:08:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812083458.GB6916@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
	<CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
	<20110812083458.GB6916@cmpxchg.org>
Date: Fri, 12 Aug 2011 10:08:18 -0700
Message-ID: <CALWz4iz=30A7hUkEmo5_K3q1KiM8tBWvh_ghhbEFm0ZksfzQ=g@mail.gmail.com>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00163628429ec252a704aa51f55b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--00163628429ec252a704aa51f55b
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Aug 12, 2011 at 1:34 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Aug 11, 2011 at 01:33:05PM -0700, Ying Han wrote:
> > > Johannes, I wonder if we should include the following patch:
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 674823e..1513deb 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -832,7 +832,7 @@ static void
> > mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
> >          * Forget old LRU when this page_cgroup is *not* used. This Used
> bit
> >          * is guarded by lock_page() because the page is SwapCache.
> >          */
> > -       if (!PageCgroupUsed(pc))
> > +       if (PageLRU(page) && !PageCgroupUsed(pc))
> >                 del_page_from_lru(zone, page);
> >         spin_unlock_irqrestore(&zone->lru_lock, flags);
>
>
:


> Yes, as the first PageLRU check is outside the lru_lock, PageLRU may
> indeed go away before grabbing the lock.  The page will already be
> unlinked and the LRU accounting will be off.
>

For some reason, the first check of PageLRU was removed by some commit in my
source tree and I don't know why. Guess I have to double check w/ that.

>
> The deeper problem, however, is that del_page_from_lru is wrong.  We
> can not keep the page off the LRU while leaving PageLRU set, or it
> won't be very meaningful after the commit, anyway.


Yes, leaving the LRU bit on while not linked to a LRU will cause various
problems. This is what it looks like on my tree:

-       if (!PageCgroupUsed(pc))
+       if (PageLRU(page) && !PageCgroupUsed(pc)) {
+              ClearPageLRU(page);
                del_page_from_lru(zone, page);
}
        spin_unlock_irqrestore(&zone->lru_lock, flags);

 We are working on the patch to break zone->lru_lock, and without this patch
the system crashes w/ running some swaptests. Sorry I didn't post the full
patch at the beginning since not sure the second "+" related to the lru_lock
patch or not.

And in reality, we only care about properly memcg-unaccounting the old lru
> state before
> we change pc->mem_cgroup, so this becomes
>
>        if (!PageLRU(page))
>                 return;
>        spin_lock_irqsave(&zone->lru_lock, flags);
>         if (!PageCgroupUsed(pc))
>                mem_cgroup_lru_del(page);
>         spin_unlock_irqrestore(&zone->lru_lock, flags);
>


I don't see why we should care if the page stays physically linked to
> the list.


Can you clarify that?


> The PageLRU check outside the lock is still fine as the
> accounting has been done already if !PageLRU and a putback without
> PageCgroupUsed will not re-account to pc->mem_cgroup, as the comment
> above this code explains nicely.
>


The handling after committing the charge becomes this:
>
> -       if (likely(!PageLRU(page)))
> -               return;
>        spin_lock_irqsave(&zone->lru_lock, flags);
>         lru = page_lru(page);
>        if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
>                del_page_from_lru_list(zone, page, lru);
>                add_page_to_lru_list(zone, page, lru);
>        }
>
> If the page is not on the LRU, someone else will put it there and link
> it up properly.  If it is on the LRU and already memcg-accounted then
> it must be on the right lruvec as setting pc->mem_cgroup and PCG_USED
> is properly ordered.  Otherwise, it has to be physically moved to the
> correct lruvec and memcg-accounted for.
>

While working on the zone->lru_lock patch, i have been questioning myself on
the PageLRU and PageCgroupAcctLRU bit. Here is my question:

It looks to me that PageLRU indicates the page is linked to per-zone lru
list, and PageCgroupAcctLRU indicates the page is charged to a memcg and
also linked to memcg's private lru list. All of these work nicely when we
have both global and private (per-memcg) lru list, but i can not put them
together after this patch.

Now page is linked to private lru always either memcg or root. While linked
to either lru list, the page could be uncharged (like swapcache). No matter
what, i am thinking whether or not we can get rid of the AcctLRU bit from pc
and use LRU bit only here.

I haven't got chance put up the patch doing that, and at the same time i
wonder maybe i missed something ?


> The old unlocked PageLRU check in after_commit is no longer possible
> because setting PG_lru is not ordered against setting the list head,
> which means the page could be linked to the wrong lruvec while this
> CPU would not yet observe PG_lru and do the relink.  So this needs
> strong ordering.  Given that this code is hairy enough as it is, I
> just removed the preliminary check for now and do the check only under
> the lock instead of adding barriers here and to the lru linking sites.
>
> Thanks for making me write this out, few thinks put one's
> understanding of a problem to the test like this.
>
> Let's hope it helped :-)
>

Thank you for the detailed information :)

--Ying

--00163628429ec252a704aa51f55b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Aug 12, 2011 at 1:34 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Thu, Aug 11, 2011 at 01:33:05PM -0700, Ying Han wrote:=
<br>
&gt; &gt; Johannes, I wonder if we should include the following patch:<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 674823e..1513deb 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -832,7 +832,7 @@ static void<br>
&gt; mem_cgroup_lru_del_before_commit_swapcache(struct page *page)<br>
&gt; =A0 =A0 =A0 =A0 =A0* Forget old LRU when this page_cgroup is *not* use=
d. This Used bit<br>
&gt; =A0 =A0 =A0 =A0 =A0* is guarded by lock_page() because the page is Swa=
pCache.<br>
&gt; =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 if (!PageCgroupUsed(pc))<br>
&gt; + =A0 =A0 =A0 if (PageLRU(page) &amp;&amp; !PageCgroupUsed(pc))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_lru(zone, page);<br>
&gt; =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&amp;zone-&gt;lru_lock, flags);=
<br>
<br></div></blockquote><div><br></div><div>:</div><div>=A0</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;"><div class=3D"im">
</div>Yes, as the first PageLRU check is outside the lru_lock, PageLRU may<=
br>
indeed go away before grabbing the lock. =A0The page will already be<br>
unlinked and the LRU accounting will be off.<br></blockquote><div><br></div=
><div>For some reason, the first check of PageLRU was removed by some commi=
t in my source tree and I don&#39;t know why. Guess=A0I have to double chec=
k w/ that.=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
The deeper problem, however, is that del_page_from_lru is wrong. =A0We<br>
can not keep the page off the LRU while leaving PageLRU set, or it<br>
won&#39;t be very meaningful after the commit, anyway. =A0</blockquote><div=
><br></div><div>Yes, leaving the LRU bit on while not linked to a LRU will =
cause various problems. This is what it looks like on my tree:</div><div>
<br></div><div><span class=3D"Apple-style-span" style=3D"color: rgb(80, 0, =
80); font-family: arial, sans-serif; font-size: 13px; background-color: rgb=
(255, 255, 255); "><div class=3D"im" style=3D"color: rgb(80, 0, 80); "><div=
>- =A0 =A0 =A0 if (!PageCgroupUsed(pc))</div>
</div><div>+ =A0 =A0 =A0 if (PageLRU(page) &amp;&amp; !PageCgroupUsed(pc)) =
{</div><div class=3D"im" style=3D"color: rgb(80, 0, 80); "><div>+ =A0 =A0 =
=A0 =A0 =A0 =A0 =A0ClearPageLRU(page);</div><div>=A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 del_page_from_lru(zone, page);</div>
<div>}</div><div>=A0 =A0 =A0 =A0 spin_unlock_irqrestore(&amp;zone-&gt;lru_l=
ock, flags);</div><div><br></div></div></span></div><div>=A0We are working =
on the patch to break zone-&gt;lru_lock, and without this patch the system =
crashes w/ running some swaptests.=A0Sorry I didn&#39;t post the full patch=
 at the beginning since not sure the second &quot;+&quot; related to the lr=
u_lock patch or not.</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">And in reality, we=A0only ca=
re about properly memcg-unaccounting the old lru state before<br>
we change pc-&gt;mem_cgroup, so this becomes<br>
<br>
 =A0 =A0 =A0 =A0if (!PageLRU(page))<br>
<div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0spin_lock_irqsave(&amp;zone-&gt;lru_lock, flags);<br>
</div> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_lru_del(page);<br>
<div class=3D"im"> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&amp;zone-&gt;lru_=
lock, flags);<br></div></blockquote><div><br></div><div><br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex;">
<div class=3D"im">I don&#39;t see why we should care if the page stays phys=
ically linked to</div>
the list. =A0</blockquote><div><br></div><div>Can you clarify that?</div><d=
iv>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex;">The PageLRU check outside the l=
ock is still fine as the<br>

accounting has been done already if !PageLRU and a putback without<br>
PageCgroupUsed will not re-account to pc-&gt;mem_cgroup, as the comment<br>
above this code explains nicely.<br></blockquote><div><br></div><div><br></=
div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-lef=
t:1px #ccc solid;padding-left:1ex;">The handling after committing the charg=
e becomes this:<br>

<br>
- =A0 =A0 =A0 if (likely(!PageLRU(page)))<br>
<div class=3D"im">- =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
 =A0 =A0 =A0 =A0spin_lock_irqsave(&amp;zone-&gt;lru_lock, flags);<br>
</div> =A0 =A0 =A0 =A0lru =3D page_lru(page);<br>
 =A0 =A0 =A0 =A0if (PageLRU(page) &amp;&amp; !PageCgroupAcctLRU(pc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_page_from_lru_list(zone, page, lru);<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_page_to_lru_list(zone, page, lru);<br>
 =A0 =A0 =A0 =A0}<br>
<br>
If the page is not on the LRU, someone else will put it there and link<br>
it up properly. =A0If it is on the LRU and already memcg-accounted then<br>
it must be on the right lruvec as setting pc-&gt;mem_cgroup and PCG_USED<br=
>
is properly ordered. =A0Otherwise, it has to be physically moved to the<br>
correct lruvec and memcg-accounted for.<br></blockquote><div><br></div><div=
>While working on the zone-&gt;lru_lock patch, i have been questioning myse=
lf on the PageLRU and PageCgroupAcctLRU bit. Here is my question:</div>
<div><br></div><div>It looks to me that PageLRU indicates the page is linke=
d to per-zone lru list, and PageCgroupAcctLRU indicates the page is charged=
 to a memcg and also linked to memcg&#39;s private lru list. All of these w=
ork nicely when we have both global and private (per-memcg) lru list, but i=
 can not put them together after this patch.</div>
<div><br></div><div>Now page is linked to private lru always either memcg o=
r root. While linked to either lru list, the page could be uncharged (like =
swapcache). No matter what, i am thinking whether or not we can get rid of =
the AcctLRU bit from pc and use LRU bit only here.</div>
<div><br></div><div>I haven&#39;t got chance put up the patch doing that, a=
nd at the same time i wonder maybe i missed something ?</div><div>=A0</div>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">

The old unlocked PageLRU check in after_commit is no longer possible<br>
because setting PG_lru is not ordered against setting the list head,<br>
which means the page could be linked to the wrong lruvec while this<br>
CPU would not yet observe PG_lru and do the relink. =A0So this needs<br>
strong ordering. =A0Given that this code is hairy enough as it is, I<br>
just removed the preliminary check for now and do the check only under<br>
the lock instead of adding barriers here and to the lru linking sites.<br>
<br>
Thanks for making me write this out, few thinks put one&#39;s<br>
understanding of a problem to the test like this.<br>
<br>
Let&#39;s hope it helped :-)<br>
</blockquote></div><div><br></div><div>Thank you for the detailed informati=
on=A0:)</div><div><br></div><div>--Ying</div>

--00163628429ec252a704aa51f55b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
