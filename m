Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5FFC8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:00:05 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so24564373qtb.9
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 05:00:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v64si1458846qkh.60.2019.01.14.05.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 05:00:05 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 7/9] arm64: kdump: No need to mark crashkernel pages manually PG_reserved
Date: Mon, 14 Jan 2019 13:59:01 +0100
Message-Id: <20190114125903.24845-8-david@redhat.com>
In-Reply-To: <20190114125903.24845-1-david@redhat.com>
References: <20190114125903.24845-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, David Hildenbrand <david@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, James Morse <james.morse@arm.com>, Bhupesh Sharma <bhsharma@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Florian Fainelli <f.fainelli@gmail.com>, Stefan Agner <stefan@agner.ch>, Laura Abbott <labbott@redhat.com>, Greg Hackmann <ghackmann@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Kristina Martsenko <kristina.martsenko@arm.com>, CHANDAN VN <chandan.vn@samsung.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Logan Gunthorpe <logang@deltatee.com>

The crashkernel is reserved via memblock_reserve(). memblock_free_all()
will call free_low_memory_core_early(), which will go over all reserved
memblocks, marking the pages as PG_reserved.

So manually marking pages as PG_reserved is not necessary, they are
already in the desired state (otherwise they would have been handed over
to the buddy as free pages and bad things would happen).

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: James Morse <james.morse@arm.com>
Cc: Bhupesh Sharma <bhsharma@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Greg Hackmann <ghackmann@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kristina Martsenko <kristina.martsenko@arm.com>
Cc: CHANDAN VN <chandan.vn@samsung.com>
Cc: AKASHI Takahiro <takahiro.akashi@linaro.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Matthias Brugger <mbrugger@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/arm64/kernel/machine_kexec.c |  2 +-
 arch/arm64/mm/init.c              | 27 ---------------------------
 2 files changed, 1 insertion(+), 28 deletions(-)

diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
index 6f0587b5e941..66b5d697d943 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -321,7 +321,7 @@ void crash_post_resume(void)
  * but does not hold any data of loaded kernel image.
  *
  * Note that all the pages in crash dump kernel memory have been initially
- * marked as Reserved in kexec_reserve_crashkres_pages().
+ * marked as Reserved as memory was allocated via memblock_reserve().
  *
  * In hibernation, the pages which are Reserved and yet "nosave" are excluded
  * from the hibernation iamge. crash_is_nosave() does thich check for crash
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 7205a9085b4d..c38976b70069 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -118,35 +118,10 @@ static void __init reserve_crashkernel(void)
 	crashk_res.start = crash_base;
 	crashk_res.end = crash_base + crash_size - 1;
 }
-
-static void __init kexec_reserve_crashkres_pages(void)
-{
-#ifdef CONFIG_HIBERNATION
-	phys_addr_t addr;
-	struct page *page;
-
-	if (!crashk_res.end)
-		return;
-
-	/*
-	 * To reduce the size of hibernation image, all the pages are
-	 * marked as Reserved initially.
-	 */
-	for (addr = crashk_res.start; addr < (crashk_res.end + 1);
-			addr += PAGE_SIZE) {
-		page = phys_to_page(addr);
-		SetPageReserved(page);
-	}
-#endif
-}
 #else
 static void __init reserve_crashkernel(void)
 {
 }
-
-static void __init kexec_reserve_crashkres_pages(void)
-{
-}
 #endif /* CONFIG_KEXEC_CORE */
 
 #ifdef CONFIG_CRASH_DUMP
@@ -586,8 +561,6 @@ void __init mem_init(void)
 	/* this will put all unused low memory onto the freelists */
 	memblock_free_all();
 
-	kexec_reserve_crashkres_pages();
-
 	mem_init_print_info(NULL);
 
 	/*
-- 
2.17.2
