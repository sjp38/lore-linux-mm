Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 27DB86B00AF
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 11:32:58 -0400 (EDT)
Received: by oiag65 with SMTP id g65so19798113oia.2
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 08:32:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id nv12si15349676pdb.56.2015.03.12.13.28.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 13:28:33 -0700 (PDT)
Date: Thu, 12 Mar 2015 13:28:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, mempool: poison elements backed by slab
 allocator
Message-Id: <20150312132832.87c85af5a1bc1978c0d7c049@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Mar 2015 00:21:56 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

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
> This is only effective for configs with CONFIG_DEBUG_VM.

At present CONFIG_DEBUG_VM is pretty lightweight (I hope) and using it
for mempool poisoning might be inappropriately costly.  Would it be
better to tie this to something else?  Either standalone or reuse some
slab debug option, perhaps.

Did you measure the overhead btw?  It might be significant with fast
devices.

> --- a/mm/mempool.c
> +++ b/mm/mempool.c
> @@ -16,16 +16,77 @@
>  #include <linux/blkdev.h>
>  #include <linux/writeback.h>
>  
> +#ifdef CONFIG_DEBUG_VM
> +static void poison_error(mempool_t *pool, void *element, size_t size,
> +			 size_t byte)
> +{
> +	const int nr = pool->curr_nr;
> +	const int start = max_t(int, byte - (BITS_PER_LONG / 8), 0);
> +	const int end = min_t(int, byte + (BITS_PER_LONG / 8), size);
> +	int i;
> +
> +	pr_err("BUG: mempool element poison mismatch\n");
> +	pr_err("Mempool %p size %ld\n", pool, size);
> +	pr_err(" nr=%d @ %p: %s0x", nr, element, start > 0 ? "... " : "");
> +	for (i = start; i < end; i++)
> +		pr_cont("%x ", *(u8 *)(element + i));
> +	pr_cont("%s\n", end < size ? "..." : "");
> +	dump_stack();
> +}

"byte" wasn't a very useful identifier, and it's called "i" in
check_slab_element().  Rename it to "offset" in both places?

> +static void check_slab_element(mempool_t *pool, void *element)
> +{
> +	if (pool->free == mempool_free_slab || pool->free == mempool_kfree) {
> +		size_t size = ksize(element);
> +		u8 *obj = element;
> +		size_t i;
> +
> +		for (i = 0; i < size; i++) {
> +			u8 exp = (i < size - 1) ? POISON_FREE : POISON_END;
> +
> +			if (obj[i] != exp) {
> +				poison_error(pool, element, size, i);
> +				return;
> +			}
> +		}
> +		memset(obj, POISON_INUSE, size);
> +	}
> +}

I question the reuse of POISON_FREE/POISON_INUSE.  If this thing
triggers, it may be hard to tell if it was due to a slab thing or to a
mempool thing.  Using a distinct poison pattern for mempool would clear
that up?

> ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
