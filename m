Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8580E82F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 02:46:44 -0500 (EST)
Received: by pasz6 with SMTP id z6so115596090pas.2
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 00:46:44 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id co2si24921179pbc.217.2015.11.01.00.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 00:46:43 -0700 (PDT)
Received: by padhy1 with SMTP id hy1so109578419pad.0
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 00:46:43 -0700 (PDT)
From: Jungseok Lee <jungseoklee85@gmail.com>
Subject: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu area setup
Date: Sun,  1 Nov 2015 07:46:16 +0000
Message-Id: <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com>
In-Reply-To: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

There is no room to adjust 'atom_size' now when a generic percpu area
is used. It would be redundant to write down an architecture-specific
setup_per_cpu_areas() in order to only change the 'atom_size'. Thus,
this patch adds a new definition, PERCPU_ATOM_SIZE, which is PAGE_SIZE
by default. The value could be updated if needed by architecture.

Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
---
 include/linux/percpu.h | 4 ++++
 mm/percpu.c            | 6 +++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 4bc6daf..57a2f16 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -18,6 +18,10 @@
 #define PERCPU_MODULE_RESERVE		0
 #endif
 
+#ifndef PERCPU_ATOM_SIZE
+#define PERCPU_ATOM_SIZE		PAGE_SIZE
+#endif
+
 /* minimum unit size, also is the maximum supported allocation size */
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(32 << 10)
 
diff --git a/mm/percpu.c b/mm/percpu.c
index a63b4d8..cd1e0ec 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2201,8 +2201,8 @@ void __init setup_per_cpu_areas(void)
 	 * what the legacy allocator did.
 	 */
 	rc = pcpu_embed_first_chunk(PERCPU_MODULE_RESERVE,
-				    PERCPU_DYNAMIC_RESERVE, PAGE_SIZE, NULL,
-				    pcpu_dfl_fc_alloc, pcpu_dfl_fc_free);
+				    PERCPU_DYNAMIC_RESERVE, PERCPU_ATOM_SIZE,
+				    NULL, pcpu_dfl_fc_alloc, pcpu_dfl_fc_free);
 	if (rc < 0)
 		panic("Failed to initialize percpu areas.");
 
@@ -2231,7 +2231,7 @@ void __init setup_per_cpu_areas(void)
 
 	ai = pcpu_alloc_alloc_info(1, 1);
 	fc = memblock_virt_alloc_from_nopanic(unit_size,
-					      PAGE_SIZE,
+					      PERCPU_ATOM_SIZE,
 					      __pa(MAX_DMA_ADDRESS));
 	if (!ai || !fc)
 		panic("Failed to allocate memory for percpu areas.");
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
