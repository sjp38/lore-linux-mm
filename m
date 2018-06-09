Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E11106B0003
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 06:20:32 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m9-v6so4897326lfb.15
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 03:20:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a75-v6sor3077977lfb.19.2018.06.09.03.20.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Jun 2018 03:20:30 -0700 (PDT)
Date: Sat, 9 Jun 2018 13:20:27 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v3] mm: fix race between kmem_cache destroy, create and
 deactivate
Message-ID: <20180609102027.5vkqucnzvh6nfdxu@esperanza>
References: <20180530001204.183758-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530001204.183758-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 29, 2018 at 05:12:04PM -0700, Shakeel Butt wrote:
> The memcg kmem cache creation and deactivation (SLUB only) is
> asynchronous. If a root kmem cache is destroyed whose memcg cache is in
> the process of creation or deactivation, the kernel may crash.
> 
> Example of one such crash:
> 	general protection fault: 0000 [#1] SMP PTI
> 	CPU: 1 PID: 1721 Comm: kworker/14:1 Not tainted 4.17.0-smp
> 	...
> 	Workqueue: memcg_kmem_cache kmemcg_deactivate_workfn
> 	RIP: 0010:has_cpu_slab
> 	...
> 	Call Trace:
> 	? on_each_cpu_cond
> 	__kmem_cache_shrink
> 	kmemcg_cache_deact_after_rcu
> 	kmemcg_deactivate_workfn
> 	process_one_work
> 	worker_thread
> 	kthread
> 	ret_from_fork+0x35/0x40
> 
> To fix this race, on root kmem cache destruction, mark the cache as
> dying and flush the workqueue used for memcg kmem cache creation and
> deactivation.

> @@ -845,6 +862,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  	if (unlikely(!s))
>  		return;
>  
> +	flush_memcg_workqueue(s);
> +

This should definitely help against async memcg_kmem_cache_create(),
but I'm afraid it doesn't eliminate the race with async destruction,
unfortunately, because the latter uses call_rcu_sched():

  memcg_deactivate_kmem_caches
   __kmem_cache_deactivate
    slab_deactivate_memcg_cache_rcu_sched
     call_rcu_sched
                                            kmem_cache_destroy
                                             shutdown_memcg_caches
                                              shutdown_cache
      memcg_deactivate_rcufn
       <dereference destroyed cache>

Can we somehow flush those pending rcu requests?
