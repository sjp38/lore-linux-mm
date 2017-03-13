Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C76E76B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:44:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c143so13490906wmd.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:44:32 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id x204si10521528wmg.164.2017.03.13.04.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 04:44:31 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id v186so38149434wmd.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:44:30 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] mm: don't warn when vmalloc() fails due to a fatal signal
Date: Mon, 13 Mar 2017 12:44:25 +0100
Message-Id: <20170313114425.72724-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

When vmalloc() fails it prints a very lengthy message with all the
details about memory consumption assuming that it happened due to OOM.
However, vmalloc() can also fail due to fatal signal pending.
In such case the message is quite confusing because it suggests that
it is OOM but the numbers suggest otherwise. The messages can also
pollute console considerably.

Don't warn when vmalloc() fails due to fatal signal pending.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
---
 mm/vmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index edf15f49831e..68eb0028004b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1683,7 +1683,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 
 		if (fatal_signal_pending(current)) {
 			area->nr_pages = i;
-			goto fail;
+			goto fail_no_warn;
 		}
 
 		if (node == NUMA_NO_NODE)
@@ -1709,6 +1709,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	warn_alloc(gfp_mask, NULL,
 			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
 			  (area->nr_pages*PAGE_SIZE), area->size);
+fail_no_warn:
 	vfree(area->addr);
 	return NULL;
 }
-- 
2.12.0.246.ga2ecc84866-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
