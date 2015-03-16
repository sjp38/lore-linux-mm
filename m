Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id D5D536B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 06:47:00 -0400 (EDT)
Received: by lbbzq9 with SMTP id zq9so28427600lbb.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:47:00 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id zj11si7765497lbb.148.2015.03.16.03.46.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 03:46:59 -0700 (PDT)
Received: by lbcds1 with SMTP id ds1so28402434lbc.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:46:58 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [patch 1/2] mm, mempool: poison elements backed by slab allocator
References: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
Date: Mon, 16 Mar 2015 11:46:56 +0100
In-Reply-To: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
	(David Rientjes's message of "Mon, 9 Mar 2015 00:21:56 -0700 (PDT)")
Message-ID: <8761a1dxsv.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 09 2015, David Rientjes <rientjes@google.com> wrote:

> Mempools keep elements in a reserved pool for contexts in which
> allocation may not be possible.  When an element is allocated from the
> reserved pool, its memory contents is the same as when it was added to
> the reserved pool.
>
> Because of this, elements lack any free poisoning to detect
> use-after-free errors.
>
> This patch adds free poisoning for elements backed by the slab allocator.
> This is possible because the mempool layer knows the object size of each
> element.
>
> When an element is added to the reserved pool, it is poisoned with
> POISON_FREE.  When it is removed from the reserved pool, the contents are
> checked for POISON_FREE.  If there is a mismatch, a warning is emitted to
> the kernel log.
>
> +
> +static void poison_slab_element(mempool_t *pool, void *element)
> +{
> +	if (pool->alloc == mempool_alloc_slab ||
> +	    pool->alloc == mempool_kmalloc) {
> +		size_t size = ksize(element);
> +		u8 *obj = element;
> +
> +		memset(obj, POISON_FREE, size - 1);
> +		obj[size - 1] = POISON_END;
> +	}
> +}

Maybe a stupid question, but what happens if the underlying slab
allocator has non-trivial ->ctor?

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
