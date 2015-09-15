Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 27A3B6B025C
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:08:58 -0400 (EDT)
Received: by lagj9 with SMTP id j9so109919329lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:57 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id e4si13874966lab.35.2015.09.15.07.08.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:08:57 -0700 (PDT)
Received: by lanb10 with SMTP id b10so107793290lan.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:56 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 05/10] mm/percpu: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:08:01 +0600
Message-Id: <1442326081-7383-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/percpu.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index a63b4d8..8a943b9 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1554,12 +1554,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(ai->nr_groups <= 0);
 #ifdef CONFIG_SMP
 	PCPU_SETUP_BUG_ON(!ai->static_size);
-	PCPU_SETUP_BUG_ON((unsigned long)__per_cpu_start & ~PAGE_MASK);
+	PCPU_SETUP_BUG_ON(offset_in_page(__per_cpu_start));
 #endif
 	PCPU_SETUP_BUG_ON(!base_addr);
-	PCPU_SETUP_BUG_ON((unsigned long)base_addr & ~PAGE_MASK);
+	PCPU_SETUP_BUG_ON(offset_in_page(base_addr));
 	PCPU_SETUP_BUG_ON(ai->unit_size < size_sum);
-	PCPU_SETUP_BUG_ON(ai->unit_size & ~PAGE_MASK);
+	PCPU_SETUP_BUG_ON(offset_in_page(ai->unit_size));
 	PCPU_SETUP_BUG_ON(ai->unit_size < PCPU_MIN_UNIT_SIZE);
 	PCPU_SETUP_BUG_ON(ai->dyn_size < PERCPU_DYNAMIC_EARLY_SIZE);
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
@@ -1806,7 +1806,7 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 
 	alloc_size = roundup(min_unit_size, atom_size);
 	upa = alloc_size / min_unit_size;
-	while (alloc_size % upa || ((alloc_size / upa) & ~PAGE_MASK))
+	while (alloc_size % upa || (offset_in_page(alloc_size / upa)))
 		upa--;
 	max_upa = upa;
 
@@ -1838,7 +1838,7 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
 	for (upa = max_upa; upa; upa--) {
 		int allocs = 0, wasted = 0;
 
-		if (alloc_size % upa || ((alloc_size / upa) & ~PAGE_MASK))
+		if (alloc_size % upa || (offset_in_page(alloc_size / upa)))
 			continue;
 
 		for (group = 0; group < nr_groups; group++) {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
