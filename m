Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D95916B0292
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 14:56:19 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v20so13864042qtg.3
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 11:56:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f132sor1104583qkb.12.2017.06.09.11.56.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 11:56:18 -0700 (PDT)
Subject: Re: [PATCH 2/4] Protectable Memory Allocator
References: <20170607123505.16629-1-igor.stoppa@huawei.com>
 <20170607123505.16629-3-igor.stoppa@huawei.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <ace6f45a-2d21-9a00-fa74-518ac727074f@redhat.com>
Date: Fri, 9 Jun 2017 11:56:14 -0700
MIME-Version: 1.0
In-Reply-To: <20170607123505.16629-3-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/07/2017 05:35 AM, Igor Stoppa wrote:
> The MMU available in many systems running Linux can often provide R/O
> protection to the memory pages it handles.
> 
> However, the MMU-based protection works efficiently only when said pages
> contain only data that will not need further modifications.
> 
> Statically allocated variables can be segregated into a dedicated
> section, however this is not fit too well the case of dynamically
> allocated ones.
> 
> Dynamic allocation does not provide, currently, means for grouping
> variables in memory pages that would contain exclusively data that can
> be made read only.
> 
> The allocator here provided (pmalloc - protectable memory allocator)
> introduces the concept of pools of protectable memory.
> 
> A module can request a pool and then refer any allocation request to the
> pool handler it has received.
> 
> Once all the memory requested (over various iterations) is initialized,
> the pool can be protected.
> 
> After this point, the pool can only be destroyed (it is up to the module
> to avoid any further references to the memory from the pool, after
> the destruction is invoked).
> 
> The latter case is mainly meant for releasing memory, when a module is
> unloaded.
> 
> A module can have as many pools as needed, for example to support the
> protection of data that is initialized in sufficiently distinct phases.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  include/linux/page-flags.h     |   2 +
>  include/linux/pmalloc.h        |  20 ++++
>  include/trace/events/mmflags.h |   1 +
>  init/main.c                    |   2 +
>  mm/Makefile                    |   1 +
>  mm/pmalloc.c                   | 226 +++++++++++++++++++++++++++++++++++++++++
>  mm/usercopy.c                  |  24 +++--
>  7 files changed, 267 insertions(+), 9 deletions(-)
>  create mode 100644 include/linux/pmalloc.h
>  create mode 100644 mm/pmalloc.c
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 6b5818d..acc0723 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -81,6 +81,7 @@ enum pageflags {
>  	PG_active,
>  	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
>  	PG_slab,
> +	PG_pmalloc,
>  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
>  	PG_arch_1,
>  	PG_reserved,
> @@ -274,6 +275,7 @@ PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
>  	TESTCLEARFLAG(Active, active, PF_HEAD)
>  __PAGEFLAG(Slab, slab, PF_NO_TAIL)
>  __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
> +__PAGEFLAG(Pmalloc, pmalloc, PF_NO_TAIL)
>  PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
>  
>  /* Xen */
> diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
> new file mode 100644
> index 0000000..83d3557
> --- /dev/null
> +++ b/include/linux/pmalloc.h
> @@ -0,0 +1,20 @@
> +/*
> + * pmalloc.h: Header for Protectable Memory Allocator
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +
> +#ifndef _PMALLOC_H
> +#define _PMALLOC_H
> +
> +struct pmalloc_pool *pmalloc_create_pool(const char *name);
> +void *pmalloc(unsigned long size, struct pmalloc_pool *pool);
> +int pmalloc_protect_pool(struct pmalloc_pool *pool);
> +int pmalloc_destroy_pool(struct pmalloc_pool *pool);
> +#endif
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 304ff94..41d1587 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -91,6 +91,7 @@
>  	{1UL << PG_lru,			"lru"		},		\
>  	{1UL << PG_active,		"active"	},		\
>  	{1UL << PG_slab,		"slab"		},		\
> +	{1UL << PG_pmalloc,		"pmalloc"	},		\
>  	{1UL << PG_owner_priv_1,	"owner_priv_1"	},		\
>  	{1UL << PG_arch_1,		"arch_1"	},		\
>  	{1UL << PG_reserved,		"reserved"	},		\
> diff --git a/init/main.c b/init/main.c
> index f866510..7850887 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -485,6 +485,7 @@ static void __init mm_init(void)
>  	ioremap_huge_init();
>  }
>  
> +extern int __init pmalloc_init(void);
>  asmlinkage __visible void __init start_kernel(void)
>  {
>  	char *command_line;
> @@ -653,6 +654,7 @@ asmlinkage __visible void __init start_kernel(void)
>  	proc_caches_init();
>  	buffer_init();
>  	key_init();
> +	pmalloc_init();
>  	security_init();
>  	dbg_late_init();
>  	vfs_caches_init();
> diff --git a/mm/Makefile b/mm/Makefile
> index 026f6a8..b47dcf8 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -65,6 +65,7 @@ obj-$(CONFIG_SPARSEMEM)	+= sparse.o
>  obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
>  obj-$(CONFIG_SLOB) += slob.o
>  obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
> +obj-$(CONFIG_ARCH_HAS_SET_MEMORY) += pmalloc.o
>  obj-$(CONFIG_KSM) += ksm.o
>  obj-$(CONFIG_PAGE_POISONING) += page_poison.o
>  obj-$(CONFIG_SLAB) += slab.o
> diff --git a/mm/pmalloc.c b/mm/pmalloc.c
> new file mode 100644
> index 0000000..8050dea
> --- /dev/null
> +++ b/mm/pmalloc.c
> @@ -0,0 +1,226 @@
> +/*
> + * pmalloc.c: Protectable Memory Allocator
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@huawei.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +
> +#include <linux/printk.h>
> +#include <linux/init.h>
> +#include <linux/mm.h>
> +#include <linux/vmalloc.h>
> +#include <linux/list.h>
> +#include <linux/rculist.h>
> +#include <linux/mutex.h>
> +#include <linux/atomic.h>
> +#include <asm/set_memory.h>
> +#include <asm/page.h>
> +
> +typedef unsigned long align_t;
> +#define WORD_SIZE sizeof(unsigned long)
> +
> +#define __PMALLOC_ALIGNED __aligned(WORD_SIZE)
> +
> +#define MAX_POOL_NAME_LEN 20
> +
> +struct pmalloc_data {
> +	struct hlist_head pools_list_head;
> +	struct mutex pools_list_mutex;
> +	atomic_t pools_count;
> +};
> +
> +struct pmalloc_pool {
> +	struct hlist_node pools_list;
> +	struct hlist_head nodes_list_head;
> +	struct mutex nodes_list_mutex;
> +	atomic_t nodes_count;
> +	atomic_t protected;
> +	char name[MAX_POOL_NAME_LEN];
> +};
> +
> +struct pmalloc_node {
> +	struct hlist_node nodes_list;
> +	atomic_t used_words;
> +	unsigned int total_words;
> +	__PMALLOC_ALIGNED align_t data[];
> +};
> +
> +#define HEADER_SIZE sizeof(struct pmalloc_node)
> +
> +static struct pmalloc_data *pmalloc_data;
> +
> +static struct pmalloc_node *__pmalloc_create_node(int words)
> +{
> +	struct pmalloc_node *node;
> +	unsigned long size, i, pages;
> +	struct page *p;
> +
> +	size = roundup(HEADER_SIZE + WORD_SIZE * words, PAGE_SIZE);
> +	node = vmalloc(size);
> +	if (!node)
> +		return NULL;
> +	atomic_set(&node->used_words, 0);
> +	node->total_words = (size - HEADER_SIZE) / WORD_SIZE;
> +	pages = size / PAGE_SIZE;
> +	for (i = 0; i < pages; i++) {
> +		p = vmalloc_to_page((void *)(i * PAGE_SIZE +
> +					     (unsigned long)node));
> +		__SetPagePmalloc(p);
> +	}
> +	return node;
> +}
> +
> +void *pmalloc(unsigned long size, struct pmalloc_pool *pool)
> +{
> +	struct pmalloc_node *node;
> +	int req_words;
> +	int starting_word;
> +
> +	if (size > INT_MAX || size == 0 ||
> +	    !pool || atomic_read(&pool->protected))
> +		return NULL;
> +	req_words = roundup(size, WORD_SIZE) / WORD_SIZE;
> +	rcu_read_lock();
> +	hlist_for_each_entry_rcu(node, &pool->nodes_list_head, nodes_list) {
> +		starting_word = atomic_fetch_add(req_words, &node->used_words);
> +		if (starting_word + req_words > node->total_words) {
> +			atomic_sub(req_words, &node->used_words);
> +		} else {
> +			rcu_read_unlock();
> +			return node->data + starting_word;
> +		}
> +	}
> +	rcu_read_unlock();
> +	node = __pmalloc_create_node(req_words);
> +	if (!node)
> +		return NULL;
> +	starting_word = atomic_fetch_add(req_words, &node->used_words);
> +	mutex_lock(&pool->nodes_list_mutex);
> +	hlist_add_head_rcu(&node->nodes_list, &pool->nodes_list_head);
> +	mutex_unlock(&pool->nodes_list_mutex);
> +	synchronize_rcu();
> +	atomic_inc(&pool->nodes_count);
> +	return node->data + starting_word;
> +}

The pool logic looks remarkably similar to genalloc (lib/genalloc.c).
It's not a perfect 1-to-1 mapping but it's close enough to be worth
a look.

> +
> +const char msg[] = "Not a valid Pmalloc object.";
> +const char *__pmalloc_check_object(const void *ptr, unsigned long n)
> +{
> +	unsigned long p;
> +
> +	p = (unsigned long)ptr;
> +	n = p + n - 1;
> +	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
> +		if (is_vmalloc_addr((void *)p)) {
> +			struct page *page;
> +
> +			page = vmalloc_to_page((void *)p);
> +			if (!(page && PagePmalloc(page)))
> +				return msg;
> +		}

Should this be an error if is_vmalloc_addr returns false?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
