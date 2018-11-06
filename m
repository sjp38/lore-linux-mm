Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 148506B0386
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 13:12:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id j13-v6so13134376pff.0
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 10:12:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v7-v6si47842535plp.420.2018.11.06.10.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 10:12:14 -0800 (PST)
Date: Tue, 6 Nov 2018 10:12:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7] mm, drm/i915: mark pinned shmemfs pages as
 unevictable
Message-Id: <20181106101211.d2e4857aa36ea8ffbd870d2f@linux-foundation.org>
In-Reply-To: <20181106132324.17390-1-chris@chris-wilson.co.uk>
References: <20181106093100.71829-1-vovoy@chromium.org>
	<20181106132324.17390-1-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kuo-Hsin Yang <vovoy@chromium.org>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>

On Tue,  6 Nov 2018 13:23:24 +0000 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> From: Kuo-Hsin Yang <vovoy@chromium.org>
> 
> The i915 driver uses shmemfs to allocate backing storage for gem
> objects. These shmemfs pages can be pinned (increased ref count) by
> shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> wastes a lot of time scanning these pinned pages. In some extreme case,
> all pages in the inactive anon lru are pinned, and only the inactive
> anon lru is scanned due to inactive_ratio, the system cannot swap and
> invokes the oom-killer. Mark these pinned pages as unevictable to speed
> up vmscan.
> 
> Export pagevec API check_move_unevictable_pages().
> 
> This patch was inspired by Chris Wilson's change [1].
> 
> [1]: https://patchwork.kernel.org/patch/9768741/
> 
> ...
>
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -2382,12 +2382,26 @@ void __i915_gem_object_invalidate(struct drm_i915_gem_object *obj)
>  	invalidate_mapping_pages(mapping, 0, (loff_t)-1);
>  }
>  
> +/**

This token is used to introduce a kerneldoc comment.

> + * Move pages to appropriate lru and release the pagevec. Decrement the ref
> + * count of these pages.
> + */

But this isn't a kerneldoc comment.

At least, I don't think it is.  Maybe the parser got smarter when I
wasn't looking.

> +static inline void check_release_pagevec(struct pagevec *pvec)
> +{
> +	if (pagevec_count(pvec)) {
> +		check_move_unevictable_pages(pvec);
> +		__pagevec_release(pvec);
> +		cond_resched();
> +	}
> +}

This looks too large to be inlined and the compiler will ignore the
`inline' anyway.


Otherwise, Acked-by: Andrew Morton <akpm@linux-foundation.org>.  Please
go ahead and merge via the appropriate drm tree.
