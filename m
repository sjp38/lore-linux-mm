Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 9DF076B0115
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:31:20 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id k13so669532wgh.7
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:31:18 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH 8/9] ARM64: mm: Introduce MAX_ZONE_ORDER for 64K and THP.
Date: Tue, 30 Apr 2013 17:30:47 +0100
Message-Id: <1367339448-21727-9-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>

The buddy allocator has a default order of 11, which is too low to
allocate enough memory for 512MB Transparent HugePages if our base
page size is 64K. For any order less than 13, the combination of
THP with 64K pages will cause a compile error.

This patch introduces the MAX_ZONE_ORDER config option that allows
one to explicitly override the order of the buddy allocator. If
64K pages and THP are enabled the minimum value is set to 13.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm64/Kconfig | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 16aa780..908fd95 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -196,6 +196,23 @@ config ARCH_WANT_HUGE_PMD_SHARE
 
 source "mm/Kconfig"
 
+config FORCE_MAX_ZONEORDER
+	int "Maximum zone order"
+	range 11 64 if !(ARM64_64K_PAGES && TRANSPARENT_HUGEPAGE)
+	range 13 64 if ARM64_64K_PAGES && TRANSPARENT_HUGEPAGE
+	default "11" if !(ARM64_64K_PAGES && TRANSPARENT_HUGEPAGE)
+	default "13" if (ARM64_64K_PAGES && TRANSPARENT_HUGEPAGE)
+	help
+	  The kernel memory allocator divides physically contiguous memory
+	  blocks into "zones", where each zone is a power of two number of
+	  pages.  This option selects the largest power of two that the kernel
+	  keeps in the memory allocator.  If you need to allocate very large
+	  blocks of physically contiguous memory, then you may need to
+	  increase this value.
+
+	  This config option is actually maximum order plus one. For example,
+	  a value of 11 means that the largest free memory block is 2^10 pages.
+
 endmenu
 
 menu "Boot options"
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
