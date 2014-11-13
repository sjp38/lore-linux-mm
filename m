Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2698D6B00E3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 14:25:34 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id f10so1254218yha.4
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 11:25:33 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com. [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id h48si28014364yhb.147.2014.11.13.11.25.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 11:25:33 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id f10so1258424yha.18
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 11:25:32 -0800 (PST)
From: Pranith Kumar <bobby.prani@gmail.com>
Subject: [PATCH 14/16] slab: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 14:24:20 -0500
Message-Id: <1415906662-4576-15-git-send-email-bobby.prani@gmail.com>
In-Reply-To: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>
Cc: paulmck@linux.vnet.ibm.com

Recently lockless_dereference() was added which can be used in place of
hard-coding smp_read_barrier_depends(). The following PATCH makes the change.

Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>
---
 mm/slab.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 3347fd7..1cf40054 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -209,15 +209,15 @@ cache_from_memcg_idx(struct kmem_cache *s, int idx)
 
 	rcu_read_lock();
 	params = rcu_dereference(s->memcg_params);
-	cachep = params->memcg_caches[idx];
-	rcu_read_unlock();
 
 	/*
 	 * Make sure we will access the up-to-date value. The code updating
 	 * memcg_caches issues a write barrier to match this (see
 	 * memcg_register_cache()).
 	 */
-	smp_read_barrier_depends();
+	cachep = lockless_dereference(params->memcg_caches[idx]);
+	rcu_read_unlock();
+
 	return cachep;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
