Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1D26B0069
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 05:37:06 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j73so3986383lfg.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 02:37:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si1136891wrb.19.2017.10.06.02.37.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 02:37:05 -0700 (PDT)
Date: Fri, 6 Oct 2017 11:37:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <20171006093702.3ca2p6ymyycwfgbk@dhcp22.suse.cz>
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
 <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 05-10-17 05:29:10, Yang Shi wrote:
> Kernel may panic when oom happens without killable process sometimes it
> is caused by huge unreclaimable slabs used by kernel.
> 
> Although kdump could help debug such problem, however, kdump is not
> available on all architectures and it might be malfunction sometime.
> And, since kernel already panic it is worthy capturing such information
> in dmesg to aid touble shooting.
> 
> Print out unreclaimable slab info (used size and total size) which
> actual memory usage is not zero (num_objs * size != 0) when
> unreclaimable slabs amount is greater than total user memory (LRU
> pages).
> 
> The output looks like:
> 
> Unreclaimable slab info:
> Name                      Used          Total
> rpc_buffers               31KB         31KB
> rpc_tasks                  7KB          7KB
> ebitmap_node            1964KB       1964KB
> avtab_node              5024KB       5024KB
> xfs_buf                 1402KB       1402KB
> xfs_ili                  134KB        134KB
> xfs_efi_item             115KB        115KB
> xfs_efd_item             115KB        115KB
> xfs_buf_item             134KB        134KB
> xfs_log_item_desc        342KB        342KB
> xfs_trans               1412KB       1412KB
> xfs_ifork                212KB        212KB

OK this looks better. The naming is not the greatest but I will not
nitpick on this. I have one question though

> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
[...]
> +void dump_unreclaimable_slab(void)
> +{
> +	struct kmem_cache *s, *s2;
> +	struct slabinfo sinfo;
> +
> +	/*
> +	 * Here acquiring slab_mutex is risky since we don't prefer to get
> +	 * sleep in oom path. But, without mutex hold, it may introduce a
> +	 * risk of crash.
> +	 * Use mutex_trylock to protect the list traverse, dump nothing
> +	 * without acquiring the mutex.
> +	 */
> +	if (!mutex_trylock(&slab_mutex)) {
> +		pr_warn("excessive unreclaimable slab but cannot dump stats\n");
> +		return;
> +	}
> +
> +	pr_info("Unreclaimable slab info:\n");
> +	pr_info("Name                      Used          Total\n");
> +
> +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
> +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
> +			continue;
> +
> +		memset(&sinfo, 0, sizeof(sinfo));

why do you zero out the structure. All the fields you are printing are
filled out in get_slabinfo.

> +		get_slabinfo(s, &sinfo);
> +
> +		if (sinfo.num_objs > 0)
> +			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
> +				(sinfo.active_objs * s->size) / 1024,
> +				(sinfo.num_objs * s->size) / 1024);
> +	}
> +	mutex_unlock(&slab_mutex);
> +}
> +
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>  void *memcg_slab_start(struct seq_file *m, loff_t *pos)
>  {
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
