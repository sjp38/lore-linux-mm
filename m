Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93AD383200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 12:39:23 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id a6so24704750lfa.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 09:39:23 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id k66si1931289lfe.160.2017.03.08.09.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 09:39:21 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id v2so2877834lfi.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 09:39:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
References: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487952313-22381-2-git-send-email-Mahipal.Challa@cavium.com>
 <CALZtONBeS7bAjxpbLDdQj=y_tsXUX5TVCFdqbQ3LccTSa6kfnw@mail.gmail.com> <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 8 Mar 2017 12:38:40 -0500
Message-ID: <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] mm: zswap - Add crypto acomp/scomp framework support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahipal Reddy <mahipalreddy2006@gmail.com>
Cc: Mahipal Challa <Mahipal.Challa@cavium.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-kernel <linux-kernel@vger.kernel.org>, pathreya@cavium.com, Vishnu Nair <Vishnu.Nair@cavium.com>

On Mon, Feb 27, 2017 at 9:40 AM, Mahipal Reddy
<mahipalreddy2006@gmail.com> wrote:
> Hi Dan,
> Thanks for your reply.
>
> On Sat, Feb 25, 2017 at 3:51 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Fri, Feb 24, 2017 at 11:05 AM, Mahipal Challa
>> <Mahipal.Challa@cavium.com> wrote:
>>> This adds support for kernel's new crypto acomp/scomp framework
>>> to zswap.
>>
>> I don't understand the point of this, zswap can't compress pages
>> asynchronously, so what benefit do we get from using the async crypto
>> api and then immediately waiting for it to finish?  This seems like
>> it's just adding complexity for no reason?
>
> 1) The new crypto acomp/scomp framework, provides both synchronous and
> asynchronous comp/decomp
> functionality with the same async-crypto(acomp) api(include/crypto/acompress.h).
>
> 2) Currently with new crypto acomp/scomp framework, the crypto
> sub-system(crypto/lzo.c, crypto/deflate.c)
> only supports synchronous mode of compression/decompression which
> meets the zswap requirement.
>
> 3) The new crypto acomp/scomp framework is introduced in the 4.10.xx kernel.
> With this new framework, according to Herbert Xu, existing crypto
> comp(CRYPTO_ALG_TYPE_COMPRESS ) api
> is going to be deprecated (which zswap uses).

zswap gets the fun of being the first crypto compression consumer to
switch to the new api? ;-)

It looks like the crypto_scomp interface is buried under
include/crypto/internal/scompress.h, however that's exactly what zswap
should be using.  We don't need to switch to an asynchronous interface
that's rather significantly more complicated, and then use it in a
synchronous way.  The crypto_scomp interface should probably be made
public, not an implementation internal.


>
> 4) Applications like zswap, which use comp/decomp of crypto subsystem,
> at some point will have to be ported to
> the new framework.
>
> Regards,
> -Mahipal
>
>>> Signed-off-by: Mahipal Challa <Mahipal.Challa@cavium.com>
>>> Signed-off-by: Vishnu Nair <Vishnu.Nair@cavium.com>
>>> ---
>>>  mm/zswap.c | 192 +++++++++++++++++++++++++++++++++++++++++++++++++++----------
>>>  1 file changed, 162 insertions(+), 30 deletions(-)
>>>
>>> diff --git a/mm/zswap.c b/mm/zswap.c
>>> index cabf09e..b29d109 100644
>>> --- a/mm/zswap.c
>>> +++ b/mm/zswap.c
>>> @@ -33,8 +33,10 @@
>>>  #include <linux/rbtree.h>
>>>  #include <linux/swap.h>
>>>  #include <linux/crypto.h>
>>> +#include <linux/scatterlist.h>
>>>  #include <linux/mempool.h>
>>>  #include <linux/zpool.h>
>>> +#include <crypto/acompress.h>
>>>
>>>  #include <linux/mm_types.h>
>>>  #include <linux/page-flags.h>
>>> @@ -118,9 +120,21 @@ static int zswap_compressor_param_set(const char *,
>>>  * data structures
>>>  **********************************/
>>>
>>> +/**
>>> + * struct zswap_acomp_result - Data structure to store result of acomp callback
>>> + * @completion: zswap will wait for completion on this entry
>>> + * @err       : return value from acomp algorithm will be stored here
>>> + */
>>> +struct zswap_acomp_result {
>>> +       struct completion completion;
>>> +       int err;
>>> +};
>>> +
>>>  struct zswap_pool {
>>>         struct zpool *zpool;
>>> -       struct crypto_comp * __percpu *tfm;
>>> +       struct crypto_acomp * __percpu *acomp;
>>> +       struct acomp_req * __percpu *acomp_req;
>>> +       struct zswap_acomp_result * __percpu *result;
>>>         struct kref kref;
>>>         struct list_head list;
>>>         struct work_struct work;
>>> @@ -388,30 +402,66 @@ static int zswap_dstmem_dead(unsigned int cpu)
>>>  static int zswap_cpu_comp_prepare(unsigned int cpu, struct hlist_node *node)
>>>  {
>>>         struct zswap_pool *pool = hlist_entry(node, struct zswap_pool, node);
>>> -       struct crypto_comp *tfm;
>>> +       struct crypto_acomp *acomp;
>>> +       struct acomp_req *acomp_req;
>>> +       struct zswap_acomp_result *result;
>>>
>>> -       if (WARN_ON(*per_cpu_ptr(pool->tfm, cpu)))
>>> +       if (WARN_ON(*per_cpu_ptr(pool->acomp, cpu)))
>>>                 return 0;
>>> +       if (WARN_ON(*per_cpu_ptr(pool->acomp_req, cpu)))
>>> +               return 0;
>>> +       if (WARN_ON(*per_cpu_ptr(pool->result, cpu)))
>>> +               return 0;
>>> +
>>> +       acomp = crypto_alloc_acomp(pool->tfm_name, 0, 0);
>>> +       if (IS_ERR_OR_NULL(acomp)) {
>>> +               pr_err("could not alloc crypto acomp %s : %ld\n",
>>> +                      pool->tfm_name, PTR_ERR(acomp));
>>> +               return -ENOMEM;
>>> +       }
>>> +       *per_cpu_ptr(pool->acomp, cpu) = acomp;
>>> +
>>> +       acomp_req = acomp_request_alloc(acomp);
>>> +       if (IS_ERR_OR_NULL(acomp_req)) {
>>> +               pr_err("could not alloc crypto acomp %s : %ld\n",
>>> +                      pool->tfm_name, PTR_ERR(acomp));
>>> +               return -ENOMEM;
>>> +       }
>>> +       *per_cpu_ptr(pool->acomp_req, cpu) = acomp_req;
>>>
>>> -       tfm = crypto_alloc_comp(pool->tfm_name, 0, 0);
>>> -       if (IS_ERR_OR_NULL(tfm)) {
>>> -               pr_err("could not alloc crypto comp %s : %ld\n",
>>> -                      pool->tfm_name, PTR_ERR(tfm));
>>> +       result = kzalloc(sizeof(*result), GFP_KERNEL);
>>> +       if (IS_ERR_OR_NULL(result)) {
>>> +               pr_err("Could not initialize completion on result\n");
>>>                 return -ENOMEM;
>>>         }
>>> -       *per_cpu_ptr(pool->tfm, cpu) = tfm;
>>> +       init_completion(&result->completion);
>>> +       *per_cpu_ptr(pool->result, cpu) = result;
>>> +
>>>         return 0;
>>>  }
>>>
>>>  static int zswap_cpu_comp_dead(unsigned int cpu, struct hlist_node *node)
>>>  {
>>>         struct zswap_pool *pool = hlist_entry(node, struct zswap_pool, node);
>>> -       struct crypto_comp *tfm;
>>> +       struct crypto_acomp *acomp;
>>> +       struct acomp_req *acomp_req;
>>> +       struct zswap_acomp_result *result;
>>> +
>>> +       acomp_req = *per_cpu_ptr(pool->acomp_req, cpu);
>>> +       if (!IS_ERR_OR_NULL(acomp_req))
>>> +               acomp_request_free(acomp_req);
>>> +       *per_cpu_ptr(pool->acomp_req, cpu) = NULL;
>>> +
>>> +       acomp = *per_cpu_ptr(pool->acomp, cpu);
>>> +       if (!IS_ERR_OR_NULL(acomp))
>>> +               crypto_free_acomp(acomp);
>>> +       *per_cpu_ptr(pool->acomp, cpu) = NULL;
>>> +
>>> +       result = *per_cpu_ptr(pool->result, cpu);
>>> +       if (!IS_ERR_OR_NULL(result))
>>> +               kfree(result);
>>> +       *per_cpu_ptr(pool->result, cpu) = NULL;
>>>
>>> -       tfm = *per_cpu_ptr(pool->tfm, cpu);
>>> -       if (!IS_ERR_OR_NULL(tfm))
>>> -               crypto_free_comp(tfm);
>>> -       *per_cpu_ptr(pool->tfm, cpu) = NULL;
>>>         return 0;
>>>  }
>>>
>>> @@ -512,8 +562,20 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
>>>         pr_debug("using %s zpool\n", zpool_get_type(pool->zpool));
>>>
>>>         strlcpy(pool->tfm_name, compressor, sizeof(pool->tfm_name));
>>> -       pool->tfm = alloc_percpu(struct crypto_comp *);
>>> -       if (!pool->tfm) {
>>> +       pool->acomp = alloc_percpu(struct crypto_acomp *);
>>> +       if (!pool->acomp) {
>>> +               pr_err("percpu alloc failed\n");
>>> +               goto error;
>>> +       }
>>> +
>>> +       pool->acomp_req = alloc_percpu(struct acomp_req *);
>>> +       if (!pool->acomp_req) {
>>> +               pr_err("percpu alloc failed\n");
>>> +               goto error;
>>> +       }
>>> +
>>> +       pool->result = alloc_percpu(struct zswap_acomp_result *);
>>> +       if (!pool->result) {
>>>                 pr_err("percpu alloc failed\n");
>>>                 goto error;
>>>         }
>>> @@ -535,7 +597,9 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
>>>         return pool;
>>>
>>>  error:
>>> -       free_percpu(pool->tfm);
>>> +       free_percpu(pool->result);
>>> +       free_percpu(pool->acomp_req);
>>> +       free_percpu(pool->acomp);
>>>         if (pool->zpool)
>>>                 zpool_destroy_pool(pool->zpool);
>>>         kfree(pool);
>>> @@ -575,7 +639,9 @@ static void zswap_pool_destroy(struct zswap_pool *pool)
>>>         zswap_pool_debug("destroying", pool);
>>>
>>>         cpuhp_state_remove_instance(CPUHP_MM_ZSWP_POOL_PREPARE, &pool->node);
>>> -       free_percpu(pool->tfm);
>>> +       free_percpu(pool->result);
>>> +       free_percpu(pool->acomp_req);
>>> +       free_percpu(pool->acomp);
>>>         zpool_destroy_pool(pool->zpool);
>>>         kfree(pool);
>>>  }
>>> @@ -622,6 +688,30 @@ static void zswap_pool_put(struct zswap_pool *pool)
>>>  }
>>>
>>>  /*********************************
>>> +* CRYPTO_ACOMPRESS wait and callbacks
>>> +**********************************/
>>> +static void zswap_acomp_callback(struct crypto_async_request *req, int err)
>>> +{
>>> +       struct zswap_acomp_result *res = req->data;
>>> +
>>> +       if (err == -EINPROGRESS)
>>> +               return;
>>> +
>>> +       res->err = err;
>>> +       complete(&res->completion);
>>> +}
>>> +
>>> +static int zswap_wait_acomp(struct zswap_acomp_result *res, int ret)
>>> +{
>>> +       if (ret == -EINPROGRESS || ret == -EBUSY) {
>>> +               wait_for_completion(&res->completion);
>>> +               reinit_completion(&res->completion);
>>> +               ret = res->err;
>>> +       }
>>> +       return ret;
>>> +}
>>> +
>>> +/*********************************
>>>  * param callbacks
>>>  **********************************/
>>>
>>> @@ -788,7 +878,9 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>>>         pgoff_t offset;
>>>         struct zswap_entry *entry;
>>>         struct page *page;
>>> -       struct crypto_comp *tfm;
>>> +       struct scatterlist input, output;
>>> +       struct acomp_req *req;
>>> +       struct zswap_acomp_result *result;
>>>         u8 *src, *dst;
>>>         unsigned int dlen;
>>>         int ret;
>>> @@ -828,14 +920,25 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>>>
>>>         case ZSWAP_SWAPCACHE_NEW: /* page is locked */
>>>                 /* decompress */
>>> +               req = *get_cpu_ptr(entry->pool->acomp_req);
>>>                 dlen = PAGE_SIZE;
>>>                 src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
>>>                                 ZPOOL_MM_RO) + sizeof(struct zswap_header);
>>>                 dst = kmap_atomic(page);
>>> -               tfm = *get_cpu_ptr(entry->pool->tfm);
>>> -               ret = crypto_comp_decompress(tfm, src, entry->length,
>>> -                                            dst, &dlen);
>>> -               put_cpu_ptr(entry->pool->tfm);
>>> +
>>> +               result = *get_cpu_ptr(entry->pool->result);
>>> +               sg_init_one(&input, src, entry->length);
>>> +               sg_init_one(&output, dst, dlen);
>>> +               acomp_request_set_params(req, &input, &output, entry->length,
>>> +                                        dlen);
>>> +               acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
>>> +                                          zswap_acomp_callback, result);
>>> +
>>> +               ret = zswap_wait_acomp(result, crypto_acomp_decompress(req));
>>> +
>>> +               dlen = req->dlen;
>>> +               put_cpu_ptr(entry->pool->acomp_req);
>>> +               put_cpu_ptr(entry->pool->result);
>>>                 kunmap_atomic(dst);
>>>                 zpool_unmap_handle(entry->pool->zpool, entry->handle);
>>>                 BUG_ON(ret);
>>> @@ -911,7 +1014,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>>  {
>>>         struct zswap_tree *tree = zswap_trees[type];
>>>         struct zswap_entry *entry, *dupentry;
>>> -       struct crypto_comp *tfm;
>>> +       struct scatterlist input, output;
>>> +       struct acomp_req *req;
>>> +       struct zswap_acomp_result *result;
>>>         int ret;
>>>         unsigned int dlen = PAGE_SIZE, len;
>>>         unsigned long handle;
>>> @@ -950,12 +1055,24 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>>>         }
>>>
>>>         /* compress */
>>> +       req = *get_cpu_ptr(entry->pool->acomp_req);
>>> +       result = *get_cpu_ptr(entry->pool->result);
>>> +
>>>         dst = get_cpu_var(zswap_dstmem);
>>> -       tfm = *get_cpu_ptr(entry->pool->tfm);
>>>         src = kmap_atomic(page);
>>> -       ret = crypto_comp_compress(tfm, src, PAGE_SIZE, dst, &dlen);
>>> +
>>> +       sg_init_one(&input, src, PAGE_SIZE);
>>> +       /* zswap_dstmem is of size (PAGE_SIZE * 2). Reflect same in sg_list */
>>> +       sg_init_one(&output, dst, PAGE_SIZE * 2);
>>> +       acomp_request_set_params(req, &input, &output, PAGE_SIZE, dlen);
>>> +       acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
>>> +                                  zswap_acomp_callback, result);
>>> +
>>> +       ret = zswap_wait_acomp(result, crypto_acomp_compress(req));
>>>         kunmap_atomic(src);
>>> -       put_cpu_ptr(entry->pool->tfm);
>>> +       put_cpu_ptr(entry->pool->acomp_req);
>>> +       put_cpu_ptr(entry->pool->result);
>>> +       dlen = req->dlen;
>>>         if (ret) {
>>>                 ret = -EINVAL;
>>>                 goto put_dstmem;
>>> @@ -1023,7 +1140,9 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>>>  {
>>>         struct zswap_tree *tree = zswap_trees[type];
>>>         struct zswap_entry *entry;
>>> -       struct crypto_comp *tfm;
>>> +       struct scatterlist input, output;
>>> +       struct acomp_req *req;
>>> +       struct zswap_acomp_result *result;
>>>         u8 *src, *dst;
>>>         unsigned int dlen;
>>>         int ret;
>>> @@ -1039,13 +1158,25 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
>>>         spin_unlock(&tree->lock);
>>>
>>>         /* decompress */
>>> +       req = *get_cpu_ptr(entry->pool->acomp_req);
>>> +       result = *get_cpu_ptr(entry->pool->result);
>>> +
>>>         dlen = PAGE_SIZE;
>>>         src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
>>>                         ZPOOL_MM_RO) + sizeof(struct zswap_header);
>>>         dst = kmap_atomic(page);
>>> -       tfm = *get_cpu_ptr(entry->pool->tfm);
>>> -       ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
>>> -       put_cpu_ptr(entry->pool->tfm);
>>> +
>>> +       sg_init_one(&input, src, entry->length);
>>> +       sg_init_one(&output, dst, dlen);
>>> +       acomp_request_set_params(req, &input, &output, entry->length, dlen);
>>> +       acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
>>> +                                  zswap_acomp_callback, result);
>>> +
>>> +       ret = zswap_wait_acomp(result, crypto_acomp_decompress(req));
>>> +
>>> +       dlen = req->dlen;
>>> +       put_cpu_ptr(entry->pool->acomp_req);
>>> +       put_cpu_ptr(entry->pool->result);
>>>         kunmap_atomic(dst);
>>>         zpool_unmap_handle(entry->pool->zpool, entry->handle);
>>>         BUG_ON(ret);
>>> @@ -1237,3 +1368,4 @@ static int __init init_zswap(void)
>>>  MODULE_LICENSE("GPL");
>>>  MODULE_AUTHOR("Seth Jennings <sjennings@variantweb.net>");
>>>  MODULE_DESCRIPTION("Compressed cache for swap pages");
>>> +
>>> --
>>> 1.8.3.1
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
