Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4059F6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 04:53:06 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id g10so41743885wrg.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:53:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m144si12861464wma.137.2017.02.27.01.53.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 01:53:05 -0800 (PST)
Date: Mon, 27 Feb 2017 10:52:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Message-ID: <20170227095258.GG14029@dhcp22.suse.cz>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com>
 <20170226043829.14270-1-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170226043829.14270-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 25-02-17 20:38:29, Tahsin Erdogan wrote:
> When pcpu_alloc() is called with gfp != GFP_KERNEL, the likelihood of
> a failure is higher than GFP_KERNEL case. This is mainly because
> pcpu_alloc() relies on previously allocated reserves and does not make
> an effort to add memory to its pools for non-GFP_KERNEL case.

Who is going to use a different mask?
 
> This issue is somewhat mitigated by kicking off a background work when
> a memory allocation failure occurs. But this doesn't really help the
> original victim of allocation failure.
> 
> This problem affects blkg_lookup_create() callers on machines with a
> lot of cpus.
> 
> This patch reduces failure cases by trying to expand the memory pools.
> It passes along gfp flag so it is safe to allocate memory this way.
> 
> To make this work, a gfp flag aware vmalloc_gfp() function is added.
> Also, locking around vmap_area_lock has been updated to save/restore
> irq flags. This was needed to avoid a lockdep problem between
> request_queue->queue_lock and vmap_area_lock.

We already have __vmalloc_gfp, why this cannot be used? Also note that
vmalloc dosn't really support arbitrary gfp flags. One have to be really
careful because there are some internal allocations which are hardcoded
GFP_KERNEL. Also this patch doesn't really add any new callers so it is
hard to tell whether what you do actually makes sense and is correct.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
