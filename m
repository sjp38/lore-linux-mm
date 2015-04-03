Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 75BF56B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 18:07:23 -0400 (EDT)
Received: by pddn5 with SMTP id n5so133709105pdd.2
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 15:07:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tn1si13581399pab.216.2015.04.03.15.07.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 15:07:21 -0700 (PDT)
Date: Fri, 3 Apr 2015 15:07:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, mempool: kasan: poison mempool elements
Message-Id: <20150403150719.b2197f71260fee25434e49fc@linux-foundation.org>
In-Reply-To: <1428072467-21668-1-git-send-email-a.ryabinin@samsung.com>
References: <1428072467-21668-1-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: David Rientjes <rientjes@google.com>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, Dmitry Chernenkov <drcheren@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On Fri, 03 Apr 2015 17:47:47 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> Mempools keep allocated objects in reserved for situations
> when ordinary allocation may not be possible to satisfy.
> These objects shouldn't be accessed before they leave
> the pool.
> This patch poison elements when get into the pool
> and unpoison when they leave it. This will let KASan
> to detect use-after-free of mempool's elements.
> 
> ...
>
> +static void kasan_poison_element(mempool_t *pool, void *element)
> +{
> +	if (pool->alloc == mempool_alloc_slab)
> +		kasan_slab_free(pool->pool_data, element);
> +	if (pool->alloc == mempool_kmalloc)
> +		kasan_kfree(element);
> +	if (pool->alloc == mempool_alloc_pages)
> +		kasan_free_pages(element, (unsigned long)pool->pool_data);
> +}

We recently discovered that mempool pages (from alloc_pages, not slab)
can be in highmem.  But kasan apepars to handle highmem pages (by
baling out) so we should be OK with that.

Can kasan be taught to use kmap_atomic() or is it more complicated than
that?  It probably isn't worthwhile - highmem pages don'[t get used by the
kernel much and most bugs will be found using 64-bit testing anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
