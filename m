Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5C06B0038
	for <linux-mm@kvack.org>; Sun,  2 Apr 2017 22:20:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m28so128692856pgn.14
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 19:20:54 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id r76si12643354pfe.57.2017.04.02.19.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Apr 2017 19:20:53 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id 81so105603708pgh.2
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 19:20:53 -0700 (PDT)
From: AKASHI Takahiro <takahiro.akashi@linaro.org>
Subject: [PATCH v35 01/14] memblock: add memblock_clear_nomap()
Date: Mon,  3 Apr 2017 11:23:54 +0900
Message-Id: <20170403022355.12463-1-takahiro.akashi@linaro.org>
In-Reply-To: <20170403022139.12383-1-takahiro.akashi@linaro.org>
References: <20170403022139.12383-1-takahiro.akashi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org
Cc: james.morse@arm.com, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, ard.biesheuvel@linaro.org, panand@redhat.com, sgoel@codeaurora.org, dwmw2@infradead.org, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, AKASHI Takahiro <takahiro.akashi@linaro.org>

This function, with a combination of memblock_mark_nomap(), will be used
in a later kdump patch for arm64 when it temporarily isolates some range
of memory from the other memory blocks in order to create a specific
kernel mapping at boot time.

Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bdfc65af4152..e82daffcfc44 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -93,6 +93,7 @@ int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
+int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
 
 /* Low level functions */
diff --git a/mm/memblock.c b/mm/memblock.c
index 696f06d17c4e..2f4ca8104ea4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -805,6 +805,18 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
 }
 
 /**
+ * memblock_clear_nomap - Clear flag MEMBLOCK_NOMAP for a specified region.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * Return 0 on success, -errno on failure.
+ */
+int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 0, MEMBLOCK_NOMAP);
+}
+
+/**
  * __next_reserved_mem_region - next function for for_each_reserved_region()
  * @idx: pointer to u64 loop variable
  * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
