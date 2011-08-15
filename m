Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 47ECB6B00EE
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 21:34:23 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p7F1YE0j027625
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 18:34:14 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by hpaq2.eem.corp.google.com with ESMTP id p7F1Y8iM004630
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 14 Aug 2011 18:34:12 -0700
Received: by qwh5 with SMTP id 5so2442530qwh.6
        for <linux-mm@kvack.org>; Sun, 14 Aug 2011 18:34:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812083458.GB6916@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
	<CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
	<20110812083458.GB6916@cmpxchg.org>
Date: Sun, 14 Aug 2011 18:34:07 -0700
Message-ID: <CALWz4iwE_L5nf7_YDyr0T+racbj0_j=Lf_U7vFCA+UPtoitsRA@mail.gmail.com>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 12, 2011 at 1:34 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Thu, Aug 11, 2011 at 01:33:05PM -0700, Ying Han wrote:
>> > Johannes, I wonder if we should include the following patch:
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 674823e..1513deb 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -832,7 +832,7 @@ static void
>> mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
>> =A0 =A0 =A0 =A0 =A0* Forget old LRU when this page_cgroup is *not* used.=
 This Used bit
>> =A0 =A0 =A0 =A0 =A0* is guarded by lock_page() because the page is SwapC=
ache.
>> =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 if (!PageCgroupUsed(pc))
>> + =A0 =A0 =A0 if (PageLRU(page) && !PageCgroupUsed(pc))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_lru(zone, page);
>> =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&zone->lru_lock, flags);
>
> Yes, as the first PageLRU check is outside the lru_lock, PageLRU may
> indeed go away before grabbing the lock. =A0The page will already be
> unlinked and the LRU accounting will be off.
>
> The deeper problem, however, is that del_page_from_lru is wrong. =A0We
> can not keep the page off the LRU while leaving PageLRU set, or it
> won't be very meaningful after the commit, anyway.

So do you think we should include the patch:
-       if (!PageCgroupUsed(pc))
+       if (PageLRU(page) && !PageCgroupUsed(pc)) {
+              ClearPageLRU(page);
                del_page_from_lru(zone, page);
}
        spin_unlock_irqrestore(&zone->lru_lock, flags);


And in reality, we
> only care about properly memcg-unaccounting the old lru state before
> we change pc->mem_cgroup, so this becomes
>
> =A0 =A0 =A0 =A0if (!PageLRU(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lru_lock, flags);
> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_lru_del(page);
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, flags);
>
> I don't see why we should care if the page stays physically linked to
> the list. =A0The PageLRU check outside the lock is still fine as the
> accounting has been done already if !PageLRU and a putback without
> PageCgroupUsed will not re-account to pc->mem_cgroup, as the comment
> above this code explains nicely.

Here is the comment above the code:
>-------/*
>------- * Doing this check without taking ->lru_lock seems wrong but this
>------- * is safe. Because if page_cgroup's USED bit is unset, the page
>------- * will not be added to any memcg's LRU. If page_cgroup's USED bit =
is
>------- * set, the commit after this will fail, anyway.
>------- * This all charge/uncharge is done under some mutual execustion.
>------- * So, we don't need to taking care of changes in USED bit.
>------- */

It says that page will not be added to any memcg's LRU if
!PageCgroupUsed, which seems not true after this patch series. page
will be added to either root or memcg's lru depending on the used bit.

>
> The handling after committing the charge becomes this:
>
> - =A0 =A0 =A0 if (likely(!PageLRU(page)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lru_lock, flags);
> =A0 =A0 =A0 =A0lru =3D page_lru(page);
> =A0 =A0 =A0 =A0if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_page_from_lru_list(zone, page, lru);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_page_to_lru_list(zone, page, lru);
> =A0 =A0 =A0 =A0}

Is the function mem_cgroup_lru_add_after_commit() ? I don't understand
why we have del_page_from_lru_list() here?Here is how the function
looks like on my local tree:

static void mem_cgroup_lru_add_after_commit(struct page *page)
{
>-------unsigned long flags;
>-------struct zone *zone =3D page_zone(page);
>-------struct page_cgroup *pc =3D lookup_page_cgroup(page);

>-------/* taking care of that the page is added to LRU while we commit it =
*/
>-------if (likely(!PageLRU(page)))
>------->-------return;
>-------spin_lock_irqsave(&zone->lru_lock, flags);
>-------/* link when the page is linked to LRU but page_cgroup isn't */
>-------if (PageLRU(page) && !PageCgroupAcctLRU(pc))
>------->-------mem_cgroup_add_lru_list(page, page_lru(page));
>-------spin_unlock_irqrestore(&zone->lru_lock, flags);
}

 I agree to move the PageLRU inside the lru_lock though.

--Ying

>
> If the page is not on the LRU, someone else will put it there and link
> it up properly. =A0If it is on the LRU and already memcg-accounted then
> it must be on the right lruvec as setting pc->mem_cgroup and PCG_USED
> is properly ordered. =A0Otherwise, it has to be physically moved to the
> correct lruvec and memcg-accounted for.


>
> The old unlocked PageLRU check in after_commit is no longer possible
> because setting PG_lru is not ordered against setting the list head,
> which means the page could be linked to the wrong lruvec while this
> CPU would not yet observe PG_lru and do the relink. =A0So this needs
> strong ordering. =A0Given that this code is hairy enough as it is, I
> just removed the preliminary check for now and do the check only under
> the lock instead of adding barriers here and to the lru linking sites.
>
> Thanks for making me write this out, few thinks put one's
> understanding of a problem to the test like this.
>
> Let's hope it helped :-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
