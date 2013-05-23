Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 750956B005C
	for <linux-mm@kvack.org>; Thu, 23 May 2013 13:08:27 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id q56so2168084wes.37
        for <linux-mm@kvack.org>; Thu, 23 May 2013 10:08:25 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 10/11] ARM64: mm: Raise MAX_ORDER for 64KB pages and THP.
Date: Thu, 23 May 2013 18:07:57 +0100
Message-Id: <1369328878-11706-11-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

The buddy allocator has a default MAX_ORDER of 11, which is too
low to allocate enough memory for 512MB Transparent HugePages if
our base page size is 64KB.

This patch introduces MAX_ZONE_ORDER and sets it to 14 when 64KB
pages are used in conjuction with THP, otherwise the default value
of 11 is used.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index cd6eca8..10607d6 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -191,6 +191,11 @@ config ARCH_WANT_HUGE_PMD_SHARE
 
 source "mm/Kconfig"
 
+config FORCE_MAX_ZONEORDER
+	int
+	default "14" if (ARM64_64K_PAGES && TRANSPARENT_HUGEPAGE)
+	default "11"
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
