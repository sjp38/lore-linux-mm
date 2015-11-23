Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 355D06B0260
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:07:37 -0500 (EST)
Received: by wmec201 with SMTP id c201so95521583wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:36 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id jh1si17877899wjb.174.2015.11.23.01.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:07:35 -0800 (PST)
Received: by wmec201 with SMTP id c201so95520939wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:35 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 13/13] ARM: add UEFI stub support
Date: Mon, 23 Nov 2015 10:06:33 +0100
Message-Id: <1448269593-20758-14-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

From: Roy Franz <roy.franz@linaro.org>

This patch adds EFI stub support for the ARM Linux kernel.

The EFI stub operates similarly to the x86 and arm64 stubs: it is a
shim between the EFI firmware and the normal zImage entry point, and
sets up the environment that the zImage is expecting. This includes
optionally loading the initrd and device tree from the system partition
based on the kernel command line.

Signed-off-by: Roy Franz <roy.franz@linaro.org>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/Kconfig                          |  19 +++
 arch/arm/boot/compressed/Makefile         |   4 +-
 arch/arm/boot/compressed/efi-header.S     | 130 ++++++++++++++++++++
 arch/arm/boot/compressed/head.S           |  54 +++++++-
 arch/arm/boot/compressed/vmlinux.lds.S    |   7 ++
 arch/arm/include/asm/efi.h                |  23 ++++
 drivers/firmware/efi/libstub/Makefile     |   9 ++
 drivers/firmware/efi/libstub/arm-stub.c   |   4 +-
 drivers/firmware/efi/libstub/arm32-stub.c |  85 +++++++++++++
 9 files changed, 331 insertions(+), 4 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 7e338228cc8d..0d84e04cfe48 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -2041,6 +2041,25 @@ config AUTO_ZRELADDR
 	  0xf8000000. This assumes the zImage being placed in the first 128MB
 	  from start of memory.
 
+config EFI_STUB
+	bool
+
+config EFI
+	bool "UEFI runtime support"
+	depends on OF && !CPU_BIG_ENDIAN && MMU && AUTO_ZRELADDR && !XIP_KERNEL
+	select UCS2_STRING
+	select EFI_PARAMS_FROM_FDT
+	select EFI_STUB
+	select EFI_ARMSTUB
+	select EFI_RUNTIME_WRAPPERS
+	---help---
+	  This option provides support for runtime services provided
+	  by UEFI firmware (such as non-volatile variables, realtime
+	  clock, and platform reset). A UEFI stub is also provided to
+	  allow the kernel to be booted as an EFI application. This
+	  is only useful for kernels that may run on systems that have
+	  UEFI firmware.
+
 endmenu
 
 menu "CPU Power Management"
diff --git a/arch/arm/boot/compressed/Makefile b/arch/arm/boot/compressed/Makefile
index 3f9a9ebc77c3..4c23a68a0917 100644
--- a/arch/arm/boot/compressed/Makefile
+++ b/arch/arm/boot/compressed/Makefile
@@ -167,9 +167,11 @@ if [ $(words $(ZRELADDR)) -gt 1 -a "$(CONFIG_AUTO_ZRELADDR)" = "" ]; then \
 	false; \
 fi
 
+efi-obj-$(CONFIG_EFI_STUB) := $(objtree)/drivers/firmware/efi/libstub/lib.a
+
 $(obj)/vmlinux: $(obj)/vmlinux.lds $(obj)/$(HEAD) $(obj)/piggy.$(suffix_y).o \
 		$(addprefix $(obj)/, $(OBJS)) $(lib1funcs) $(ashldi3) \
-		$(bswapsdi2) FORCE
+		$(bswapsdi2) $(efi-obj-y) FORCE
 	@$(check_for_multiple_zreladdr)
 	$(call if_changed,ld)
 	@$(check_for_bad_syms)
diff --git a/arch/arm/boot/compressed/efi-header.S b/arch/arm/boot/compressed/efi-header.S
new file mode 100644
index 000000000000..9d5dc4fda3c1
--- /dev/null
+++ b/arch/arm/boot/compressed/efi-header.S
@@ -0,0 +1,130 @@
+/*
+ * Copyright (C) 2013-2015 Linaro Ltd
+ * Authors: Roy Franz <roy.franz@linaro.org>
+ *          Ard Biesheuvel <ard.biesheuvel@linaro.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+		.macro	__nop
+#ifdef CONFIG_EFI_STUB
+		@ This is almost but not quite a NOP, since it does clobber the
+		@ condition flags. But it is the best we can do for EFI, since
+		@ PE/COFF expects the magic string "MZ" at offset 0, while the
+		@ ARM/Linux boot protocol expects an executable instruction
+		@ there.
+		.inst	'M' | ('Z' << 8) | (0x1310 << 16)   @ tstne r0, #0x4d000
+#else
+		mov	r0, r0
+#endif
+		.endm
+
+		.macro	__EFI_HEADER
+#ifdef CONFIG_EFI_STUB
+		b	__efi_start
+
+		.set	start_offset, __efi_start - start
+		.org	start + 0x3c
+		@
+		@ The PE header can be anywhere in the file, but for
+		@ simplicity we keep it together with the MSDOS header
+		@ The offset to the PE/COFF header needs to be at offset
+		@ 0x3C in the MSDOS header.
+		@ The only 2 fields of the MSDOS header that are used are this
+		@ PE/COFF offset, and the "MZ" bytes at offset 0x0.
+		@
+		.long	pe_header - start	@ Offset to the PE header.
+
+pe_header:
+		.ascii	"PE\0\0"
+
+coff_header:
+		.short	0x01c2			@ ARM or Thumb
+		.short	2			@ nr_sections
+		.long	0 			@ TimeDateStamp
+		.long	0			@ PointerToSymbolTable
+		.long	1			@ NumberOfSymbols
+		.short	section_table - optional_header
+						@ SizeOfOptionalHeader
+		.short	0x306			@ Characteristics.
+						@ IMAGE_FILE_32BIT_MACHINE |
+						@ IMAGE_FILE_DEBUG_STRIPPED |
+						@ IMAGE_FILE_EXECUTABLE_IMAGE |
+						@ IMAGE_FILE_LINE_NUMS_STRIPPED
+
+optional_header:
+		.short	0x10b			@ PE32 format
+		.byte	0x02			@ MajorLinkerVersion
+		.byte	0x14			@ MinorLinkerVersion
+		.long	_end - __efi_start	@ SizeOfCode
+		.long	0			@ SizeOfInitializedData
+		.long	0			@ SizeOfUninitializedData
+		.long	efi_stub_entry - start	@ AddressOfEntryPoint
+		.long	start_offset		@ BaseOfCode
+		.long	0			@ data
+
+extra_header_fields:
+		.long	0			@ ImageBase
+		.long	0x200			@ SectionAlignment
+		.long	0x200			@ FileAlignment
+		.short	0			@ MajorOperatingSystemVersion
+		.short	0			@ MinorOperatingSystemVersion
+		.short	0			@ MajorImageVersion
+		.short	0			@ MinorImageVersion
+		.short	0			@ MajorSubsystemVersion
+		.short	0			@ MinorSubsystemVersion
+		.long	0			@ Win32VersionValue
+
+		.long	_end - start		@ SizeOfImage
+		.long	start_offset		@ SizeOfHeaders
+		.long	0			@ CheckSum
+		.short	0xa			@ Subsystem (EFI application)
+		.short	0			@ DllCharacteristics
+		.long	0			@ SizeOfStackReserve
+		.long	0			@ SizeOfStackCommit
+		.long	0			@ SizeOfHeapReserve
+		.long	0			@ SizeOfHeapCommit
+		.long	0			@ LoaderFlags
+		.long	0x6			@ NumberOfRvaAndSizes
+
+		.quad	0			@ ExportTable
+		.quad	0			@ ImportTable
+		.quad	0			@ ResourceTable
+		.quad	0			@ ExceptionTable
+		.quad	0			@ CertificationTable
+		.quad	0			@ BaseRelocationTable
+
+section_table:
+		@
+		@ The EFI application loader requires a relocation section
+		@ because EFI applications must be relocatable. This is a
+		@ dummy section as far as we are concerned.
+		@
+		.ascii	".reloc\0\0"
+		.long	0			@ VirtualSize
+		.long	0			@ VirtualAddress
+		.long	0			@ SizeOfRawData
+		.long	0			@ PointerToRawData
+		.long	0			@ PointerToRelocations
+		.long	0			@ PointerToLineNumbers
+		.short	0			@ NumberOfRelocations
+		.short	0			@ NumberOfLineNumbers
+		.long	0x42100040		@ Characteristics
+
+		.ascii	".text\0\0\0"
+		.long	_end - __efi_start	@ VirtualSize
+		.long	__efi_start		@ VirtualAddress
+		.long	_edata - __efi_start	@ SizeOfRawData
+		.long	__efi_start		@ PointerToRawData
+		.long	0			@ PointerToRelocations
+		.long	0			@ PointerToLineNumbers
+		.short	0			@ NumberOfRelocations
+		.short	0			@ NumberOfLineNumbers
+		.long	0xe0500020		@ Characteristics
+
+		.align	9
+__efi_start:
+#endif
+		.endm
diff --git a/arch/arm/boot/compressed/head.S b/arch/arm/boot/compressed/head.S
index 06e983f59980..af11c2f8f3b7 100644
--- a/arch/arm/boot/compressed/head.S
+++ b/arch/arm/boot/compressed/head.S
@@ -12,6 +12,8 @@
 #include <asm/assembler.h>
 #include <asm/v7m.h>
 
+#include "efi-header.S"
+
  AR_CLASS(	.arch	armv7-a	)
  M_CLASS(	.arch	armv7-m	)
 
@@ -126,7 +128,7 @@
 start:
 		.type	start,#function
 		.rept	7
-		mov	r0, r0
+		__nop
 		.endr
    ARM(		mov	r0, r0		)
    ARM(		b	1f		)
@@ -139,7 +141,8 @@ start:
 		.word	0x04030201	@ endianness flag
 
  THUMB(		.thumb			)
-1:
+1:		__EFI_HEADER
+
  ARM_BE8(	setend	be		)	@ go BE8 if compiled for BE8
  AR_CLASS(	mrs	r9, cpsr	)
 #ifdef CONFIG_ARM_VIRT_EXT
@@ -1353,6 +1356,53 @@ __enter_kernel:
 
 reloc_code_end:
 
+#ifdef CONFIG_EFI_STUB
+		.align	2
+_start:		.long	start - .
+
+ENTRY(efi_stub_entry)
+		@ allocate space on stack for passing current zImage address
+		@ and for the EFI stub to return of new entry point of
+		@ zImage, as EFI stub may copy the kernel. Pointer address
+		@ is passed in r2. r0 and r1 are passed through from the
+		@ EFI firmware to efi_entry
+		adr	ip, _start
+		ldr	r3, [ip]
+		add	r3, r3, ip
+		stmfd	sp!, {r3, lr}
+		mov	r2, sp			@ pass zImage address in r2
+		bl	efi_entry
+
+		@ Check for error return from EFI stub. r0 has FDT address
+		@ or error code.
+		cmn	r0, #1
+		beq	efi_load_fail
+
+		@ Preserve return value of efi_entry() in r4
+		mov	r4, r0
+		bl	cache_clean_flush
+		bl	cache_off
+
+		@ Set parameters for booting zImage according to boot protocol
+		@ put FDT address in r2, it was returned by efi_entry()
+		@ r1 is the machine type, and r0 needs to be 0
+		mov	r0, #0
+		mov	r1, #0xFFFFFFFF
+		mov	r2, r4
+
+		@ Branch to (possibly) relocated zImage that is in [sp]
+		ldr	lr, [sp]
+		ldr	ip, =start_offset
+		add	lr, lr, ip
+		mov	pc, lr				@ no mode switch
+
+efi_load_fail:
+		@ Return EFI_LOAD_ERROR to EFI firmware on error.
+		ldr	r0, =0x80000001
+		ldmfd	sp!, {ip, pc}
+ENDPROC(efi_stub_entry)
+#endif
+
 		.align
 		.section ".stack", "aw", %nobits
 .L_user_stack:	.space	4096
diff --git a/arch/arm/boot/compressed/vmlinux.lds.S b/arch/arm/boot/compressed/vmlinux.lds.S
index 2b60b843ac5e..81c493156ce8 100644
--- a/arch/arm/boot/compressed/vmlinux.lds.S
+++ b/arch/arm/boot/compressed/vmlinux.lds.S
@@ -48,6 +48,13 @@ SECTIONS
     *(.rodata)
     *(.rodata.*)
   }
+  .data : {
+    /*
+     * The EFI stub always executes from RAM, and runs strictly before the
+     * decompressor, so we can make an exception for its r/w data, and keep it
+     */
+    *(.data.efistub)
+  }
   .piggydata : {
     *(.piggydata)
   }
diff --git a/arch/arm/include/asm/efi.h b/arch/arm/include/asm/efi.h
index c91e330616ad..e0eea72deb87 100644
--- a/arch/arm/include/asm/efi.h
+++ b/arch/arm/include/asm/efi.h
@@ -57,4 +57,27 @@ void efi_virtmap_unload(void);
 #define efi_init()
 #endif /* CONFIG_EFI */
 
+/* arch specific definitions used by the stub code */
+
+#define efi_call_early(f, ...) sys_table_arg->boottime->f(__VA_ARGS__)
+
+/*
+ * A reasonable upper bound for the uncompressed kernel size is 32 MBytes,
+ * so we will reserve that amount of memory. We have no easy way to tell what
+ * the actuall size of code + data the uncompressed kernel will use.
+ * If this is insufficient, the decompressor will relocate itself out of the
+ * way before performing the decompression.
+ */
+#define MAX_UNCOMP_KERNEL_SIZE	SZ_32M
+
+/*
+ * The kernel zImage should preferably be located between 32 MB and 128 MB
+ * from the base of DRAM. The min address leaves space for a maximal size
+ * uncompressed image, and the max address is due to how the zImage decompressor
+ * picks a destination address.
+ */
+#define ZIMAGE_OFFSET_LIMIT	SZ_128M
+#define MIN_ZIMAGE_OFFSET	MAX_UNCOMP_KERNEL_SIZE
+#define MAX_FDT_OFFSET		ZIMAGE_OFFSET_LIMIT
+
 #endif /* _ASM_ARM_EFI_H */
diff --git a/drivers/firmware/efi/libstub/Makefile b/drivers/firmware/efi/libstub/Makefile
index 3c0467d3688c..8cf9ccbf42d5 100644
--- a/drivers/firmware/efi/libstub/Makefile
+++ b/drivers/firmware/efi/libstub/Makefile
@@ -34,6 +34,7 @@ $(obj)/lib-%.o: $(srctree)/lib/%.c FORCE
 lib-$(CONFIG_EFI_ARMSTUB)	+= arm-stub.o fdt.o string.o \
 				   $(patsubst %.c,lib-%.o,$(arm-deps))
 
+lib-$(CONFIG_ARM)		+= arm32-stub.o
 lib-$(CONFIG_ARM64)		+= arm64-stub.o
 CFLAGS_arm64-stub.o 		:= -DTEXT_OFFSET=$(TEXT_OFFSET)
 
@@ -67,3 +68,11 @@ quiet_cmd_stubcopy = STUBCPY $@
 		     $(OBJDUMP) -r $@ | grep $(STUBCOPY_RELOC-y)	\
 		     && (echo >&2 "$@: absolute symbol references not allowed in the EFI stub"; \
 			 rm -f $@; /bin/false); else /bin/false; fi
+
+#
+# ARM discards the .data section because it disallows r/w data in the
+# decompressor. So move our .data to .data.efistub, which is preserved
+# explicitly by the decompressor linker script.
+#
+STUBCOPY_FLAGS-$(CONFIG_ARM)	+= --rename-section .data=.data.efistub
+STUBCOPY_RELOC-$(CONFIG_ARM)	:= R_ARM_ABS
diff --git a/drivers/firmware/efi/libstub/arm-stub.c b/drivers/firmware/efi/libstub/arm-stub.c
index 950c87f5d279..3397902e4040 100644
--- a/drivers/firmware/efi/libstub/arm-stub.c
+++ b/drivers/firmware/efi/libstub/arm-stub.c
@@ -303,8 +303,10 @@ fail:
  * The value chosen is the largest non-zero power of 2 suitable for this purpose
  * both on 32-bit and 64-bit ARM CPUs, to maximize the likelihood that it can
  * be mapped efficiently.
+ * Since 32-bit ARM could potentially execute with a 1G/3G user/kernel split,
+ * map everything below 1 GB.
  */
-#define EFI_RT_VIRTUAL_BASE	0x40000000
+#define EFI_RT_VIRTUAL_BASE	SZ_512M
 
 static int cmp_mem_desc(const void *l, const void *r)
 {
diff --git a/drivers/firmware/efi/libstub/arm32-stub.c b/drivers/firmware/efi/libstub/arm32-stub.c
new file mode 100644
index 000000000000..958075a72d72
--- /dev/null
+++ b/drivers/firmware/efi/libstub/arm32-stub.c
@@ -0,0 +1,85 @@
+/*
+ * Copyright (C) 2013 Linaro Ltd;  <roy.franz@linaro.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/efi.h>
+#include <asm/efi.h>
+
+efi_status_t handle_kernel_image(efi_system_table_t *sys_table,
+				 unsigned long *image_addr,
+				 unsigned long *image_size,
+				 unsigned long *reserve_addr,
+				 unsigned long *reserve_size,
+				 unsigned long dram_base,
+				 efi_loaded_image_t *image)
+{
+	unsigned long nr_pages;
+	efi_status_t status;
+	/* Use alloc_addr to tranlsate between types */
+	efi_physical_addr_t alloc_addr;
+
+	/*
+	 * Verify that the DRAM base address is compatible with the ARM
+	 * boot protocol, which determines the base of DRAM by masking
+	 * off the low 27 bits of the address at which the zImage is
+	 * loaded. These assumptions are made by the decompressor,
+	 * before any memory map is available.
+	 */
+	dram_base = round_up(dram_base, SZ_128M);
+
+	/*
+	 * Reserve memory for the uncompressed kernel image. This is
+	 * all that prevents any future allocations from conflicting
+	 * with the kernel. Since we can't tell from the compressed
+	 * image how much DRAM the kernel actually uses (due to BSS
+	 * size uncertainty) we allocate the maximum possible size.
+	 * Do this very early, as prints can cause memory allocations
+	 * that may conflict with this.
+	 */
+	alloc_addr = dram_base;
+	*reserve_size = MAX_UNCOMP_KERNEL_SIZE;
+	nr_pages = round_up(*reserve_size, EFI_PAGE_SIZE) / EFI_PAGE_SIZE;
+	status = sys_table->boottime->allocate_pages(EFI_ALLOCATE_ADDRESS,
+						     EFI_LOADER_DATA,
+						     nr_pages, &alloc_addr);
+	if (status != EFI_SUCCESS) {
+		*reserve_size = 0;
+		pr_efi_err(sys_table, "Unable to allocate memory for uncompressed kernel.\n");
+		return status;
+	}
+	*reserve_addr = alloc_addr;
+
+	/*
+	 * Relocate the zImage, if required. ARM doesn't have a
+	 * preferred address, so we set it to 0, as we want to allocate
+	 * as low in memory as possible.
+	 */
+	*image_size = image->image_size;
+	status = efi_relocate_kernel(sys_table, image_addr, *image_size,
+				     *image_size, 0, 0);
+	if (status != EFI_SUCCESS) {
+		pr_efi_err(sys_table, "Failed to relocate kernel.\n");
+		efi_free(sys_table, *reserve_size, *reserve_addr);
+		*reserve_size = 0;
+		return status;
+	}
+
+	/*
+	 * Check to see if we were able to allocate memory low enough
+	 * in memory. The kernel determines the base of DRAM from the
+	 * address at which the zImage is loaded.
+	 */
+	if (*image_addr + *image_size > dram_base + ZIMAGE_OFFSET_LIMIT) {
+		pr_efi_err(sys_table, "Failed to relocate kernel, no low memory available.\n");
+		efi_free(sys_table, *reserve_size, *reserve_addr);
+		*reserve_size = 0;
+		efi_free(sys_table, *image_size, *image_addr);
+		*image_size = 0;
+		return EFI_LOAD_ERROR;
+	}
+	return EFI_SUCCESS;
+}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
