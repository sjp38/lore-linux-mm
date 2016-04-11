Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AEEE86B0264
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:08:34 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id u206so99247683wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:34 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e133si3252881wmd.103.2016.04.11.04.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:29 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id l6so20396486wml.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 05/19] arm64: get rid of superfluous __GFP_REPEAT
Date: Mon, 11 Apr 2016 13:07:58 +0200
Message-Id: <1460372892-8157-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

{pte,pmd,pud}_alloc_one{_kernel}, late_pgtable_alloc use PGALLOC_GFP for
__get_free_page (aka order-0).

pgd_alloc is slightly more complex because it allocates from pgd_cache
if PGD_SIZE != PAGE_SIZE and PGD_SIZE depends on the configuration
(CONFIG_ARM64_VA_BITS, PAGE_SHIFT and CONFIG_PGTABLE_LEVELS).

As per
config PGTABLE_LEVELS
	int
	default 2 if ARM64_16K_PAGES && ARM64_VA_BITS_36
	default 2 if ARM64_64K_PAGES && ARM64_VA_BITS_42
	default 3 if ARM64_64K_PAGES && ARM64_VA_BITS_48
	default 3 if ARM64_4K_PAGES && ARM64_VA_BITS_39
	default 3 if ARM64_16K_PAGES && ARM64_VA_BITS_47
	default 4 if !ARM64_64K_PAGES && ARM64_VA_BITS_48

we should have the following options

CONFIG_ARM64_VA_BITS:48 CONFIG_PGTABLE_LEVELS:4 PAGE_SIZE:4k size:4096 pages:1
CONFIG_ARM64_VA_BITS:48 CONFIG_PGTABLE_LEVELS:4 PAGE_SIZE:16k size:16 pages:1
CONFIG_ARM64_VA_BITS:48 CONFIG_PGTABLE_LEVELS:3 PAGE_SIZE:64k size:512 pages:1
CONFIG_ARM64_VA_BITS:47 CONFIG_PGTABLE_LEVELS:3 PAGE_SIZE:16k size:16384 pages:1
CONFIG_ARM64_VA_BITS:42 CONFIG_PGTABLE_LEVELS:2 PAGE_SIZE:64k size:65536 pages:1
CONFIG_ARM64_VA_BITS:39 CONFIG_PGTABLE_LEVELS:3 PAGE_SIZE:4k size:4096 pages:1
CONFIG_ARM64_VA_BITS:36 CONFIG_PGTABLE_LEVELS:2 PAGE_SIZE:16k size:16384 pages:1

All of them fit into a single page (aka order-0). This means that this
flag has never been actually useful here because it has always been used
only for PAGE_ALLOC_COSTLY requests.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/arm64/include/asm/pgalloc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index ff98585d085a..d25f4f137c2a 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -26,7 +26,7 @@
 
 #define check_pgt_cache()		do { } while (0)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 #define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
 
 #if CONFIG_PGTABLE_LEVELS > 2
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
