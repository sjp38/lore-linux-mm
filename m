Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 316956B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:33:41 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id e6so3399574otd.17
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:33:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 90si4919522ots.312.2017.12.19.11.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 11:33:40 -0800 (PST)
Date: Tue, 19 Dec 2017 20:33:13 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171219203313.56d42bae@redhat.com>
In-Reply-To: <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
References: <rao.shoaib@oracle.com>
	<1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, brouer@redhat.com


On Tue, 19 Dec 2017 09:52:27 -0800 rao.shoaib@oracle.com wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index c8cb367..06fd12c 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -20,6 +20,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/page.h>
>  #include <linux/memcontrol.h>
> +#include <linux/types.h>
>  
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/kmem.h>
> @@ -129,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
>  
>  	for (i = 0; i < nr; i++) {
>  		void *x = p[i] = kmem_cache_alloc(s, flags);
> +
>  		if (!x) {
>  			__kmem_cache_free_bulk(s, i, p);
>  			return 0;
> @@ -353,6 +355,7 @@ unsigned long calculate_alignment(slab_flags_t flags,
>  	 */
>  	if (flags & SLAB_HWCACHE_ALIGN) {
>  		unsigned long ralign = cache_line_size();
> +
>  		while (size <= ralign / 2)
>  			ralign /= 2;
>  		align = max(align, ralign);
> @@ -444,9 +447,8 @@ kmem_cache_create(const char *name, size_t size, size_t align,
>  	mutex_lock(&slab_mutex);
>  
>  	err = kmem_cache_sanity_check(name, size);
> -	if (err) {
> +	if (err)
>  		goto out_unlock;
> -	}
>  
>  	/* Refuse requests with allocator specific flags */
>  	if (flags & ~SLAB_FLAGS_PERMITTED) {
> @@ -1131,6 +1133,7 @@ EXPORT_SYMBOL(kmalloc_order);
>  void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
>  {
>  	void *ret = kmalloc_order(size, flags, order);
> +
>  	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE << order, flags);
>  	return ret;
>  }

Looks like you are mixing in cleanups (which should be avoided, and
instead moved to another patch).

> @@ -1483,6 +1486,197 @@ void kzfree(const void *p)
[...]
> +
> +/* processes list of rcu structures
> + * used when conatiner can not be allocated
> + */

Spelling.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
