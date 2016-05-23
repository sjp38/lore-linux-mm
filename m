Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F16C26B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 14:43:11 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hs7so4151877pac.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:43:11 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id or6si18032581pac.233.2016.05.23.11.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 11:43:11 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id bt5so64661562pac.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:43:11 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [v2 PATCH] mm: make CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on !FLATMEM explicitly
Date: Mon, 23 May 2016 11:15:56 -0700
Message-Id: <1464027356-32282-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

Per the suggestion from Michal Hocko [1], DEFERRED_STRUCT_PAGE_INIT requires
some ordering wrt other initialization operations, e.g. page_ext_init has to
happen after the whole memmap is initialized properly. For SPARSEMEM this
requires to wait for page_alloc_init_late. Other memory models (e.g. flatmem)
might have different initialization layouts (page_ext_init_flatmem). Currently
DEFERRED_STRUCT_PAGE_INIT depends on MEMORY_HOTPLUG which in turn
	depends on SPARSEMEM || X86_64_ACPI_NUMA
	depends on ARCH_ENABLE_MEMORY_HOTPLUG

and X86_64_ACPI_NUMA depends on NUMA which in turn disable FLATMEM
memory model:
config ARCH_FLATMEM_ENABLE
	def_bool y
	depends on X86_32 && !NUMA

so FLATMEM is ruled out via dependency maze. Be explicit and disable
FLATMEM for DEFERRED_STRUCT_PAGE_INIT so that we do not reintroduce
subtle initialization bugs

[1] http://lkml.kernel.org/r/20160523073157.GD2278@dhcp22.suse.cz

CC: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
v2:
 Adopted Michal's comments for the commit log

 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 2664c11..22fa818 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -649,6 +649,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 	default n
 	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 	depends on MEMORY_HOTPLUG
+	depends on !FLATMEM
 	help
 	  Ordinarily all struct pages are initialised during early boot in a
 	  single thread. On very large machines this can take a considerable
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
