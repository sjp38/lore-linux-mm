Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 553CF6B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:32:02 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id p10so262481pdj.1
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:32:01 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id am7si7195088pad.299.2014.01.22.03.31.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:32:01 -0800 (PST)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 1/3] ARM: Premit ioremap() to map reserved pages
Date: Wed, 22 Jan 2014 19:25:14 +0800
Message-ID: <1390389916-8711-2-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kexec@lists.infradead.org
Cc: Eric Biederman <ebiederm@xmission.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Geng Hui <hui.geng@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>, stable@vger.kernel.org

This patch relaxes the restriction set by commit 309caa9cc, which
prohibit ioremap() on all kernel managed pages.

Other architectures, such as x86 and (some specific platforms of) powerpc,
allow such mapping.

ioremap() pages is an efficient way to avoid arm's mysterious cache control.
This feature will be used for arm kexec support to ensure copied data goes into
RAM even without cache flushing, because we found that flush_cache_xxx can't
reliably flush code to memory.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: <stable@vger.kernel.org> # 3.4+
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Geng Hui <hui.geng@huawei.com>
---
 arch/arm/mm/ioremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index f123d6e..98b1c10 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -298,7 +298,7 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
 	/*
 	 * Don't allow RAM to be mapped - this causes problems with ARMv6+
 	 */
-	if (WARN_ON(pfn_valid(pfn)))
+	if (WARN_ON(pfn_valid(pfn) && !PageReserved(pfn_to_page(pfn))))
 		return NULL;
 
 	area = get_vm_area_caller(size, VM_IOREMAP, caller);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
