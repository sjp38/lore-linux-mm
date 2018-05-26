Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D64B96B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 14:58:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f188-v6so5460632wme.2
        for <linux-mm@kvack.org>; Sat, 26 May 2018 11:58:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q22-v6sor4484804lfg.31.2018.05.26.11.58.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 11:58:40 -0700 (PDT)
Date: Sat, 26 May 2018 21:58:37 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2] mm: fix race between kmem_cache destroy, create and
 deactivate
Message-ID: <20180526185837.k5ztrillokpi65qj@esperanza>
References: <20180522201336.196994-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522201336.196994-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, May 22, 2018 at 01:13:36PM -0700, Shakeel Butt wrote:
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
> This issue is due to the lack of real reference counting for the root
> kmem_caches. Currently kmem_cache does have a field named refcount which
> has been used for multiple purposes i.e. shared count, reference count
> and noshare flag. Due to its conflated nature, it can not be used for
> reference counting by other subsystems.
> 
> This patch decoupled the reference counting from shared count and
> noshare flag. The new field 'shared_count' represents the shared count
> and noshare flag while 'refcount' is converted into a real reference
> counter.
> 
> The reference counting is only implemented for root kmem_caches for
> simplicity. The reference of a root kmem_cache is elevated on sharing or
> while its memcg kmem_cache creation or deactivation request is in the
> fly and thus it is made sure that the root kmem_cache is not destroyed
> in the middle. As the reference of kmem_cache is elevated on sharing,
> the 'shared_count' does not need any locking protection as at worst it
> can be out-dated for a small window which is tolerable.

I wonder if we could fix this problem without introducing reference
counting for kmem caches (which seems a bit of an overkill to me TBO),
e.g. by flushing memcg_kmem_cache_wq before root cache destruction?
