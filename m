Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9C06B025F
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 05:54:47 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f6so34791655ith.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 02:54:47 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0138.outbound.protection.outlook.com. [157.55.234.138])
        by mx.google.com with ESMTPS id q45si13897032otq.53.2016.06.21.02.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 02:54:46 -0700 (PDT)
Date: Tue, 21 Jun 2016 12:54:33 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v3 05/13] mm: Fix memcg stack accounting for sub-page
 stacks
Message-ID: <20160621095433.GB15970@esperanza>
References: <cover.1466466093.git.luto@kernel.org>
 <6bacdd1005517bef4c6f6a4154bd7d1d4f4371f3.1466466093.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <6bacdd1005517bef4c6f6a4154bd7d1d4f4371f3.1466466093.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 20, 2016 at 04:43:35PM -0700, Andy Lutomirski wrote:
> We should account for stacks regardless of stack size, and we need
> to account in sub-page units if THREAD_SIZE < PAGE_SIZE.  Change the
> units to kilobytes and Move it into account_kernel_stack().
> 
> Fixes: 12580e4b54ba8 ("mm: memcontrol: report kernel stack usage in cgroup2 memory.stat")
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

This patch is going to have a minor conflict with recent changes in
mmotm, where {alloc,free}_kmem_pages were dropped, The conflict should
be trivial to resolve - we only need to replace {alloc,free}_kmem_pages
with {alloc,free}_pages in this patch.

> ---
>  include/linux/memcontrol.h |  2 +-
>  kernel/fork.c              | 15 ++++++---------
>  mm/memcontrol.c            |  2 +-
>  3 files changed, 8 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index a805474df4ab..3b653b86bb8f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -52,7 +52,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
>  	MEM_CGROUP_STAT_NSTATS,
>  	/* default hierarchy stats */
> -	MEMCG_KERNEL_STACK = MEM_CGROUP_STAT_NSTATS,
> +	MEMCG_KERNEL_STACK_KB = MEM_CGROUP_STAT_NSTATS,
>  	MEMCG_SLAB_RECLAIMABLE,
>  	MEMCG_SLAB_UNRECLAIMABLE,
>  	MEMCG_SOCK,
> diff --git a/kernel/fork.c b/kernel/fork.c
> index be7f006af727..ff3c41c2ba96 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -165,20 +165,12 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
>  	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
>  						  THREAD_SIZE_ORDER);
>  
> -	if (page)
> -		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
> -					    1 << THREAD_SIZE_ORDER);
> -
>  	return page ? page_address(page) : NULL;
>  }
>  
>  static inline void free_thread_info(struct thread_info *ti)
>  {
> -	struct page *page = virt_to_page(ti);
> -
> -	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
> -				    -(1 << THREAD_SIZE_ORDER));
> -	__free_kmem_pages(page, THREAD_SIZE_ORDER);
> +	free_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
>  }
>  # else
>  static struct kmem_cache *thread_info_cache;
> @@ -227,6 +219,11 @@ static void account_kernel_stack(struct thread_info *ti, int account)
>  
>  	mod_zone_page_state(zone, NR_KERNEL_STACK_KB,
>  			    THREAD_SIZE / 1024 * account);
> +
> +	/* All stack pages belong to the same memcg. */
> +	memcg_kmem_update_page_stat(
> +		virt_to_page(ti), MEMCG_KERNEL_STACK_KB,
> +		account * (THREAD_SIZE / 1024));
>  }
>  
>  void free_task(struct task_struct *tsk)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 75e74408cc8f..8e13a2419dad 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5133,7 +5133,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  	seq_printf(m, "file %llu\n",
>  		   (u64)stat[MEM_CGROUP_STAT_CACHE] * PAGE_SIZE);
>  	seq_printf(m, "kernel_stack %llu\n",
> -		   (u64)stat[MEMCG_KERNEL_STACK] * PAGE_SIZE);
> +		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
>  	seq_printf(m, "slab %llu\n",
>  		   (u64)(stat[MEMCG_SLAB_RECLAIMABLE] +
>  			 stat[MEMCG_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
