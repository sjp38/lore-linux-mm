Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB896B02A4
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:39:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b130so64207134wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:39:14 -0700 (PDT)
Received: from mx0b-0016f401.pphosted.com (mx0b-0016f401.pphosted.com. [67.231.156.173])
        by mx.google.com with ESMTPS id v6si4859138wjy.7.2016.09.29.00.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 00:39:13 -0700 (PDT)
From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] mm/vmalloc: reduce the number of lazy_max_pages to reduce latency
Date: Thu, 29 Sep 2016 15:34:11 +0800
Message-ID: <20160929073411.3154-1-jszhang@marvell.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, chris@chris-wilson.co.uk, rientjes@google.com, iamjoonsoo.kim@lge.com, npiggin@kernel.dk, agnel.joel@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Jisheng Zhang <jszhang@marvell.com>

On Marvell berlin arm64 platforms, I see the preemptoff tracer report
a max 26543 us latency at __purge_vmap_area_lazy, this latency is an
awfully bad for STB. And the ftrace log also shows __free_vmap_area
contributes most latency now. I noticed that Joel mentioned the same
issue[1] on x86 platform and gave two solutions, but it seems no patch
is sent out for this purpose.

This patch adopts Joel's first solution, but I use 16MB per core
rather than 8MB per core for the number of lazy_max_pages. After this
patch, the preemptoff tracer reports a max 6455us latency, reduced to
1/4 of original result.

[1] http://lkml.iu.edu/hypermail/linux/kernel/1603.2/04803.html

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..66f377a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -596,7 +596,7 @@ static unsigned long lazy_max_pages(void)
 
 	log = fls(num_online_cpus());
 
-	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
+	return log * (16UL * 1024 * 1024 / PAGE_SIZE);
 }
 
 static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
