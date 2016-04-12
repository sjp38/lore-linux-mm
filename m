Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5741F6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 12:38:42 -0400 (EDT)
Received: by mail-io0-f175.google.com with SMTP id g185so35551702ioa.2
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 09:38:42 -0700 (PDT)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id i72si23370338ioe.22.2016.04.12.09.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 09:38:41 -0700 (PDT)
Date: Tue, 12 Apr 2016 11:38:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 01/11] mm/slab: fix the theoretical race by holding
 proper lock
In-Reply-To: <1460436666-20462-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1604121137470.14315@east.gentwo.org>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com> <1460436666-20462-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 12 Apr 2016, js1304@gmail.com wrote:

> @@ -2222,6 +2241,7 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
>  {
>  	struct kmem_cache_node *n;
>  	int node;
> +	LIST_HEAD(list);
>
>  	on_each_cpu(do_drain, cachep, 1);
>  	check_irq_on();
> @@ -2229,8 +2249,13 @@ static void drain_cpu_caches(struct kmem_cache *cachep)
>  		if (n->alien)
>  			drain_alien_cache(cachep, n->alien);
>
> -	for_each_kmem_cache_node(cachep, node, n)
> -		drain_array(cachep, n, n->shared, 1, node);
> +	for_each_kmem_cache_node(cachep, node, n) {
> +		spin_lock_irq(&n->list_lock);
> +		drain_array_locked(cachep, n->shared, node, true, &list);
> +		spin_unlock_irq(&n->list_lock);
> +
> +		slabs_destroy(cachep, &list);

Can the slabs_destroy() call be moved outside of the loop? It may be
faster then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
