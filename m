Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 628326B6D4F
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 07:45:21 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u74-v6so3799064oie.16
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 04:45:21 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r135-v6si14092251oie.100.2018.09.04.04.45.20
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 04:45:20 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 1/5] asm-generic/tlb: Guard with #ifdef CONFIG_MMU
Date: Tue,  4 Sep 2018 12:45:29 +0100
Message-Id: <1536061533-16188-2-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
References: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

The inner workings of the mmu_gather-based TLB invalidation mechanism
are not relevant to nommu configurations, so guard them with an #ifdef.
This allows us to implement future functions using static inlines
without breaking the build.

Acked-by: Nicholas Piggin <npiggin@gmail.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 include/asm-generic/tlb.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b3353e21f3b3..a25e236f7a7f 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -20,6 +20,8 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
+#ifdef CONFIG_MMU
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
  * Semi RCU freeing of the page directories.
@@ -310,6 +312,8 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #endif
 #endif
 
+#endif /* CONFIG_MMU */
+
 #define tlb_migrate_finish(mm) do {} while (0)
 
 #endif /* _ASM_GENERIC__TLB_H */
-- 
2.1.4
