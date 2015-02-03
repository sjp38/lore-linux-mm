Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C4B9C6B0073
	for <linux-mm@kvack.org>; Mon,  4 May 2015 16:57:52 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so173487113pdb.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 13:57:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ha8si21264229pac.226.2015.05.04.13.57.51
        for <linux-mm@kvack.org>;
        Mon, 04 May 2015 13:57:51 -0700 (PDT)
Message-Id: <b28413d7e10a07406d87f8b48c7ea54e53273691.1430772743.git.tony.luck@intel.com>
In-Reply-To: <cover.1430772743.git.tony.luck@intel.com>
References: <cover.1430772743.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 3 Feb 2015 14:40:19 -0800
Subject: [PATCH 3/3] x86, mirror: x86 enabling - find mirrored memory ranges
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

UEFI GetMemoryMap() uses a new attribute bit to mark mirrored memory
address ranges. See UEFI 2.5 spec pages 157-158:

  http://www.uefi.org/sites/default/files/resources/UEFI%202_5.pdf

On EFI enabled systems scan the memory map and tell memblock about
any mirrored ranges.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/kernel/setup.c     |  3 +++
 arch/x86/platform/efi/efi.c | 21 +++++++++++++++++++++
 include/linux/efi.h         |  3 +++
 3 files changed, 27 insertions(+)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d74ac33290ae..ac85a1775661 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1103,6 +1103,9 @@ void __init setup_arch(char **cmdline_p)
 	memblock_set_current_limit(ISA_END_ADDRESS);
 	memblock_x86_fill();
 
+	if (efi_enabled(EFI_BOOT))
+		efi_find_mirror();
+
 	/*
 	 * The EFI specification says that boot service code won't be called
 	 * after ExitBootServices(). This is, in fact, a lie.
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 02744df576d5..31635dc5bca4 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -117,6 +117,27 @@ void efi_get_time(struct timespec *now)
 	now->tv_nsec = 0;
 }
 
+void __init efi_find_mirror(void)
+{
+	void *p;
+	unsigned long long mirror_size = 0, total_size = 0;
+
+	for (p = memmap.map; p < memmap.map_end; p += memmap.desc_size) {
+		efi_memory_desc_t *md = p;
+		unsigned long long start = md->phys_addr;
+		unsigned long long size = md->num_pages << EFI_PAGE_SHIFT;
+
+		total_size += size;
+		if (md->attribute & EFI_MEMORY_MORE_RELIABLE) {
+			memblock_mark_mirror(start, size);
+			mirror_size += size;
+		}
+	}
+	if (mirror_size)
+		pr_info("Memory: %lldM/%lldM mirrored memory\n",
+			mirror_size>>20, total_size>>20);
+}
+
 /*
  * Tell the kernel about the EFI memory map.  This might include
  * more than the max 128 entries that can fit in the e820 legacy
diff --git a/include/linux/efi.h b/include/linux/efi.h
index af5be0368dec..3f13903346a2 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -96,6 +96,8 @@ typedef	struct {
 #define EFI_MEMORY_WP		((u64)0x0000000000001000ULL)	/* write-protect */
 #define EFI_MEMORY_RP		((u64)0x0000000000002000ULL)	/* read-protect */
 #define EFI_MEMORY_XP		((u64)0x0000000000004000ULL)	/* execute-protect */
+#define EFI_MEMORY_MORE_RELIABLE \
+				((u64)0x0000000000010000ULL)	/* higher reliability */
 #define EFI_MEMORY_RUNTIME	((u64)0x8000000000000000ULL)	/* range requires runtime mapping */
 #define EFI_MEMORY_DESCRIPTOR_VERSION	1
 
@@ -864,6 +866,7 @@ extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, if pos
 extern void efi_late_init(void);
 extern void efi_free_boot_services(void);
 extern efi_status_t efi_query_variable_store(u32 attributes, unsigned long size);
+extern void efi_find_mirror (void);
 #else
 static inline void efi_late_init(void) {}
 static inline void efi_free_boot_services(void) {}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
