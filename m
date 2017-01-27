Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54DAA6B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:03:13 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id x1so110367335lff.6
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:03:13 -0800 (PST)
Received: from smtp54.i.mail.ru (smtp54.i.mail.ru. [217.69.128.34])
        by mx.google.com with ESMTPS id g38si3306583lfi.85.2017.01.27.10.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 10:03:11 -0800 (PST)
Date: Fri, 27 Jan 2017 21:03:05 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 03/10] slab: remove synchronous rcu_barrier() call in
 memcg cache release path
Message-ID: <20170127180305.GB4332@esperanza>
References: <20170117235411.9408-1-tj@kernel.org>
 <20170117235411.9408-4-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117235411.9408-4-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 17, 2017 at 03:54:04PM -0800, Tejun Heo wrote:
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.  This is one of the patches to address the issue.
> 
> SLAB_DESTORY_BY_RCU caches need to flush all RCU operations before
> destruction because slab pages are freed through RCU and they need to
> be able to dereference the associated kmem_cache.  Currently, it's
> done synchronously with rcu_barrier().  As rcu_barrier() is expensive
> time-wise, slab implements a batching mechanism so that rcu_barrier()
> can be done for multiple caches at the same time.
> 
> Unfortunately, the rcu_barrier() is in synchronous path which is
> called while holding cgroup_mutex and the batching is too limited to
> be actually helpful.
> 
> This patch updates the cache release path so that the batching is
> asynchronous and global.  All SLAB_DESTORY_BY_RCU caches are queued
> globally and a work item consumes the list.  The work item calls
> rcu_barrier() only once for all caches that are currently queued.
> 
> * release_caches() is removed and shutdown_cache() now either directly
>   release the cache or schedules a RCU callback to do that.  This
>   makes the cache inaccessible once shutdown_cache() is called and
>   makes it impossible for shutdown_memcg_caches() to do memcg-specific
>   cleanups afterwards.  Move memcg-specific part into a helper,
>   unlink_memcg_cache(), and make shutdown_cache() call it directly.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov@tarantool.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
