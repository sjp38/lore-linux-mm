Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 702226B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 10:27:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p10so4298361wrc.14
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 07:27:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s12si12251013wma.164.2017.10.04.07.27.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 07:27:41 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:27:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <20171004142736.u4z7zdar6g7bqgrj@dhcp22.suse.cz>
References: <1507053977-116952-1-git-send-email-yang.s@alibaba-inc.com>
 <1507053977-116952-4-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507053977-116952-4-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 04-10-17 02:06:17, Yang Shi wrote:
> +static bool is_dump_unreclaim_slabs(void)
> +{
> +	unsigned long nr_lru;
> +
> +	nr_lru = global_node_page_state(NR_ACTIVE_ANON) +
> +		 global_node_page_state(NR_INACTIVE_ANON) +
> +		 global_node_page_state(NR_ACTIVE_FILE) +
> +		 global_node_page_state(NR_INACTIVE_FILE) +
> +		 global_node_page_state(NR_ISOLATED_ANON) +
> +		 global_node_page_state(NR_ISOLATED_FILE) +
> +		 global_node_page_state(NR_UNEVICTABLE);
> +
> +	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
> +}

I am sorry I haven't pointed this earlier (I was following only half
way) but this should really be memcg aware. You are checking only global
counters. I do not think it is an absolute must to provide per-memcg
data but you should at least check !is_memcg_oom(oc).

[...]
> +void dump_unreclaimable_slab(void)
> +{
> +	struct kmem_cache *s, *s2;
> +	struct slabinfo sinfo;
> +
> +	pr_info("Unreclaimable slab info:\n");
> +	pr_info("Name                      Used          Total\n");
> +
> +	/*
> +	 * Here acquiring slab_mutex is risky since we don't prefer to get
> +	 * sleep in oom path. But, without mutex hold, it may introduce a
> +	 * risk of crash.
> +	 * Use mutex_trylock to protect the list traverse, dump nothing
> +	 * without acquiring the mutex.
> +	 */
> +	if (!mutex_trylock(&slab_mutex))
> +		return;

I would move the trylock up so that we do not get empty and confusing
Unreclaimable slab info: and add a note that we are not dumping anything
due to lock contention
	pr_warn("excessive unreclaimable slab memory but cannot dump stats to give you more details\n");

Other than that this looks sensible to me.

> +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
> +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
> +			continue;
> +
> +		memset(&sinfo, 0, sizeof(sinfo));
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
