Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7971D6B0071
	for <linux-mm@kvack.org>; Fri,  8 May 2015 13:18:08 -0400 (EDT)
Received: by pdea3 with SMTP id a3so93002956pde.3
        for <linux-mm@kvack.org>; Fri, 08 May 2015 10:18:08 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id jq15si4141506pbb.91.2015.05.08.10.17.59
        for <linux-mm@kvack.org>;
        Fri, 08 May 2015 10:17:59 -0700 (PDT)
Message-Id: <8b6b7831d31eb3711dcdbb1b117b685101bb2d47.1431103461.git.tony.luck@intel.com>
In-Reply-To: <cover.1431103461.git.tony.luck@intel.com>
References: <cover.1431103461.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Thu, 7 May 2015 15:19:27 -0700
Subject: [PATCHv2 3/3] x86, mirror: x86 enabling - find mirrored memory ranges
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

v1->v2:
	Use u64 instead of "unsigned long long"

Just one checkpatch warning for this patch:
WARNING: line over 80 characters
#86: FILE: include/linux/efi.h:100:
+				((u64)0x0000000000010000ULL)	/* higher reliability */
But this fits the style for all the other attribute defintions
(all of which are above 80 columns - one even longer than this new one)

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
index 02744df576d5..8b1d8dfa3c5c 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -117,6 +117,27 @@ void efi_get_time(struct timespec *now)
 	now->tv_nsec = 0;
 }
 
+void __init efi_find_mirror(void)
+{
+	void *p;
+	u64 mirror_size = 0, total_size = 0;
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
index af5be0368dec..8d4efdb9dfe9 100644
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
+extern void efi_find_mirror(void);
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
