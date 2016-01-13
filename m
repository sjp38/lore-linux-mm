Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 779F86B0265
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 17:49:31 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so349647278pac.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 14:49:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id um10si4777562pab.110.2016.01.13.14.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 14:49:30 -0800 (PST)
Date: Wed, 13 Jan 2016 14:49:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: basic memory statistics in cgroup2
 memory controller
Message-Id: <20160113144930.b20ed63f1c6a28730f66eccd@linux-foundation.org>
In-Reply-To: <1452722469-24704-2-git-send-email-hannes@cmpxchg.org>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
	<1452722469-24704-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, 13 Jan 2016 17:01:08 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Provide a cgroup2 memory.stat that provides statistics on LRU memory
> and fault event counters. More consumers and breakdowns will follow.
> 
> ...
>
> @@ -5095,6 +5107,46 @@ static int memory_events_show(struct seq_file *m, void *v)
>  	return 0;
>  }
>  
> +static int memory_stat_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +	int i;
> +
> +	/* Memory consumer totals */
> +
> +	seq_printf(m, "anon %lu\n",
> +		   tree_stat(memcg, MEM_CGROUP_STAT_RSS) * PAGE_SIZE);

Is there any reason why this won't overflow a longword on 32-bit?

> +	seq_printf(m, "file %lu\n",
> +		   tree_stat(memcg, MEM_CGROUP_STAT_CACHE) * PAGE_SIZE);
> +
> +	/* Per-consumer breakdowns */
> +
> +	for (i = 0; i < NR_LRU_LISTS; i++) {
> +		struct mem_cgroup *mi;
> +		unsigned long val = 0;
> +
> +		for_each_mem_cgroup_tree(mi, memcg)
> +			val += mem_cgroup_nr_lru_pages(mi, BIT(i)) * PAGE_SIZE;
> +		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i], val);
> +	}
> +
> +	seq_printf(m, "file_mapped %lu\n",
> +		   tree_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED) * PAGE_SIZE);
> +	seq_printf(m, "file_dirty %lu\n",
> +		   tree_stat(memcg, MEM_CGROUP_STAT_DIRTY) * PAGE_SIZE);
> +	seq_printf(m, "file_writeback %lu\n",
> +		   tree_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) * PAGE_SIZE);
> +
> +	/* Memory management events */
> +
> +	seq_printf(m, "pgfault %lu\n",
> +		   tree_events(memcg, MEM_CGROUP_EVENTS_PGFAULT));
> +	seq_printf(m, "pgmajfault %lu\n",
> +		   tree_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT));
> +
> +	return 0;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
