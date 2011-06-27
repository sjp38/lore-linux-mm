Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 191206B00FC
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 12:06:42 -0400 (EDT)
Date: Mon, 27 Jun 2011 12:06:22 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] drivers/staging/zcache: support multiple clients, prep
 for RAMster and KVM
Message-ID: <20110627160622.GM6978@dumpdata.com>
References: <cc182d60-216c-4ab5-8fcd-b61cedc4fbd4@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc182d60-216c-4ab5-8fcd-b61cedc4fbd4@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@linuxdriverproject.org, linux-mm <linux-mm@kvack.org>, kvm@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>

> @@ -503,15 +529,13 @@ static void tmem_pampd_destroy_all_in_ob
>   * always flushes for simplicity.
>   */
>  int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
> -		struct page *page)
> +		char *data, size_t size, bool raw, int ephemeral)

why not make ephemeral bool?

>  {
>  	struct tmem_obj *obj = NULL, *objfound = NULL, *objnew = NULL;
>  	void *pampd = NULL, *pampd_del = NULL;
>  	int ret = -ENOMEM;
> -	bool ephemeral;
>  	struct tmem_hashbucket *hb;
>  
> -	ephemeral = is_ephemeral(pool);
>  	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
>  	spin_lock(&hb->lock);
>  	obj = objfound = tmem_obj_find(hb, oidp);
> @@ -521,7 +545,7 @@ int tmem_put(struct tmem_pool *pool, str
>  			/* if found, is a dup put, flush the old one */
>  			pampd_del = tmem_pampd_delete_from_obj(obj, index);
>  			BUG_ON(pampd_del != pampd);
> -			(*tmem_pamops.free)(pampd, pool);
> +			(*tmem_pamops.free)(pampd, pool, oidp, index);
>  			if (obj->pampd_count == 0) {
>  				objnew = obj;
>  				objfound = NULL;
> @@ -538,7 +562,8 @@ int tmem_put(struct tmem_pool *pool, str
>  	}
>  	BUG_ON(obj == NULL);
>  	BUG_ON(((objnew != obj) && (objfound != obj)) || (objnew == objfound));
> -	pampd = (*tmem_pamops.create)(obj->pool, &obj->oid, index, page);
> +	pampd = (*tmem_pamops.create)(data, size, raw, ephemeral,
> +					obj->pool, &obj->oid, index);
>  	if (unlikely(pampd == NULL))
>  		goto free;
>  	ret = tmem_pampd_add_to_obj(obj, index, pampd);
> @@ -551,7 +576,7 @@ delete_and_free:
>  	(void)tmem_pampd_delete_from_obj(obj, index);
>  free:
>  	if (pampd)
> -		(*tmem_pamops.free)(pampd, pool);
> +		(*tmem_pamops.free)(pampd, pool, NULL, 0);
>  	if (objnew) {
>  		tmem_obj_free(objnew, hb);
>  		(*tmem_hostops.obj_free)(objnew, pool);
> @@ -573,41 +598,52 @@ out:
>   * "put" done with the same handle).
>  
>   */
> -int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp,
> -				uint32_t index, struct page *page)
> +int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
> +		char *data, size_t *size, bool raw, int get_and_free)

And also here.. make get_and_free be bool?

>  {
>  	struct tmem_obj *obj;
>  	void *pampd;
>  	bool ephemeral = is_ephemeral(pool);
>  	uint32_t ret = -1;
>  	struct tmem_hashbucket *hb;
> +	bool free = (get_and_free == 1) || ((get_and_free == 0) && ephemeral);
> +	bool lock_held = 0;
>  
>  	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
>  	spin_lock(&hb->lock);
> +	lock_held = 1;

true, not 1.

>  	obj = tmem_obj_find(hb, oidp);
>  	if (obj == NULL)
>  		goto out;
> -	ephemeral = is_ephemeral(pool);
> -	if (ephemeral)
> +	if (free)
>  		pampd = tmem_pampd_delete_from_obj(obj, index);
>  	else
>  		pampd = tmem_pampd_lookup_in_obj(obj, index);
>  	if (pampd == NULL)
>  		goto out;
> -	ret = (*tmem_pamops.get_data)(page, pampd, pool);
> -	if (ret < 0)
> -		goto out;
> -	if (ephemeral) {
> -		(*tmem_pamops.free)(pampd, pool);
> +	if (free) {
>  		if (obj->pampd_count == 0) {
>  			tmem_obj_free(obj, hb);
>  			(*tmem_hostops.obj_free)(obj, pool);
>  			obj = NULL;
>  		}
>  	}
> +	if (tmem_pamops.is_remote(pampd)) {
> +		lock_held = 0;

false.
> +		spin_unlock(&hb->lock);
> +	}
> +	if (free)
> +		ret = (*tmem_pamops.get_data_and_free)(
> +				data, size, raw, pampd, pool, oidp, index);
> +	else
> +		ret = (*tmem_pamops.get_data)(
> +				data, size, raw, pampd, pool, oidp, index);
> +	if (ret < 0)
> +		goto out;
>  	ret = 0;
>  out:
> -	spin_unlock(&hb->lock);
> +	if (lock_held)
> +		spin_unlock(&hb->lock);
>  	return ret;
>  }
>  
> @@ -632,7 +668,7 @@ int tmem_flush_page(struct tmem_pool *po
>  	pampd = tmem_pampd_delete_from_obj(obj, index);
>  	if (pampd == NULL)
>  		goto out;
> -	(*tmem_pamops.free)(pampd, pool);
> +	(*tmem_pamops.free)(pampd, pool, oidp, index);
>  	if (obj->pampd_count == 0) {
>  		tmem_obj_free(obj, hb);
>  		(*tmem_hostops.obj_free)(obj, pool);
> @@ -645,6 +681,30 @@ out:
>  }
>  
>  /*
> + * If a page in tmem matches the handle, replace the page so that any
> + * subsequent "get" gets the new page.  Returns the new page if
> + * there was a page to replace, else returns NULL.

uh, you return -1 not NULL.
> + */
> +int tmem_replace(struct tmem_pool *pool, struct tmem_oid *oidp,
> +			uint32_t index, void *new_pampd)
> +{
> +	struct tmem_obj *obj;
> +	int ret = -1;
> +	struct tmem_hashbucket *hb;
> +
> +	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
> +	spin_lock(&hb->lock);
> +	obj = tmem_obj_find(hb, oidp);
> +	if (obj == NULL)
> +		goto out;
> +	new_pampd = tmem_pampd_replace_in_obj(obj, index, new_pampd);
> +	ret = (*tmem_pamops.replace_in_obj)(new_pampd, obj);
> +out:
> +	spin_unlock(&hb->lock);
> +	return ret;
> +}
> +
> +/*
>   * "Flush" all pages in tmem matching this oid.
>   */
>  int tmem_flush_object(struct tmem_pool *pool, struct tmem_oid *oidp)
> diff -Napur -X linux-3.0-rc1/Documentation/dontdiff linux-3.0-rc4/drivers/staging/zcache/tmem.h linux-3.0-rc4-zcache/drivers/staging/zcache/tmem.h
> --- linux-3.0-rc4/drivers/staging/zcache/tmem.h	2011-06-20 21:25:46.000000000 -0600
> +++ linux-3.0-rc4-zcache/drivers/staging/zcache/tmem.h	2011-06-25 15:43:20.236906477 -0600
> @@ -147,6 +147,7 @@ struct tmem_obj {
>  	unsigned int objnode_tree_height;
>  	unsigned long objnode_count;
>  	long pampd_count;
> +	void *extra; /* for private use by pampd implementation */
>  	DECL_SENTINEL
>  };
>  
> @@ -166,10 +167,18 @@ struct tmem_objnode {
>  
>  /* pampd abstract datatype methods provided by the PAM implementation */
>  struct tmem_pamops {
> -	void *(*create)(struct tmem_pool *, struct tmem_oid *, uint32_t,
> -			struct page *);
> -	int (*get_data)(struct page *, void *, struct tmem_pool *);
> -	void (*free)(void *, struct tmem_pool *);
> +	void *(*create)(char *, size_t, bool, int,
> +			struct tmem_pool *, struct tmem_oid *, uint32_t);
> +	int (*get_data)(char *, size_t *, bool, void *, struct tmem_pool *,
> +				struct tmem_oid *, uint32_t);
> +	int (*get_data_and_free)(char *, size_t *, bool, void *,
> +				struct tmem_pool *, struct tmem_oid *,
> +				uint32_t);
> +	void (*free)(void *, struct tmem_pool *, struct tmem_oid *, uint32_t);
> +	void (*free_obj)(struct tmem_pool *, struct tmem_obj *);
> +	bool (*is_remote)(void *);
> +	void (*new_obj)(struct tmem_obj *);
> +	int (*replace_in_obj)(void *, struct tmem_obj *);
>  };
>  extern void tmem_register_pamops(struct tmem_pamops *m);
>  
> @@ -184,9 +193,11 @@ extern void tmem_register_hostops(struct
>  
>  /* core tmem accessor functions */
>  extern int tmem_put(struct tmem_pool *, struct tmem_oid *, uint32_t index,
> -			struct page *page);
> +			char *, size_t, bool, int);
>  extern int tmem_get(struct tmem_pool *, struct tmem_oid *, uint32_t index,
> -			struct page *page);
> +			char *, size_t *, bool, int);
> +extern int tmem_replace(struct tmem_pool *, struct tmem_oid *, uint32_t index,
> +			void *);
>  extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
>  			uint32_t index);
>  extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
> diff -Napur -X linux-3.0-rc1/Documentation/dontdiff linux-3.0-rc4/drivers/staging/zcache/zcache.c linux-3.0-rc4-zcache/drivers/staging/zcache/zcache.c
> --- linux-3.0-rc4/drivers/staging/zcache/zcache.c	2011-06-20 21:25:46.000000000 -0600
> +++ linux-3.0-rc4-zcache/drivers/staging/zcache/zcache.c	2011-06-25 15:45:55.016705466 -0600
> @@ -49,6 +49,32 @@
>  	(__GFP_FS | __GFP_NORETRY | __GFP_NOWARN | __GFP_NOMEMALLOC)
>  #endif
>  
> +#define MAX_POOLS_PER_CLIENT 16
> +
> +#define MAX_CLIENTS 16
> +#define LOCAL_CLIENT ((uint16_t)-1)
> +struct zcache_client {
> +	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
> +	struct xv_pool *xvpool;
> +	bool allocated;
> +	atomic_t refcount;
> +};
> +
> +static struct zcache_client zcache_host;
> +static struct zcache_client zcache_clients[MAX_CLIENTS];
> +
> +static inline uint16_t get_client_id_from_client(struct zcache_client *cli)
> +{
> +	if (cli == &zcache_host)
> +		return LOCAL_CLIENT;

What if cli is NULL?

> +	return cli - &zcache_clients[0];
> +}
> +
> +static inline bool is_local_client(struct zcache_client *cli)
> +{
> +	return cli == &zcache_host;
> +}
> +
>  /**********
>   * Compression buddies ("zbud") provides for packing two (or, possibly
>   * in the future, more) compressed ephemeral pages into a single "raw"
> @@ -72,7 +98,8 @@
>  #define ZBUD_MAX_BUDS 2
>  
>  struct zbud_hdr {
> -	uint32_t pool_id;
> +	uint16_t client_id;
> +	uint16_t pool_id;
>  	struct tmem_oid oid;
>  	uint32_t index;
>  	uint16_t size; /* compressed size in bytes, zero means unused */
> @@ -294,7 +321,8 @@ static void zbud_free_and_delist(struct 
>  	}
>  }
>  
> -static struct zbud_hdr *zbud_create(uint32_t pool_id, struct tmem_oid *oid,
> +static struct zbud_hdr *zbud_create(uint16_t client_id, uint16_t pool_id,
> +					struct tmem_oid *oid,
>  					uint32_t index, struct page *page,
>  					void *cdata, unsigned size)
>  {
> @@ -353,6 +381,7 @@ init_zh:
>  	zh->index = index;
>  	zh->oid = *oid;
>  	zh->pool_id = pool_id;
> +	zh->client_id = client_id;
>  	/* can wait to copy the data until the list locks are dropped */
>  	spin_unlock(&zbud_budlists_spinlock);
>  
> @@ -407,7 +436,8 @@ static unsigned long zcache_evicted_raw_
>  static unsigned long zcache_evicted_buddied_pages;
>  static unsigned long zcache_evicted_unbuddied_pages;
>  
> -static struct tmem_pool *zcache_get_pool_by_id(uint32_t poolid);
> +static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id,
> +						uint16_t poolid);
>  static void zcache_put_pool(struct tmem_pool *pool);
>  
>  /*
> @@ -417,7 +447,8 @@ static void zbud_evict_zbpg(struct zbud_
>  {
>  	struct zbud_hdr *zh;
>  	int i, j;
> -	uint32_t pool_id[ZBUD_MAX_BUDS], index[ZBUD_MAX_BUDS];
> +	uint32_t pool_id[ZBUD_MAX_BUDS], client_id[ZBUD_MAX_BUDS];
> +	uint32_t index[ZBUD_MAX_BUDS];
>  	struct tmem_oid oid[ZBUD_MAX_BUDS];
>  	struct tmem_pool *pool;
>  
> @@ -426,6 +457,7 @@ static void zbud_evict_zbpg(struct zbud_
>  	for (i = 0, j = 0; i < ZBUD_MAX_BUDS; i++) {
>  		zh = &zbpg->buddy[i];
>  		if (zh->size) {
> +			client_id[j] = zh->client_id;
>  			pool_id[j] = zh->pool_id;
>  			oid[j] = zh->oid;
>  			index[j] = zh->index;
> @@ -435,7 +467,7 @@ static void zbud_evict_zbpg(struct zbud_
>  	}
>  	spin_unlock(&zbpg->lock);
>  	for (i = 0; i < j; i++) {
> -		pool = zcache_get_pool_by_id(pool_id[i]);
> +		pool = zcache_get_pool_by_id(client_id[i], pool_id[i]);
>  		if (pool != NULL) {
>  			tmem_flush_page(pool, &oid[i], index[i]);
>  			zcache_put_pool(pool);
> @@ -677,36 +709,70 @@ static unsigned long zcache_flobj_found;
>  static unsigned long zcache_failed_eph_puts;
>  static unsigned long zcache_failed_pers_puts;
>  
> -#define MAX_POOLS_PER_CLIENT 16
> -
> -static struct {
> -	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
> -	struct xv_pool *xvpool;
> -} zcache_client;
> -
>  /*
>   * Tmem operations assume the poolid implies the invoking client.
> - * Zcache only has one client (the kernel itself), so translate
> - * the poolid into the tmem_pool allocated for it.  A KVM version
> + * Zcache only has one client (the kernel itself): LOCAL_CLIENT.
> + * RAMster has each client numbered by cluster node, and a KVM version
>   * of zcache would have one client per guest and each client might
>   * have a poolid==N.
>   */
> -static struct tmem_pool *zcache_get_pool_by_id(uint32_t poolid)
> +static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t poolid)
>  {
>  	struct tmem_pool *pool = NULL;
> +	struct zcache_client *cli = NULL;
>  
> -	if (poolid >= 0) {
> -		pool = zcache_client.tmem_pools[poolid];
> +	if (cli_id == LOCAL_CLIENT)
> +		cli = &zcache_host;
> +	else {
> +		if (cli_id >= MAX_CLIENTS)
> +			goto out;
> +		cli = &zcache_clients[cli_id];
> +		if (cli == NULL)
> +			goto out;
> +		atomic_inc(&cli->refcount);
> +	}
> +	if (poolid < MAX_POOLS_PER_CLIENT) {
> +		pool = cli->tmem_pools[poolid];
>  		if (pool != NULL)
>  			atomic_inc(&pool->refcount);
>  	}
> +out:
>  	return pool;
>  }
>  
>  static void zcache_put_pool(struct tmem_pool *pool)
>  {
> -	if (pool != NULL)
> -		atomic_dec(&pool->refcount);
> +	struct zcache_client *cli = NULL;
> +
> +	if (pool == NULL)
> +		BUG();
> +	cli = pool->client;
> +	atomic_dec(&pool->refcount);
> +	atomic_dec(&cli->refcount);
> +}
> +
> +int zcache_new_client(uint16_t cli_id)
> +{
> +	struct zcache_client *cli = NULL;
> +	int ret = -1;
> +
> +	if (cli_id == LOCAL_CLIENT)
> +		cli = &zcache_host;
> +	else if ((unsigned int)cli_id < MAX_CLIENTS)
> +		cli = &zcache_clients[cli_id];
> +	if (cli == NULL)
> +		goto out;
> +	if (cli->allocated)
> +		goto out;
> +	cli->allocated = 1;
> +#ifdef CONFIG_FRONTSWAP
> +	cli->xvpool = xv_create_pool();
> +	if (cli->xvpool == NULL)
> +		goto out;
> +#endif
> +	ret = 0;
> +out:
> +	return ret;
>  }
>  
>  /* counters for debugging */
> @@ -901,26 +967,28 @@ static unsigned long zcache_curr_pers_pa
>  /* forward reference */
>  static int zcache_compress(struct page *from, void **out_va, size_t *out_len);
>  
> -static void *zcache_pampd_create(struct tmem_pool *pool, struct tmem_oid *oid,
> -				 uint32_t index, struct page *page)
> +static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
> +				struct tmem_pool *pool, struct tmem_oid *oid,
> +				 uint32_t index)
>  {
>  	void *pampd = NULL, *cdata;
>  	size_t clen;
>  	int ret;
> -	bool ephemeral = is_ephemeral(pool);
>  	unsigned long count;
> +	struct page *page = virt_to_page(data);
> +	struct zcache_client *cli = pool->client;
> +	uint16_t client_id = get_client_id_from_client(cli);
>  
> -	if (ephemeral) {
> +	if (eph) {
>  		ret = zcache_compress(page, &cdata, &clen);
>  		if (ret == 0)
> -
>  			goto out;
>  		if (clen == 0 || clen > zbud_max_buddy_size()) {
>  			zcache_compress_poor++;
>  			goto out;
>  		}
> -		pampd = (void *)zbud_create(pool->pool_id, oid, index,
> -						page, cdata, clen);
> +		pampd = (void *)zbud_create(client_id, pool->pool_id, oid,
> +						index, page, cdata, clen);
>  		if (pampd != NULL) {
>  			count = atomic_inc_return(&zcache_curr_eph_pampd_count);
>  			if (count > zcache_curr_eph_pampd_count_max)
> @@ -942,7 +1010,7 @@ static void *zcache_pampd_create(struct 
>  			zcache_compress_poor++;
>  			goto out;
>  		}
> -		pampd = (void *)zv_create(zcache_client.xvpool, pool->pool_id,
> +		pampd = (void *)zv_create(cli->xvpool, pool->pool_id,
>  						oid, index, cdata, clen);
>  		if (pampd == NULL)
>  			goto out;
> @@ -958,15 +1026,31 @@ out:
>   * fill the pageframe corresponding to the struct page with the data
>   * from the passed pampd
>   */
> -static int zcache_pampd_get_data(struct page *page, void *pampd,
> -						struct tmem_pool *pool)
> +static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
> +					void *pampd, struct tmem_pool *pool,
> +					struct tmem_oid *oid, uint32_t index)
>  {
>  	int ret = 0;
>  
> -	if (is_ephemeral(pool))
> -		ret = zbud_decompress(page, pampd);
> -	else
> -		zv_decompress(page, pampd);
> +	BUG_ON(is_ephemeral(pool));
> +	zv_decompress(virt_to_page(data), pampd);
> +	return ret;
> +}
> +
> +/*
> + * fill the pageframe corresponding to the struct page with the data
> + * from the passed pampd
> + */
> +static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, bool raw,
> +					void *pampd, struct tmem_pool *pool,
> +					struct tmem_oid *oid, uint32_t index)
> +{
> +	int ret = 0;
> +
> +	BUG_ON(!is_ephemeral(pool));
> +	zbud_decompress(virt_to_page(data), pampd);
> +	zbud_free_and_delist((struct zbud_hdr *)pampd);
> +	atomic_dec(&zcache_curr_eph_pampd_count);
>  	return ret;
>  }
>  
> @@ -974,23 +1058,49 @@ static int zcache_pampd_get_data(struct 
>   * free the pampd and remove it from any zcache lists
>   * pampd must no longer be pointed to from any tmem data structures!
>   */
> -static void zcache_pampd_free(void *pampd, struct tmem_pool *pool)
> +static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
> +				struct tmem_oid *oid, uint32_t index)
>  {
> +	struct zcache_client *cli = pool->client;
> +
>  	if (is_ephemeral(pool)) {
>  		zbud_free_and_delist((struct zbud_hdr *)pampd);
>  		atomic_dec(&zcache_curr_eph_pampd_count);
>  		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
>  	} else {
> -		zv_free(zcache_client.xvpool, (struct zv_hdr *)pampd);
> +		zv_free(cli->xvpool, (struct zv_hdr *)pampd);
>  		atomic_dec(&zcache_curr_pers_pampd_count);
>  		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
>  	}
>  }
>  
> +static void zcache_pampd_free_obj(struct tmem_pool *pool, struct tmem_obj *obj)
> +{
> +}
> +
> +static void zcache_pampd_new_obj(struct tmem_obj *obj)
> +{
> +}
> +
> +static int zcache_pampd_replace_in_obj(void *pampd, struct tmem_obj *obj)
> +{
> +	return -1;
> +}
> +
> +static bool zcache_pampd_is_remote(void *pampd)
> +{
> +	return 0;
> +}
> +
>  static struct tmem_pamops zcache_pamops = {
>  	.create = zcache_pampd_create,
>  	.get_data = zcache_pampd_get_data,
> +	.get_data_and_free = zcache_pampd_get_data_and_free,
>  	.free = zcache_pampd_free,
> +	.free_obj = zcache_pampd_free_obj,
> +	.new_obj = zcache_pampd_new_obj,
> +	.replace_in_obj = zcache_pampd_replace_in_obj,
> +	.is_remote = zcache_pampd_is_remote,
>  };
>  
>  /*
> @@ -1212,19 +1322,20 @@ static struct shrinker zcache_shrinker =
>   * zcache shims between cleancache/frontswap ops and tmem
>   */
>  
> -static int zcache_put_page(int pool_id, struct tmem_oid *oidp,
> +static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>  				uint32_t index, struct page *page)
>  {
>  	struct tmem_pool *pool;
>  	int ret = -1;
>  
>  	BUG_ON(!irqs_disabled());
> -	pool = zcache_get_pool_by_id(pool_id);
> +	pool = zcache_get_pool_by_id(cli_id, pool_id);
>  	if (unlikely(pool == NULL))
>  		goto out;
>  	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
>  		/* preload does preempt_disable on success */
> -		ret = tmem_put(pool, oidp, index, page);
> +		ret = tmem_put(pool, oidp, index, page_address(page),
> +				PAGE_SIZE, 0, is_ephemeral(pool));
>  		if (ret < 0) {
>  			if (is_ephemeral(pool))
>  				zcache_failed_eph_puts++;
> @@ -1244,25 +1355,28 @@ out:
>  	return ret;
>  }
>  
> -static int zcache_get_page(int pool_id, struct tmem_oid *oidp,
> +static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>  				uint32_t index, struct page *page)
>  {
>  	struct tmem_pool *pool;
>  	int ret = -1;
>  	unsigned long flags;
> +	size_t size = PAGE_SIZE;
>  
>  	local_irq_save(flags);
> -	pool = zcache_get_pool_by_id(pool_id);
> +	pool = zcache_get_pool_by_id(cli_id, pool_id);
>  	if (likely(pool != NULL)) {
>  		if (atomic_read(&pool->obj_count) > 0)
> -			ret = tmem_get(pool, oidp, index, page);
> +			ret = tmem_get(pool, oidp, index, page_address(page),
> +					&size, 0, is_ephemeral(pool));
>  		zcache_put_pool(pool);
>  	}
>  	local_irq_restore(flags);
>  	return ret;
>  }
>  
> -static int zcache_flush_page(int pool_id, struct tmem_oid *oidp, uint32_t index)
> +static int zcache_flush_page(int cli_id, int pool_id,
> +				struct tmem_oid *oidp, uint32_t index)
>  {
>  	struct tmem_pool *pool;
>  	int ret = -1;
> @@ -1270,7 +1384,7 @@ static int zcache_flush_page(int pool_id
>  
>  	local_irq_save(flags);
>  	zcache_flush_total++;
> -	pool = zcache_get_pool_by_id(pool_id);
> +	pool = zcache_get_pool_by_id(cli_id, pool_id);
>  	if (likely(pool != NULL)) {
>  		if (atomic_read(&pool->obj_count) > 0)
>  			ret = tmem_flush_page(pool, oidp, index);
> @@ -1282,7 +1396,8 @@ static int zcache_flush_page(int pool_id
>  	return ret;
>  }
>  
> -static int zcache_flush_object(int pool_id, struct tmem_oid *oidp)
> +static int zcache_flush_object(int cli_id, int pool_id,
> +				struct tmem_oid *oidp)
>  {
>  	struct tmem_pool *pool;
>  	int ret = -1;
> @@ -1290,7 +1405,7 @@ static int zcache_flush_object(int pool_
>  
>  	local_irq_save(flags);
>  	zcache_flobj_total++;
> -	pool = zcache_get_pool_by_id(pool_id);
> +	pool = zcache_get_pool_by_id(cli_id, pool_id);
>  	if (likely(pool != NULL)) {
>  		if (atomic_read(&pool->obj_count) > 0)
>  			ret = tmem_flush_object(pool, oidp);
> @@ -1302,34 +1417,52 @@ static int zcache_flush_object(int pool_
>  	return ret;
>  }
>  
> -static int zcache_destroy_pool(int pool_id)
> +static int zcache_destroy_pool(int cli_id, int pool_id)
>  {
>  	struct tmem_pool *pool = NULL;
> +	struct zcache_client *cli = NULL;
>  	int ret = -1;
>  
>  	if (pool_id < 0)
>  		goto out;
> -	pool = zcache_client.tmem_pools[pool_id];
> +	if (cli_id == LOCAL_CLIENT)
> +		cli = &zcache_host;
> +	else if ((unsigned int)cli_id < MAX_CLIENTS)
> +		cli = &zcache_clients[cli_id];
> +	if (cli == NULL)
> +		goto out;
> +	atomic_inc(&cli->refcount);
> +	pool = cli->tmem_pools[pool_id];
>  	if (pool == NULL)
>  		goto out;
> -	zcache_client.tmem_pools[pool_id] = NULL;
> +	cli->tmem_pools[pool_id] = NULL;
>  	/* wait for pool activity on other cpus to quiesce */
>  	while (atomic_read(&pool->refcount) != 0)
>  		;
> +	atomic_dec(&cli->refcount);
>  	local_bh_disable();
>  	ret = tmem_destroy_pool(pool);
>  	local_bh_enable();
>  	kfree(pool);
> -	pr_info("zcache: destroyed pool id=%d\n", pool_id);
> +	pr_info("zcache: destroyed pool id=%d, cli_id=%d\n",
> +			pool_id, cli_id);
>  out:
>  	return ret;
>  }
>  
> -static int zcache_new_pool(uint32_t flags)
> +static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
>  {
>  	int poolid = -1;
>  	struct tmem_pool *pool;
> +	struct zcache_client *cli = NULL;
>  
> +	if (cli_id == LOCAL_CLIENT)
> +		cli = &zcache_host;
> +	else if ((unsigned int)cli_id < MAX_CLIENTS)
> +		cli = &zcache_clients[cli_id];
> +	if (cli == NULL)
> +		goto out;
> +	atomic_inc(&cli->refcount);
>  	pool = kmalloc(sizeof(struct tmem_pool), GFP_KERNEL);
>  	if (pool == NULL) {
>  		pr_info("zcache: pool creation failed: out of memory\n");
> @@ -1337,7 +1470,7 @@ static int zcache_new_pool(uint32_t flag
>  	}
>  
>  	for (poolid = 0; poolid < MAX_POOLS_PER_CLIENT; poolid++)
> -		if (zcache_client.tmem_pools[poolid] == NULL)
> +		if (cli->tmem_pools[poolid] == NULL)
>  			break;
>  	if (poolid >= MAX_POOLS_PER_CLIENT) {
>  		pr_info("zcache: pool creation failed: max exceeded\n");
> @@ -1346,14 +1479,16 @@ static int zcache_new_pool(uint32_t flag
>  		goto out;
>  	}
>  	atomic_set(&pool->refcount, 0);
> -	pool->client = &zcache_client;
> +	pool->client = cli;
>  	pool->pool_id = poolid;
>  	tmem_new_pool(pool, flags);
> -	zcache_client.tmem_pools[poolid] = pool;
> -	pr_info("zcache: created %s tmem pool, id=%d\n",
> +	cli->tmem_pools[poolid] = pool;
> +	pr_info("zcache: created %s tmem pool, id=%d, client=%d\n",
>  		flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
> -		poolid);
> +		poolid, cli_id);
>  out:
> +	if (cli != NULL)
> +		atomic_dec(&cli->refcount);
>  	return poolid;
>  }
>  
> @@ -1374,7 +1509,7 @@ static void zcache_cleancache_put_page(i
>  	struct tmem_oid oid = *(struct tmem_oid *)&key;
>  
>  	if (likely(ind == index))
> -		(void)zcache_put_page(pool_id, &oid, index, page);
> +		(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index, page);
>  }
>  
>  static int zcache_cleancache_get_page(int pool_id,
> @@ -1386,7 +1521,7 @@ static int zcache_cleancache_get_page(in
>  	int ret = -1;
>  
>  	if (likely(ind == index))
> -		ret = zcache_get_page(pool_id, &oid, index, page);
> +		ret = zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index, page);
>  	return ret;
>  }
>  
> @@ -1398,7 +1533,7 @@ static void zcache_cleancache_flush_page
>  	struct tmem_oid oid = *(struct tmem_oid *)&key;
>  
>  	if (likely(ind == index))
> -		(void)zcache_flush_page(pool_id, &oid, ind);
> +		(void)zcache_flush_page(LOCAL_CLIENT, pool_id, &oid, ind);
>  }
>  
>  static void zcache_cleancache_flush_inode(int pool_id,
> @@ -1406,13 +1541,13 @@ static void zcache_cleancache_flush_inod
>  {
>  	struct tmem_oid oid = *(struct tmem_oid *)&key;
>  
> -	(void)zcache_flush_object(pool_id, &oid);
> +	(void)zcache_flush_object(LOCAL_CLIENT, pool_id, &oid);
>  }
>  
>  static void zcache_cleancache_flush_fs(int pool_id)
>  {
>  	if (pool_id >= 0)
> -		(void)zcache_destroy_pool(pool_id);
> +		(void)zcache_destroy_pool(LOCAL_CLIENT, pool_id);
>  }
>  
>  static int zcache_cleancache_init_fs(size_t pagesize)
> @@ -1420,7 +1555,7 @@ static int zcache_cleancache_init_fs(siz
>  	BUG_ON(sizeof(struct cleancache_filekey) !=
>  				sizeof(struct tmem_oid));
>  	BUG_ON(pagesize != PAGE_SIZE);
> -	return zcache_new_pool(0);
> +	return zcache_new_pool(LOCAL_CLIENT, 0);
>  }
>  
>  static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
> @@ -1429,7 +1564,7 @@ static int zcache_cleancache_init_shared
>  	BUG_ON(sizeof(struct cleancache_filekey) !=
>  				sizeof(struct tmem_oid));
>  	BUG_ON(pagesize != PAGE_SIZE);
> -	return zcache_new_pool(0);
> +	return zcache_new_pool(LOCAL_CLIENT, 0);
>  }
>  
>  static struct cleancache_ops zcache_cleancache_ops = {
> @@ -1483,8 +1618,8 @@ static int zcache_frontswap_put_page(uns
>  	BUG_ON(!PageLocked(page));
>  	if (likely(ind64 == ind)) {
>  		local_irq_save(flags);
> -		ret = zcache_put_page(zcache_frontswap_poolid, &oid,
> -					iswiz(ind), page);
> +		ret = zcache_put_page(LOCAL_CLIENT, zcache_frontswap_poolid,
> +					&oid, iswiz(ind), page);
>  		local_irq_restore(flags);
>  	}
>  	return ret;
> @@ -1502,8 +1637,8 @@ static int zcache_frontswap_get_page(uns
>  
>  	BUG_ON(!PageLocked(page));
>  	if (likely(ind64 == ind))
> -		ret = zcache_get_page(zcache_frontswap_poolid, &oid,
> -					iswiz(ind), page);
> +		ret = zcache_get_page(LOCAL_CLIENT, zcache_frontswap_poolid,
> +					&oid, iswiz(ind), page);
>  	return ret;
>  }
>  
> @@ -1515,8 +1650,8 @@ static void zcache_frontswap_flush_page(
>  	struct tmem_oid oid = oswiz(type, ind);
>  
>  	if (likely(ind64 == ind))
> -		(void)zcache_flush_page(zcache_frontswap_poolid, &oid,
> -					iswiz(ind));
> +		(void)zcache_flush_page(LOCAL_CLIENT, zcache_frontswap_poolid,
> +					&oid, iswiz(ind));
>  }
>  
>  /* flush all pages from the passed swaptype */
> @@ -1527,7 +1662,8 @@ static void zcache_frontswap_flush_area(
>  
>  	for (ind = SWIZ_MASK; ind >= 0; ind--) {
>  		oid = oswiz(type, ind);
> -		(void)zcache_flush_object(zcache_frontswap_poolid, &oid);
> +		(void)zcache_flush_object(LOCAL_CLIENT,
> +						zcache_frontswap_poolid, &oid);
>  	}
>  }
>  
> @@ -1535,7 +1671,8 @@ static void zcache_frontswap_init(unsign
>  {
>  	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
>  	if (zcache_frontswap_poolid < 0)
> -		zcache_frontswap_poolid = zcache_new_pool(TMEM_POOL_PERSIST);
> +		zcache_frontswap_poolid =
> +			zcache_new_pool(LOCAL_CLIENT, TMEM_POOL_PERSIST);
>  }
>  
>  static struct frontswap_ops zcache_frontswap_ops = {
> @@ -1624,6 +1761,11 @@ static int __init zcache_init(void)
>  				sizeof(struct tmem_objnode), 0, 0, NULL);
>  	zcache_obj_cache = kmem_cache_create("zcache_obj",
>  				sizeof(struct tmem_obj), 0, 0, NULL);
> +	ret = zcache_new_client(LOCAL_CLIENT);
> +	if (ret) {
> +		pr_err("zcache: can't create client\n");
> +		goto out;
> +	}
>  #endif
>  #ifdef CONFIG_CLEANCACHE
>  	if (zcache_enabled && use_cleancache) {
> @@ -1642,11 +1784,6 @@ static int __init zcache_init(void)
>  	if (zcache_enabled && use_frontswap) {
>  		struct frontswap_ops old_ops;
>  
> -		zcache_client.xvpool = xv_create_pool();
> -		if (zcache_client.xvpool == NULL) {
> -			pr_err("zcache: can't create xvpool\n");
> -			goto out;
> -		}
>  		old_ops = zcache_frontswap_register_ops();
>  		pr_info("zcache: frontswap enabled using kernel "
>  			"transcendent memory and xvmalloc\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
