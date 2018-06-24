Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40FBF6B000A
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 16:09:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a131-v6so3367182lfe.1
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 13:09:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w3-v6sor2546700ljh.32.2018.06.24.13.09.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Jun 2018 13:09:10 -0700 (PDT)
Date: Sun, 24 Jun 2018 23:09:07 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 3/3] mm: list_lru: Add lock_irq member to
 __list_lru_init()
Message-ID: <20180624200907.ufjxk6l2biz6xcm2@esperanza>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-4-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622151221.28167-4-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 22, 2018 at 05:12:21PM +0200, Sebastian Andrzej Siewior wrote:
> scan_shadow_nodes() is the only user of __list_lru_walk_one() which
> disables interrupts before invoking it. The reason is that nlru->lock is
> nesting inside IRQ-safe i_pages lock. Some functions unconditionally
> acquire the lock with the _irq() suffix.
> 
> __list_lru_walk_one() can't acquire the lock unconditionally with _irq()
> suffix because it might invoke a callback which unlocks the nlru->lock
> and invokes a sleeping function without enabling interrupts.
> 
> Add an argument to __list_lru_init() which identifies wheather the
> nlru->lock needs to be acquired with disabling interrupts or without.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  include/linux/list_lru.h | 12 ++++++++----
>  mm/list_lru.c            | 14 ++++++++++----
>  mm/workingset.c          | 12 ++++--------
>  3 files changed, 22 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 96def9d15b1b..c2161c3a1809 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -51,18 +51,22 @@ struct list_lru_node {
>  
>  struct list_lru {
>  	struct list_lru_node	*node;
> +	bool			lock_irq;
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>  	struct list_head	list;
>  #endif
>  };

TBO I don't like this patch, because the new member of struct list_lru,
lock_irq, has rather obscure meaning IMHO: it makes list_lru_walk
disable irq before taking lru_lock, but at the same time list_lru_add
and list_lru_del never do that, no matter whether lock_irq is true or
false. That is, if a user of struct list_lru sets this flag, he's
supposed to disable irq for list_lru_add/del by himself (mm/workingset
does that). IMHO the code of mm/workingset is clear as it is. Since it
is the only place where this flag is used, I'd rather leave it as is.

>  
>  void list_lru_destroy(struct list_lru *lru);
> -int __list_lru_init(struct list_lru *lru, bool memcg_aware,
> +int __list_lru_init(struct list_lru *lru, bool memcg_aware, bool lock_irq,
>  		    struct lock_class_key *key);
>  
> -#define list_lru_init(lru)		__list_lru_init((lru), false, NULL)
> -#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, (key))
> -#define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
> +#define list_lru_init(lru)		__list_lru_init((lru), false, false, \
> +							NULL)
> +#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, false, \
> +							(key))
> +#define list_lru_init_memcg(lru)	__list_lru_init((lru), true, false, \
> +							NULL)
>  
>  int memcg_update_all_list_lrus(int num_memcgs);
>  void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index fcfb6c89ed47..1c49d48078e4 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -204,7 +204,10 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int memcg_idx,
>  	struct list_head *item, *n;
>  	unsigned long isolated = 0;
>  
> -	spin_lock(&nlru->lock);
> +	if (lru->lock_irq)
> +		spin_lock_irq(&nlru->lock);
> +	else
> +		spin_lock(&nlru->lock);
>  	l = list_lru_from_memcg_idx(nlru, memcg_idx);
>  restart:
>  	list_for_each_safe(item, n, &l->list) {
> @@ -251,7 +254,10 @@ __list_lru_walk_one(struct list_lru *lru, int nid, int memcg_idx,
>  		}
>  	}
>  
> -	spin_unlock(&nlru->lock);
> +	if (lru->lock_irq)
> +		spin_unlock_irq(&nlru->lock);
> +	else
> +		spin_unlock(&nlru->lock);
>  	return isolated;
>  }
>  
> @@ -553,7 +559,7 @@ static void memcg_destroy_list_lru(struct list_lru *lru)
>  }
>  #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>  
> -int __list_lru_init(struct list_lru *lru, bool memcg_aware,
> +int __list_lru_init(struct list_lru *lru, bool memcg_aware, bool lock_irq,
>  		    struct lock_class_key *key)
>  {
>  	int i;
> @@ -580,7 +586,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
>  		lru->node = NULL;
>  		goto out;
>  	}
> -
> +	lru->lock_irq = lock_irq;
>  	list_lru_register(lru);
>  out:
>  	memcg_put_cache_ids();
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 529480c21f93..23ce00f48212 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -480,13 +480,8 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
>  static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
>  				       struct shrink_control *sc)
>  {
> -	unsigned long ret;
> -
> -	/* list_lru lock nests inside the IRQ-safe i_pages lock */
> -	local_irq_disable();
> -	ret = list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate, NULL);
> -	local_irq_enable();
> -	return ret;
> +	return list_lru_shrink_walk(&shadow_nodes, sc, shadow_lru_isolate,
> +				    NULL);
>  }
>  
>  static struct shrinker workingset_shadow_shrinker = {
> @@ -523,7 +518,8 @@ static int __init workingset_init(void)
>  	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
>  	       timestamp_bits, max_order, bucket_order);
>  
> -	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
> +	/* list_lru lock nests inside the IRQ-safe i_pages lock */
> +	ret = __list_lru_init(&shadow_nodes, true, true, &shadow_nodes_key);
>  	if (ret)
>  		goto err;
>  	ret = register_shrinker(&workingset_shadow_shrinker);
