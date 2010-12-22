Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4F6D36B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 04:02:27 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBM92O1B016771
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Dec 2010 18:02:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 14D5C45DE80
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:02:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E893B45DE73
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:02:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D4B9FE18008
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:02:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DBD0E38004
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 18:02:23 +0900 (JST)
Date: Wed, 22 Dec 2010 17:56:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: migration: Use rcu_dereference_protected when
 dereferencing the radix tree slot during file page migration
Message-Id: <20101222175630.9ef72148.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101220152335.GR13914@csn.ul.ie>
References: <20101220152335.GR13914@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, gerald.schaefer@de.ibm.com, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Ted Ts'o <tytso@mit.edu>, Arun Bhanu <ab@arunbhanu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Dec 2010 15:23:36 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> migrate_pages() -> unmap_and_move() only calls rcu_read_lock() for anonymous
> pages, as introduced by git commit 989f89c57e6361e7d16fbd9572b5da7d313b073d.
> The point of the RCU protection there is part of getting a stable reference
> to anon_vma and is only held for anon pages as file pages are locked
> which is sufficient protection against freeing.
> 
> However, while a file page's mapping is being migrated, the radix
> tree is double checked to ensure it is the expected page. This uses
> radix_tree_deref_slot() -> rcu_dereference() without the RCU lock held
> triggering the following warning under CONFIG_PROVE_RCU.
> 
> [  173.674290] ===================================================
> [  173.676016] [ INFO: suspicious rcu_dereference_check() usage. ]
> [  173.676016] ---------------------------------------------------
> [  173.676016] include/linux/radix-tree.h:145 invoked rcu_dereference_check() without protection!
> [  173.676016]
> [  173.676016] other info that might help us debug this:
> [  173.676016]
> [  173.676016]
> [  173.676016] rcu_scheduler_active = 1, debug_locks = 0
> [  173.676016] 1 lock held by hugeadm/2899:
> [  173.676016]  #0:  (&(&inode->i_data.tree_lock)->rlock){..-.-.}, at: [<c10e3d2b>] migrate_page_move_mapping+0x40/0x1ab
> [  173.676016]
> [  173.676016] stack backtrace:
> [  173.676016] Pid: 2899, comm: hugeadm Not tainted 2.6.37-rc5-autobuild
> [  173.676016] Call Trace:
> [  173.676016]  [<c128cc01>] ? printk+0x14/0x1b
> [  173.676016]  [<c1063502>] lockdep_rcu_dereference+0x7d/0x86
> [  173.676016]  [<c10e3db5>] migrate_page_move_mapping+0xca/0x1ab
> [  173.676016]  [<c10e41ad>] migrate_page+0x23/0x39
> [  173.676016]  [<c10e491b>] buffer_migrate_page+0x22/0x107
> [  173.676016]  [<c10e48f9>] ? buffer_migrate_page+0x0/0x107
> [  173.676016]  [<c10e425d>] move_to_new_page+0x9a/0x1ae
> [  173.676016]  [<c10e47e6>] migrate_pages+0x1e7/0x2fa
> 
> This patch introduces radix_tree_deref_slot_protected() which calls
> rcu_dereference_protected(). Users of it must pass in the mapping->tree_lock
> that is protecting this dereference. Holding the tree lock protects against
> parallel updaters of the radix tree meaning that rcu_dereference_protected
> is allowable.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Thank you for fixing.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  include/linux/radix-tree.h |   17 +++++++++++++++++
>  mm/migrate.c               |    4 ++--
>  2 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index ab2baa5..a1f1672 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -146,6 +146,23 @@ static inline void *radix_tree_deref_slot(void **pslot)
>  }
>  
>  /**
> + * radix_tree_deref_slot_protected	- dereference a slot without RCU lock but with tree lock held
> + * @pslot:	pointer to slot, returned by radix_tree_lookup_slot
> + * Returns:	item that was stored in that slot with any direct pointer flag
> + *		removed.
> + *
> + * Similar to radix_tree_deref_slot but only used during migration when a pages
> + * mapping is being moved. The caller does not hold the RCU read lock but it
> + * must hold the tree lock to prevent parallel updates.
> + */
> +static inline void *radix_tree_deref_slot_protected(void **pslot,
> +							spinlock_t *treelock)
> +{
> +	BUG_ON(rcu_read_lock_held());
> +	return rcu_dereference_protected(*pslot, lockdep_is_held(treelock));
> +}
> +
> +/**
>   * radix_tree_deref_retry	- check radix_tree_deref_slot
>   * @arg:	pointer returned by radix_tree_deref_slot
>   * Returns:	0 if retry is not required, otherwise retry is required
> diff --git a/mm/migrate.c b/mm/migrate.c
> index fe5a3c6..7d4686a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -244,7 +244,7 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>  
>  	expected_count = 2 + page_has_private(page);
>  	if (page_count(page) != expected_count ||
> -			(struct page *)radix_tree_deref_slot(pslot) != page) {
> +			(struct page *)radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
>  		spin_unlock_irq(&mapping->tree_lock);
>  		return -EAGAIN;
>  	}
> @@ -316,7 +316,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  
>  	expected_count = 2 + page_has_private(page);
>  	if (page_count(page) != expected_count ||
> -	    (struct page *)radix_tree_deref_slot(pslot) != page) {
> +	    (struct page *)radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
>  		spin_unlock_irq(&mapping->tree_lock);
>  		return -EAGAIN;
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
