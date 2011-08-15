Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 087286B00EE
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 23:01:43 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p7F31fBZ001631
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 20:01:41 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by wpaz5.hot.corp.google.com with ESMTP id p7F31QmT002406
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 20:01:40 -0700
Received: by qyk35 with SMTP id 35so2886482qyk.3
        for <linux-mm@kvack.org>; Sun, 14 Aug 2011 20:01:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812191718.GE29086@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
	<CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
	<20110812083458.GB6916@cmpxchg.org>
	<CALWz4iz=30A7hUkEmo5_K3q1KiM8tBWvh_ghhbEFm0ZksfzQ=g@mail.gmail.com>
	<20110812191718.GE29086@cmpxchg.org>
Date: Sun, 14 Aug 2011 20:01:36 -0700
Message-ID: <CALWz4iz=dE9BGme7+-Fwdz2-gt2GfymzYcXrg0ZcSD7PAbARfg@mail.gmail.com>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 12, 2011 at 12:17 PM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> On Fri, Aug 12, 2011 at 10:08:18AM -0700, Ying Han wrote:
>> On Fri, Aug 12, 2011 at 1:34 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > And in reality, we only care about properly memcg-unaccounting the
>> > old lru state before we change pc->mem_cgroup, so this becomes
>> >
>> > =A0 =A0 =A0 =A0if (!PageLRU(page))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> > =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lru_lock, flags);
>> > =A0 =A0 =A0 =A0 if (!PageCgroupUsed(pc))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_lru_del(page);
>> > =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&zone->lru_lock, flags);
>> >
>> > I don't see why we should care if the page stays physically linked
>> > to the list.
>>
>> Can you clarify that?
>
> Well, I don't see anything wrong with leaving it on the LRU. =A0We just
> need to unaccount the page from pc->mem_cgroup's lru stats before the
> page is charged, pc->mem_cgroup overwritten, and the account lost.
>
>> > The handling after committing the charge becomes this:
>> >
>> > - =A0 =A0 =A0 if (likely(!PageLRU(page)))
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> > =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lru_lock, flags);
>> > =A0 =A0 =A0 =A0 lru =3D page_lru(page);
>> > =A0 =A0 =A0 =A0if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_page_from_lru_list(zone, page, lru)=
;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_page_to_lru_list(zone, page, lru);
>> > =A0 =A0 =A0 =A0}
>> >
>> > If the page is not on the LRU, someone else will put it there and link
>> > it up properly. =A0If it is on the LRU and already memcg-accounted the=
n
>> > it must be on the right lruvec as setting pc->mem_cgroup and PCG_USED
>> > is properly ordered. =A0Otherwise, it has to be physically moved to th=
e
>> > correct lruvec and memcg-accounted for.
>>
>> While working on the zone->lru_lock patch, i have been questioning mysel=
f on
>> the PageLRU and PageCgroupAcctLRU bit. Here is my question:
>>
>> It looks to me that PageLRU indicates the page is linked to per-zone lru
>> list, and PageCgroupAcctLRU indicates the page is charged to a memcg and
>> also linked to memcg's private lru list. All of these work nicely when w=
e
>> have both global and private (per-memcg) lru list, but i can not put the=
m
>> together after this patch.
>>
>> Now page is linked to private lru always either memcg or root. While lin=
ked
>> to either lru list, the page could be uncharged (like swapcache). No mat=
ter
>> what, i am thinking whether or not we can get rid of the AcctLRU bit fro=
m pc
>> and use LRU bit only here.
>
> As I said above: if after the commit the page is on the LRU (PageLRU
> set), pc->mem_cgroup's lru stats may or may not include the page, and
> the page may or may not be on the right lruvec.
>
> If someone had the page isolated (reclaim?) while we charge it and put
> it back, the page may either be charged or uncharged at the time of
> putback.

Thank you and this is a good example.

So PageLRU bit is consistent w/ whether or not the page is linked  to
a lru list (root or memcg), and AcctLRU indicates more on the memcg
charge/uncharge.

Here I am trying to summarize the possibilities of different flags of
a page linked to a lru list ( based on the implementation after this
patch series). please help to correct :

root lru:
1. PageLRU, Used, AcctLRU: page charged to root and linked to root lru
list. ( ext: page allocated under root cgroup )

2. PageLRU, !Used, !AcctLRU: page not charged and linked to root lru
list. ( ext: page uncharged before free, or like readahead swapcache)

3. PageLRU, Used, !AcctLRU: page del from root lru before uncharge, or
charged before add to root lru

4. PageLRU, !Used, AcctLRU: page uncharged before del from root lru
(ext: swapcache)

non-root lru:

1. PageLRU, Used, AcctLRU: page charged to memcg and linked to memcg lru li=
st

2. PageLRU, !Used, !AcctLRU: not sure if this is possible

3. PageLRU, Used, !AcctLRU: page del from memcg lru before uncharge,
or charged before add to memcg lru

4. PageLRU, !Used, AcctLRU: page uncharged before del from memcg lru
(ext: swapcache)


>
> =A0 =A0 =A0 =A0unused: PageLRU is set, but page possibly on the wrong lru=
vec
> =A0 =A0 =A0 =A0(root_mem_cgroup's per default, see mem_cgroup_lru_add_lis=
t)
> =A0 =A0 =A0 =A0and not properly accounted for. =A0We can detect this case=
 by
> =A0 =A0 =A0 =A0seeing AcctLRU cleared.

This fits the case 2 above.

>
> =A0 =A0 =A0 =A0used: PageLRU is set, page on the right lruvec and properl=
y
> =A0 =A0 =A0 =A0accounted. =A0We can detect this case by seeing that
> =A0 =A0 =A0 =A0mem_cgroup_lru_add_list() set AcctLRU.

This fits the case 1 above.


Thanks

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
