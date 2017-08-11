Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08C226B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 17:37:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t18so4984514oih.11
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:37:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s16si1102218oih.449.2017.08.11.14.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 14:37:18 -0700 (PDT)
Date: Fri, 11 Aug 2017 14:37:17 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: kernel panic on null pointer on page->mem_cgroup
Message-ID: <20170811213717.GA15524@jaegeuk-macbookpro.roam.corp.google.com>
References: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808010150.4155-1-bradleybolen@gmail.com>
 <20170808162122.GA14689@cmpxchg.org>
 <20170808165601.GA7693@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808173704.GA22887@cmpxchg.org>
 <CADvgSZSn1v-tTpa07ebqr19heQbkzbavdPM_nbRNR1WF-EBnFw@mail.gmail.com>
 <20170808200849.GA1104@cmpxchg.org>
 <20170809014459.GB7693@jaegeuk-macbookpro.roam.corp.google.com>
 <CADvgSZSNn7N3R7+jjeCgns2ZEPtYc6c3MWmkkQ3PA+0LHO_MfA@mail.gmail.com>
 <20170809183825.GA26387@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809183825.GA26387@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Brad Bolen <bradleybolen@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Johannes,

On 08/09, Johannes Weiner wrote:
> On Tue, Aug 08, 2017 at 10:39:27PM -0400, Brad Bolen wrote:
> > Yes, the BUG_ON(!page_count(page)) fired for me as well.
> 
> Brad, Jaegeuk, does the following patch address this problem?

I also confirmed that this patch addresses the problem.

Tested-by: Jaegeuk Kim <jaegeuk@kernel.org>

Thanks,

> 
> ---
> 
> >From cf0060892eb70bccbc8cedeac0a5756c8f7b975e Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 9 Aug 2017 12:06:03 -0400
> Subject: [PATCH] mm: memcontrol: fix NULL pointer crash in
>  test_clear_page_writeback()
> 
> Jaegeuk and Brad report a NULL pointer crash when writeback ending
> tries to update the memcg stats:
> 
> [] BUG: unable to handle kernel NULL pointer dereference at 00000000000003b0
> [] IP: test_clear_page_writeback+0x12e/0x2c0
> [...]
> [] RIP: 0010:test_clear_page_writeback+0x12e/0x2c0
> [] RSP: 0018:ffff8e3abfd03d78 EFLAGS: 00010046
> [] RAX: 0000000000000000 RBX: ffffdb59c03f8900 RCX: ffffffffffffffe8
> [] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffff8e3abffeb000
> [] RBP: ffff8e3abfd03da8 R08: 0000000000020059 R09: 00000000fffffffc
> [] R10: 0000000000000000 R11: 0000000000020048 R12: ffff8e3a8c39f668
> [] R13: 0000000000000001 R14: ffff8e3a8c39f680 R15: 0000000000000000
> [] FS:  0000000000000000(0000) GS:ffff8e3abfd00000(0000) knlGS:0000000000000000
> [] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [] CR2: 00000000000003b0 CR3: 000000002c5e1000 CR4: 00000000000406e0
> [] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [] Call Trace:
> []  <IRQ>
> []  end_page_writeback+0x47/0x70
> []  f2fs_write_end_io+0x76/0x180 [f2fs]
> []  bio_endio+0x9f/0x120
> []  blk_update_request+0xa8/0x2f0
> []  scsi_end_request+0x39/0x1d0
> []  scsi_io_completion+0x211/0x690
> []  scsi_finish_command+0xd9/0x120
> []  scsi_softirq_done+0x127/0x150
> []  __blk_mq_complete_request_remote+0x13/0x20
> []  flush_smp_call_function_queue+0x56/0x110
> []  generic_smp_call_function_single_interrupt+0x13/0x30
> []  smp_call_function_single_interrupt+0x27/0x40
> []  call_function_single_interrupt+0x89/0x90
> [] RIP: 0010:native_safe_halt+0x6/0x10
> 
> (gdb) l *(test_clear_page_writeback+0x12e)
> 0xffffffff811bae3e is in test_clear_page_writeback (./include/linux/memcontrol.h:619).
> 614		mod_node_page_state(page_pgdat(page), idx, val);
> 615		if (mem_cgroup_disabled() || !page->mem_cgroup)
> 616			return;
> 617		mod_memcg_state(page->mem_cgroup, idx, val);
> 618		pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
> 619		this_cpu_add(pn->lruvec_stat->count[idx], val);
> 620	}
> 621
> 622	unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
> 623							gfp_t gfp_mask,
> 
> The issue is that writeback doesn't hold a page reference and the page
> might get freed after PG_writeback is cleared (and the mapping is
> unlocked) in test_clear_page_writeback(). The stat functions looking
> up the page's node or zone are safe, as those attributes are static
> across allocation and free cycles. But page->mem_cgroup is not, and it
> will get cleared if we race with truncation or migration.
> 
> It appears this race window has been around for a while, but less
> likely to trigger when the memcg stats were updated first thing after
> PG_writeback is cleared. Recent changes reshuffled this code to update
> the global node stats before the memcg ones, though, stretching the
> race window out to an extent where people can reproduce the problem.
> 
> Update test_clear_page_writeback() to look up and pin page->mem_cgroup
> before clearing PG_writeback, then not use that pointer afterward. It
> is a partial revert of 62cccb8c8e7a ("mm: simplify lock_page_memcg()")
> but leaves the pageref-holding callsites that aren't affected alone.
> 
> Fixes: 62cccb8c8e7a ("mm: simplify lock_page_memcg()")
> Reported-by: Jaegeuk Kim <jaegeuk@kernel.org>
> Reported-by: Bradley Bolen <bradleybolen@gmail.com>
> Cc: <stable@vger.kernel.org> # 4.6+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 10 ++++++++--
>  mm/memcontrol.c            | 43 +++++++++++++++++++++++++++++++------------
>  mm/page-writeback.c        | 15 ++++++++++++---
>  3 files changed, 51 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3914e3dd6168..9b15a4bcfa77 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -484,7 +484,8 @@ bool mem_cgroup_oom_synchronize(bool wait);
>  extern int do_swap_account;
>  #endif
>  
> -void lock_page_memcg(struct page *page);
> +struct mem_cgroup *lock_page_memcg(struct page *page);
> +void __unlock_page_memcg(struct mem_cgroup *memcg);
>  void unlock_page_memcg(struct page *page);
>  
>  static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
> @@ -809,7 +810,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
>  
> -static inline void lock_page_memcg(struct page *page)
> +static inline struct mem_cgroup *lock_page_memcg(struct page *page)
> +{
> +	return NULL;
> +}
> +
> +static inline void __unlock_page_memcg(struct mem_cgroup *memcg)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3df3c04d73ab..e09741af816f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1611,9 +1611,13 @@ bool mem_cgroup_oom_synchronize(bool handle)
>   * @page: the page
>   *
>   * This function protects unlocked LRU pages from being moved to
> - * another cgroup and stabilizes their page->mem_cgroup binding.
> + * another cgroup.
> + *
> + * It ensures lifetime of the returned memcg. Caller is responsible
> + * for the lifetime of the page; __unlock_page_memcg() is available
> + * when @page might get freed inside the locked section.
>   */
> -void lock_page_memcg(struct page *page)
> +struct mem_cgroup *lock_page_memcg(struct page *page)
>  {
>  	struct mem_cgroup *memcg;
>  	unsigned long flags;
> @@ -1622,18 +1626,24 @@ void lock_page_memcg(struct page *page)
>  	 * The RCU lock is held throughout the transaction.  The fast
>  	 * path can get away without acquiring the memcg->move_lock
>  	 * because page moving starts with an RCU grace period.
> -	 */
> +	 *
> +	 * The RCU lock also protects the memcg from being freed when
> +	 * the page state that is going to change is the only thing
> +	 * preventing the page itself from being freed. E.g. writeback
> +	 * doesn't hold a page reference and relies on PG_writeback to
> +	 * keep off truncation, migration and so forth.
> +         */
>  	rcu_read_lock();
>  
>  	if (mem_cgroup_disabled())
> -		return;
> +		return NULL;
>  again:
>  	memcg = page->mem_cgroup;
>  	if (unlikely(!memcg))
> -		return;
> +		return NULL;
>  
>  	if (atomic_read(&memcg->moving_account) <= 0)
> -		return;
> +		return memcg;
>  
>  	spin_lock_irqsave(&memcg->move_lock, flags);
>  	if (memcg != page->mem_cgroup) {
> @@ -1649,18 +1659,18 @@ void lock_page_memcg(struct page *page)
>  	memcg->move_lock_task = current;
>  	memcg->move_lock_flags = flags;
>  
> -	return;
> +	return memcg;
>  }
>  EXPORT_SYMBOL(lock_page_memcg);
>  
>  /**
> - * unlock_page_memcg - unlock a page->mem_cgroup binding
> - * @page: the page
> + * __unlock_page_memcg - unlock and unpin a memcg
> + * @memcg: the memcg
> + *
> + * Unlock and unpin a memcg returned by lock_page_memcg().
>   */
> -void unlock_page_memcg(struct page *page)
> +void __unlock_page_memcg(struct mem_cgroup *memcg)
>  {
> -	struct mem_cgroup *memcg = page->mem_cgroup;
> -
>  	if (memcg && memcg->move_lock_task == current) {
>  		unsigned long flags = memcg->move_lock_flags;
>  
> @@ -1672,6 +1682,15 @@ void unlock_page_memcg(struct page *page)
>  
>  	rcu_read_unlock();
>  }
> +
> +/**
> + * unlock_page_memcg - unlock a page->mem_cgroup binding
> + * @page: the page
> + */
> +void unlock_page_memcg(struct page *page)
> +{
> +	__unlock_page_memcg(page->mem_cgroup);
> +}
>  EXPORT_SYMBOL(unlock_page_memcg);
>  
>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 96e93b214d31..bf050ab025b7 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2724,9 +2724,12 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
>  int test_clear_page_writeback(struct page *page)
>  {
>  	struct address_space *mapping = page_mapping(page);
> +	struct mem_cgroup *memcg;
> +	struct lruvec *lruvec;
>  	int ret;
>  
> -	lock_page_memcg(page);
> +	memcg = lock_page_memcg(page);
> +	lruvec = mem_cgroup_page_lruvec(page, page_pgdat(page));
>  	if (mapping && mapping_use_writeback_tags(mapping)) {
>  		struct inode *inode = mapping->host;
>  		struct backing_dev_info *bdi = inode_to_bdi(inode);
> @@ -2754,12 +2757,18 @@ int test_clear_page_writeback(struct page *page)
>  	} else {
>  		ret = TestClearPageWriteback(page);
>  	}
> +	/*
> +	 * NOTE: Page might be free now! Writeback doesn't hold a page
> +	 * reference on its own, it relies on truncation to wait for
> +	 * the clearing of PG_writeback. The below can only access
> +	 * page state that is static across allocation cycles.
> +	 */
>  	if (ret) {
> -		dec_lruvec_page_state(page, NR_WRITEBACK);
> +		dec_lruvec_state(lruvec, NR_WRITEBACK);
>  		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
>  		inc_node_page_state(page, NR_WRITTEN);
>  	}
> -	unlock_page_memcg(page);
> +	__unlock_page_memcg(memcg);
>  	return ret;
>  }
>  
> -- 
> 2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
