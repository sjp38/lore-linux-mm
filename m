Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0560C6B02C3
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 00:47:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u8so70895294pgo.11
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 21:47:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z3si13684838pfl.319.2017.06.05.21.46.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 21:47:00 -0700 (PDT)
Message-Id: <201706060444.v564iWds024768@www262.sakura.ne.jp>
Subject: Re: [PATCH 2/5] Protectable Memory Allocator
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 06 Jun 2017 13:44:32 +0900
References: <20170605192216.21596-1-igor.stoppa@huawei.com> <20170605192216.21596-3-igor.stoppa@huawei.com>
In-Reply-To: <20170605192216.21596-3-igor.stoppa@huawei.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Igor Stoppa wrote:
> +int pmalloc_protect_pool(struct pmalloc_pool *pool)
> +{
> +	struct pmalloc_node *node;
> +
> +	if (!pool)
> +		return -EINVAL;
> +	mutex_lock(&pool->nodes_list_mutex);
> +	hlist_for_each_entry(node, &pool->nodes_list_head, nodes_list) {
> +		unsigned long size, pages;
> +
> +		size = WORD_SIZE * node->total_words + HEADER_SIZE;
> +		pages = size / PAGE_SIZE;
> +		set_memory_ro((unsigned long)node, pages);
> +	}
> +	pool->protected = true;
> +	mutex_unlock(&pool->nodes_list_mutex);
> +	return 0;
> +}

As far as I know, not all CONFIG_MMU=y architectures provide
set_memory_ro()/set_memory_rw(). You need to provide fallback for
architectures which do not provide set_memory_ro()/set_memory_rw()
or kernels built with CONFIG_MMU=n.

>  mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
>  			   mlock.o mmap.o mprotect.o mremap.o msync.o \
>  			   page_vma_mapped.o pagewalk.o pgtable-generic.o \
> -			   rmap.o vmalloc.o
> +			   rmap.o vmalloc.o pmalloc.o



Is this __PMALLOC_ALIGNED needed? Why not use "long" and "BITS_PER_LONG" ?

> +struct pmalloc_node {
> +	struct hlist_node nodes_list;
> +	atomic_t used_words;
> +	unsigned int total_words;
> +	__PMALLOC_ALIGNED align_t data[];
> +};



Please use macros for round up/down.

> +	size = ((HEADER_SIZE - 1 + PAGE_SIZE) +
> +		WORD_SIZE * (unsigned long) words) & PAGE_MASK;

> +	req_words = (((int)size) + WORD_SIZE - 1) / WORD_SIZE;



You need to check for node != NULL before dereference it.
Also, why rcu_read_lock()/rcu_read_unlock() ? 
I can't find corresponding synchronize_rcu() etc. in this patch.
pmalloc() won't be hotpath. Enclosing whole using a mutex might be OK.
If any reason to use rcu, rcu_read_unlock() is missing if came from "goto".

+void *pmalloc(unsigned long size, struct pmalloc_pool *pool)
+{
+	struct pmalloc_node *node;
+	int req_words;
+	int starting_word;
+
+	if (size > INT_MAX || size == 0)
+		return NULL;
+	req_words = (((int)size) + WORD_SIZE - 1) / WORD_SIZE;
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(node, &pool->nodes_list_head, nodes_list) {
+		starting_word = atomic_fetch_add(req_words, &node->used_words);
+		if (starting_word + req_words > node->total_words)
+			atomic_sub(req_words, &node->used_words);
+		else
+			goto found_node;
+	}
+	rcu_read_unlock();
+	node = __pmalloc_create_node(req_words);
+	starting_word = atomic_fetch_add(req_words, &node->used_words);
+	mutex_lock(&pool->nodes_list_mutex);
+	hlist_add_head_rcu(&node->nodes_list, &pool->nodes_list_head);
+	mutex_unlock(&pool->nodes_list_mutex);
+	atomic_inc(&pool->nodes_count);
+found_node:
+	return node->data + starting_word;
+}



I feel that n is off-by-one if (ptr + n) % PAGE_SIZE == 0
according to check_page_span().

> +const char *__pmalloc_check_object(const void *ptr, unsigned long n)
> +{
> +	unsigned long p;
> +
> +	p = (unsigned long)ptr;
> +	n += (unsigned long)ptr;
> +	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
> +		if (is_vmalloc_addr((void *)p)) {
> +			struct page *page;
> +
> +			page = vmalloc_to_page((void *)p);
> +			if (!(page && PagePmalloc(page)))
> +				return msg;
> +		}
> +	}
> +	return NULL;
> +}



Why need to call pmalloc_init() from loadable kernel module?
It has to be called very early stage of boot for only once.

> +int __init pmalloc_init(void)
> +{
> +	pmalloc_data = vmalloc(sizeof(struct pmalloc_data));
> +	if (!pmalloc_data)
> +		return -ENOMEM;
> +	INIT_HLIST_HEAD(&pmalloc_data->pools_list_head);
> +	mutex_init(&pmalloc_data->pools_list_mutex);
> +	atomic_set(&pmalloc_data->pools_count, 0);
> +	return 0;
> +}
> +EXPORT_SYMBOL(pmalloc_init);

Since pmalloc_data is a globally shared variable, why need to
allocate it dynamically? If it is for randomizing the address
of pmalloc_data, it does not make sense to continue because
vmalloc() failure causes subsequent oops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
