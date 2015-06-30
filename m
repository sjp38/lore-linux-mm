Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7B26B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 06:14:59 -0400 (EDT)
Received: by wiar9 with SMTP id r9so30916078wia.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 03:14:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex7si18502387wib.85.2015.06.30.03.14.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 03:14:58 -0700 (PDT)
Date: Tue, 30 Jun 2015 12:14:52 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 23/51] writeback: make backing_dev_info host
 cgroup-specific bdi_writebacks
Message-ID: <20150630101452.GI7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-24-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-24-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Dan Carpenter <dan.carpenter@oracle.com>

On Fri 22-05-15 17:13:37, Tejun Heo wrote:
> For the planned cgroup writeback support, on each bdi
> (backing_dev_info), each memcg will be served by a separate wb
> (bdi_writeback).  This patch updates bdi so that a bdi can host
> multiple wbs (bdi_writebacks).
> 
> On the default hierarchy, blkcg implicitly enables memcg.  This allows
> using memcg's page ownership for attributing writeback IOs, and every
> memcg - blkcg combination can be served by its own wb by assigning a
> dedicated wb to each memcg.  This means that there may be multiple
> wb's of a bdi mapped to the same blkcg.  As congested state is per
> blkcg - bdi combination, those wb's should share the same congested
> state.  This is achieved by tracking congested state via
> bdi_writeback_congested structs which are keyed by blkcg.
> 
> bdi->wb remains unchanged and will keep serving the root cgroup.
> cgwb's (cgroup wb's) for non-root cgroups are created on-demand or
> looked up while dirtying an inode according to the memcg of the page
> being dirtied or current task.  Each cgwb is indexed on bdi->cgwb_tree
> by its memcg id.  Once an inode is associated with its wb, it can be
> retrieved using inode_to_wb().
> 
> Currently, none of the filesystems has FS_CGROUP_WRITEBACK and all
> pages will keep being associated with bdi->wb.
> 
> v3: inode_attach_wb() in account_page_dirtied() moved inside
>     mapping_cap_account_dirty() block where it's known to be !NULL.
>     Also, an unnecessary NULL check before kfree() removed.  Both
>     detected by the kbuild bot.
> 
> v2: Updated so that wb association is per inode and wb is per memcg
>     rather than blkcg.

It may be a good place to explain in this changelog (and add that
explanation to a comment before the definition of struct bdi_writeback) why
are the writeback structures per memcg and not per coarser blkcg. I was
pondering about it for a while before I realized that amount of avaliable
memory and thus dirty limits are a memcg property so we have to be able to
writeback only a specific memcg. It would be nice if one didn't have to
figure this out on his own (although it's kind of obvious once you realize
that ;).

Other than that the patch looks good so you can add:

Reviewed-by: Jan Kara <jack@suse.com>

A few nits below.
 
> +/**
> + * wb_find_current - find wb for %current on a bdi
> + * @bdi: bdi of interest
> + *
> + * Find the wb of @bdi which matches both the memcg and blkcg of %current.
> + * Must be called under rcu_read_lock() which protects the returend wb.
								^^ returned

> + * NULL if not found.
> + */
> +static inline struct bdi_writeback *wb_find_current(struct backing_dev_info *bdi)
> +{
> +	struct cgroup_subsys_state *memcg_css;
> +	struct bdi_writeback *wb;
> +
> +	memcg_css = task_css(current, memory_cgrp_id);
> +	if (!memcg_css->parent)
> +		return &bdi->wb;
> +
> +	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
> +
> +	/*
> +	 * %current's blkcg equals the effective blkcg of its memcg.  No
> +	 * need to use the relatively expensive cgroup_get_e_css().
> +	 */
> +	if (likely(wb && wb->blkcg_css == task_css(current, blkio_cgrp_id)))
> +		return wb;

This won't hit only in case where memcg moves to a different blkcg?
Just want to make sure I understand things right...

...
> +/**
> + * wb_congested_put - put a wb_congested
> + * @congested: wb_congested to put
> + *
> + * Put @congested and destroy it if the refcnt reaches zero.
> + */
> +void wb_congested_put(struct bdi_writeback_congested *congested)
> +{
> +	struct backing_dev_info *bdi = congested->bdi;
> +	unsigned long flags;
> +
> +	if (congested->blkcg_id == 1)
> +		return;
> +
> +	local_irq_save(flags);
> +	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
> +		local_irq_restore(flags);
> +		return;
> +	}
> +
> +	rb_erase(&congested->rb_node, &congested->bdi->cgwb_congested_tree);
> +	spin_unlock_irqrestore(&cgwb_lock, flags);
> +	kfree(congested);
> +
> +	if (atomic_dec_and_test(&bdi->usage_cnt))
> +		wake_up_all(&cgwb_release_wait);

Maybe we could have a small wrapper for dropping bdi->usage_cnt? If someone
forgets to wake up cgwb_release_wait after dropping the ref count, it will be
somewhat difficult to chase down that call site...

...
> +#ifdef CONFIG_CGROUP_WRITEBACK
> +
> +struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg)
> +{
> +	return &memcg->cgwb_list;
> +}
> +
> +#endif	/* CONFIG_CGROUP_WRITEBACK */
> +

What is the reason for this wrapper? It doesn't seem particularly useful...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
