Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 46C416B003A
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:40:11 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id h18so1762436igc.6
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:40:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g20si18846121ici.46.2014.08.08.15.40.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Aug 2014 15:40:10 -0700 (PDT)
Date: Fri, 8 Aug 2014 15:40:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv6 2/5] lib/genalloc.c: Add genpool range check function
Message-Id: <20140808154008.4e5183b67d29159a83ffcf25@linux-foundation.org>
In-Reply-To: <1407529397-6642-2-git-send-email-lauraa@codeaurora.org>
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
	<1407529397-6642-2-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Fri,  8 Aug 2014 13:23:14 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:

> 
> After allocating an address from a particular genpool,
> there is no good way to verify if that address actually
> belongs to a genpool. Introduce addr_in_gen_pool which
> will return if an address plus size falls completely
> within the genpool range.
> 
> ...
>
>  /**
> + * addr_in_gen_pool - checks if an address falls within the range of a pool
> + * @pool:	the generic memory pool
> + * @start:	start address
> + * @size:	size of the region
> + *
> + * Check if the range of addresses falls within the specified pool.

This description should make it clear that the entire range must be
within the pool - that an overlap is "no".

>     Takes
> + * the rcu_read_lock for the duration of the check.

I don't think this part is worth including.

> + */
> +bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
> +			size_t size)
> +{
> +	bool found = false;
> +	unsigned long end = start + size;
> +	struct gen_pool_chunk *chunk;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(chunk, &(pool)->chunks, next_chunk) {
> +		if (start >= chunk->start_addr && start <= chunk->end_addr) {
> +			if (end <= chunk->end_addr) {
> +				found = true;
> +				break;
> +			}
> +		}
> +	}
> +	rcu_read_unlock();
> +	return found;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
