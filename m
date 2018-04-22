Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D51CC6B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 13:17:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id f194-v6so2612605lfe.10
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 10:17:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65-v6sor2373275lfv.35.2018.04.22.10.16.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 10:16:59 -0700 (PDT)
Date: Sun, 22 Apr 2018 20:16:55 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 01/12] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180422171655.llxowifnxzpf5hee@esperanza>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399118252.3456.17590357803686895373.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152399118252.3456.17590357803686895373.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, Apr 17, 2018 at 09:53:02PM +0300, Kirill Tkhai wrote:
> The patch introduces shrinker::id number, which is used to enumerate
> memcg-aware shrinkers. The number start from 0, and the code tries
> to maintain it as small as possible.
> 
> This will be used as to represent a memcg-aware shrinkers in memcg
> shrinkers map.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/shrinker.h |    2 ++
>  mm/vmscan.c              |   51 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 53 insertions(+)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index a3894918a436..86b651fa2846 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -66,6 +66,8 @@ struct shrinker {
>  
>  	/* These are for internal use */
>  	struct list_head list;

> +	/* ID in shrinkers_id_idr */
> +	int id;

This should be under ifdef CONFIG_MEMCG && CONFIG_SLOB.

>  	/* objs pending delete, per node */
>  	atomic_long_t *nr_deferred;
>  };
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8b920ce3ae02..4f02fe83537e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -169,6 +169,43 @@ unsigned long vm_total_pages;
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)

> +static DEFINE_IDR(shrinkers_id_idr);

IMO shrinker_idr would be a better name.

> +
> +static int add_memcg_shrinker(struct shrinker *shrinker)
> +{
> +	int id, ret;
> +
> +	down_write(&shrinker_rwsem);
> +	ret = id = idr_alloc(&shrinkers_id_idr, shrinker, 0, 0, GFP_KERNEL);
> +	if (ret < 0)
> +		goto unlock;
> +	shrinker->id = id;
> +	ret = 0;
> +unlock:
> +	up_write(&shrinker_rwsem);
> +	return ret;
> +}
> +
> +static void del_memcg_shrinker(struct shrinker *shrinker)
> +{
> +	int id = shrinker->id;
> +
> +	down_write(&shrinker_rwsem);
> +	idr_remove(&shrinkers_id_idr, id);
> +	up_write(&shrinker_rwsem);
> +}
> +#else /* CONFIG_MEMCG && !CONFIG_SLOB */
> +static int add_memcg_shrinker(struct shrinker *shrinker)
> +{
> +	return 0;
> +}
> +
> +static void del_memcg_shrinker(struct shrinker *shrinker)
> +{
> +}
> +#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
> +
>  #ifdef CONFIG_MEMCG
>  static bool global_reclaim(struct scan_control *sc)
>  {
> @@ -306,6 +343,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
>  int register_shrinker(struct shrinker *shrinker)
>  {
>  	size_t size = sizeof(*shrinker->nr_deferred);
> +	int ret;
>  
>  	if (shrinker->flags & SHRINKER_NUMA_AWARE)
>  		size *= nr_node_ids;
> @@ -314,10 +352,21 @@ int register_shrinker(struct shrinker *shrinker)
>  	if (!shrinker->nr_deferred)
>  		return -ENOMEM;
>  
> +	if (shrinker->flags & SHRINKER_MEMCG_AWARE) {
> +		ret = add_memcg_shrinker(shrinker);
> +		if (ret)
> +			goto free_deferred;
> +	}
> +

This doesn't apply anymore, not after commit 8e04944f0ea8a ("mm,vmscan:
Allow preallocating memory for register_shrinker()"). Please rebase.

I guess now you have to allocate an id in prealloc_shrinker and set the
pointer (with idr_replace) in register_shrinker_prepared.

>  	down_write(&shrinker_rwsem);
>  	list_add_tail(&shrinker->list, &shrinker_list);
>  	up_write(&shrinker_rwsem);
>  	return 0;
> +
> +free_deferred:
> +	kfree(shrinker->nr_deferred);
> +	shrinker->nr_deferred = NULL;
> +	return -ENOMEM;
>  }
>  EXPORT_SYMBOL(register_shrinker);
>  
> @@ -328,6 +377,8 @@ void unregister_shrinker(struct shrinker *shrinker)
>  {
>  	if (!shrinker->nr_deferred)
>  		return;
> +	if (shrinker->flags & SHRINKER_MEMCG_AWARE)
> +		del_memcg_shrinker(shrinker);
>  	down_write(&shrinker_rwsem);
>  	list_del(&shrinker->list);
>  	up_write(&shrinker_rwsem);
> 
