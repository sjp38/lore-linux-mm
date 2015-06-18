Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id DC63D6B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 11:57:38 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so29200024qke.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 08:57:38 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id f34si7450886qkh.54.2015.06.18.08.57.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 08:57:37 -0700 (PDT)
Date: Thu, 18 Jun 2015 10:57:30 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] zswap: dynamic pool creation
Message-ID: <20150618155730.GA9958@cerebellum.local.variantweb.net>
References: <1433419358-21820-1-git-send-email-ddstreet@ieee.org>
 <CALZtONC_-uQcE30hgzwD-V9Ps9k8g2Y_XUTjD9xcXaiXAc-hGw@mail.gmail.com>
 <CALZtONA6C3v0mwwgbf4QqLqehqtrdqs9Y=Td2-HXyhQhySki_w@mail.gmail.com>
 <20150611185145.GA4346@cerebellum.local.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150611185145.GA4346@cerebellum.local.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 11, 2015 at 01:51:45PM -0500, Seth Jennings wrote:
> On Wed, Jun 10, 2015 at 04:54:24PM -0400, Dan Streetman wrote:
> > On Thu, Jun 4, 2015 at 8:13 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> > > On Thu, Jun 4, 2015 at 8:02 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> > >> Add dynamic creation of pools.  Move the static crypto compression
> > >> per-cpu transforms into each pool.  Add a pointer to zswap_entry to
> > >> the pool it's in.
> > >
> > > Seth, as far as the design, from your previous comments I assume you
> > > were thinking of maintaining separate lists of zpools and compressors?
> > >  I do see how that will reduce duplication of zpools and compressors,
> > > but it also requires adding a new pointer to each zswap_entry, and
> > > increasing the amount of code to manage each list separately.  And the
> > > most common case in zswap will be just a single zpool and compressor,
> > > not repeatedly changing params.  What do you think?
> > 
> > Any opinion on this patch?  If you want, I can break it up so there's
> > a list of zpools and a list of compressors.  Either the combined way
> > (this patch) or separate lists works for me, as long as the params are
> > changeable at runtime :-)
> 
> I'm still reviewing the code.  I was going to test it too but it doesn't
> compile for me:
> 
>   CC      mm/zswap.o
> mm/zswap.c: In function a??__zswap_pool_create_fallbacka??:
> mm/zswap.c:605:10: warning: argument to a??sizeofa?? in a??strncpya?? call is the same expression as the destination; did you mean to provide an explicit length? [-Wsizeof-pointer-memaccess]
>     sizeof(zswap_compressor));
>           ^
> mm/zswap.c:607:7: error: implicit declaration of function a??zpool_has_poola?? [-Werror=implicit-function-declaration]
>   if (!zpool_has_pool(zswap_zpool_type)) {
>        ^
> mm/zswap.c:611:10: warning: argument to a??sizeofa?? in a??strncpya?? call is the same expression as the destination; did you mean to provide an explicit length? [-Wsizeof-pointer-memaccess]
>     sizeof(zswap_zpool_type));
>           ^
> mm/zswap.c: At top level:
> mm/zswap.c:664:1: error: expected identifier or a??(a?? before a??}a?? token
>  }
>  ^
> mm/zswap.c:99:22: warning: a??zswap_poola?? defined but not used [-Wunused-variable]
>  static struct zpool *zswap_pool;
>                       ^
> mm/zswap.c:531:27: warning: a??zswap_pool_find_geta?? defined but not used [-Wunused-function]
>  static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
>                            ^

Dan, I never heard back from you on this, but I figured it out.  PATCH
1/5 from your original patchset wasn't pulled in, but you didn't roll it
into this new patch either.

Seth


> 
> Seth
> 
> > 
> > 
> > >
> > >>
> > >> This is required by a separate patch which enables changing the
> > >> zswap zpool and compressor params at runtime.
> > >>
> > >> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> > >> ---
> > >>  mm/zswap.c | 550 +++++++++++++++++++++++++++++++++++++++++++++----------------
> > >>  1 file changed, 408 insertions(+), 142 deletions(-)
> > >>
> > >> diff --git a/mm/zswap.c b/mm/zswap.c
> > >> index 2d5727b..fc93770 100644
> > >> --- a/mm/zswap.c
> > >> +++ b/mm/zswap.c
> > >> @@ -99,66 +99,19 @@ module_param_named(zpool, zswap_zpool_type, charp, 0444);
> > >>  static struct zpool *zswap_pool;
> > >>
> > >>  /*********************************
> > >> -* compression functions
> > >> +* data structures
> > >>  **********************************/
> > >> -/* per-cpu compression transforms */
> > >> -static struct crypto_comp * __percpu *zswap_comp_pcpu_tfms;
> > >>
> > >> -enum comp_op {
> > >> -       ZSWAP_COMPOP_COMPRESS,
> > >> -       ZSWAP_COMPOP_DECOMPRESS
> > >> +struct zswap_pool {
> > >> +       struct zpool *zpool;
> > >> +       struct kref kref;
> > >> +       struct list_head list;
> > >> +       struct rcu_head rcu_head;
> > >> +       struct notifier_block notifier;
> > >> +       char tfm_name[CRYPTO_MAX_ALG_NAME];
> > >> +       struct crypto_comp * __percpu *tfm;
> > >>  };
> > >>
> > >> -static int zswap_comp_op(enum comp_op op, const u8 *src, unsigned int slen,
> > >> -                               u8 *dst, unsigned int *dlen)
> > >> -{
> > >> -       struct crypto_comp *tfm;
> > >> -       int ret;
> > >> -
> > >> -       tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, get_cpu());
> > >> -       switch (op) {
> > >> -       case ZSWAP_COMPOP_COMPRESS:
> > >> -               ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
> > >> -               break;
> > >> -       case ZSWAP_COMPOP_DECOMPRESS:
> > >> -               ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
> > >> -               break;
> > >> -       default:
> > >> -               ret = -EINVAL;
> > >> -       }
> > >> -
> > >> -       put_cpu();
> > >> -       return ret;
> > >> -}
> > >> -
> > >> -static int __init zswap_comp_init(void)
> > >> -{
> > >> -       if (!crypto_has_comp(zswap_compressor, 0, 0)) {
> > >> -               pr_info("%s compressor not available\n", zswap_compressor);
> > >> -               /* fall back to default compressor */
> > >> -               zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> > >> -               if (!crypto_has_comp(zswap_compressor, 0, 0))
> > >> -                       /* can't even load the default compressor */
> > >> -                       return -ENODEV;
> > >> -       }
> > >> -       pr_info("using %s compressor\n", zswap_compressor);
> > >> -
> > >> -       /* alloc percpu transforms */
> > >> -       zswap_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
> > >> -       if (!zswap_comp_pcpu_tfms)
> > >> -               return -ENOMEM;
> > >> -       return 0;
> > >> -}
> > >> -
> > >> -static void __init zswap_comp_exit(void)
> > >> -{
> > >> -       /* free percpu transforms */
> > >> -       free_percpu(zswap_comp_pcpu_tfms);
> > >> -}
> > >> -
> > >> -/*********************************
> > >> -* data structures
> > >> -**********************************/
> > >>  /*
> > >>   * struct zswap_entry
> > >>   *
> > >> @@ -166,22 +119,24 @@ static void __init zswap_comp_exit(void)
> > >>   * page within zswap.
> > >>   *
> > >>   * rbnode - links the entry into red-black tree for the appropriate swap type
> > >> + * offset - the swap offset for the entry.  Index into the red-black tree.
> > >>   * refcount - the number of outstanding reference to the entry. This is needed
> > >>   *            to protect against premature freeing of the entry by code
> > >>   *            concurrent calls to load, invalidate, and writeback.  The lock
> > >>   *            for the zswap_tree structure that contains the entry must
> > >>   *            be held while changing the refcount.  Since the lock must
> > >>   *            be held, there is no reason to also make refcount atomic.
> > >> - * offset - the swap offset for the entry.  Index into the red-black tree.
> > >> - * handle - zpool allocation handle that stores the compressed page data
> > >>   * length - the length in bytes of the compressed page data.  Needed during
> > >>   *          decompression
> > >> + * pool - the zswap_pool the entry's data is in
> > >> + * handle - zpool allocation handle that stores the compressed page data
> > >>   */
> > >>  struct zswap_entry {
> > >>         struct rb_node rbnode;
> > >>         pgoff_t offset;
> > >>         int refcount;
> > >>         unsigned int length;
> > >> +       struct zswap_pool *pool;
> > >>         unsigned long handle;
> > >>  };
> > >>
> > >> @@ -201,6 +156,44 @@ struct zswap_tree {
> > >>
> > >>  static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
> > >>
> > >> +/* RCU-protected iteration */
> > >> +static LIST_HEAD(zswap_pools);
> > >> +/* protects zswap_pools list modification */
> > >> +static DEFINE_SPINLOCK(zswap_pools_lock);
> > >> +
> > >> +/*********************************
> > >> +* helpers and fwd declarations
> > >> +**********************************/
> > >> +
> > >> +#define zswap_pool_debug(msg, p)                               \
> > >> +       pr_debug("%s pool %s/%s\n", msg, (p)->tfm_name,         \
> > >> +                zpool_get_type((p)->zpool))
> > >> +
> > >> +static int zswap_writeback_entry(struct zpool *pool, unsigned long handle);
> > >> +static int zswap_pool_get(struct zswap_pool *pool);
> > >> +static void zswap_pool_put(struct zswap_pool *pool);
> > >> +
> > >> +static bool zswap_is_full(void)
> > >> +{
> > >> +       return totalram_pages * zswap_max_pool_percent / 100 <
> > >> +               DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
> > >> +}
> > >> +
> > >> +static void zswap_update_total_size(void)
> > >> +{
> > >> +       struct zswap_pool *pool;
> > >> +       u64 total = 0;
> > >> +
> > >> +       rcu_read_lock();
> > >> +
> > >> +       list_for_each_entry_rcu(pool, &zswap_pools, list)
> > >> +               total += zpool_get_total_size(pool->zpool);
> > >> +
> > >> +       rcu_read_unlock();
> > >> +
> > >> +       zswap_pool_total_size = total;
> > >> +}
> > >> +
> > >>  /*********************************
> > >>  * zswap entry functions
> > >>  **********************************/
> > >> @@ -294,10 +287,11 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
> > >>   */
> > >>  static void zswap_free_entry(struct zswap_entry *entry)
> > >>  {
> > >> -       zpool_free(zswap_pool, entry->handle);
> > >> +       zpool_free(entry->pool->zpool, entry->handle);
> > >> +       zswap_pool_put(entry->pool);
> > >>         zswap_entry_cache_free(entry);
> > >>         atomic_dec(&zswap_stored_pages);
> > >> -       zswap_pool_total_size = zpool_get_total_size(zswap_pool);
> > >> +       zswap_update_total_size();
> > >>  }
> > >>
> > >>  /* caller must hold the tree lock */
> > >> @@ -339,35 +333,21 @@ static struct zswap_entry *zswap_entry_find_get(struct rb_root *root,
> > >>  **********************************/
> > >>  static DEFINE_PER_CPU(u8 *, zswap_dstmem);
> > >>
> > >> -static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> > >> +static int __zswap_cpu_dstmem_notifier(unsigned long action, unsigned long cpu)
> > >>  {
> > >> -       struct crypto_comp *tfm;
> > >>         u8 *dst;
> > >>
> > >>         switch (action) {
> > >>         case CPU_UP_PREPARE:
> > >> -               tfm = crypto_alloc_comp(zswap_compressor, 0, 0);
> > >> -               if (IS_ERR(tfm)) {
> > >> -                       pr_err("can't allocate compressor transform\n");
> > >> -                       return NOTIFY_BAD;
> > >> -               }
> > >> -               *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = tfm;
> > >>                 dst = kmalloc_node(PAGE_SIZE * 2, GFP_KERNEL, cpu_to_node(cpu));
> > >>                 if (!dst) {
> > >>                         pr_err("can't allocate compressor buffer\n");
> > >> -                       crypto_free_comp(tfm);
> > >> -                       *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> > >>                         return NOTIFY_BAD;
> > >>                 }
> > >>                 per_cpu(zswap_dstmem, cpu) = dst;
> > >>                 break;
> > >>         case CPU_DEAD:
> > >>         case CPU_UP_CANCELED:
> > >> -               tfm = *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu);
> > >> -               if (tfm) {
> > >> -                       crypto_free_comp(tfm);
> > >> -                       *per_cpu_ptr(zswap_comp_pcpu_tfms, cpu) = NULL;
> > >> -               }
> > >>                 dst = per_cpu(zswap_dstmem, cpu);
> > >>                 kfree(dst);
> > >>                 per_cpu(zswap_dstmem, cpu) = NULL;
> > >> @@ -378,43 +358,309 @@ static int __zswap_cpu_notifier(unsigned long action, unsigned long cpu)
> > >>         return NOTIFY_OK;
> > >>  }
> > >>
> > >> -static int zswap_cpu_notifier(struct notifier_block *nb,
> > >> -                               unsigned long action, void *pcpu)
> > >> +static int zswap_cpu_dstmem_notifier(struct notifier_block *nb,
> > >> +                                    unsigned long action, void *pcpu)
> > >>  {
> > >> -       unsigned long cpu = (unsigned long)pcpu;
> > >> -       return __zswap_cpu_notifier(action, cpu);
> > >> +       return __zswap_cpu_dstmem_notifier(action, (unsigned long)pcpu);
> > >>  }
> > >>
> > >> -static struct notifier_block zswap_cpu_notifier_block = {
> > >> -       .notifier_call = zswap_cpu_notifier
> > >> +static struct notifier_block zswap_dstmem_notifier = {
> > >> +       .notifier_call =        zswap_cpu_dstmem_notifier,
> > >>  };
> > >>
> > >> -static int __init zswap_cpu_init(void)
> > >> +static int __init zswap_cpu_dstmem_init(void)
> > >>  {
> > >>         unsigned long cpu;
> > >>
> > >>         cpu_notifier_register_begin();
> > >>         for_each_online_cpu(cpu)
> > >> -               if (__zswap_cpu_notifier(CPU_UP_PREPARE, cpu) != NOTIFY_OK)
> > >> +               if (__zswap_cpu_dstmem_notifier(CPU_UP_PREPARE, cpu) ==
> > >> +                   NOTIFY_BAD)
> > >>                         goto cleanup;
> > >> -       __register_cpu_notifier(&zswap_cpu_notifier_block);
> > >> +       __register_cpu_notifier(&zswap_dstmem_notifier);
> > >>         cpu_notifier_register_done();
> > >>         return 0;
> > >>
> > >>  cleanup:
> > >>         for_each_online_cpu(cpu)
> > >> -               __zswap_cpu_notifier(CPU_UP_CANCELED, cpu);
> > >> +               __zswap_cpu_dstmem_notifier(CPU_UP_CANCELED, cpu);
> > >>         cpu_notifier_register_done();
> > >>         return -ENOMEM;
> > >>  }
> > >>
> > >> +static void zswap_cpu_dstmem_destroy(void)
> > >> +{
> > >> +       unsigned long cpu;
> > >> +
> > >> +       cpu_notifier_register_begin();
> > >> +       for_each_online_cpu(cpu)
> > >> +               __zswap_cpu_dstmem_notifier(CPU_UP_CANCELED, cpu);
> > >> +       __unregister_cpu_notifier(&zswap_dstmem_notifier);
> > >> +       cpu_notifier_register_done();
> > >> +}
> > >> +
> > >> +static int __zswap_cpu_comp_notifier(struct zswap_pool *pool,
> > >> +                                    unsigned long action, unsigned long cpu)
> > >> +{
> > >> +       struct crypto_comp *tfm;
> > >> +
> > >> +       switch (action) {
> > >> +       case CPU_UP_PREPARE:
> > >> +               if (WARN_ON(*per_cpu_ptr(pool->tfm, cpu)))
> > >> +                       break;
> > >> +               tfm = crypto_alloc_comp(pool->tfm_name, 0, 0);
> > >> +               if (IS_ERR_OR_NULL(tfm)) {
> > >> +                       pr_err("could not alloc crypto comp %s : %ld\n",
> > >> +                              pool->tfm_name, PTR_ERR(tfm));
> > >> +                       return NOTIFY_BAD;
> > >> +               }
> > >> +               *per_cpu_ptr(pool->tfm, cpu) = tfm;
> > >> +               break;
> > >> +       case CPU_DEAD:
> > >> +       case CPU_UP_CANCELED:
> > >> +               tfm = *per_cpu_ptr(pool->tfm, cpu);
> > >> +               if (!IS_ERR_OR_NULL(tfm))
> > >> +                       crypto_free_comp(tfm);
> > >> +               *per_cpu_ptr(pool->tfm, cpu) = NULL;
> > >> +               break;
> > >> +       default:
> > >> +               break;
> > >> +       }
> > >> +       return NOTIFY_OK;
> > >> +}
> > >> +
> > >> +static int zswap_cpu_comp_notifier(struct notifier_block *nb,
> > >> +                                  unsigned long action, void *pcpu)
> > >> +{
> > >> +       unsigned long cpu = (unsigned long)pcpu;
> > >> +       struct zswap_pool *pool = container_of(nb, typeof(*pool), notifier);
> > >> +
> > >> +       return __zswap_cpu_comp_notifier(pool, action, cpu);
> > >> +}
> > >> +
> > >> +static int zswap_cpu_comp_init(struct zswap_pool *pool)
> > >> +{
> > >> +       unsigned long cpu;
> > >> +
> > >> +       memset(&pool->notifier, 0, sizeof(pool->notifier));
> > >> +       pool->notifier.notifier_call = zswap_cpu_comp_notifier;
> > >> +
> > >> +       cpu_notifier_register_begin();
> > >> +       for_each_online_cpu(cpu)
> > >> +               if (__zswap_cpu_comp_notifier(pool, CPU_UP_PREPARE, cpu) ==
> > >> +                   NOTIFY_BAD)
> > >> +                       goto cleanup;
> > >> +       __register_cpu_notifier(&pool->notifier);
> > >> +       cpu_notifier_register_done();
> > >> +       return 0;
> > >> +
> > >> +cleanup:
> > >> +       for_each_online_cpu(cpu)
> > >> +               __zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
> > >> +       cpu_notifier_register_done();
> > >> +       return -ENOMEM;
> > >> +}
> > >> +
> > >> +static void zswap_cpu_comp_destroy(struct zswap_pool *pool)
> > >> +{
> > >> +       unsigned long cpu;
> > >> +
> > >> +       cpu_notifier_register_begin();
> > >> +       for_each_online_cpu(cpu)
> > >> +               __zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
> > >> +       __unregister_cpu_notifier(&pool->notifier);
> > >> +       cpu_notifier_register_done();
> > >> +}
> > >> +
> > >>  /*********************************
> > >> -* helpers
> > >> +* pool functions
> > >>  **********************************/
> > >> -static bool zswap_is_full(void)
> > >> +
> > >> +static struct zswap_pool *__zswap_pool_current(void)
> > >>  {
> > >> -       return totalram_pages * zswap_max_pool_percent / 100 <
> > >> -               DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
> > >> +       struct zswap_pool *pool;
> > >> +
> > >> +       pool = list_first_or_null_rcu(&zswap_pools, typeof(*pool), list);
> > >> +       WARN_ON(!pool);
> > >> +
> > >> +       return pool;
> > >> +}
> > >> +
> > >> +static struct zswap_pool *zswap_pool_current(void)
> > >> +{
> > >> +       assert_spin_locked(&zswap_pools_lock);
> > >> +
> > >> +       return __zswap_pool_current();
> > >> +}
> > >> +
> > >> +static struct zswap_pool *zswap_pool_current_get(void)
> > >> +{
> > >> +       struct zswap_pool *pool;
> > >> +
> > >> +       rcu_read_lock();
> > >> +
> > >> +       pool = __zswap_pool_current();
> > >> +       if (!pool || !zswap_pool_get(pool))
> > >> +               pool = NULL;
> > >> +
> > >> +       rcu_read_unlock();
> > >> +
> > >> +       return pool;
> > >> +}
> > >> +
> > >> +static struct zswap_pool *zswap_pool_last_get(void)
> > >> +{
> > >> +       struct zswap_pool *pool, *last = NULL;
> > >> +
> > >> +       rcu_read_lock();
> > >> +
> > >> +       list_for_each_entry_rcu(pool, &zswap_pools, list)
> > >> +               last = pool;
> > >> +       if (!WARN_ON(!last) && !zswap_pool_get(last))
> > >> +               last = NULL;
> > >> +
> > >> +       rcu_read_unlock();
> > >> +
> > >> +       return last;
> > >> +}
> > >> +
> > >> +static struct zpool_ops zswap_zpool_ops = {
> > >> +       .evict = zswap_writeback_entry
> > >> +};
> > >> +
> > >> +static struct zswap_pool *zswap_pool_find_get(char *type, char *compressor)
> > >> +{
> > >> +       struct zswap_pool *pool;
> > >> +
> > >> +       assert_spin_locked(&zswap_pools_lock);
> > >> +
> > >> +       list_for_each_entry_rcu(pool, &zswap_pools, list) {
> > >> +               if (strncmp(pool->tfm_name, compressor, sizeof(pool->tfm_name)))
> > >> +                       continue;
> > >> +               if (strncmp(zpool_get_type(pool->zpool), type,
> > >> +                           sizeof(zswap_zpool_type)))
> > >> +                       continue;
> > >> +               /* if we can't get it, it's about to be destroyed */
> > >> +               if (!zswap_pool_get(pool))
> > >> +                       continue;
> > >> +               return pool;
> > >> +       }
> > >> +
> > >> +       return NULL;
> > >> +}
> > >> +
> > >> +static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
> > >> +{
> > >> +       struct zswap_pool *pool;
> > >> +       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
> > >> +
> > >> +       pool = kzalloc(sizeof(*pool), GFP_KERNEL);
> > >> +       if (!pool) {
> > >> +               pr_err("pool alloc failed\n");
> > >> +               return NULL;
> > >> +       }
> > >> +
> > >> +       pool->zpool = zpool_create_pool(type, "zswap", gfp, &zswap_zpool_ops);
> > >> +       if (!pool->zpool) {
> > >> +               pr_err("%s zpool not available\n", type);
> > >> +               goto error;
> > >> +       }
> > >> +       pr_debug("using %s zpool\n", zpool_get_type(pool->zpool));
> > >> +
> > >> +       strlcpy(pool->tfm_name, compressor, sizeof(pool->tfm_name));
> > >> +       pool->tfm = alloc_percpu(struct crypto_comp *);
> > >> +       if (!pool->tfm) {
> > >> +               pr_err("percpu alloc failed\n");
> > >> +               goto error;
> > >> +       }
> > >> +
> > >> +       if (zswap_cpu_comp_init(pool))
> > >> +               goto error;
> > >> +       pr_debug("using %s compressor\n", pool->tfm_name);
> > >> +
> > >> +       /* being the current pool takes 1 ref; this func expects the
> > >> +        * caller to always add the new pool as the current pool
> > >> +        */
> > >> +       kref_init(&pool->kref);
> > >> +       INIT_LIST_HEAD(&pool->list);
> > >> +
> > >> +       zswap_pool_debug("created", pool);
> > >> +
> > >> +       return pool;
> > >> +
> > >> +error:
> > >> +       free_percpu(pool->tfm);
> > >> +       if (pool->zpool)
> > >> +               zpool_destroy_pool(pool->zpool);
> > >> +       kfree(pool);
> > >> +       return NULL;
> > >> +}
> > >> +
> > >> +static struct zswap_pool *__zswap_pool_create_fallback(void)
> > >> +{
> > >> +       if (!crypto_has_comp(zswap_compressor, 0, 0)) {
> > >> +               pr_err("compressor %s not available, using default %s\n",
> > >> +                      zswap_compressor, ZSWAP_COMPRESSOR_DEFAULT);
> > >> +               strncpy(zswap_compressor, ZSWAP_COMPRESSOR_DEFAULT,
> > >> +                       sizeof(zswap_compressor));
> > >> +       }
> > >> +       if (!zpool_has_pool(zswap_zpool_type)) {
> > >> +               pr_err("zpool %s not available, using default %s\n",
> > >> +                      zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT);
> > >> +               strncpy(zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT,
> > >> +                       sizeof(zswap_zpool_type));
> > >> +       }
> > >> +
> > >> +       return zswap_pool_create(zswap_zpool_type, zswap_compressor);
> > >> +}
> > >> +
> > >> +static void zswap_pool_destroy(struct zswap_pool *pool)
> > >> +{
> > >> +       zswap_pool_debug("destroying", pool);
> > >> +
> > >> +       zswap_cpu_comp_destroy(pool);
> > >> +       free_percpu(pool->tfm);
> > >> +       zpool_destroy_pool(pool->zpool);
> > >> +       kfree(pool);
> > >> +}
> > >> +
> > >> +static int __must_check zswap_pool_get(struct zswap_pool *pool)
> > >> +{
> > >> +       return kref_get_unless_zero(&pool->kref);
> > >> +}
> > >> +
> > >> +static void __zswap_pool_release(struct rcu_head *head)
> > >> +{
> > >> +       struct zswap_pool *pool = container_of(head, typeof(*pool), rcu_head);
> > >> +
> > >> +       /* nobody should have been able to get a kref... */
> > >> +       WARN_ON(kref_get_unless_zero(&pool->kref));
> > >> +
> > >> +       /* pool is now off zswap_pools list and has no references. */
> > >> +       zswap_pool_destroy(pool);
> > >> +}
> > >> +
> > >> +static void __zswap_pool_empty(struct kref *kref)
> > >> +{
> > >> +       struct zswap_pool *pool;
> > >> +
> > >> +       pool = container_of(kref, typeof(*pool), kref);
> > >> +
> > >> +       spin_lock(&zswap_pools_lock);
> > >> +
> > >> +       WARN_ON(pool == zswap_pool_current());
> > >> +
> > >> +       list_del_rcu(&pool->list);
> > >> +       call_rcu(&pool->rcu_head, __zswap_pool_release);
> > >> +
> > >> +       spin_unlock(&zswap_pools_lock);
> > >> +}
> > >> +
> > >> +static void zswap_pool_put(struct zswap_pool *pool)
> > >> +{
> > >> +       kref_put(&pool->kref, __zswap_pool_empty);
> > >> +}
> > >> +
> > >>  }
> > >>
> > >>  /*********************************
> > >> @@ -538,6 +784,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
> > >>         pgoff_t offset;
> > >>         struct zswap_entry *entry;
> > >>         struct page *page;
> > >> +       struct crypto_comp *tfm;
> > >>         u8 *src, *dst;
> > >>         unsigned int dlen;
> > >>         int ret;
> > >> @@ -578,13 +825,15 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
> > >>         case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> > >>                 /* decompress */
> > >>                 dlen = PAGE_SIZE;
> > >> -               src = (u8 *)zpool_map_handle(zswap_pool, entry->handle,
> > >> +               src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
> > >>                                 ZPOOL_MM_RO) + sizeof(struct zswap_header);
> > >>                 dst = kmap_atomic(page);
> > >> -               ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
> > >> -                               entry->length, dst, &dlen);
> > >> +               tfm = *get_cpu_ptr(entry->pool->tfm);
> > >> +               ret = crypto_comp_decompress(tfm, src, entry->length,
> > >> +                                            dst, &dlen);
> > >> +               put_cpu_ptr(entry->pool->tfm);
> > >>                 kunmap_atomic(dst);
> > >> -               zpool_unmap_handle(zswap_pool, entry->handle);
> > >> +               zpool_unmap_handle(entry->pool->zpool, entry->handle);
> > >>                 BUG_ON(ret);
> > >>                 BUG_ON(dlen != PAGE_SIZE);
> > >>
> > >> @@ -633,6 +882,22 @@ end:
> > >>         return ret;
> > >>  }
> > >>
> > >> +static int zswap_shrink(void)
> > >> +{
> > >> +       struct zswap_pool *pool;
> > >> +       int ret;
> > >> +
> > >> +       pool = zswap_pool_last_get();
> > >> +       if (!pool)
> > >> +               return -ENOENT;
> > >> +
> > >> +       ret = zpool_shrink(pool->zpool, 1, NULL);
> > >> +
> > >> +       zswap_pool_put(pool);
> > >> +
> > >> +       return ret;
> > >> +}
> > >> +
> > >>  /*********************************
> > >>  * frontswap hooks
> > >>  **********************************/
> > >> @@ -642,6 +907,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> > >>  {
> > >>         struct zswap_tree *tree = zswap_trees[type];
> > >>         struct zswap_entry *entry, *dupentry;
> > >> +       struct crypto_comp *tfm;
> > >>         int ret;
> > >>         unsigned int dlen = PAGE_SIZE, len;
> > >>         unsigned long handle;
> > >> @@ -657,7 +923,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> > >>         /* reclaim space if needed */
> > >>         if (zswap_is_full()) {
> > >>                 zswap_pool_limit_hit++;
> > >> -               if (zpool_shrink(zswap_pool, 1, NULL)) {
> > >> +               if (zswap_shrink()) {
> > >>                         zswap_reject_reclaim_fail++;
> > >>                         ret = -ENOMEM;
> > >>                         goto reject;
> > >> @@ -672,33 +938,42 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> > >>                 goto reject;
> > >>         }
> > >>
> > >> +       /* if entry is successfully added, it keeps the reference */
> > >> +       entry->pool = zswap_pool_current_get();
> > >> +       if (!entry->pool) {
> > >> +               ret = -EINVAL;
> > >> +               goto freepage;
> > >> +       }
> > >> +
> > >>         /* compress */
> > >>         dst = get_cpu_var(zswap_dstmem);
> > >> +       tfm = *get_cpu_ptr(entry->pool->tfm);
> > >>         src = kmap_atomic(page);
> > >> -       ret = zswap_comp_op(ZSWAP_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dlen);
> > >> +       ret = crypto_comp_compress(tfm, src, PAGE_SIZE, dst, &dlen);
> > >>         kunmap_atomic(src);
> > >> +       put_cpu_ptr(entry->pool->tfm);
> > >>         if (ret) {
> > >>                 ret = -EINVAL;
> > >> -               goto freepage;
> > >> +               goto put_dstmem;
> > >>         }
> > >>
> > >>         /* store */
> > >>         len = dlen + sizeof(struct zswap_header);
> > >> -       ret = zpool_malloc(zswap_pool, len, __GFP_NORETRY | __GFP_NOWARN,
> > >> -               &handle);
> > >> +       ret = zpool_malloc(entry->pool->zpool, len,
> > >> +                          __GFP_NORETRY | __GFP_NOWARN, &handle);
> > >>         if (ret == -ENOSPC) {
> > >>                 zswap_reject_compress_poor++;
> > >> -               goto freepage;
> > >> +               goto put_dstmem;
> > >>         }
> > >>         if (ret) {
> > >>                 zswap_reject_alloc_fail++;
> > >> -               goto freepage;
> > >> +               goto put_dstmem;
> > >>         }
> > >> -       zhdr = zpool_map_handle(zswap_pool, handle, ZPOOL_MM_RW);
> > >> +       zhdr = zpool_map_handle(entry->pool->zpool, handle, ZPOOL_MM_RW);
> > >>         zhdr->swpentry = swp_entry(type, offset);
> > >>         buf = (u8 *)(zhdr + 1);
> > >>         memcpy(buf, dst, dlen);
> > >> -       zpool_unmap_handle(zswap_pool, handle);
> > >> +       zpool_unmap_handle(entry->pool->zpool, handle);
> > >>         put_cpu_var(zswap_dstmem);
> > >>
> > >>         /* populate entry */
> > >> @@ -721,12 +996,14 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> > >>
> > >>         /* update stats */
> > >>         atomic_inc(&zswap_stored_pages);
> > >> -       zswap_pool_total_size = zpool_get_total_size(zswap_pool);
> > >> +       zswap_update_total_size();
> > >>
> > >>         return 0;
> > >>
> > >> -freepage:
> > >> +put_dstmem:
> > >>         put_cpu_var(zswap_dstmem);
> > >> +       zswap_pool_put(entry->pool);
> > >> +freepage:
> > >>         zswap_entry_cache_free(entry);
> > >>  reject:
> > >>         return ret;
> > >> @@ -741,6 +1018,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> > >>  {
> > >>         struct zswap_tree *tree = zswap_trees[type];
> > >>         struct zswap_entry *entry;
> > >> +       struct crypto_comp *tfm;
> > >>         u8 *src, *dst;
> > >>         unsigned int dlen;
> > >>         int ret;
> > >> @@ -757,13 +1035,14 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> > >>
> > >>         /* decompress */
> > >>         dlen = PAGE_SIZE;
> > >> -       src = (u8 *)zpool_map_handle(zswap_pool, entry->handle,
> > >> +       src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
> > >>                         ZPOOL_MM_RO) + sizeof(struct zswap_header);
> > >>         dst = kmap_atomic(page);
> > >> -       ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
> > >> -               dst, &dlen);
> > >> +       tfm = *get_cpu_ptr(entry->pool->tfm);
> > >> +       ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
> > >> +       put_cpu_ptr(entry->pool->tfm);
> > >>         kunmap_atomic(dst);
> > >> -       zpool_unmap_handle(zswap_pool, entry->handle);
> > >> +       zpool_unmap_handle(entry->pool->zpool, entry->handle);
> > >>         BUG_ON(ret);
> > >>
> > >>         spin_lock(&tree->lock);
> > >> @@ -816,10 +1095,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
> > >>         zswap_trees[type] = NULL;
> > >>  }
> > >>
> > >> -static struct zpool_ops zswap_zpool_ops = {
> > >> -       .evict = zswap_writeback_entry
> > >> -};
> > >> -
> > >>  static void zswap_frontswap_init(unsigned type)
> > >>  {
> > >>         struct zswap_tree *tree;
> > >> @@ -900,49 +1175,40 @@ static void __exit zswap_debugfs_exit(void) { }
> > >>  **********************************/
> > >>  static int __init init_zswap(void)
> > >>  {
> > >> -       gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
> > >> +       struct zswap_pool *pool;
> > >>
> > >> -       pr_info("loading zswap\n");
> > >> -
> > >> -       zswap_pool = zpool_create_pool(zswap_zpool_type, "zswap", gfp,
> > >> -                                       &zswap_zpool_ops);
> > >> -       if (!zswap_pool && strcmp(zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT)) {
> > >> -               pr_info("%s zpool not available\n", zswap_zpool_type);
> > >> -               zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
> > >> -               zswap_pool = zpool_create_pool(zswap_zpool_type, "zswap", gfp,
> > >> -                                       &zswap_zpool_ops);
> > >> -       }
> > >> -       if (!zswap_pool) {
> > >> -               pr_err("%s zpool not available\n", zswap_zpool_type);
> > >> -               pr_err("zpool creation failed\n");
> > >> -               goto error;
> > >> -       }
> > >> -       pr_info("using %s pool\n", zswap_zpool_type);
> > >> +       pr_info("loading\n");
> > >>
> > >>         if (zswap_entry_cache_create()) {
> > >>                 pr_err("entry cache creation failed\n");
> > >> -               goto cachefail;
> > >> +               goto cache_fail;
> > >>         }
> > >> -       if (zswap_comp_init()) {
> > >> -               pr_err("compressor initialization failed\n");
> > >> -               goto compfail;
> > >> +
> > >> +       if (zswap_cpu_dstmem_init()) {
> > >> +               pr_err("dstmem alloc failed\n");
> > >> +               goto dstmem_fail;
> > >>         }
> > >> -       if (zswap_cpu_init()) {
> > >> -               pr_err("per-cpu initialization failed\n");
> > >> -               goto pcpufail;
> > >> +
> > >> +       pool = __zswap_pool_create_fallback();
> > >> +       if (!pool) {
> > >> +               pr_err("pool creation failed\n");
> > >> +               goto pool_fail;
> > >>         }
> > >> +       pr_info("loaded using pool %s/%s\n", pool->tfm_name,
> > >> +               zpool_get_type(pool->zpool));
> > >> +
> > >> +       list_add(&pool->list, &zswap_pools);
> > >>
> > >>         frontswap_register_ops(&zswap_frontswap_ops);
> > >>         if (zswap_debugfs_init())
> > >>                 pr_warn("debugfs initialization failed\n");
> > >>         return 0;
> > >> -pcpufail:
> > >> -       zswap_comp_exit();
> > >> -compfail:
> > >> +
> > >> +pool_fail:
> > >> +       zswap_cpu_dstmem_destroy();
> > >> +dstmem_fail:
> > >>         zswap_entry_cache_destroy();
> > >> -cachefail:
> > >> -       zpool_destroy_pool(zswap_pool);
> > >> -error:
> > >> +cache_fail:
> > >>         return -ENOMEM;
> > >>  }
> > >>  /* must be late so crypto has time to come up */
> > >> --
> > >> 2.1.0
> > >>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
