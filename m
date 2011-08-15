Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 053186B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 05:39:52 -0400 (EDT)
Date: Mon, 15 Aug 2011 11:39:12 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
Message-ID: <20110815093912.GA15136@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
 <CALWz4izVoN2s6J9t1TVj+1pMmHVxfiWYvq=uqeTL4C5-YsBwOw@mail.gmail.com>
 <20110812083458.GB6916@cmpxchg.org>
 <CALWz4iwE_L5nf7_YDyr0T+racbj0_j=Lf_U7vFCA+UPtoitsRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iwE_L5nf7_YDyr0T+racbj0_j=Lf_U7vFCA+UPtoitsRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Aug 14, 2011 at 06:34:07PM -0700, Ying Han wrote:
> On Fri, Aug 12, 2011 at 1:34 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Thu, Aug 11, 2011 at 01:33:05PM -0700, Ying Han wrote:
> >> > Johannes, I wonder if we should include the following patch:
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 674823e..1513deb 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -832,7 +832,7 @@ static void
> >> mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
> >>          * Forget old LRU when this page_cgroup is *not* used. This Used bit
> >>          * is guarded by lock_page() because the page is SwapCache.
> >>          */
> >> -       if (!PageCgroupUsed(pc))
> >> +       if (PageLRU(page) && !PageCgroupUsed(pc))
> >>                 del_page_from_lru(zone, page);
> >>         spin_unlock_irqrestore(&zone->lru_lock, flags);
> >
> > Yes, as the first PageLRU check is outside the lru_lock, PageLRU may
> > indeed go away before grabbing the lock.  The page will already be
> > unlinked and the LRU accounting will be off.
> >
> > The deeper problem, however, is that del_page_from_lru is wrong.  We
> > can not keep the page off the LRU while leaving PageLRU set, or it
> > won't be very meaningful after the commit, anyway.
> 
> So do you think we should include the patch:
> -       if (!PageCgroupUsed(pc))
> +       if (PageLRU(page) && !PageCgroupUsed(pc)) {
> +              ClearPageLRU(page);
>                 del_page_from_lru(zone, page);
> }
>         spin_unlock_irqrestore(&zone->lru_lock, flags);

Nope.

> > And in reality, we > only care about properly memcg-unaccounting
> > the old lru state before > we change pc->mem_cgroup, so this
> > becomes
> >
> >        if (!PageLRU(page))
> >                return;
> >        spin_lock_irqsave(&zone->lru_lock, flags);
> >        if (!PageCgroupUsed(pc))
> >                mem_cgroup_lru_del(page);
> >        spin_unlock_irqrestore(&zone->lru_lock, flags);
> >
> > I don't see why we should care if the page stays physically linked to
> > the list.  The PageLRU check outside the lock is still fine as the
> > accounting has been done already if !PageLRU and a putback without
> > PageCgroupUsed will not re-account to pc->mem_cgroup, as the comment
> > above this code explains nicely.
> 
> Here is the comment above the code:
> >-------/*
> >------- * Doing this check without taking ->lru_lock seems wrong but this
> >------- * is safe. Because if page_cgroup's USED bit is unset, the page
> >------- * will not be added to any memcg's LRU. If page_cgroup's USED bit is
> >------- * set, the commit after this will fail, anyway.
> >------- * This all charge/uncharge is done under some mutual execustion.
> >------- * So, we don't need to taking care of changes in USED bit.
> >------- */
> 
> It says that page will not be added to any memcg's LRU if
> !PageCgroupUsed, which seems not true after this patch series. page
> will be added to either root or memcg's lru depending on the used bit.

The phrasing is only partially wrong.  The page will be added to the
root cgroup if unused.  But it's not accounted now, and won't be
accounted when it's linked.

The before-commit function is purely about accounting.

> > The handling after committing the charge becomes this:
> >
> > -       if (likely(!PageLRU(page)))
> > -               return;
> >        spin_lock_irqsave(&zone->lru_lock, flags);
> >        lru = page_lru(page);
> >        if (PageLRU(page) && !PageCgroupAcctLRU(pc)) {
> >                del_page_from_lru_list(zone, page, lru);
> >                add_page_to_lru_list(zone, page, lru);
> >        }
> 
> Is the function mem_cgroup_lru_add_after_commit() ? I don't understand
> why we have del_page_from_lru_list() here?Here is how the function
> looks like on my local tree:
> 
> static void mem_cgroup_lru_add_after_commit(struct page *page)
> {
> >-------unsigned long flags;
> >-------struct zone *zone = page_zone(page);
> >-------struct page_cgroup *pc = lookup_page_cgroup(page);
> 
> >-------/* taking care of that the page is added to LRU while we commit it */
> >-------if (likely(!PageLRU(page)))
> >------->-------return;
> >-------spin_lock_irqsave(&zone->lru_lock, flags);
> >-------/* link when the page is linked to LRU but page_cgroup isn't */
> >-------if (PageLRU(page) && !PageCgroupAcctLRU(pc))
> >------->-------mem_cgroup_add_lru_list(page, page_lru(page));
> >-------spin_unlock_irqrestore(&zone->lru_lock, flags);
> }
> 
>  I agree to move the PageLRU inside the lru_lock though.

Currently, mem_cgroup_add_lru_list() does both accounting and linking.
Later, mem_cgroup_lru_add_list() will only do memcg-accounting, never
LRU list linking.  But it returns the lruvec the page has to sit on.

The reason why we need to do del_page_from_lru_list() after my series
is because the page may sit on the wrong lruvec and needs to be
relinked.  So del, and readd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
