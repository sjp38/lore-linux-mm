Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32DE2C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 11:19:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24ED2089F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 11:19:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24ED2089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B4D86B0003; Tue, 10 Sep 2019 07:19:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5663C6B0006; Tue, 10 Sep 2019 07:19:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47AC26B0007; Tue, 10 Sep 2019 07:19:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 273DD6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:19:08 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 840A89063
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 11:19:07 +0000 (UTC)
X-FDA: 75918764334.27.pet77_3283b3dc46551
X-HE-Tag: pet77_3283b3dc46551
X-Filterd-Recvd-Size: 7962
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 11:19:07 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A9A9BB820;
	Tue, 10 Sep 2019 11:19:05 +0000 (UTC)
Subject: Re: [PATCH] Revert "mm/z3fold.c: fix race between migration and
 destruction"
To: Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?Q?Agust=c3=adn_Dall=27Alba?= <agustin@dallalba.com.ar>,
 Henry Burns <henrywolfeburns@gmail.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 stable <stable@vger.kernel.org>
References: <20190910123142.7a9c8d2de4d0acbc0977c602@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <33f6075c-ffc9-ea6c-129f-8bd47b1a4379@suse.cz>
Date: Tue, 10 Sep 2019 13:19:04 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190910123142.7a9c8d2de4d0acbc0977c602@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/10/19 12:31 PM, Vitaly Wool wrote:
> With the original commit applied, z3fold_zpool_destroy() may
> get blocked on wait_event() for indefinite time. Revert this
> commit for the time being to get rid of this problem since the
> issue the original commit addresses is less severe.
>=20
> This reverts commit d776aaa9895eb6eb770908e899cb7f5bd5025b3c.

Let's make it clear that the revert should go to 5.3 immediately,=20
because the commit above was introduced before 5.3-rc6.

> Reported-by: Agust=C3=ADn Dall'Alba <agustin@dallalba.com.ar>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
Fixes: d776aaa9895e ("mm/z3fold.c: fix race between migration and=20
destruction")
Cc: stable <stable@vger.kernel.org>

d776aaa9895e was Cc: stable, so if stable kernels picked it up, they=20
should pick the revert as well.

> ---
>   mm/z3fold.c | 90 ----------------------------------------------------=
-
>   1 file changed, 90 deletions(-)
>=20
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 75b7962439ff..ed19d98c9dcd 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -41,7 +41,6 @@
>   #include <linux/workqueue.h>
>   #include <linux/slab.h>
>   #include <linux/spinlock.h>
> -#include <linux/wait.h>
>   #include <linux/zpool.h>
>   #include <linux/magic.h>
>  =20
> @@ -146,8 +145,6 @@ struct z3fold_header {
>    * @release_wq:	workqueue for safe page release
>    * @work:	work_struct for safe page release
>    * @inode:	inode for z3fold pseudo filesystem
> - * @destroying: bool to stop migration once we start destruction
> - * @isolated: int to count the number of pages currently in isolation
>    *
>    * This structure is allocated at pool creation time and maintains me=
tadata
>    * pertaining to a particular z3fold pool.
> @@ -166,11 +163,8 @@ struct z3fold_pool {
>   	const struct zpool_ops *zpool_ops;
>   	struct workqueue_struct *compact_wq;
>   	struct workqueue_struct *release_wq;
> -	struct wait_queue_head isolate_wait;
>   	struct work_struct work;
>   	struct inode *inode;
> -	bool destroying;
> -	int isolated;
>   };
>  =20
>   /*
> @@ -775,7 +769,6 @@ static struct z3fold_pool *z3fold_create_pool(const=
 char *name, gfp_t gfp,
>   		goto out_c;
>   	spin_lock_init(&pool->lock);
>   	spin_lock_init(&pool->stale_lock);
> -	init_waitqueue_head(&pool->isolate_wait);
>   	pool->unbuddied =3D __alloc_percpu(sizeof(struct list_head)*NCHUNKS,=
 2);
>   	if (!pool->unbuddied)
>   		goto out_pool;
> @@ -815,15 +808,6 @@ static struct z3fold_pool *z3fold_create_pool(cons=
t char *name, gfp_t gfp,
>   	return NULL;
>   }
>  =20
> -static bool pool_isolated_are_drained(struct z3fold_pool *pool)
> -{
> -	bool ret;
> -
> -	spin_lock(&pool->lock);
> -	ret =3D pool->isolated =3D=3D 0;
> -	spin_unlock(&pool->lock);
> -	return ret;
> -}
>   /**
>    * z3fold_destroy_pool() - destroys an existing z3fold pool
>    * @pool:	the z3fold pool to be destroyed
> @@ -833,22 +817,6 @@ static bool pool_isolated_are_drained(struct z3fol=
d_pool *pool)
>   static void z3fold_destroy_pool(struct z3fold_pool *pool)
>   {
>   	kmem_cache_destroy(pool->c_handle);
> -	/*
> -	 * We set pool-> destroying under lock to ensure that
> -	 * z3fold_page_isolate() sees any changes to destroying. This way we
> -	 * avoid the need for any memory barriers.
> -	 */
> -
> -	spin_lock(&pool->lock);
> -	pool->destroying =3D true;
> -	spin_unlock(&pool->lock);
> -
> -	/*
> -	 * We need to ensure that no pages are being migrated while we destro=
y
> -	 * these workqueues, as migration can queue work on either of the
> -	 * workqueues.
> -	 */
> -	wait_event(pool->isolate_wait, !pool_isolated_are_drained(pool));
>  =20
>   	/*
>   	 * We need to destroy pool->compact_wq before pool->release_wq,
> @@ -1339,28 +1307,6 @@ static u64 z3fold_get_pool_size(struct z3fold_po=
ol *pool)
>   	return atomic64_read(&pool->pages_nr);
>   }
>  =20
> -/*
> - * z3fold_dec_isolated() expects to be called while pool->lock is held=
.
> - */
> -static void z3fold_dec_isolated(struct z3fold_pool *pool)
> -{
> -	assert_spin_locked(&pool->lock);
> -	VM_BUG_ON(pool->isolated <=3D 0);
> -	pool->isolated--;
> -
> -	/*
> -	 * If we have no more isolated pages, we have to see if
> -	 * z3fold_destroy_pool() is waiting for a signal.
> -	 */
> -	if (pool->isolated =3D=3D 0 && waitqueue_active(&pool->isolate_wait))
> -		wake_up_all(&pool->isolate_wait);
> -}
> -
> -static void z3fold_inc_isolated(struct z3fold_pool *pool)
> -{
> -	pool->isolated++;
> -}
> -
>   static bool z3fold_page_isolate(struct page *page, isolate_mode_t mod=
e)
>   {
>   	struct z3fold_header *zhdr;
> @@ -1387,34 +1333,6 @@ static bool z3fold_page_isolate(struct page *pag=
e, isolate_mode_t mode)
>   		spin_lock(&pool->lock);
>   		if (!list_empty(&page->lru))
>   			list_del(&page->lru);
> -		/*
> -		 * We need to check for destruction while holding pool->lock, as
> -		 * otherwise destruction could see 0 isolated pages, and
> -		 * proceed.
> -		 */
> -		if (unlikely(pool->destroying)) {
> -			spin_unlock(&pool->lock);
> -			/*
> -			 * If this page isn't stale, somebody else holds a
> -			 * reference to it. Let't drop our refcount so that they
> -			 * can call the release logic.
> -			 */
> -			if (unlikely(kref_put(&zhdr->refcount,
> -					      release_z3fold_page_locked))) {
> -				/*
> -				 * If we get here we have kref problems, so we
> -				 * should freak out.
> -				 */
> -				WARN(1, "Z3fold is experiencing kref problems\n");
> -				z3fold_page_unlock(zhdr);
> -				return false;
> -			}
> -			z3fold_page_unlock(zhdr);
> -			return false;
> -		}
> -
> -
> -		z3fold_inc_isolated(pool);
>   		spin_unlock(&pool->lock);
>   		z3fold_page_unlock(zhdr);
>   		return true;
> @@ -1483,10 +1401,6 @@ static int z3fold_page_migrate(struct address_sp=
ace *mapping, struct page *newpa
>  =20
>   	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
>  =20
> -	spin_lock(&pool->lock);
> -	z3fold_dec_isolated(pool);
> -	spin_unlock(&pool->lock);
> -
>   	page_mapcount_reset(page);
>   	put_page(page);
>   	return 0;
> @@ -1506,14 +1420,10 @@ static void z3fold_page_putback(struct page *pa=
ge)
>   	INIT_LIST_HEAD(&page->lru);
>   	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
>   		atomic64_dec(&pool->pages_nr);
> -		spin_lock(&pool->lock);
> -		z3fold_dec_isolated(pool);
> -		spin_unlock(&pool->lock);
>   		return;
>   	}
>   	spin_lock(&pool->lock);
>   	list_add(&page->lru, &pool->lru);
> -	z3fold_dec_isolated(pool);
>   	spin_unlock(&pool->lock);
>   	z3fold_page_unlock(zhdr);
>   }
>=20


