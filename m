Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49F5A8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 13:07:06 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so39862199qtd.20
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 10:07:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c135sor22113437qka.63.2019.01.02.10.07.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 10:07:05 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH v2] kmemleak: survive in a low-memory situation
Date: Wed,  2 Jan 2019 13:06:19 -0500
Message-Id: <20190102180619.12392-1-cai@lca.pw>
In-Reply-To: <20190102165931.GB6584@arrakis.emea.arm.com>
References: <20190102165931.GB6584@arrakis.emea.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

Kmemleak could quickly fail to allocate an object structure and then
disable itself in a low-memory situation. For example, running a mmap()
workload triggering swapping and OOM [1].

Kmemleak allocation could fail even though the trackig object is
succeeded. Hence, it could still try to start a direct reclaim if it is
not executed in an atomic context (spinlock, irq-handler etc), or a
high-priority allocation in an atomic context as a last-ditch effort.

[1]
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/oom/oom01.c

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: remove the needless checking for NULL objects in slab_post_alloc_hook()
    pointed out by Catalin.

 mm/kmemleak.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc250428..9e1aa3b7df75 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	struct rb_node **link, *rb_parent;
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+#ifdef CONFIG_PREEMPT_COUNT
+	if (!object) {
+		/* last-ditch effort in a low-memory situation */
+		if (irqs_disabled() || is_idle_task(current) || in_atomic())
+			gfp = GFP_ATOMIC;
+		else
+			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
+		object = kmem_cache_alloc(object_cache, gfp);
+	}
+#endif
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
-- 
2.17.2 (Apple Git-113)
