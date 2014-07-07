Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id AFFD66B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:24:39 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so3721927qgd.33
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:24:39 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id z6si23531266qgz.98.2014.07.07.08.24.38
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 08:24:38 -0700 (PDT)
Date: Mon, 7 Jul 2014 10:24:35 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 2/8] memcg: keep all children of each root cache on
 a list
In-Reply-To: <e58c0491eebc594f6e80a91dc0ed6905d65050bd.1404733720.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1407071022200.22121@gentwo.org>
References: <cover.1404733720.git.vdavydov@parallels.com> <e58c0491eebc594f6e80a91dc0ed6905d65050bd.1404733720.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 Jul 2014, Vladimir Davydov wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index d31c4bacc6a2..95a8f772b0d1 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -294,8 +294,12 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  	if (IS_ERR(s)) {
>  		kfree(cache_name);
>  		s = NULL;
> +		goto out_unlock;
>  	}
>
> +	list_add(&s->memcg_params->siblings,
> +		 &root_cache->memcg_params->children);
> +
>  out_unlock:
>  	mutex_unlock(&slab_mutex);
>

If there is an error then s is set to NULL. And then
the list_add is done dereferencing s?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
