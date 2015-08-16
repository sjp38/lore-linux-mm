Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2649003C8
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 16:49:40 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so82533016qgd.3
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 13:49:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 80si21944734qkp.10.2015.08.16.13.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Aug 2015 13:49:38 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V3 2/3] arm64: support initrd outside kernel linear map
Date: Sun, 16 Aug 2015 16:49:27 -0400
Message-Id: <1439758168-29427-3-git-send-email-msalter@redhat.com>
In-Reply-To: <1439758168-29427-1-git-send-email-msalter@redhat.com>
References: <1439758168-29427-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mark Salter <msalter@redhat.com>

The use of mem= could leave part or all of the initrd outside of
the kernel linear map. This will lead to an error when unpacking
the initrd and a probable failure to boot. This patch catches that
situation and relocates the initrd to be fully within the linear
map.

Signed-off-by: Mark Salter <msalter@redhat.com>
---
 arch/arm64/kernel/setup.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index f3067d4..5f45fd9 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -359,6 +359,64 @@ static void __init request_standard_resources(void)
 	}
 }
 
+#ifdef CONFIG_BLK_DEV_INITRD
+/*
+ * Relocate initrd if it is not completely within the linear mapping.
+ * This would be the case if mem= cuts out all or part of it.
+ */
+static void __init relocate_initrd(void)
+{
+	phys_addr_t orig_start = __virt_to_phys(initrd_start);
+	phys_addr_t orig_end = __virt_to_phys(initrd_end);
+	phys_addr_t ram_end = memblock_end_of_DRAM();
+	phys_addr_t new_start;
+	unsigned long size, to_free = 0;
+	void *dest;
+
+	if (orig_end <= ram_end)
+		return;
+
+	/* Note if any of original initrd will freeing below */
+	if (orig_start < ram_end)
+		to_free = ram_end - orig_start;
+
+	size = orig_end - orig_start;
+
+	/* initrd needs to be relocated completely inside linear mapping */
+	new_start = memblock_find_in_range(0, PFN_PHYS(max_pfn),
+					   size, PAGE_SIZE);
+	if (!new_start)
+		panic("Cannot relocate initrd of size %ld\n", size);
+	memblock_reserve(new_start, size);
+
+	initrd_start = __phys_to_virt(new_start);
+	initrd_end   = initrd_start + size;
+
+	pr_info("Moving initrd from [%llx-%llx] to [%llx-%llx]\n",
+		orig_start, orig_start + size - 1,
+		new_start, new_start + size - 1);
+
+	dest = (void *)initrd_start;
+
+	if (to_free) {
+		memcpy(dest, (void *)__phys_to_virt(orig_start), to_free);
+		dest += to_free;
+	}
+
+	copy_from_early_mem(dest, orig_start + to_free, size - to_free);
+
+	if (to_free) {
+		pr_info("Freeing original RAMDISK from [%llx-%llx]\n",
+			orig_start, orig_start + to_free - 1);
+		memblock_free(orig_start, to_free);
+	}
+}
+#else
+static inline void __init reserve_initrd(void)
+{
+}
+#endif
+
 u64 __cpu_logical_map[NR_CPUS] = { [0 ... NR_CPUS-1] = INVALID_HWID };
 
 void __init setup_arch(char **cmdline_p)
@@ -392,6 +450,7 @@ void __init setup_arch(char **cmdline_p)
 	acpi_boot_table_init();
 
 	paging_init();
+	relocate_initrd();
 	request_standard_resources();
 
 	early_ioremap_reset();
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
