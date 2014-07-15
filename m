Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4856B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:19:21 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id b8so2344749lan.19
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:19:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o5si14822012lae.15.2014.07.15.08.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 08:19:19 -0700 (PDT)
Date: Tue, 15 Jul 2014 19:19:07 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Remove "memcg/slab: reintroduce dead cache self-destruction" from
 mmotm
Message-ID: <20140715151907.GA23103@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

Could you drop the following patches please?

slub-kmem_cache_shrink-check-if-partial-list-is-empty-under-list_lock.patch
slab-set-free_limit-for-dead-caches-to-0.patch
slab-do-not-keep-free-objects-slabs-on-dead-memcg-caches.patch
slub-make-dead-memcg-caches-discard-free-slabs-immediately.patch
memcg-wait-for-kfrees-to-finish-before-destroying-cache.patch
slub-make-slab_free-non-preemptable.patch
slub-dont-fail-kmem_cache_shrink-if-slab-placement-optimization-fails.patch
memcg-mark-caches-that-belong-to-offline-memcgs-as-dead.patch
memcg-destroy-kmem-caches-when-last-slab-is-freed.patch
memcg-cleanup-memcg_cache_params-refcnt-usage.patch

The patches implement self-destruction of kmem caches that belong to
dead memory cgroups (see https://lkml.org/lkml/2014/6/12/681). They were
needed for re-parenting kmem charges on memcg offline.

However, as Johannes explained, recent changes to the cgroup core made
re-parenting of memcg charges unnecessary, because now we can iterate
over offline css's on memory pressure and reclaim their charges, just as
we do with online css's (see https://lkml.org/lkml/2014/7/7/335). As a
result, it isn't strictly necessary to destroy dead kmem caches as soon
as the last object is freed, because we can add a per memcg slab
shrinker for them.

Since the implementation of kmem cache self-destruction is quite
intrusive to the slab core and, what is worse, degrades kfree
performance for dead caches noticeably (especially for SLAB, see
https://lkml.org/lkml/2014/6/25/520), I propose to drop it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
