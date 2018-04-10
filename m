Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC0BC6B000C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:34:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g61-v6so8765683plb.10
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 23:34:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n76si1594343pfi.122.2018.04.09.23.34.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 23:34:01 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:33:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] writeback: safer lock nesting
Message-ID: <20180410063357.GS21835@dhcp22.suse.cz>
References: <201804080259.VS5U0mKT%fengguang.wu@intel.com>
 <20180410005908.167976-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410005908.167976-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Wang Long <wanglong19@meituan.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 09-04-18 17:59:08, Greg Thelen wrote:
> lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() if
> the page's memcg is undergoing move accounting, which occurs when a
> process leaves its memcg for a new one that has
> memory.move_charge_at_immigrate set.
> 
> unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if the
> given inode is switching writeback domains.  Switches occur when enough
> writes are issued from a new domain.
> 
> This existing pattern is thus suspicious:
>     lock_page_memcg(page);
>     unlocked_inode_to_wb_begin(inode, &locked);
>     ...
>     unlocked_inode_to_wb_end(inode, locked);
>     unlock_page_memcg(page);
> 
> If both inode switch and process memcg migration are both in-flight then
> unlocked_inode_to_wb_end() will unconditionally enable interrupts while
> still holding the lock_page_memcg() irq spinlock.  This suggests the
> possibility of deadlock if an interrupt occurs before
> unlock_page_memcg().
> 
>     truncate
>     __cancel_dirty_page
>     lock_page_memcg
>     unlocked_inode_to_wb_begin
>     unlocked_inode_to_wb_end
>     <interrupts mistakenly enabled>
>                                     <interrupt>
>                                     end_page_writeback
>                                     test_clear_page_writeback
>                                     lock_page_memcg
>                                     <deadlock>
>     unlock_page_memcg
> 
> Due to configuration limitations this deadlock is not currently possible
> because we don't mix cgroup writeback (a cgroupv2 feature) and
> memory.move_charge_at_immigrate (a cgroupv1 feature).
> 
> If the kernel is hacked to always claim inode switching and memcg
> moving_account, then this script triggers lockup in less than a minute:
>   cd /mnt/cgroup/memory
>   mkdir a b
>   echo 1 > a/memory.move_charge_at_immigrate
>   echo 1 > b/memory.move_charge_at_immigrate
>   (
>     echo $BASHPID > a/cgroup.procs
>     while true; do
>       dd if=/dev/zero of=/mnt/big bs=1M count=256
>     done
>   ) &
>   while true; do
>     sync
>   done &
>   sleep 1h &
>   SLEEP=$!
>   while true; do
>     echo $SLEEP > a/cgroup.procs
>     echo $SLEEP > b/cgroup.procs
>   done
> 

Very nice changelog!

> Given the deadlock is not currently possible, it's debatable if there's
> any reason to modify the kernel.  I suggest we should to prevent future
> surprises.

Agreed!

> Reported-by: Wang Long <wanglong19@meituan.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Change-Id: Ibb773e8045852978f6207074491d262f1b3fb613

Not a stable material IMHO but
Fixes: 682aa8e1a6a1 ("writeback: implement unlocked_inode_to_wb transaction and use it for stat updates")
AFAIU

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> Changelog since v2:
> - explicitly initialize wb_lock_cookie to silence compiler warnings.
> 
> Changelog since v1:
> - add wb_lock_cookie to record lock context.
> 
>  fs/fs-writeback.c                |  7 ++++---
>  include/linux/backing-dev-defs.h |  5 +++++
>  include/linux/backing-dev.h      | 30 ++++++++++++++++--------------
>  mm/page-writeback.c              | 18 +++++++++---------
>  4 files changed, 34 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 1280f915079b..f4b2f6625913 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -745,11 +745,12 @@ int inode_congested(struct inode *inode, int cong_bits)
>  	 */
>  	if (inode && inode_to_wb_is_valid(inode)) {
>  		struct bdi_writeback *wb;
> -		bool locked, congested;
> +		struct wb_lock_cookie lock_cookie;
> +		bool congested;
>  
> -		wb = unlocked_inode_to_wb_begin(inode, &locked);
> +		wb = unlocked_inode_to_wb_begin(inode, &lock_cookie);
>  		congested = wb_congested(wb, cong_bits);
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &lock_cookie);
>  		return congested;
>  	}
>  
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
> index bfe86b54f6c1..0bd432a4d7bd 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -223,6 +223,11 @@ static inline void set_bdi_congested(struct backing_dev_info *bdi, int sync)
>  	set_wb_congested(bdi->wb.congested, sync);
>  }
>  
> +struct wb_lock_cookie {
> +	bool locked;
> +	unsigned long flags;
> +};
> +
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  
>  /**
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 3e4ce54d84ab..1d744c61d996 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -346,7 +346,7 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
>  /**
>   * unlocked_inode_to_wb_begin - begin unlocked inode wb access transaction
>   * @inode: target inode
> - * @lockedp: temp bool output param, to be passed to the end function
> + * @cookie: output param, to be passed to the end function
>   *
>   * The caller wants to access the wb associated with @inode but isn't
>   * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
> @@ -354,12 +354,11 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
>   * association doesn't change until the transaction is finished with
>   * unlocked_inode_to_wb_end().
>   *
> - * The caller must call unlocked_inode_to_wb_end() with *@lockdep
> - * afterwards and can't sleep during transaction.  IRQ may or may not be
> - * disabled on return.
> + * The caller must call unlocked_inode_to_wb_end() with *@cookie afterwards and
> + * can't sleep during transaction.  IRQ may or may not be disabled on return.
>   */
>  static inline struct bdi_writeback *
> -unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
> +unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie *cookie)
>  {
>  	rcu_read_lock();
>  
> @@ -367,10 +366,10 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
>  	 * Paired with store_release in inode_switch_wb_work_fn() and
>  	 * ensures that we see the new wb if we see cleared I_WB_SWITCH.
>  	 */
> -	*lockedp = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
> +	cookie->locked = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
>  
> -	if (unlikely(*lockedp))
> -		spin_lock_irq(&inode->i_mapping->tree_lock);
> +	if (unlikely(cookie->locked))
> +		spin_lock_irqsave(&inode->i_mapping->tree_lock, cookie->flags);
>  
>  	/*
>  	 * Protected by either !I_WB_SWITCH + rcu_read_lock() or tree_lock.
> @@ -382,12 +381,14 @@ unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
>  /**
>   * unlocked_inode_to_wb_end - end inode wb access transaction
>   * @inode: target inode
> - * @locked: *@lockedp from unlocked_inode_to_wb_begin()
> + * @cookie: @cookie from unlocked_inode_to_wb_begin()
>   */
> -static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
> +static inline void unlocked_inode_to_wb_end(struct inode *inode,
> +					    struct wb_lock_cookie *cookie)
>  {
> -	if (unlikely(locked))
> -		spin_unlock_irq(&inode->i_mapping->tree_lock);
> +	if (unlikely(cookie->locked))
> +		spin_unlock_irqrestore(&inode->i_mapping->tree_lock,
> +				       cookie->flags);
>  
>  	rcu_read_unlock();
>  }
> @@ -434,12 +435,13 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
>  }
>  
>  static inline struct bdi_writeback *
> -unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
> +unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie *cookie)
>  {
>  	return inode_to_wb(inode);
>  }
>  
> -static inline void unlocked_inode_to_wb_end(struct inode *inode, bool locked)
> +static inline void unlocked_inode_to_wb_end(struct inode *inode,
> +					    struct wb_lock_cookie *cookie)
>  {
>  }
>  
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 586f31261c83..bc38a2a7a597 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2501,13 +2501,13 @@ void account_page_redirty(struct page *page)
>  	if (mapping && mapping_cap_account_dirty(mapping)) {
>  		struct inode *inode = mapping->host;
>  		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie = {0};
>  
> -		wb = unlocked_inode_to_wb_begin(inode, &locked);
> +		wb = unlocked_inode_to_wb_begin(inode, &cookie);
>  		current->nr_dirtied--;
>  		dec_node_page_state(page, NR_DIRTIED);
>  		dec_wb_stat(wb, WB_DIRTIED);
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &cookie);
>  	}
>  }
>  EXPORT_SYMBOL(account_page_redirty);
> @@ -2613,15 +2613,15 @@ void __cancel_dirty_page(struct page *page)
>  	if (mapping_cap_account_dirty(mapping)) {
>  		struct inode *inode = mapping->host;
>  		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie = {0};
>  
>  		lock_page_memcg(page);
> -		wb = unlocked_inode_to_wb_begin(inode, &locked);
> +		wb = unlocked_inode_to_wb_begin(inode, &cookie);
>  
>  		if (TestClearPageDirty(page))
>  			account_page_cleaned(page, mapping, wb);
>  
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &cookie);
>  		unlock_page_memcg(page);
>  	} else {
>  		ClearPageDirty(page);
> @@ -2653,7 +2653,7 @@ int clear_page_dirty_for_io(struct page *page)
>  	if (mapping && mapping_cap_account_dirty(mapping)) {
>  		struct inode *inode = mapping->host;
>  		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie = {0};
>  
>  		/*
>  		 * Yes, Virginia, this is indeed insane.
> @@ -2690,14 +2690,14 @@ int clear_page_dirty_for_io(struct page *page)
>  		 * always locked coming in here, so we get the desired
>  		 * exclusion.
>  		 */
> -		wb = unlocked_inode_to_wb_begin(inode, &locked);
> +		wb = unlocked_inode_to_wb_begin(inode, &cookie);
>  		if (TestClearPageDirty(page)) {
>  			dec_lruvec_page_state(page, NR_FILE_DIRTY);
>  			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
>  			dec_wb_stat(wb, WB_RECLAIMABLE);
>  			ret = 1;
>  		}
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &cookie);
>  		return ret;
>  	}
>  	return TestClearPageDirty(page);
> -- 
> 2.17.0.484.g0c8726318c-goog

-- 
Michal Hocko
SUSE Labs
