Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D87E6B027C
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:45:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f22-v6so2027188pgv.21
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 02:45:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor7260515pfk.58.2018.10.25.02.45.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 02:45:38 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/3] mm, slub: unify access to s->cpu_slab by replacing raw_cpu_ptr() with this_cpu_ptr()
Date: Thu, 25 Oct 2018 17:44:36 +0800
Message-Id: <20181025094437.18951-2-richard.weiyang@gmail.com>
In-Reply-To: <20181025094437.18951-1-richard.weiyang@gmail.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

In current code, we use two forms to access s->cpu_slab

  * raw_cpu_ptr()
  * this_cpu_ptr()

This patch unify the access by replacing raw_cpu_ptr() with
this_cpu_ptr().

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 11e49d95e0ac..715372a786e3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2643,7 +2643,7 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	 */
 	do {
 		tid = this_cpu_read(s->cpu_slab->tid);
-		c = raw_cpu_ptr(s->cpu_slab);
+		c = this_cpu_ptr(s->cpu_slab);
 	} while (IS_ENABLED(CONFIG_PREEMPT) &&
 		 unlikely(tid != READ_ONCE(c->tid)));
 
@@ -2916,7 +2916,7 @@ static __always_inline void do_slab_free(struct kmem_cache *s,
 	 */
 	do {
 		tid = this_cpu_read(s->cpu_slab->tid);
-		c = raw_cpu_ptr(s->cpu_slab);
+		c = this_cpu_ptr(s->cpu_slab);
 	} while (IS_ENABLED(CONFIG_PREEMPT) &&
 		 unlikely(tid != READ_ONCE(c->tid)));
 
-- 
2.15.1
