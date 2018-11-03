Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9339F6B0003
	for <linux-mm@kvack.org>; Sat,  3 Nov 2018 10:13:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 87-v6so4291733pfq.8
        for <linux-mm@kvack.org>; Sat, 03 Nov 2018 07:13:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g31-v6sor7109537pgg.8.2018.11.03.07.13.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Nov 2018 07:13:01 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/slub: remove validation on cpu_slab in __flush_cpu_slab()
Date: Sat,  3 Nov 2018 22:12:18 +0800
Message-Id: <20181103141218.22844-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

cpu_slab is a per cpu variable which is allocated in all or none. If a
cpu_slab failed to be allocated, the slub is not usable.

We could use cpu_slab without validation in __flush_cpu_slab().

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/slub.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1b6c20ac2a08..eb93d767e87d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2291,12 +2291,10 @@ static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 {
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	if (likely(c)) {
-		if (c->page)
-			flush_slab(s, c);
+	if (c->page)
+		flush_slab(s, c);
 
-		unfreeze_partials(s, c);
-	}
+	unfreeze_partials(s, c);
 }
 
 static void flush_cpu_slab(void *d)
-- 
2.15.1
