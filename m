Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 691906B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:06:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n126so1232380wma.7
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:06:09 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 26si1477537wry.389.2017.12.13.06.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 06:06:07 -0800 (PST)
Date: Wed, 13 Dec 2017 15:05:55 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH RT] mm/slub: close possible memory-leak in
 kmem_cache_alloc_bulk()
Message-ID: <20171213140555.s4hzg3igtjfgaueh@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-rt-users@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org

Under certain circumstances we could leak elements which were moved to
the local "to_free" list. The damage is limited since I can't find any
users here.

Cc: stable-rt@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
Jesper: There are no users of kmem_cache_alloc_bulk() and kfree_bulk().
Only kmem_cache_free_bulk() is used since it was introduced. Do you
think that it would make sense to remove those?

 mm/slub.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/slub.c b/mm/slub.c
index ffd2fa0f415e..9053e929ce9d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3240,6 +3240,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	return i;
 error:
 	local_irq_enable();
+	free_delayed(&to_free);
 	slab_post_alloc_hook(s, flags, i, p);
 	__kmem_cache_free_bulk(s, i, p);
 	return 0;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
