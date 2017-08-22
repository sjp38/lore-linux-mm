Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58FEF28071E
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:34:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k186so6488586lfe.6
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:34:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l9sor357358lfg.14.2017.08.22.12.34.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Aug 2017 12:34:08 -0700 (PDT)
Date: Tue, 22 Aug 2017 22:34:05 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/3] mm: Make list_lru_node::memcg_lrus RCU protected
Message-ID: <20170822193405.qxixggl3kwlmronh@esperanza>
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
 <150340496641.3845.291357513974178821.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150340496641.3845.291357513974178821.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com, akpm@linux-foundation.org

Hello Kirill,

On Tue, Aug 22, 2017 at 03:29:26PM +0300, Kirill Tkhai wrote:
> The array list_lru_node::memcg_lrus::list_lru_one[] only grows,
> and it never shrinks. The growths happens in memcg_update_list_lru_node(),
> and old array's members remain the same after it.
> 
> So, the access to the array's members may become RCU protected,
> and it's possible to avoid using list_lru_node::lock to dereference it.
> This will be used to get list's nr_items in next patch lockless.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

The patch looks very nice. A few really minor comments below.

First, I don't think it's worth splitting this patch in three: patch #1
introduces a structure member that is only used in patch #2, while patch
#2 adds RCU protection, but nobody benefits from it until patch #3 is
applied. Since patches #1 and #3 are tiny, why don't you fold them in
patch #2?

> diff --git a/mm/list_lru.c b/mm/list_lru.c
> @@ -42,24 +42,30 @@ static void list_lru_unregister(struct list_lru *lru)
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> +	struct list_lru_memcg *memcg_lrus;
>  	/*
>  	 * This needs node 0 to be always present, even
>  	 * in the systems supporting sparse numa ids.
> +	 *
> +	 * Here we only check the pointer is not NULL,
> +	 * so RCU lock is not need.
>  	 */
> -	return !!lru->node[0].memcg_lrus;
> +	memcg_lrus = rcu_dereference_check(lru->node[0].memcg_lrus, true);
> +	return !!memcg_lrus;

IIRC you don't need rcu_dereference() here, because you don't actually
dereference anything. The compiler shouldn't complain if you leaved this
as is.

>  }
>  
>  static inline struct list_lru_one *
>  list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
>  {
> +	struct list_lru_memcg *memcg_lrus;
>  	/*
> -	 * The lock protects the array of per cgroup lists from relocation
> -	 * (see memcg_update_list_lru_node).
> +	 * Either lock and RCU protects the array of per cgroup lists

Typo: s/and/or/

> +	 * from relocation (see memcg_update_list_lru_node).
>  	 */
> -	lockdep_assert_held(&nlru->lock);
> -	if (nlru->memcg_lrus && idx >= 0)
> -		return nlru->memcg_lrus->lru[idx];
> -
> +	memcg_lrus = rcu_dereference_check(nlru->memcg_lrus,
> +					   lockdep_is_held(&nlru->lock));
> +	if (memcg_lrus && idx >= 0)
> +		return memcg_lrus->lru[idx];
>  	return &nlru->lru;
>  }
>  
> @@ -76,9 +82,12 @@ static __always_inline struct mem_cgroup *mem_cgroup_from_kmem(void *ptr)
>  static inline struct list_lru_one *
>  list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
>  {
> +	struct list_lru_memcg *memcg_lrus;
>  	struct mem_cgroup *memcg;
>  
> -	if (!nlru->memcg_lrus)
> +	/* Here we only check the pointer is not NULL, so RCU lock isn't need */
> +	memcg_lrus = rcu_dereference_check(nlru->memcg_lrus, true);
> +	if (!memcg_lrus)

Again, rcu_dereference() is redundant.

>  		return &nlru->lru;
>  
>  	memcg = mem_cgroup_from_kmem(ptr);
> @@ -323,25 +332,33 @@ static int __memcg_init_list_lru_node(struct list_lru_memcg *memcg_lrus,
>  
>  static int memcg_init_list_lru_node(struct list_lru_node *nlru)
>  {
> +	struct list_lru_memcg *memcg_lrus;
>  	int size = memcg_nr_cache_ids;
>  
> -	nlru->memcg_lrus = kmalloc(sizeof(struct list_lru_memcg) +
> -				   size * sizeof(void *), GFP_KERNEL);
> -	if (!nlru->memcg_lrus)
> +	memcg_lrus = kmalloc(sizeof(*memcg_lrus) +
> +			     size * sizeof(void *), GFP_KERNEL);
> +	if (!memcg_lrus)
>  		return -ENOMEM;
>  
> -	if (__memcg_init_list_lru_node(nlru->memcg_lrus, 0, size)) {
> -		kfree(nlru->memcg_lrus);
> +	if (__memcg_init_list_lru_node(memcg_lrus, 0, size)) {
> +		kfree(memcg_lrus);
>  		return -ENOMEM;
>  	}
> +	rcu_assign_pointer(nlru->memcg_lrus, memcg_lrus);

You don't need a memory barrier here, so RCU_INIT_POINTER() would fit
better.

>  
>  	return 0;
>  }
>  
>  static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
>  {
> -	__memcg_destroy_list_lru_node(nlru->memcg_lrus, 0, memcg_nr_cache_ids);
> -	kfree(nlru->memcg_lrus);
> +	struct list_lru_memcg *memcg_lrus;
> +	/*
> +	 * This is called when shrinker has already been unregistered,

> +	 * and nobody can use it. So, it's not need to use kfree_rcu().

Typo: s/it's not need/there's no need/

> +	 */
> +	memcg_lrus = rcu_dereference_check(nlru->memcg_lrus, true);

IIRC there's rcu_dereference_protected() for cases when you don't
expect any changes to an __rcu variable. Let's use it instead of
rcu_dereference_check() where appropriate.

> +	__memcg_destroy_list_lru_node(memcg_lrus, 0, memcg_nr_cache_ids);
> +	kfree(memcg_lrus);
>  }
>  
>  static int memcg_update_list_lru_node(struct list_lru_node *nlru,
> @@ -350,8 +367,10 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>  	struct list_lru_memcg *old, *new;
>  
>  	BUG_ON(old_size > new_size);
> +	lockdep_assert_held(&list_lrus_mutex);
>  
> -	old = nlru->memcg_lrus;
> +	/* list_lrus_mutex is held, nobody can change memcg_lrus. Silence RCU */

> +	old = rcu_dereference_check(nlru->memcg_lrus, true);

s/rcu_dereference_check/rcu_dereference_protected/

>  	new = kmalloc(sizeof(*new) + new_size * sizeof(void *), GFP_KERNEL);
>  	if (!new)
>  		return -ENOMEM;
> @@ -364,26 +383,31 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>  	memcpy(&new->lru, &old->lru, old_size * sizeof(void *));
>  
>  	/*
> -	 * The lock guarantees that we won't race with a reader
> -	 * (see list_lru_from_memcg_idx).

> +	 * The locking below allows the readers, that already take nlru->lock,
> +	 * not to use additional rcu_read_lock()/rcu_read_unlock() pair.

Rephrase a little bit?

    The locking below allows readers that hold nlru->lock avoid taking
    rcu_read_lock (see list_lru_from_memcg_idx).

>  	 *
>  	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
>  	 * we have to use IRQ-safe primitives here to avoid deadlock.
>  	 */
>  	spin_lock_irq(&nlru->lock);
> -	nlru->memcg_lrus = new;
> +	rcu_assign_pointer(nlru->memcg_lrus, new);
>  	spin_unlock_irq(&nlru->lock);
>  
> -	kfree(old);
> +	kfree_rcu(old, rcu);
>  	return 0;
>  }
>  
>  static void memcg_cancel_update_list_lru_node(struct list_lru_node *nlru,
>  					      int old_size, int new_size)
>  {
> +	struct list_lru_memcg *memcg_lrus;
> +
> +	lockdep_assert_held(&list_lrus_mutex);
> +	memcg_lrus = rcu_dereference_check(nlru->memcg_lrus, true);

s/rcu_dereference_check/rcu_dereference_protected/

> +
>  	/* do not bother shrinking the array back to the old size, because we
>  	 * cannot handle allocation failures here */
> -	__memcg_destroy_list_lru_node(nlru->memcg_lrus, old_size, new_size);
> +	__memcg_destroy_list_lru_node(memcg_lrus, old_size, new_size);
>  }
>  
>  static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
> @@ -400,7 +424,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
>  	return 0;
>  fail:
>  	for (i = i - 1; i >= 0; i--) {
> -		if (!lru->node[i].memcg_lrus)
> +		if (!rcu_dereference_check(lru->node[i].memcg_lrus, true))

No need in rcu_dereference() here as you don't actually dereference
anything.

>  			continue;
>  		memcg_destroy_list_lru_node(&lru->node[i]);
>  	}
> @@ -434,7 +458,7 @@ static int memcg_update_list_lru(struct list_lru *lru,
>  	return 0;
>  fail:
>  	for (i = i - 1; i >= 0; i--) {
> -		if (!lru->node[i].memcg_lrus)
> +		if (!rcu_dereference_check(lru->node[i].memcg_lrus, true))

Ditto.

>  			continue;
>  
>  		memcg_cancel_update_list_lru_node(&lru->node[i],
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
