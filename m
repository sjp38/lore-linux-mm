Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8DD6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:59:58 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so123625270pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:59:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id rr5si15836775pab.153.2015.08.25.05.59.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 05:59:57 -0700 (PDT)
Date: Tue, 25 Aug 2015 14:59:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/3 v6] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150825125951.GR16853@twins.programming.kicks-ass.net>
References: <20150824075018.GB20106@gmail.com>
 <20150824125402.28806.qmail@ns.horizon.com>
 <20150825095638.GA24750@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825095638.GA24750@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

On Tue, Aug 25, 2015 at 11:56:38AM +0200, Ingo Molnar wrote:
> +void get_vmalloc_info(struct vmalloc_info *vmi)
> +{
> +	unsigned int cache_gen, gen;

I see you dropped the u64 thing, good, ignore that previous email.

> +
> +	/*
> +	 * The common case is that the cache is valid, so first
> +	 * read it, then check its validity.
> +	 *
> +	 * The two read barriers make sure that we read
> +	 * 'cache_gen', 'vmap_info_cache' and 'gen' in
> +	 * precisely that order:
> +	 */
> +	cache_gen = vmap_info_cache_gen;
> +	smp_rmb();
> +	*vmi = vmap_info_cache;
> +	smp_rmb();
> +	gen = vmap_info_gen;
> +
> +	/*
> +	 * If the generation counter of the cache matches that of
> +	 * the vmalloc generation counter then return the cache:
> +	 */
> +	if (cache_gen == gen)
> +		return;

There is one aspect of READ_ONCE() that is not replaced with smp_rmb(),
and that is that READ_ONCE() should avoid split loads.

Without READ_ONCE() the compiler is free to turn the loads into separate
and out of order byte loads just because its insane, thereby also making
the WRITE_ONCE() pointless.

Now I'm fairly sure it all doesn't matter much, the info can change the
moment we've copied it, so the read is inherently racy.

And by that same argument I feel this is all somewhat over engineered.

> +
> +	/* Make sure 'gen' is read before the vmalloc info: */
> +	smp_rmb();
> +	calc_vmalloc_info(vmi);
> +
> +	/*
> +	 * All updates to vmap_info_cache_gen go through this spinlock,
> +	 * so when the cache got invalidated, we'll only mark it valid
> +	 * again if we first fully write the new vmap_info_cache.
> +	 *
> +	 * This ensures that partial results won't be used and that the
> +	 * vmalloc info belonging to the freshest update is used:
> +	 */
> +	spin_lock(&vmap_info_lock);
> +	if ((int)(gen-vmap_info_cache_gen) > 0) {
> +		vmap_info_cache = *vmi;
> +		/*
> +		 * Make sure the new cached data is visible before
> +		 * the generation counter update:
> +		 */
> +		smp_wmb();
> +		vmap_info_cache_gen = gen;
> +	}
> +	spin_unlock(&vmap_info_lock);
> +}
> +
> +#endif /* CONFIG_PROC_FS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
