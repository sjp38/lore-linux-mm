Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B13056B03A1
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 08:49:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o83so19228148oik.20
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 05:49:34 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00127.outbound.protection.outlook.com. [40.107.0.127])
        by mx.google.com with ESMTPS id l10si4999196oib.138.2017.04.12.05.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 05:49:33 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 5/5] mm/vmalloc: Don't spawn workers if somebody already purging
Date: Wed, 12 Apr 2017 15:49:05 +0300
Message-ID: <20170412124905.25443-6-aryabinin@virtuozzo.com>
In-Reply-To: <20170412124905.25443-1-aryabinin@virtuozzo.com>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <20170412124905.25443-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, thellstrom@vmware.com

Don't schedule purge_vmap_work if mutex_is_locked(&vmap_purge_lock),
as this means that purging is already running in another thread.
There is no point to schedule extra purge_vmap_work if somebody
is already purging for us, because that extra work will not do anything
useful.

To evaluate performance impact of this change test that calls
fork() 100 000 times on the kernel with enabled CONFIG_VMAP_STACK=y
and NR_CACHED_STACK changed to 0 (so that each fork()/exit() executes
vmalloc()/vfree() call) was used.

Commands:
~ # grep try_purge /proc/kallsyms
ffffffff811d0dd0 t try_purge_vmap_area_lazy

~ # perf stat --repeat 10 -ae workqueue:workqueue_queue_work \
              --filter 'function == 0xffffffff811d0dd0' ./fork

gave me the following results:

before:
   30      workqueue:workqueue_queue_work                ( +-  1.31% )
   1.613231060 seconds time elapsed                      ( +-  0.38% )

after:
   15      workqueue:workqueue_queue_work                ( +-  0.88% )
   1.615368474 seconds time elapsed                      ( +-  0.41% )

So there is no measurable difference on the performance of the test itself,
but without the optimization we queue twice more jobs. This should save
kworkers from doing some useless job.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Suggested-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
---
 mm/vmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ee62c0a..1079555 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -737,7 +737,8 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 	/* After this point, we may free va at any time */
 	llist_add(&va->purge_list, &vmap_purge_list);
 
-	if (unlikely(nr_lazy > lazy_max_pages()))
+	if (unlikely(nr_lazy > lazy_max_pages()) &&
+	    !mutex_is_locked(&vmap_purge_lock))
 		schedule_work(&purge_vmap_work);
 }
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
