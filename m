Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 153006B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:47:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d140so12939122wmd.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:47:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si10234528wrc.197.2017.01.12.23.47.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 23:47:11 -0800 (PST)
Date: Fri, 13 Jan 2017 08:47:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170113074705.GA21784@dhcp22.suse.cz>
References: <586edadc.figmHAGrTxvM7Wei%akpm@linux-foundation.org>
 <20170110235250.GA7130@bbox>
 <20170111155239.GD16365@dhcp22.suse.cz>
 <20170112051247.GA8387@bbox>
 <20170112081554.GB2264@dhcp22.suse.cz>
 <20170112084813.GA24030@bbox>
 <20170112091016.GE2264@dhcp22.suse.cz>
 <20170113013724.GA23494@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113013724.GA23494@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri 13-01-17 10:37:24, Minchan Kim wrote:
> Hello,
> 
> On Thu, Jan 12, 2017 at 10:10:17AM +0100, Michal Hocko wrote:
> > On Thu 12-01-17 17:48:13, Minchan Kim wrote:
> > > On Thu, Jan 12, 2017 at 09:15:54AM +0100, Michal Hocko wrote:
> > > > On Thu 12-01-17 14:12:47, Minchan Kim wrote:
> > > > > Hello,
> > > > > 
> > > > > On Wed, Jan 11, 2017 at 04:52:39PM +0100, Michal Hocko wrote:
> > > > > > On Wed 11-01-17 08:52:50, Minchan Kim wrote:
> > > > > > [...]
> > > > > > > > @@ -2055,8 +2055,8 @@ static bool inactive_list_is_low(struct
> > > > > > > >  	if (!file && !total_swap_pages)
> > > > > > > >  		return false;
> > > > > > > >  
> > > > > > > > -	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > > > > -	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > > > > +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> > > > > > > > +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> > > > > > > >  
> > > > > > > 
> > > > > > > the decision of deactivating is based on eligible zone's LRU size,
> > > > > > > not whole zone so why should we need to get a trace of all zones's LRU?
> > > > > > 
> > > > > > Strictly speaking, the total_ counters are not necessary for making the
> > > > > > decision. I found reporting those numbers useful regardless because this
> > > > > > will give us also an information how large is the eligible portion of
> > > > > > the LRU list. We do not have any other tracepoint which would report
> > > > > > that.
> > > > > 
> > > > > The patch doesn't say anything why it's useful. Could you tell why it's
> > > > > useful and inactive_list_is_low should be right place?
> > > > > 
> > > > > Don't get me wrong, please. I don't want to bother you.
> > > > > I really don't want to add random stuff although it's tracepoint for
> > > > > debugging.
> > > > 
> > > > This doesn't sounds random to me. We simply do not have a full picture
> > > > on 32b systems without this information. Especially when memcgs are
> > > > involved and global numbers spread over different LRUs.
> > > 
> > > Could you elaborate it?
> > 
> > The problem with 32b systems is that you only can consider a part of the
> > LRU for the lowmem requests. While we have global counters to see how
> > much lowmem inactive/active pages we have, those get distributed to
> > memcg LRUs. And that distribution is impossible to guess. So my thinking
> > is that it can become a real head scratcher to realize why certain
> > active LRUs are aged while others are not. This was the case when I was
> > debugging the last issue which triggered all this. All of the sudden I
> > have seen many invocations when inactive and active were zero which
> > sounded weird, until I realized that those are memcg's lruvec which is
> > what total numbers told me...
> 
> Hmm, it seems I miss something. AFAIU, what you need is just memcg
> identifier, not all lru size. If it isn't, please tell more detail
> usecase of all lru size in that particular tracepoint.

Having memcg id would be definitely helpful but that alone wouldn't tell
us how is the lowmem distributed. To be honest I really fail to see why
this bothers you all that much.
 
[...]
> > > > I am not sure I am following. Why is the additional parameter a problem?
> > > 
> > > Well, to me, it's not a elegance. Is it? If we need such boolean variable
> > > to control show the trace, it means it's not a good place or think
> > > refactoring.
> > 
> > But, even when you refactor the code there will be other callers of
> > inactive_list_is_low outside of shrink_active_list...
> 
> Yes, that's why I said "it's okay if you love your version". However,
> we can do refactoring to remove "bool trace" and even, it makes code
> more readable, I believe.
> 
> >From 06eb7201d781155a8dee7e72fbb8423ec8175223 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 13 Jan 2017 10:13:36 +0900
> Subject: [PATCH] mm: refactoring inactive_list_is_low
> 
> Recently, Michal Hocko added tracepoint into inactive_list_is_low
> for catching why VM decided to age the active list to know
> active/inacive balancing problem. With that, unfortunately, it
> added "bool trace" to inactlive_list_is_low to control some place
> should be prohibited tracing. It is not elegant to me so this patch
> try to clean it up.
> 
> Normally, most inactive_list_is_low is used for deciding active list
> demotion but one site(i.e., get_scan_count) uses for other purpose
> which reclaim file LRU forcefully. Sites for deactivation calls it
> with shrink_active_list. It means inactive_list_is_low could be
> located in shrink_active_list.
> 
> One more thing this patch does is to remove "ratio" in the tracepoint
> because we can get it by post processing in script via simple math.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/trace/events/vmscan.h |  9 +++-----
>  mm/vmscan.c                   | 51 ++++++++++++++++++++++++-------------------
>  2 files changed, 31 insertions(+), 29 deletions(-)

this cleanup adds more lines than it removes. I think reporting the
ratio is helpful because it doesn't cost us anything while calculating
it by later is just a bit annoying.

> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 27e8a5c..406ea95 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -432,9 +432,9 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
>  	TP_PROTO(int nid, int reclaim_idx,
>  		unsigned long total_inactive, unsigned long inactive,
>  		unsigned long total_active, unsigned long active,
> -		unsigned long ratio, int file),
> +		int file),
>  
> -	TP_ARGS(nid, reclaim_idx, total_inactive, inactive, total_active, active, ratio, file),
> +	TP_ARGS(nid, reclaim_idx, total_inactive, inactive, total_active, active, file),
>  
>  	TP_STRUCT__entry(
>  		__field(int, nid)
> @@ -443,7 +443,6 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
>  		__field(unsigned long, inactive)
>  		__field(unsigned long, total_active)
>  		__field(unsigned long, active)
> -		__field(unsigned long, ratio)
>  		__field(int, reclaim_flags)
>  	),
>  
> @@ -454,16 +453,14 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
>  		__entry->inactive = inactive;
>  		__entry->total_active = total_active;
>  		__entry->active = active;
> -		__entry->ratio = ratio;
>  		__entry->reclaim_flags = trace_shrink_flags(file) & RECLAIM_WB_LRU;
>  	),
>  
> -	TP_printk("nid=%d reclaim_idx=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld ratio=%ld flags=%s",
> +	TP_printk("nid=%d reclaim_idx=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld flags=%s",
>  		__entry->nid,
>  		__entry->reclaim_idx,
>  		__entry->total_inactive, __entry->inactive,
>  		__entry->total_active, __entry->active,
> -		__entry->ratio,
>  		show_reclaim_flags(__entry->reclaim_flags))
>  );
>  #endif /* _TRACE_VMSCAN_H */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 75cdf68..6890c21 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -150,6 +150,7 @@ unsigned long vm_total_pages;
>  
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
> +static bool inactive_list_is_low(bool file, unsigned long, unsigned long);
>  
>  #ifdef CONFIG_MEMCG
>  static bool global_reclaim(struct scan_control *sc)
> @@ -1962,6 +1963,22 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +	unsigned long inactive, active;
> +	enum lru_list inactive_lru = file * LRU_FILE;
> +	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
> +	bool deactivate;
> +
> +	inactive = lruvec_lru_size_eligibe_zones(lruvec, file * LRU_FILE,
> +					sc->reclaim_idx);
> +	active = lruvec_lru_size_eligibe_zones(lruvec, file * LRU_FILE +
> +					LRU_ACTIVE, sc->reclaim_idx);
> +	deactivate = inactive_list_is_low(file, inactive, active);
> +	trace_mm_vmscan_inactive_list_is_low(pgdat->node_id,
> +			sc->reclaim_idx,
> +			lruvec_lru_size(lruvec, inactive_lru), inactive,
> +			lruvec_lru_size(lruvec, active_lru), active, file);
> +	if (!deactivate)
> +		return;
>  
>  	lru_add_drain();
>  
> @@ -2073,13 +2090,10 @@ static void shrink_active_list(unsigned long nr_to_scan,
>   *    1TB     101        10GB
>   *   10TB     320        32GB
>   */
> -static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
> -						struct scan_control *sc, bool trace)
> +static bool inactive_list_is_low(bool file,
> +			unsigned long inactive, unsigned long active)
>  {
>  	unsigned long inactive_ratio;
> -	unsigned long inactive, active;
> -	enum lru_list inactive_lru = file * LRU_FILE;
> -	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
>  	unsigned long gb;
>  
>  	/*
> @@ -2089,22 +2103,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  	if (!file && !total_swap_pages)
>  		return false;
>  
> -	inactive = lruvec_lru_size_eligibe_zones(lruvec, inactive_lru, sc->reclaim_idx);
> -	active = lruvec_lru_size_eligibe_zones(lruvec, active_lru, sc->reclaim_idx);
> -
>  	gb = (inactive + active) >> (30 - PAGE_SHIFT);
>  	if (gb)
>  		inactive_ratio = int_sqrt(10 * gb);
>  	else
>  		inactive_ratio = 1;
>  
> -	if (trace)
> -		trace_mm_vmscan_inactive_list_is_low(lruvec_pgdat(lruvec)->node_id,
> -				sc->reclaim_idx,
> -				lruvec_lru_size(lruvec, inactive_lru), inactive,
> -				lruvec_lru_size(lruvec, active_lru), active,
> -				inactive_ratio, file);
> -
>  	return inactive * inactive_ratio < active;
>  }
>  
> @@ -2112,8 +2116,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  				 struct lruvec *lruvec, struct scan_control *sc)
>  {
>  	if (is_active_lru(lru)) {
> -		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
> -			shrink_active_list(nr_to_scan, lruvec, sc, lru);
> +		shrink_active_list(nr_to_scan, lruvec, sc, lru);
>  		return 0;
>  	}
>  
> @@ -2153,6 +2156,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	enum lru_list lru;
>  	bool some_scanned;
>  	int pass;
> +	unsigned long inactive, active;
>  
>  	/*
>  	 * If the zone or memcg is small, nr[l] can be 0.  This
> @@ -2243,7 +2247,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	 * lruvec even if it has plenty of old anonymous pages unless the
>  	 * system is under heavy pressure.
>  	 */
> -	if (!inactive_list_is_low(lruvec, true, sc, false) &&
> +	inactive = lruvec_lru_size_eligibe_zones(lruvec,
> +				LRU_FILE, sc->reclaim_idx);
> +	active = lruvec_lru_size_eligibe_zones(lruvec,
> +				LRU_FILE + LRU_ACTIVE, sc->reclaim_idx);
> +	if (!inactive_list_is_low(true, inactive, active) &&
>  	    lruvec_lru_size_eligibe_zones(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
> @@ -2468,9 +2476,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (inactive_list_is_low(lruvec, false, sc, true))
> -		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
> -				   sc, LRU_ACTIVE_ANON);
> +	shrink_active_list(SWAP_CLUSTER_MAX, lruvec, sc, LRU_ACTIVE_ANON);
>  }
>  
>  /* Use reclaim/compaction for costly allocs or under memory pressure */
> @@ -3118,8 +3124,7 @@ static void age_active_anon(struct pglist_data *pgdat,
>  	do {
>  		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
>  
> -		if (inactive_list_is_low(lruvec, false, sc, true))
> -			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
> +		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>  					   sc, LRU_ACTIVE_ANON);
>  
>  		memcg = mem_cgroup_iter(NULL, memcg, NULL);
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
