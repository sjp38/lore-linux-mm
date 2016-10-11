Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C29C6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:04:40 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so13650620qkf.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:04:40 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id h20si1385100qtb.151.2016.10.11.06.04.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 06:04:39 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH] mm/percpu.c: fix panic triggered by BUG_ON() falsely
Message-ID: <7ed31efd-a59a-0a74-1145-c1af3c3d0d73@zoho.com>
Date: Tue, 11 Oct 2016 21:03:26 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

as shown by pcpu_build_alloc_info(), the number of units within a percpu
group is educed by rounding up the number of CPUs within the group to
@upa boundary, therefore, the number of CPUs isn't equal to the units's
if it isn't aligned to @upa normally. however, pcpu_page_first_chunk()
uses BUG_ON() to assert one number is equal the other roughly, so a panic
is maybe triggered by the BUG_ON() falsely.

in order to fix this issue, the number of CPUs is rounded up then compared
with units's, the BUG_ON() is replaced by warning and returning error code
as well to keep system alive as much as possible.

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/percpu.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 32e2d8d128c1..c2f0d9734d8c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2095,6 +2095,8 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	size_t pages_size;
 	struct page **pages;
 	int unit, i, j, rc;
+	int upa;
+	int nr_g0_units;
 
 	snprintf(psize_str, sizeof(psize_str), "%luK", PAGE_SIZE >> 10);
 
@@ -2102,7 +2104,12 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	if (IS_ERR(ai))
 		return PTR_ERR(ai);
 	BUG_ON(ai->nr_groups != 1);
-	BUG_ON(ai->groups[0].nr_units != num_possible_cpus());
+	upa = ai->alloc_size/ai->unit_size;
+	g0_nr_units = roundup(num_possible_cpus(), upa);
+	if (unlikely(WARN_ON(ai->groups[0].nr_units != nr_g0_units))) {
+		pcpu_free_alloc_info(ai);
+		return -EINVAL;
+	}
 
 	unit_pages = ai->unit_size >> PAGE_SHIFT;
 
@@ -2113,21 +2120,22 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 
 	/* allocate pages */
 	j = 0;
-	for (unit = 0; unit < num_possible_cpus(); unit++)
+	for (unit = 0; unit < num_possible_cpus(); unit++) {
+		unsigned int cpu = ai->groups[0].cpu_map[unit];
 		for (i = 0; i < unit_pages; i++) {
-			unsigned int cpu = ai->groups[0].cpu_map[unit];
 			void *ptr;
 
 			ptr = alloc_fn(cpu, PAGE_SIZE, PAGE_SIZE);
 			if (!ptr) {
 				pr_warn("failed to allocate %s page for cpu%u\n",
-					psize_str, cpu);
+						psize_str, cpu);
 				goto enomem;
 			}
 			/* kmemleak tracks the percpu allocations separately */
 			kmemleak_free(ptr);
 			pages[j++] = virt_to_page(ptr);
 		}
+	}
 
 	/* allocate vm area, map the pages and copy static data */
 	vm.flags = VM_ALLOC;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
