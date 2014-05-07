Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C10366B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 16:53:54 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1681407pad.9
        for <linux-mm@kvack.org>; Wed, 07 May 2014 13:53:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ef1si2471372pbc.300.2014.05.07.13.53.53
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 13:53:53 -0700 (PDT)
Date: Wed, 7 May 2014 13:53:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 1/2] memcg: get rid of memcg_create_cache_name
Message-Id: <20140507135352.3790c739ae331d1f6721f3de@linux-foundation.org>
In-Reply-To: <20140507104514.GC4757@esperanza>
References: <a4aa62026c10fc709e8bf13542b29cf771381394.1399450112.git.vdavydov@parallels.com>
	<20140507095127.GC9489@dhcp22.suse.cz>
	<20140507104514.GC4757@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014 14:45:16 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> @@ -3164,6 +3141,7 @@ void memcg_free_cache_params(struct kmem_cache *s)
>  static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
>  				    struct kmem_cache *root_cache)
>  {
> +	static char *memcg_name_buf;	/* protected by memcg_slab_mutex */
>  	struct kmem_cache *cachep;
>  	int id;
>  
> @@ -3179,7 +3157,14 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
>  	if (cache_from_memcg_idx(root_cache, id))
>  		return;
>  
> -	cachep = kmem_cache_create_memcg(memcg, root_cache);
> +	if (!memcg_name_buf) {
> +		memcg_name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
> +		if (!memcg_name_buf)
> +			return;
> +	}

Does this have any meaningful advantage over the simpler

	static char memcg_name_buf[NAME_MAX + 1];

?

I guess it saves a scrap of memory if the machine never uses memcg's.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
