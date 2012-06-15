Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id AA7D16B0070
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 11:32:46 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so169050bkc.2
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:32:44 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 2/2] memcg: add per cgroup dirty pages accounting
References: <1339761611-29033-1-git-send-email-handai.szj@taobao.com>
	<1339761717-29070-1-git-send-email-handai.szj@taobao.com>
Date: Fri, 15 Jun 2012 08:32:43 -0700
In-Reply-To: <1339761717-29070-1-git-send-email-handai.szj@taobao.com> (Sha
	Zhengju's message of "Fri, 15 Jun 2012 20:01:57 +0800")
Message-ID: <xr93k3z8twtg.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Fri, Jun 15 2012, Sha Zhengju wrote:

> This patch adds memcg routines to count dirty pages. I notice that
> the list has talked about per-cgroup dirty page limiting
> (http://lwn.net/Articles/455341/) before, but it did not get merged.

Good timing, I was just about to make another effort to get some of
these patches upstream.  Like you, I was going to start with some basic
counters.

Your approach is similar to what I have in mind.  While it is good to
use the existing PageDirty flag, rather than introducing a new
page_cgroup flag, there are locking complications (see below) to handle
races between moving pages between memcg and the pages being {un}marked
dirty.

> I've no idea how is this going now, but maybe we can add per cgroup
> dirty pages accounting first. This allows the memory controller to
> maintain an accurate view of the amount of its memory that is dirty
> and can provide some infomation while group's direct reclaim is working.
>
> After commit 89c06bd5 (memcg: use new logic for page stat accounting),
> we do not need per page_cgroup flag anymore and can directly use
> struct page flag.
>
>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  include/linux/memcontrol.h |    1 +
>  mm/filemap.c               |    1 +
>  mm/memcontrol.c            |   32 +++++++++++++++++++++++++-------
>  mm/page-writeback.c        |    2 ++
>  mm/truncate.c              |    1 +
>  5 files changed, 30 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index a337c2e..8154ade 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -39,6 +39,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
> +	MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 79c4b2b..5b5c121 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -141,6 +141,7 @@ void __delete_from_page_cache(struct page *page)
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);

You need to use mem_cgroup_{begin,end}_update_page_stat around critical
sections that:
1) check PageDirty
2) update MEM_CGROUP_STAT_FILE_DIRTY counter

This protects against the page from being moved between memcg while
accounting.  Same comment applies to all of your new calls to
mem_cgroup_{dec,inc}_page_stat.  For usage pattern, see
page_add_file_rmap.

>  		dec_zone_page_state(page, NR_FILE_DIRTY);
>  		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	}
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9102b8c..d200ad1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2548,6 +2548,18 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
> +static inline
> +void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
> +					struct mem_cgroup *to,
> +					enum mem_cgroup_stat_index idx)
> +{
> +	/* Update stat data for mem_cgroup */
> +	preempt_disable();
> +	__this_cpu_dec(from->stat->count[idx]);
> +	__this_cpu_inc(to->stat->count[idx]);
> +	preempt_enable();
> +}
> +
>  /**
>   * mem_cgroup_move_account - move account of the page
>   * @page: the page
> @@ -2597,13 +2609,14 @@ static int mem_cgroup_move_account(struct page *page,
>  
>  	move_lock_mem_cgroup(from, &flags);
>  
> -	if (!anon && page_mapped(page)) {
> -		/* Update mapped_file data for mem_cgroup */
> -		preempt_disable();
> -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		preempt_enable();
> -	}
> +	if (!anon && page_mapped(page))
> +		mem_cgroup_move_account_page_stat(from, to,
> +					MEM_CGROUP_STAT_FILE_MAPPED);
> +
> +	if (PageDirty(page))
> +		mem_cgroup_move_account_page_stat(from, to,
> +					MEM_CGROUP_STAT_FILE_DIRTY);
> +
>  	mem_cgroup_charge_statistics(from, anon, -nr_pages);
>  	if (uncharge)
>  		/* This is not "cancel", but cancel_charge does all we need. */
> @@ -4023,6 +4036,7 @@ enum {
>  	MCS_SWAP,
>  	MCS_PGFAULT,
>  	MCS_PGMAJFAULT,
> +	MCS_FILE_DIRTY,
>  	MCS_INACTIVE_ANON,
>  	MCS_ACTIVE_ANON,
>  	MCS_INACTIVE_FILE,
> @@ -4047,6 +4061,7 @@ struct {
>  	{"swap", "total_swap"},
>  	{"pgfault", "total_pgfault"},
>  	{"pgmajfault", "total_pgmajfault"},
> +	{"dirty", "total_dirty"},

Please add something to Documentation/cgroups/memory.txt describing this
new user visible data.  See my previous patch
http://thread.gmane.org/gmane.linux.kernel.mm/67114 for example text.

>  	{"inactive_anon", "total_inactive_anon"},
>  	{"active_anon", "total_active_anon"},
>  	{"inactive_file", "total_inactive_file"},
> @@ -4080,6 +4095,9 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
>  	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT);
>  	s->stat[MCS_PGMAJFAULT] += val;
>  
> +	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY);
> +	s->stat[MCS_FILE_DIRTY] += val * PAGE_SIZE;
> +
>  	/* per zone stat */
>  	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
>  	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 26adea8..b17c692 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1936,6 +1936,7 @@ int __set_page_dirty_no_writeback(struct page *page)
>  void account_page_dirtied(struct page *page, struct address_space *mapping)
>  {
>  	if (mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>  		__inc_zone_page_state(page, NR_FILE_DIRTY);
>  		__inc_zone_page_state(page, NR_DIRTIED);
>  		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> @@ -2155,6 +2156,7 @@ int clear_page_dirty_for_io(struct page *page)
>  		 * for more comments.
>  		 */
>  		if (TestClearPageDirty(page)) {
> +			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 61a183b..fe8363e 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -76,6 +76,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
>  	if (TestClearPageDirty(page)) {
>  		struct address_space *mapping = page->mapping;
>  		if (mapping && mapping_cap_account_dirty(mapping)) {
> +			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
