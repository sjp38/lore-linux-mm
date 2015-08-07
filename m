Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6466B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 02:30:28 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so23632157pdr.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 23:30:28 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id cx7si15878710pad.49.2015.08.06.23.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 23:30:27 -0700 (PDT)
Received: by pabxd6 with SMTP id xd6so62743491pab.2
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 23:30:27 -0700 (PDT)
Date: Fri, 7 Aug 2015 15:30:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/3] zswap: dynamic pool creation
Message-ID: <20150807063056.GG1891@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-3-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438782403-29496-3-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On (08/05/15 09:46), Dan Streetman wrote:
[..]
> -enum comp_op {
> -	ZSWAP_COMPOP_COMPRESS,
> -	ZSWAP_COMPOP_DECOMPRESS
> +struct zswap_pool {
> +	struct zpool *zpool;
> +	struct kref kref;
> +	struct list_head list;
> +	struct rcu_head rcu_head;
> +	struct notifier_block notifier;
> +	char tfm_name[CRYPTO_MAX_ALG_NAME];

do you need to keep a second CRYPTO_MAX_ALG_NAME copy? shouldn't it
be `tfm->__crt_alg->cra_name`, which is what
	crypto_tfm_alg_name(struct crypto_tfm *tfm)
does?

> +	struct crypto_comp * __percpu *tfm;
>  };

->tfm will be access pretty often, right? did you intentionally put it
at the bottom offset of `struct zswap_pool'?

[..]
> +static struct zswap_pool *__zswap_pool_current(void)
>  {
> -	return totalram_pages * zswap_max_pool_percent / 100 <
> -		DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
> +	struct zswap_pool *pool;
> +
> +	pool = list_first_or_null_rcu(&zswap_pools, typeof(*pool), list);
> +	WARN_ON(!pool);
> +
> +	return pool;
> +}
> +
> +static struct zswap_pool *zswap_pool_current(void)
> +{
> +	assert_spin_locked(&zswap_pools_lock);
> +
> +	return __zswap_pool_current();
> +}

this one seems to be used only once. do you want to replace
that single usage (well, if it's really needed)

	WARN_ON(pool == zswap_pool_current());
with
	WARN_ON(pool == __zswap_pool_current);

?

you can then drop zswap_pool_current()... and probably rename
__zswap_pool_current() to zswap_pool_current().

	-ss

> +static struct zswap_pool *zswap_pool_current_get(void)
> +{
> +	struct zswap_pool *pool;
> +
> +	rcu_read_lock();
> +
> +	pool = __zswap_pool_current();
> +	if (!pool || !zswap_pool_get(pool))
> +		pool = NULL;
> +
> +	rcu_read_unlock();
> +
> +	return pool;
> +}
> +
> +static struct zswap_pool *zswap_pool_last_get(void)
> +{
> +	struct zswap_pool *pool, *last = NULL;
> +
> +	rcu_read_lock();
> +
> +	list_for_each_entry_rcu(pool, &zswap_pools, list)
> +		last = pool;
> +	if (!WARN_ON(!last) && !zswap_pool_get(last))
> +		last = NULL;
> +
> +	rcu_read_unlock();
> +
> +	return last;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
