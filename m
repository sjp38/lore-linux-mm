Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC7506B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 17:29:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l30so11673174pgc.15
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:29:36 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id t12si4675094pfi.3.2017.08.14.14.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 14:29:33 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id y129so54898104pgy.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:29:33 -0700 (PDT)
Date: Mon, 14 Aug 2017 14:29:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: fix per memcg cache leak on css offline
In-Reply-To: <20170812181134.25027-1-vdavydov.dev@gmail.com>
Message-ID: <alpine.DEB.2.10.1708141429190.19280@chino.kir.corp.google.com>
References: <20170812181134.25027-1-vdavydov.dev@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrei Vagin <avagin@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 12 Aug 2017, Vladimir Davydov wrote:

> To avoid a possible deadlock, sysfs_slab_remove() schedules an
> asynchronous work to delete sysfs entries corresponding to the kmem
> cache. To ensure the cache isn't freed before the work function is
> called, it takes a reference to the cache kobject. The reference is
> supposed to be released by the work function. However, the work function
> (sysfs_slab_remove_workfn()) does nothing in case the cache sysfs entry
> has already been deleted, leaking the kobject and the corresponding
> cache. This may happen on a per memcg cache destruction, because sysfs
> entries of a per memcg cache are deleted on memcg offline if the cache
> is empty (see __kmemcg_cache_deactivate()).
> 
> The kmemleak report looks like this:
> 
>   unreferenced object 0xffff9f798a79f540 (size 32):
>     comm "kworker/1:4", pid 15416, jiffies 4307432429 (age 28687.554s)
>     hex dump (first 32 bytes):
>       6b 6d 61 6c 6c 6f 63 2d 31 36 28 31 35 39 39 3a  kmalloc-16(1599:
>       6e 65 77 72 6f 6f 74 29 00 23 6b c0 ff ff ff ff  newroot).#k.....
>     backtrace:
>       [<ffffffff9591d28a>] kmemleak_alloc+0x4a/0xa0
>       [<ffffffff9527a378>] __kmalloc_track_caller+0x148/0x2c0
>       [<ffffffff95499466>] kvasprintf+0x66/0xd0
>       [<ffffffff954995a9>] kasprintf+0x49/0x70
>       [<ffffffff952305c6>] memcg_create_kmem_cache+0xe6/0x160
>       [<ffffffff9528eaf0>] memcg_kmem_cache_create_func+0x20/0x110
>       [<ffffffff950cd6c5>] process_one_work+0x205/0x5d0
>       [<ffffffff950cdade>] worker_thread+0x4e/0x3a0
>       [<ffffffff950d5169>] kthread+0x109/0x140
>       [<ffffffff9592b8fa>] ret_from_fork+0x2a/0x40
>       [<ffffffffffffffff>] 0xffffffffffffffff
>   unreferenced object 0xffff9f79b6136840 (size 416):
>     comm "kworker/1:4", pid 15416, jiffies 4307432429 (age 28687.573s)
>     hex dump (first 32 bytes):
>       40 fb 80 c2 3e 33 00 00 00 00 00 40 00 00 00 00  @...>3.....@....
>       00 00 00 00 00 00 00 00 10 00 00 00 10 00 00 00  ................
>     backtrace:
>       [<ffffffff9591d28a>] kmemleak_alloc+0x4a/0xa0
>       [<ffffffff95275bc8>] kmem_cache_alloc+0x128/0x280
>       [<ffffffff9522fedb>] create_cache+0x3b/0x1e0
>       [<ffffffff952305f8>] memcg_create_kmem_cache+0x118/0x160
>       [<ffffffff9528eaf0>] memcg_kmem_cache_create_func+0x20/0x110
>       [<ffffffff950cd6c5>] process_one_work+0x205/0x5d0
>       [<ffffffff950cdade>] worker_thread+0x4e/0x3a0
>       [<ffffffff950d5169>] kthread+0x109/0x140
>       [<ffffffff9592b8fa>] ret_from_fork+0x2a/0x40
>       [<ffffffffffffffff>] 0xffffffffffffffff
> 
> Fix the leak by adding the missing call to kobject_put() to
> sysfs_slab_remove_workfn().
> 
> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Reported-and-tested-by: Andrei Vagin <avagin@gmail.com>
> Acked-by: Tejun Heo <tj@kernel.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Fixes: 3b7b314053d02 ("slub: make sysfs file removal asynchronous")

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
