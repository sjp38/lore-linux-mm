Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8776B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 04:35:25 -0400 (EDT)
Date: Fri, 12 Aug 2011 10:34:58 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
Message-ID: <20110812083458.GB6916@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
 <CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 11, 2011 at 01:33:05PM -0700, Ying Han wrote:
> > Johannes, I wonder if we should include the following patch:
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 674823e..1513deb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -832,7 +832,7 @@ static void
> mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
>          * Forget old LRU when this page_cgroup is *not* used. This Used bit
>          * is guarded by lock_page() because the page is SwapCache.
>          */
> -       if (!PageCgroupUsed(pc))
> +       if (PageLRU(page) && !PageCgroupUsed(pc))
>                 del_page_from_lru(zone, page);
>         spin_unlock_irqrestore(&zone->lru_lock, flags);

Yes, as the first PageLRU check is outside the lru_lock, PageLRU may
indeed go away before grabbing the lock.  The page will already be
unlinked and the LRU accounting will be off.

The deeper problem, however, is that del_page_from_lru is wrong.  We
can not keep the page off the LRU while leaving PageLRU set, or it
won't be very meaningful after the commit, anyway.  And in reality, we
only care about properly memcg-unaccounting the old lru state before
we change pc->mem_cgroup, so this becomes

	if (!PageLRU(page))
		return;
	spin_lock_irqsave(&zone->lru_lock, flags);
	if (!PageCgroupUsed(pc))
		mem_cgroup_lru_del(page);
	spin_unlock_irqrestore(&zone->lru_lock, flags);

I don't see why we should care if the page stays physically linked to
the list.  The PageLRU check outside the lock is still fine as the
accounting has been done already if !PageLRU and a putback without
PageCgroupUsed will not re-account to pc->mem_cgroup, as the comment
above this code explains nicely.

The handling after committing the charge becomes this:

-	if (likely(!PageLRU(page)))
-		return;
	spin_lock_irqsave(&zone->lru_lock, flags);
	lru = page_lru(page);
	if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
		del_page_from_lru_list(zone, page, lru);
		add_page_to_lru_list(zone, page, lru);
	}

If the page is not on the LRU, someone else will put it there and link
it up properly.  If it is on the LRU and already memcg-accounted then
it must be on the right lruvec as setting pc->mem_cgroup and PCG_USED
is properly ordered.  Otherwise, it has to be physically moved to the
correct lruvec and memcg-accounted for.

The old unlocked PageLRU check in after_commit is no longer possible
because setting PG_lru is not ordered against setting the list head,
which means the page could be linked to the wrong lruvec while this
CPU would not yet observe PG_lru and do the relink.  So this needs
strong ordering.  Given that this code is hairy enough as it is, I
just removed the preliminary check for now and do the check only under
the lock instead of adding barriers here and to the lru linking sites.

Thanks for making me write this out, few thinks put one's
understanding of a problem to the test like this.

Let's hope it helped :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
