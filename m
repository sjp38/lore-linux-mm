Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 13FDC6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:47:19 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so63368169wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:47:18 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id ff10si30575045wjc.32.2015.08.24.00.47.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 00:47:17 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so41206461wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 00:47:17 -0700 (PDT)
Date: Mon, 24 Aug 2015 09:47:14 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3 v4] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150824074714.GA20106@gmail.com>
References: <20150823081750.GA28349@gmail.com>
 <20150824010403.27903.qmail@ns.horizon.com>
 <20150824073422.GC13082@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824073422.GC13082@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* Ingo Molnar <mingo@kernel.org> wrote:

> +/*
> + * Return a consistent snapshot of the current vmalloc allocation
> + * statistics, for /proc/meminfo:
> + */
> +void get_vmalloc_info(struct vmalloc_info *vmi)
> +{
> +	int gen = READ_ONCE(vmap_info_gen);
> +
> +	/*
> +	 * If the generation counter of the cache matches that of
> +	 * the vmalloc generation counter then return the cache:
> +	 */
> +	if (READ_ONCE(vmap_info_cache_gen) == gen) {
> +		int gen_after;
> +
> +		/*
> +		 * The two read barriers make sure that we read
> +		 * 'gen', 'vmap_info_cache' and 'gen_after' in
> +		 * precisely that order:
> +		 */
> +		smp_rmb();
> +		*vmi = vmap_info_cache;
> +
> +		smp_rmb();
> +		gen_after = READ_ONCE(vmap_info_gen);
> +
> +		/* The cache is still valid: */
> +		if (gen == gen_after)
> +			return;
> +
> +		/* Ok, the cache got invalidated just now, regenerate it */
> +		gen = gen_after;
> +	}

One more detail: I just realized that with the read barriers, the READ_ONCE() 
accesses are not needed anymore - the barriers and the control dependencies are 
enough.

This will further simplify the code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
