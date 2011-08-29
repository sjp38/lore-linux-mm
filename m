Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8E290900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 17:05:45 -0400 (EDT)
Date: Mon, 29 Aug 2011 23:05:09 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110829210508.GA1599@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
 <20110811210914.GB31229@cmpxchg.org>
 <CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
 <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
 <20110829190426.GC1434@cmpxchg.org>
 <CALWz4ix1X8=L0HzQpdGd=XVbjZuMCtYngzdG+hLMoeJJCUEjrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4ix1X8=L0HzQpdGd=XVbjZuMCtYngzdG+hLMoeJJCUEjrg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 01:36:48PM -0700, Ying Han wrote:
> On Mon, Aug 29, 2011 at 12:04 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:
> > On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
> > > > @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *page,
> > > > enum lru_list lru)
> > > >  {
> > > >  >------struct page_cgroup *pc;
> > > >  >------struct mem_cgroup_per_zone *mz;
> > > > +>------struct mem_cgroup *mem;
> > > > .
> > > >  >------if (mem_cgroup_disabled())
> > > >  >------>-------return;
> > > >  >------pc = lookup_page_cgroup(page);
> > > > ->------/* can happen while we handle swapcache. */
> > > > ->------if (!TestClearPageCgroupAcctLRU(pc))
> > > > ->------>-------return;
> > > > ->------VM_BUG_ON(!pc->mem_cgroup);
> > > > ->------/*
> > > > ->------ * We don't check PCG_USED bit. It's cleared when the "page" is
> > finally
> > > > ->------ * removed from global LRU.
> > > > ->------ */
> > > > ->------mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> > > > +
> > > > +>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {
> >
> > This PageCgroupUsed part confuses me.  A page that is being isolated
> > shortly after being charged while on the LRU may reach here, and then
> > it is unaccounted from pc->mem_cgroup, which it never was accounted
> > to.
> >
> > Could you explain why you added it?
> 
> To be honest, i don't have very good reason for that. The PageCgroupUsed
> check is put there after running some tests and some fixes seems help the
> test, including this one.
> 
> The one case I can think of for page !AcctLRU | Used is in the pagevec.
> However, we shouldn't get to the mem_cgroup_del_lru_list() for a page in
> pagevec at the first place.
> 
> I now made it so that PageCgroupAcctLRU on the LRU means accounted
> to pc->mem_cgroup,
> 
> this is the same logic currently.
> 
> > and !PageCgroupAcctLRU on the LRU means accounted to
> > and babysitted by root_mem_cgroup.
> 
> this seems to be different from what it is now, especially for swapcache
> page. So, the page here is linked to root cgroup LRU or not?
> 
> Anyway, the AcctLRU flags still seems confusing to me:
> 
> what this flag tells me is that whether or not the page is on a PRIVATE lru
> and being accounted, i used private here to differentiate from the per zone
> lru, where it also has PageLRU flag.  The two flags are separate since pages
> could be on one lru not the other ( I guess ) , but this is changed after
> having the root cgroup lru back. For example, AcctLRU is used to keep track
> of the accounted lru pages, especially for root ( we didn't account the
> !Used pages to root like readahead swapcache). Now we account the full size
> of lru list of root including Used and !Used, but only mark the Used pages
> w/ AcctLRU flag.
> 
> So in general, i am wondering we should be able to replace that eventually
> with existing Used and LRU bit.  Sorry this seems to be something we like to
> consider later, not necessarily now :)

I have now the following comment in mem_cgroup_lru_del_list():

        /*
         * root_mem_cgroup babysits uncharged LRU pages, but
         * PageCgroupUsed is cleared when the page is about to get
         * freed.  PageCgroupAcctLRU remembers whether the
         * LRU-accounting happened against pc->mem_cgroup or
         * root_mem_cgroup.
         */

Does that answer your question?  If not, please tell me, so I can fix
the comment :-)

> > Always.  Which also means that before_commit now ensures an LRU
> > page is moved to root_mem_cgroup for babysitting during the
> > charge, so that concurrent isolations/putbacks are always
> > accounted correctly.  Is this what you had in mind?  Did I miss
> > something?
> 
> In my tree, the before->commit->after protocol is folded into one function.
> I didn't post it since I know you also have patch doing that.  So guess I
> don't understand why we need to move the page to root while it is gonna be
> charged to a memcg by commit_charge shortly after.

It is a consequence of your fix that LRU-accounts unused pages to
root_mem_cgroup upon lru-add, and thus deaccounts !PageCgroupAcctLRU
from root_mem_cgroup unconditionally upon lru-del.

Consider the following scenario:

	1. page with multiple mappings swapped out.

	2. one memcg faults the page, then unmaps it.  The page is
	uncharged, but swap-freeing fails due to the other ptes, and
	the page stays lru-accounted on the memcg it's no longer
	charged to.

	3. another memcg faults the page.  before_commit must
	lru-unaccount from pc->mem_cgroup before pc->mem_cgroup is
	overwritten.

	4. the page is charged.  after_commit does the fixup.

Between 3. and 4., a reclaimer can isolate the page.  The old
lru-accounting is undone and mem_cgroup_lru_del() does this:

        if (TestClearPageCgroupAcctLRU(pc)) {
                VM_BUG_ON(!pc->mem_cgroup);
                mem = pc->mem_cgroup;
        } else
                mem = root_mem_cgroup;
       mz = page_cgroup_zoneinfo(mem, page);
        /* huge page split is done under lru_lock. so, we have no races. */
        MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);

The rule is that !PageCgroupAcctLRU means that the page is
lru-accounted to root_mem_cgroup.  So when charging, the page has to
be moved to root_mem_cgroup until a new memcg is responsible for it.

> My understanding is that in before_commit, we uncharge the page from
> previous memcg lru if AcctLRU was set, then in the commit_charge we update
> the new owner of it. And in after_commit we update the memcg lru for the new
> owner after linking the page in the lru.

Exactly, just that between unaccounting from the old and accounting to
the new, someone else may look at the page and has to find it in a
sensible state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
