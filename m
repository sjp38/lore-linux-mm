Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2A356900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:16:07 -0400 (EDT)
Date: Tue, 30 Aug 2011 17:14:49 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110830151449.GA28136@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
 <20110811210914.GB31229@cmpxchg.org>
 <CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
 <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
 <20110829190426.GC1434@cmpxchg.org>
 <CALWz4ix1X8=L0HzQpdGd=XVbjZuMCtYngzdG+hLMoeJJCUEjrg@mail.gmail.com>
 <20110829210508.GA1599@cmpxchg.org>
 <CALWz4ixH-7c-fEUAHiyf83KyO9SsRzdUm-u+wm2_Ty=xvU_NyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4ixH-7c-fEUAHiyf83KyO9SsRzdUm-u+wm2_Ty=xvU_NyA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Tue, Aug 30, 2011 at 12:07:07AM -0700, Ying Han wrote:
> On Mon, Aug 29, 2011 at 2:05 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Mon, Aug 29, 2011 at 01:36:48PM -0700, Ying Han wrote:
> >> On Mon, Aug 29, 2011 at 12:04 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:
> >> > On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
> >> > > > @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *page,
> >> > > > enum lru_list lru)
> >> > > >  {
> >> > > >  >------struct page_cgroup *pc;
> >> > > >  >------struct mem_cgroup_per_zone *mz;
> >> > > > +>------struct mem_cgroup *mem;
> >> > > > .
> >> > > >  >------if (mem_cgroup_disabled())
> >> > > >  >------>-------return;
> >> > > >  >------pc = lookup_page_cgroup(page);
> >> > > > ->------/* can happen while we handle swapcache. */
> >> > > > ->------if (!TestClearPageCgroupAcctLRU(pc))
> >> > > > ->------>-------return;
> >> > > > ->------VM_BUG_ON(!pc->mem_cgroup);
> >> > > > ->------/*
> >> > > > ->------ * We don't check PCG_USED bit. It's cleared when the "page" is
> >> > finally
> >> > > > ->------ * removed from global LRU.
> >> > > > ->------ */
> >> > > > ->------mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> >> > > > +
> >> > > > +>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {
> >> >
> >> > This PageCgroupUsed part confuses me.  A page that is being isolated
> >> > shortly after being charged while on the LRU may reach here, and then
> >> > it is unaccounted from pc->mem_cgroup, which it never was accounted
> >> > to.
> >> >
> >> > Could you explain why you added it?
> >>
> >> To be honest, i don't have very good reason for that. The PageCgroupUsed
> >> check is put there after running some tests and some fixes seems help the
> >> test, including this one.
> >>
> >> The one case I can think of for page !AcctLRU | Used is in the pagevec.
> >> However, we shouldn't get to the mem_cgroup_del_lru_list() for a page in
> >> pagevec at the first place.
> >>
> >> I now made it so that PageCgroupAcctLRU on the LRU means accounted
> >> to pc->mem_cgroup,
> >>
> >> this is the same logic currently.
> >>
> >> > and !PageCgroupAcctLRU on the LRU means accounted to
> >> > and babysitted by root_mem_cgroup.
> >>
> >> this seems to be different from what it is now, especially for swapcache
> >> page. So, the page here is linked to root cgroup LRU or not?
> >>
> >> Anyway, the AcctLRU flags still seems confusing to me:
> >>
> >> what this flag tells me is that whether or not the page is on a PRIVATE lru
> >> and being accounted, i used private here to differentiate from the per zone
> >> lru, where it also has PageLRU flag.  The two flags are separate since pages
> >> could be on one lru not the other ( I guess ) , but this is changed after
> >> having the root cgroup lru back. For example, AcctLRU is used to keep track
> >> of the accounted lru pages, especially for root ( we didn't account the
> >> !Used pages to root like readahead swapcache). Now we account the full size
> >> of lru list of root including Used and !Used, but only mark the Used pages
> >> w/ AcctLRU flag.
> >>
> >> So in general, i am wondering we should be able to replace that eventually
> >> with existing Used and LRU bit.  Sorry this seems to be something we like to
> >> consider later, not necessarily now :)
> >
> > I have now the following comment in mem_cgroup_lru_del_list():
> >
> >        /*
> >         * root_mem_cgroup babysits uncharged LRU pages, but
> >         * PageCgroupUsed is cleared when the page is about to get
> >         * freed.  PageCgroupAcctLRU remembers whether the
> >         * LRU-accounting happened against pc->mem_cgroup or
> >         * root_mem_cgroup.
> >         */
> >
> > Does that answer your question?  If not, please tell me, so I can fix
> > the comment :-)
> 
> Sorry, not clear to me yet :(
> 
> Is this saying that we can not differentiate the page linked to root
> but not charged vs
> page linked to memcg which is about to be freed.
> 
> If that is the case, isn't the page being removed from lru first
> before doing uncharge (ClearPageCgroupUsed) ?

It depends.  From the reclaim path, yes.  But it may be freed through
__page_cache_release() for example, which unlinks after uncharge.

So when we reach mem_cgroup_lru_del(), PageCgroupUsed could be cleared
with the page being lru-accounted to root_mem_cgroup (swap readahead,
swapoff) or cleared with the page being lru-accounted to a different
memcg (truncate/invalidate, unmap)

> >> > Always.  Which also means that before_commit now ensures an LRU
> >> > page is moved to root_mem_cgroup for babysitting during the
> >> > charge, so that concurrent isolations/putbacks are always
> >> > accounted correctly.  Is this what you had in mind?  Did I miss
> >> > something?
> >>
> >> In my tree, the before->commit->after protocol is folded into one function.
> >> I didn't post it since I know you also have patch doing that.  So guess I
> >> don't understand why we need to move the page to root while it is gonna be
> >> charged to a memcg by commit_charge shortly after.
> >
> > It is a consequence of your fix that LRU-accounts unused pages to
> > root_mem_cgroup upon lru-add, and thus deaccounts !PageCgroupAcctLRU
> > from root_mem_cgroup unconditionally upon lru-del.
> >
> > Consider the following scenario:
> >
> >        1. page with multiple mappings swapped out.
> >
> >        2. one memcg faults the page, then unmaps it.  The page is
> >        uncharged, but swap-freeing fails due to the other ptes, and
> >        the page stays lru-accounted on the memcg it's no longer
> >        charged to.
> 
> I agree that a page could be ending up on a memcg-lru (AcctLRU) but
> not charged (!Used). But not sure
> if the case above is true or not, since we don't uncharge a page which
> marked as SwapCache until the
> page is removed from the swapcache.

Blergh, you are right.  I missed the PageSwapCache() check in
__mem_cgroup_uncharge_common().  That looks pretty misplaced up there,
btw, I see whether it can be moved.

> One case which we might change the owner of a page while it is linked
> on lru is calling reuse_swap_page() under write fault, so the page is
> uncharged after removing from
> swapcache while linked in the old memcg lru. It will be adjust by
> commit_charge_swapin() later.

Yes, this scenario has this window where PageCgroupAcctLRU is cleared
in before_commit and reclaim could race and isolate the page,
unaccounting it from root_mem_cgroup which it was never charged to.

> >        3. another memcg faults the page.  before_commit must
> >        lru-unaccount from pc->mem_cgroup before pc->mem_cgroup is
> >        overwritten.
> >
> >        4. the page is charged.  after_commit does the fixup.
> >
> > Between 3. and 4., a reclaimer can isolate the page.  The old
> > lru-accounting is undone and mem_cgroup_lru_del() does this:
> >
> >        if (TestClearPageCgroupAcctLRU(pc)) {
> >                VM_BUG_ON(!pc->mem_cgroup);
> >                mem = pc->mem_cgroup;
> >        } else
> >                mem = root_mem_cgroup;
> >       mz = page_cgroup_zoneinfo(mem, page);
> >        /* huge page split is done under lru_lock. so, we have no races. */
> >        MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> >
> > The rule is that !PageCgroupAcctLRU means that the page is
> > lru-accounted to root_mem_cgroup.  So when charging, the page has to
> > be moved to root_mem_cgroup until a new memcg is responsible for it.
> 
> So here we are saying that isolating a page which has be
> mem_cgroup_lru_del().  Isn't the later one does lru-unaccount and also
> list_del(), so is that possible to isolate a page not on lru. Or is
> this caused by not clearing the LRU bit in before_commit?

mem_cgroup_lru_del() does not do list_del() anymore.  It's just about
accounting and, in the add case, returning the proper lruvec.

Calling it on a page not on the LRU is a bug.

> >> My understanding is that in before_commit, we uncharge the page from
> >> previous memcg lru if AcctLRU was set, then in the commit_charge we update
> >> the new owner of it. And in after_commit we update the memcg lru for the new
> >> owner after linking the page in the lru.
> >
> > Exactly, just that between unaccounting from the old and accounting to
> > the new, someone else may look at the page and has to find it in a
> > sensible state.
> 
> Wonder if clearing the PageLRU after before_commit is helpful here.

How would after_commit detect whether the page needs relinking or not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
