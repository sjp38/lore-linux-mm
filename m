Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0E66B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 05:39:03 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so2827334pdi.9
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 02:39:02 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id cv2si9015411pbc.135.2014.06.20.02.39.01
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 02:39:02 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:38:56 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv3 2/5] lib/genalloc.c: Add genpool range check function
Message-ID: <20140620093856.GM25104@arm.com>
References: <1402969165-7526-1-git-send-email-lauraa@codeaurora.org>
 <1402969165-7526-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402969165-7526-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jun 17, 2014 at 02:39:22AM +0100, Laura Abbott wrote:
> After allocating an address from a particular genpool,
> there is no good way to verify if that address actually
> belongs to a genpool. Introduce addr_in_gen_pool which
> will return if an address plus size falls completely
> within the genpool range.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>  include/linux/genalloc.h |  3 +++
>  lib/genalloc.c           | 29 +++++++++++++++++++++++++++++
>  2 files changed, 32 insertions(+)
> 
> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
> index 3cd0934..1ccaab4 100644
> --- a/include/linux/genalloc.h
> +++ b/include/linux/genalloc.h
> @@ -121,6 +121,9 @@ extern struct gen_pool *devm_gen_pool_create(struct device *dev,
>  		int min_alloc_order, int nid);
>  extern struct gen_pool *dev_get_gen_pool(struct device *dev);
>  
> +bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
> +			size_t size);
> +
>  #ifdef CONFIG_OF
>  extern struct gen_pool *of_get_named_gen_pool(struct device_node *np,
>  	const char *propname, int index);
> diff --git a/lib/genalloc.c b/lib/genalloc.c
> index 9758529..66edf93 100644
> --- a/lib/genalloc.c
> +++ b/lib/genalloc.c
> @@ -403,6 +403,35 @@ void gen_pool_for_each_chunk(struct gen_pool *pool,
>  EXPORT_SYMBOL(gen_pool_for_each_chunk);
>  
>  /**
> + * addr_in_gen_pool - checks if an address falls within the range of a pool
> + * @pool:	the generic memory pool
> + * @start:	start address
> + * @size:	size of the region
> + *
> + * Check if the range of addresses falls within the specified pool. Takes
> + * the rcu_read_lock for the duration of the check.
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

Why do you need to check start against the end of the chunk? Is that in case
of overflow?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
