Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2AD6B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:57:37 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o12so31331663lfg.7
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:57:37 -0800 (PST)
Received: from smtp39.i.mail.ru (smtp39.i.mail.ru. [94.100.177.99])
        by mx.google.com with ESMTPS id v25si9896829lja.11.2017.01.14.05.57.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 05:57:35 -0800 (PST)
Date: Sat, 14 Jan 2017 16:57:27 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 8/9] slab: remove synchronous synchronize_sched() from
 memcg cache deactivation path
Message-ID: <20170114135727.GG2668@esperanza>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-9-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114055449.11044-9-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 12:54:48AM -0500, Tejun Heo wrote:
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.  This is one of the patches to address the issue.
> 
> slub uses synchronize_sched() to deactivate a memcg cache.
> synchronize_sched() is an expensive and slow operation and doesn't
> scale when a huge number of caches are destroyed back-to-back.  While
> there used to be a simple batching mechanism, the batching was too
> restricted to be helpful.
> 
> This patch implements slab_deactivate_memcg_cache_rcu_sched() which
> slub can use to schedule sched RCU callback instead of performing
> synchronize_sched() synchronously while holding cgroup_mutex.  While
> this adds online cpus, mems and slab_mutex operations, operating on
> these locks back-to-back from the same kworker, which is what's gonna
> happen when there are many to deactivate, isn't expensive at all and
> this gets rid of the scalability problem completely.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

I don't think there's much point in having the infrastructure for this
in slab_common.c, as only SLUB needs it, but it isn't a show stopper.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
