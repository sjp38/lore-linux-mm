Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id EB43F6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 18:19:20 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so3696475igb.2
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:19:20 -0800 (PST)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id f9si3876054igh.23.2015.01.22.15.19.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 15:19:20 -0800 (PST)
Received: by mail-ie0-f180.google.com with SMTP id rl12so4317520iec.11
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:19:20 -0800 (PST)
Date: Thu, 22 Jan 2015 15:19:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slub: suppress BUG messages for
 kmem_cache_alloc/kmem_cache_free
In-Reply-To: <1421932519-21036-1-git-send-email-Andrej.Skvortzov@gmail.com>
Message-ID: <alpine.DEB.2.10.1501221518020.27807@chino.kir.corp.google.com>
References: <1421932519-21036-1-git-send-email-Andrej.Skvortzov@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org

On Thu, 22 Jan 2015, Andrey Skvortsov wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index ceee1d7..6bcd031 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2404,7 +2404,7 @@ redo:
>  	 */
>  	do {
>  		tid = this_cpu_read(s->cpu_slab->tid);
> -		c = this_cpu_ptr(s->cpu_slab);
> +		c = raw_cpu_ptr(s->cpu_slab);
>  	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
>  
>  	/*
> @@ -2670,7 +2670,7 @@ redo:
>  	 */
>  	do {
>  		tid = this_cpu_read(s->cpu_slab->tid);
> -		c = this_cpu_ptr(s->cpu_slab);
> +		c = raw_cpu_ptr(s->cpu_slab);
>  	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
>  
>  	/* Same with comment on barrier() in slab_alloc_node() */

This should already be fixed with 
http://ozlabs.org/~akpm/mmotm/broken-out/mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off-v3.patch

You can find the latest mmotm, which was just released, at 
http://ozlabs.org/~akpm/mmotm and it should be in linux-next tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
