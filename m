Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 38A9A6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 02:19:35 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so12442023pbb.25
        for <linux-mm@kvack.org>; Wed, 28 May 2014 23:19:34 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id sl5si26970584pab.202.2014.05.28.23.19.32
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 23:19:34 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] vmalloc: use rcu list iterator to reduce vmap_area_lock contention
Date: Thu, 29 May 2014 15:22:34 +0900
Message-Id: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Richard Yao reported a month ago that his system have a trouble
with vmap_area_lock contention during performance analysis
by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
stressfully, but he didn't answer it.

https://lkml.org/lkml/2014/4/10/416

Although I'm not sure that this is right usage or not, there is a solution
reducing vmap_area_lock contention with no side-effect. That is just
to use rcu list iterator in get_vmalloc_info(). This function only needs
values on vmap_area structure, so we don't need to grab a spinlock.

Reported-by: Richard Yao <ryao@gentoo.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f64632b..fdbb116 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2690,14 +2690,14 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 
 	prev_end = VMALLOC_START;
 
-	spin_lock(&vmap_area_lock);
+	rcu_read_lock();
 
 	if (list_empty(&vmap_area_list)) {
 		vmi->largest_chunk = VMALLOC_TOTAL;
 		goto out;
 	}
 
-	list_for_each_entry(va, &vmap_area_list, list) {
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
 		unsigned long addr = va->va_start;
 
 		/*
@@ -2724,7 +2724,7 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 		vmi->largest_chunk = VMALLOC_END - prev_end;
 
 out:
-	spin_unlock(&vmap_area_lock);
+	rcu_read_unlock();
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
