Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42DDE6B026E
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 04:33:20 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b26-v6so7117324lfa.6
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 01:33:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 79-v6sor98169ljs.86.2018.06.12.01.33.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 01:33:18 -0700 (PDT)
Date: Tue, 12 Jun 2018 11:33:14 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v4] mm: fix race between kmem_cache destroy, create and
 deactivate
Message-ID: <20180612083314.ftl4hmn4xwnehjdx@esperanza>
References: <20180611192951.195727-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180611192951.195727-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 11, 2018 at 12:29:51PM -0700, Shakeel Butt wrote:
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
> deactivation. SLUB's memcg kmem cache deactivation also includes RCU
> callback and thus make sure all previous registered RCU callbacks
> have completed as well.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Thanks.
