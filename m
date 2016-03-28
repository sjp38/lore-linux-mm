Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 27A706B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 17:19:13 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fe3so106718940pab.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 14:19:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q195si17932726pfq.247.2016.03.28.14.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 14:19:12 -0700 (PDT)
Date: Mon, 28 Mar 2016 14:19:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/11] mm/slab: remove BAD_ALIEN_MAGIC again
Message-Id: <20160328141911.3048ab8d406b86a6e5b9f910@linux-foundation.org>
In-Reply-To: <1459142821-20303-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1459142821-20303-3-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Mar 2016 14:26:52 +0900 js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Initial attemp to remove BAD_ALIEN_MAGIC is once reverted by
> 'commit edcad2509550 ("Revert "slab: remove BAD_ALIEN_MAGIC"")'
> because it causes a problem on m68k which has many node
> but !CONFIG_NUMA.

Whaaa?  How is that even possible?  I'd have thought that everything
would break at compile time (at least) with such a setup.

> In this case, although alien cache isn't used
> at all but to cope with some initialization path, garbage value
> is used and that is BAD_ALIEN_MAGIC. Now, this patch set
> use_alien_caches to 0 when !CONFIG_NUMA, there is no initialization
> path problem so we don't need BAD_ALIEN_MAGIC at all. So remove it.
> 
> ...
>
> @@ -1205,7 +1203,7 @@ void __init kmem_cache_init(void)
>  					sizeof(struct rcu_head));
>  	kmem_cache = &kmem_cache_boot;
>  
> -	if (num_possible_nodes() == 1)
> +	if (!IS_ENABLED(CONFIG_NUMA) || num_possible_nodes() == 1)
>  		use_alien_caches = 0;
>  
>  	for (i = 0; i < NUM_INIT_LISTS; i++)

This does look screwy.  How can num_possible_nodes() possibly return
anything but "1" if CONFIG_NUMA=n.

Can we please get a code comment in here to explain things to the poor
old reader and to prevent people from trying to "fix" it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
