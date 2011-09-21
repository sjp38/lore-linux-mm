Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7559000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:47:57 -0400 (EDT)
Date: Wed, 21 Sep 2011 17:47:45 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 10/11] mm: make per-memcg LRU lists exclusive
Message-ID: <20110921154745.GA25828@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-11-git-send-email-jweiner@redhat.com>
 <20110921152458.GI8501@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110921152458.GI8501@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 21, 2011 at 05:24:58PM +0200, Michal Hocko wrote:
> On Mon 12-09-11 12:57:27, Johannes Weiner wrote:
> > Now that all code that operated on global per-zone LRU lists is
> > converted to operate on per-memory cgroup LRU lists instead, there is
> > no reason to keep the double-LRU scheme around any longer.
> > 
> > The pc->lru member is removed and page->lru is linked directly to the
> > per-memory cgroup LRU lists, which removes two pointers from a
> > descriptor that exists for every page frame in the system.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks.

> > @@ -934,115 +954,123 @@ EXPORT_SYMBOL(mem_cgroup_count_vm_event);
> >   * When moving account, the page is not on LRU. It's isolated.
> >   */
> >  
> > -struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *mem,
> > -				    enum lru_list lru)
> > +/**
> > + * mem_cgroup_lru_add_list - account for adding an lru page and return lruvec
> > + * @zone: zone of the page
> > + * @page: the page
> > + * @lru: current lru
> > + *
> > + * This function accounts for @page being added to @lru, and returns
> > + * the lruvec for the given @zone and the memcg @page is charged to.
> > + *
> > + * The callsite is then responsible for physically linking the page to
> > + * the returned lruvec->lists[@lru].
> > + */
> > +struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
> > +				       enum lru_list lru)
> 
> I know that names are alway tricky but what about mem_cgroup_acct_lru_add?
> Analogously for mem_cgroup_lru_del_list, mem_cgroup_lru_del and
> mem_cgroup_lru_move_lists.

Hmm, but it doesn't just lru-account, it also looks up the right
lruvec for the caller to link the page to, so it's not necessarily an
improvement, although I agree that the name could be better.

> > @@ -3615,11 +3593,11 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >  static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> >  				int node, int zid, enum lru_list lru)
> >  {
> > -	struct zone *zone;
> >  	struct mem_cgroup_per_zone *mz;
> > -	struct page_cgroup *pc, *busy;
> >  	unsigned long flags, loop;
> >  	struct list_head *list;
> > +	struct page *busy;
> > +	struct zone *zone;
> 
> Any specific reason to move zone declaration down here? Not that it
> matters much. Just curious.

I find this arrangement more readable, I believe Ingo Molnar called it
the reverse christmas tree once :-).  Longest lines first, then sort
lines of equal length alphabetically.

And since it was basically complete, except for @zone, I just HAD to!

> > @@ -3639,16 +3618,16 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> >  			spin_unlock_irqrestore(&zone->lru_lock, flags);
> >  			break;
> >  		}
> > -		pc = list_entry(list->prev, struct page_cgroup, lru);
> > -		if (busy == pc) {
> > -			list_move(&pc->lru, list);
> > +		page = list_entry(list->prev, struct page, lru);
> > +		if (busy == page) {
> > +			list_move(&page->lru, list);
> >  			busy = NULL;
> >  			spin_unlock_irqrestore(&zone->lru_lock, flags);
> >  			continue;
> >  		}
> >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> >  
> > -		page = lookup_cgroup_page(pc);
> > +		pc = lookup_page_cgroup(page);
> 
> lookup_page_cgroup might return NULL so we probably want BUG_ON(!pc)
> here. We are not very consistent about checking the return value,
> though.

I think this is a myth and we should remove all those checks.  How can
pages circulate in userspace before they are fully onlined and their
page_cgroup buddies allocated?  In this case: how would they have been
charged in the first place and sit on a list without a list_head? :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
