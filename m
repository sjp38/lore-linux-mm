Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 25EBC6B0005
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 11:48:10 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id 20so28135969wmh.1
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 08:48:10 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id i69si35541509wmd.6.2016.04.01.08.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 08:48:08 -0700 (PDT)
Date: Fri, 1 Apr 2016 17:48:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: slub: replace kick_all_cpus_sync with
 synchronize_sched in kmem_cache_shrink
Message-ID: <20160401154803.GL3448@twins.programming.kicks-ass.net>
References: <1459513817-11853-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459513817-11853-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 01, 2016 at 03:30:17PM +0300, Vladimir Davydov wrote:
> When we call __kmem_cache_shrink on memory cgroup removal, we need to
> synchronize kmem_cache->cpu_partial update with put_cpu_partial that
> might be running on other cpus. Currently, we achieve that by using
> kick_all_cpus_sync, which works as a system wide memory barrier. Though
> fast it is, this method has a flow - it issues a lot of IPIs, which
> might hurt high performance or real-time workloads.
> 
> To fix this, let's replace kick_all_cpus_sync with synchronize_sched.
> Although the latter one may take much longer to finish, it shouldn't be
> a problem in this particular case, because memory cgroups are destroyed
> asynchronously from a workqueue so that no user visible effects should
> be introduced. OTOH, it will save us from excessive IPIs when someone
> removes a cgroup.
> 
> Anyway, even if using synchronize_sched turns out to take too long, we
> can always introduce a kind of __kmem_cache_shrink batching so that this
> method would only be called once per one cgroup destruction (not per
> each per memcg kmem cache as it is now).
> 
> Reported-and-suggested-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks!

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
