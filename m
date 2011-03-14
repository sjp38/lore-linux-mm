Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A90EB8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:00:01 -0400 (EDT)
Date: Mon, 14 Mar 2011 13:59:43 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page writeback
Message-ID: <20110314175943.GF31120@redhat.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com>
 <20110314175408.GE31120@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314175408.GE31120@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>

On Mon, Mar 14, 2011 at 01:54:08PM -0400, Vivek Goyal wrote:
> On Fri, Mar 11, 2011 at 10:43:30AM -0800, Greg Thelen wrote:
> > If the current process is in a non-root memcg, then
> > balance_dirty_pages() will consider the memcg dirty limits as well as
> > the system-wide limits.  This allows different cgroups to have distinct
> > dirty limits which trigger direct and background writeback at different
> > levels.
> > 
> > If called with a mem_cgroup, then throttle_vm_writeout() queries the
> > given cgroup for its dirty memory usage limits.
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> > Changelog since v5:
> > - Simplified this change by using mem_cgroup_balance_dirty_pages() rather than
> >   cramming the somewhat different logic into balance_dirty_pages().  This means
> >   the global (non-memcg) dirty limits are not passed around in the
> >   struct dirty_info, so there's less change to existing code.
> 
> Yes there is less change to existing code but now we also have a separate
> throttlig logic for cgroups. 
> 
> I thought that we are moving in the direction of IO less throttling
> where bdi threads always do the IO and Jan Kara also implemented the
> logic to distribute the finished IO pages uniformly across the waiting
> threads.
> 
> Keeping it separate for cgroups, reduces the complexity but also forks
> off the balancing logic for root and other cgroups. So if Jan Kara's
> changes go in, it automatically does not get used for memory cgroups.
> 
> Not sure how good a idea it is to use a separate throttling logic for
> for non-root cgroups. 

One more disadvantage seems to be that new logic does not take into
account the dirty ratio of each task. So a fast writer in a non-root
cgroup might consume most of the quota of that cgroup and starve
the other task in same cgroup.

So keeping a separate logic for cgroup throttling does simplify the
logic and achieves immediate goal of limiting the memory usage of
a cgroup but I suspect down the line root cgroup and non-root cgroup
logic will keep on drifting far apart.

Thanks
Vivek

> 
> Thanks
> Vivek 
> 
> > 
> > Changelog since v4:
> > - Added missing 'struct mem_cgroup' forward declaration in writeback.h.
> > - Made throttle_vm_writeout() memcg aware.
> > - Removed previously added dirty_writeback_pages() which is no longer needed.
> > - Added logic to balance_dirty_pages() to throttle if over foreground memcg
> >   limit.
> > 
> > Changelog since v3:
> > - Leave determine_dirtyable_memory() static.  v3 made is non-static.
> > - balance_dirty_pages() now considers both system and memcg dirty limits and
> >   usage data.  This data is retrieved with global_dirty_info() and
> >   memcg_dirty_info().  
> > 
> >  include/linux/writeback.h |    3 ++-
> >  mm/page-writeback.c       |   34 ++++++++++++++++++++++++++++------
> >  mm/vmscan.c               |    2 +-
> >  3 files changed, 31 insertions(+), 8 deletions(-)
> > 
> > diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> > index 0ead399..a45d895 100644
> > --- a/include/linux/writeback.h
> > +++ b/include/linux/writeback.h
> > @@ -8,6 +8,7 @@
> >  #include <linux/fs.h>
> >  
> >  struct backing_dev_info;
> > +struct mem_cgroup;
> >  
> >  extern spinlock_t inode_lock;
> >  
> > @@ -92,7 +93,7 @@ void laptop_mode_timer_fn(unsigned long data);
> >  #else
> >  static inline void laptop_sync_completion(void) { }
> >  #endif
> > -void throttle_vm_writeout(gfp_t gfp_mask);
> > +void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup);
> >  
> >  /* These are exported to sysctl. */
> >  extern int dirty_background_ratio;
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index d8005b0..f6a8dd6 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -473,7 +473,8 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
> >   * data.  It looks at the number of dirty pages in the machine and will force
> >   * the caller to perform writeback if the system is over `vm_dirty_ratio'.
> >   * If we're over `background_thresh' then the writeback threads are woken to
> > - * perform some writeout.
> > + * perform some writeout.  The current task may have per-memcg dirty
> > + * limits, which are also checked.
> >   */
> >  static void balance_dirty_pages(struct address_space *mapping,
> >  				unsigned long write_chunk)
> > @@ -488,6 +489,8 @@ static void balance_dirty_pages(struct address_space *mapping,
> >  	bool dirty_exceeded = false;
> >  	struct backing_dev_info *bdi = mapping->backing_dev_info;
> >  
> > +	mem_cgroup_balance_dirty_pages(mapping, write_chunk);
> > +
>  
> >  	for (;;) {
> >  		struct writeback_control wbc = {
> >  			.sync_mode	= WB_SYNC_NONE,
> > @@ -651,23 +654,42 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
> >  }
> >  EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
> >  
> > -void throttle_vm_writeout(gfp_t gfp_mask)
> > +/*
> > + * Throttle the current task if it is near dirty memory usage limits.  Both
> > + * global dirty memory limits and (if @mem_cgroup is given) per-cgroup dirty
> > + * memory limits are checked.
> > + *
> > + * If near limits, then wait for usage to drop.  Dirty usage should drop because
> > + * dirty producers should have used balance_dirty_pages(), which would have
> > + * scheduled writeback.
> > + */
> > +void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup)
> >  {
> >  	unsigned long background_thresh;
> >  	unsigned long dirty_thresh;
> > +	struct dirty_info memcg_info;
> > +	bool do_memcg;
> >  
> >          for ( ; ; ) {
> >  		global_dirty_limits(&background_thresh, &dirty_thresh);
> > +		do_memcg = mem_cgroup && mem_cgroup_hierarchical_dirty_info(
> > +			determine_dirtyable_memory(), true, mem_cgroup,
> > +			&memcg_info);
> >  
> >                  /*
> >                   * Boost the allowable dirty threshold a bit for page
> >                   * allocators so they don't get DoS'ed by heavy writers
> >                   */
> >                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> > -
> > -                if (global_page_state(NR_UNSTABLE_NFS) +
> > -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> > -                        	break;
> > +		if (do_memcg)
> > +			memcg_info.dirty_thresh += memcg_info.dirty_thresh / 10;
> > +
> > +		if ((global_page_state(NR_UNSTABLE_NFS) +
> > +		     global_page_state(NR_WRITEBACK) <= dirty_thresh) &&
> > +		    (!do_memcg ||
> > +		     (memcg_info.nr_unstable_nfs +
> > +		      memcg_info.nr_writeback <= memcg_info.dirty_thresh)))
> > +			break;
> >                  congestion_wait(BLK_RW_ASYNC, HZ/10);
> >  
> >  		/*
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..035d2ea 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1939,7 +1939,7 @@ restart:
> >  					sc->nr_scanned - nr_scanned, sc))
> >  		goto restart;
> >  
> > -	throttle_vm_writeout(sc->gfp_mask);
> > +	throttle_vm_writeout(sc->gfp_mask, sc->mem_cgroup);
> >  }
> >  
> >  /*
> > -- 
> > 1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
