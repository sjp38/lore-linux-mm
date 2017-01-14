Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA04F6B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:39:25 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id v186so31436571lfa.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:39:25 -0800 (PST)
Received: from smtp32.i.mail.ru (smtp32.i.mail.ru. [94.100.177.92])
        by mx.google.com with ESMTPS id x18si9881978lja.5.2017.01.14.05.39.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 05:39:24 -0800 (PST)
Date: Sat, 14 Jan 2017 16:39:18 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 6/9] slab: don't put memcg caches on slab_caches list
Message-ID: <20170114133918.GE2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-7-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-7-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 12:54:46AM -0500, Tejun Heo wrote:
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.  This is one of the patches to address the issue.
> 
> slab_caches currently lists all caches including root and memcg ones.
> This is the only data structure which lists the root caches and
> iterating root caches can only be done by walking the list while
> skipping over memcg caches.  As there can be a huge number of memcg
> caches, this can become very expensive.
> 
> This also can make /proc/slabinfo behave very badly.  seq_file
> processes reads in 4k chunks and seeks to the previous Nth position on
> slab_caches list to resume after each chunk.  With a lot of memcg
> cache churns on the list, reading /proc/slabinfo can become very slow
> and its content often ends up with duplicate and/or missing entries.
> 
> As the previous patch made it unnecessary to walk slab_caches to
> iterate memcg-specific caches, there is no reason to keep memcg caches
> on the list.  This patch makes slab_caches include only the root
> caches.  As this makes slab_cache->list unused for memcg caches,
> ->memcg_params.children_node is removed and ->list is used instead.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/slab.h |  3 ---
>  mm/slab.h            |  3 +--
>  mm/slab_common.c     | 58 +++++++++++++++++++++++++---------------------------
>  3 files changed, 29 insertions(+), 35 deletions(-)

IIRC the slab_caches list is also used on cpu/mem online/offline, so you
have to patch those places to ensure that memcg caches get updated too.
Other than that the patch looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
