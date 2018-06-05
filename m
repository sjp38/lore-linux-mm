Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21B176B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 13:54:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x203-v6so1633564wmg.8
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 10:54:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor24195436wry.4.2018.06.05.10.54.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 10:54:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416205150.113915-2-shakeelb@google.com>
References: <20180416205150.113915-1-shakeelb@google.com> <20180416205150.113915-2-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 5 Jun 2018 10:54:18 -0700
Message-ID: <CALvZod5buYF8O2TWq06f=M1SyJdS0vJrFhkH4FQw2Ga1qv3GsA@mail.gmail.com>
Subject: Re: [PATCH v5 1/2] mm: memcg: remote memcg charging for kmem allocations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

On Mon, Apr 16, 2018 at 1:51 PM, Shakeel Butt <shakeelb@google.com> wrote:
> Introduce the memcg variant for kmalloc[_node] and
> kmem_cache_alloc[_node].  For kmem_cache_alloc, the kernel switches the
> root kmem cache with the memcg specific kmem cache for __GFP_ACCOUNT
> allocations to charge those allocations to the memcg.  However, the memcg
> to charge is extracted from the current task_struct.  This patch
> introduces the variant of kmem cache allocation functions where the memcg
> can be provided explicitly by the caller instead of deducing the memcg
> from the current task.
>
> The kmalloc allocations are underlying served using the kmem caches unless
> the size of the allocation request is larger than KMALLOC_MAX_CACHE_SIZE,
> in which case, the kmem caches are bypassed and the request is routed
> directly to page allocator.  So, for __GFP_ACCOUNT kmalloc allocations,
> the memcg of current task is charged.  This patch introduces memcg variant
> of kmalloc functions to allow callers to provide memcg for charging.
>
> These functions are useful for use-cases where the allocations should be
> charged to the memcg different from the memcg of the caller.  One such
> concrete use-case is the allocations for fsnotify event objects where the
> objects should be charged to the listener instead of the producer.
>
> One requirement to call these functions is that the caller must have the
> reference to the memcg.  Using kmalloc_memcg and kmem_cache_alloc_memcg
> implicitly assumes that the caller is requesting a __GFP_ACCOUNT
> allocation.
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

I will send the v6 of this patchset after this merge window. In v6, I
will make memalloc_memcg_[save|restore] scope API similar to NOFS,
NOIO and NORECLAIM APIs.

> ---
> Changelog since v4:
> - Removed branch from hot path of memory charging.
>
> Changelog since v3:
> - Added node variant of directed kmem allocation functions.
>
> Changelog since v2:
> - Merge the kmalloc_memcg patch into this patch.
> - Instead of plumbing memcg throughout, use field in task_struct to pass
>   the target_memcg.
>
> Changelog since v1:
> - Fixed build for SLOB
>
