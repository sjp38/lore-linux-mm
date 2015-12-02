From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Date: Wed, 2 Dec 2015 12:27:25 -0800
Message-ID: <20151202202725.GA794@www.outflux.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <kernel-hardening-return-2042-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
To: Laura Abbott <labbott@redhat.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nico@linaro.org>, Arnd Bergmann <arnd@arndb.de>, kernel-hardening@lists.openwall.com
List-Id: linux-mm.kvack.org

The use of CONFIG_DEBUG_RODATA is generally seen as an essential part of
kernel self-protection:
http://www.openwall.com/lists/kernel-hardening/2015/11/30/13
Additionally, its name has grown to mean things beyond just rodata. To
get ARM closer to this, we ought to rearrange the names of the configs
that control how the kernel protects its memory. What was called
CONFIG_ARM_KERNMEM_PERMS is really doing the work that other architectures
call CONFIG_DEBUG_RODATA.

This redefines CONFIG_DEBUG_RODATA to actually do the bulk of the
ROing (and NXing). In the place of the old CONFIG_DEBUG_RODATA, use
CONFIG_DEBUG_ALIGN_RODATA, since that's what the option does: adds
section alignment for making rodata explicitly NX, as arm does not split
the page tables like arm64 does without _ALIGN_RODATA.

Also adds human readable names to the sections so I could more easily
debug my typos, and makes CONFIG_DEBUG_RODATA default "y" for CPU_V7.

Results in /sys/kernel/debug/kernel_page_tables for each config state:

 # CONFIG_DEBUG_RODATA is not set
 # CONFIG_DEBUG_ALIGN_RODATA is not set

---[ Kernel Mapping ]---
0x80000000-0x80900000           9M     RW x  SHD
0x80900000-0xa0000000         503M     RW NX SHD

 CONFIG_DEBUG_RODATA=y
 CONFIG_DEBUG_ALIGN_RODATA=y

---[ Kernel Mapping ]---
0x80000000-0x80100000           1M     RW NX SHD
0x80100000-0x80700000           6M     ro x  SHD
0x80700000-0x80a00000           3M     ro NX SHD
0x80a00000-0xa0000000         502M     RW NX SHD

 CONFIG_DEBUG_RODATA=y
 # CONFIG_DEBUG_ALIGN_RODATA is not set

---[ Kernel Mapping ]---
0x80000000-0x80100000           1M     RW NX SHD
0x80100000-0x80a00000           9M     ro x  SHD
0x80a00000-0xa0000000         502M     RW NX SHD

Signed-off-by: Kees Cook <keescook@chromium.org>
---
Depends on 8464/1 "Update all mm structures with section adjustments"
---
 arch/arm/kernel/vmlinux.lds.S | 10 +++++-----
 arch/arm/mm/Kconfig           | 34 ++++++++++++++++++----------------
 arch/arm/mm/init.c            | 19 ++++++++++---------
 3 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index 8b60fde5ce48..a6e395c53a48 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -8,7 +8,7 @@
 #include <asm/thread_info.h>
 #include <asm/memory.h>
 #include <asm/page.h>
-#ifdef CONFIG_ARM_KERNMEM_PERMS
+#ifdef CONFIG_DEBUG_RODATA
 #include <asm/pgtable.h>
 #endif
 
@@ -94,7 +94,7 @@ SECTIONS
 		HEAD_TEXT
 	}
 
-#ifdef CONFIG_ARM_KERNMEM_PERMS
+#ifdef CONFIG_DEBUG_RODATA
 	. = ALIGN(1<<SECTION_SHIFT);
 #endif
 
@@ -117,7 +117,7 @@ SECTIONS
 			ARM_CPU_KEEP(PROC_INFO)
 	}
 
-#ifdef CONFIG_DEBUG_RODATA
+#ifdef CONFIG_DEBUG_ALIGN_RODATA
 	. = ALIGN(1<<SECTION_SHIFT);
 #endif
 	RO_DATA(PAGE_SIZE)
@@ -153,7 +153,7 @@ SECTIONS
 	_etext = .;			/* End of text and rodata section */
 
 #ifndef CONFIG_XIP_KERNEL
-# ifdef CONFIG_ARM_KERNMEM_PERMS
+# ifdef CONFIG_DEBUG_RODATA
 	. = ALIGN(1<<SECTION_SHIFT);
 # else
 	. = ALIGN(PAGE_SIZE);
@@ -231,7 +231,7 @@ SECTIONS
 	__data_loc = ALIGN(4);		/* location in binary */
 	. = PAGE_OFFSET + TEXT_OFFSET;
 #else
-#ifdef CONFIG_ARM_KERNMEM_PERMS
+#ifdef CONFIG_DEBUG_RODATA
 	. = ALIGN(1<<SECTION_SHIFT);
 #else
 	. = ALIGN(THREAD_SIZE);
diff --git a/arch/arm/mm/Kconfig b/arch/arm/mm/Kconfig
index 41218867a9a6..68331f91c90f 100644
--- a/arch/arm/mm/Kconfig
+++ b/arch/arm/mm/Kconfig
@@ -1039,24 +1039,26 @@ config ARCH_SUPPORTS_BIG_ENDIAN
 	  This option specifies the architecture can support big endian
 	  operation.
 
-config ARM_KERNMEM_PERMS
-	bool "Restrict kernel memory permissions"
+config DEBUG_RODATA
+	bool "Make kernel text and rodata read-only"
 	depends on MMU
+	default y if CPU_V7
 	help
-	  If this is set, kernel memory other than kernel text (and rodata)
-	  will be made non-executable. The tradeoff is that each region is
-	  padded to section-size (1MiB) boundaries (because their permissions
-	  are different and splitting the 1M pages into 4K ones causes TLB
-	  performance problems), wasting memory.
+	  If this is set, kernel text and rodata memory will be made
+	  read-only, and non-text kernel memory will be made non-executable.
+	  The tradeoff is that each region is padded to section-size (1MiB)
+	  boundaries (because their permissions are different and splitting
+	  the 1M pages into 4K ones causes TLB performance problems), which
+	  can waste memory.
 
-config DEBUG_RODATA
-	bool "Make kernel text and rodata read-only"
-	depends on ARM_KERNMEM_PERMS
+config DEBUG_ALIGN_RODATA
+	bool "Make rodata strictly non-executable"
+	depends on DEBUG_RODATA
 	default y
 	help
-	  If this is set, kernel text and rodata will be made read-only. This
-	  is to help catch accidental or malicious attempts to change the
-	  kernel's executable code. Additionally splits rodata from kernel
-	  text so it can be made explicitly non-executable. This creates
-	  another section-size padded region, so it can waste more memory
-	  space while gaining the read-only protections.
+	  If this is set, rodata will be made explicitly non-executable. This
+	  provides protection on the rare chance that attackers might find and
+	  use ROP gadgets that exist in the rodata section. This adds an
+	  additional section-aligned split of rodata from kernel text so it
+	  can be made explicitly non-executable. This padding may waste memory
+	  space to gain the additional protection.
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 7f8cd1b3557f..321d3683dc7c 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -569,8 +569,9 @@ void __init mem_init(void)
 	}
 }
 
-#ifdef CONFIG_ARM_KERNMEM_PERMS
+#ifdef CONFIG_DEBUG_RODATA
 struct section_perm {
+	const char *name;
 	unsigned long start;
 	unsigned long end;
 	pmdval_t mask;
@@ -581,6 +582,7 @@ struct section_perm {
 static struct section_perm nx_perms[] = {
 	/* Make pages tables, etc before _stext RW (set NX). */
 	{
+		.name	= "pre-text NX",
 		.start	= PAGE_OFFSET,
 		.end	= (unsigned long)_stext,
 		.mask	= ~PMD_SECT_XN,
@@ -588,14 +590,16 @@ static struct section_perm nx_perms[] = {
 	},
 	/* Make init RW (set NX). */
 	{
+		.name	= "init NX",
 		.start	= (unsigned long)__init_begin,
 		.end	= (unsigned long)_sdata,
 		.mask	= ~PMD_SECT_XN,
 		.prot	= PMD_SECT_XN,
 	},
-#ifdef CONFIG_DEBUG_RODATA
+#ifdef CONFIG_DEBUG_ALIGN_RODATA
 	/* Make rodata NX (set RO in ro_perms below). */
 	{
+		.name	= "rodata NX",
 		.start  = (unsigned long)__start_rodata,
 		.end    = (unsigned long)__init_begin,
 		.mask   = ~PMD_SECT_XN,
@@ -604,10 +608,10 @@ static struct section_perm nx_perms[] = {
 #endif
 };
 
-#ifdef CONFIG_DEBUG_RODATA
 static struct section_perm ro_perms[] = {
 	/* Make kernel code and rodata RX (set RO). */
 	{
+		.name	= "text/rodata RO",
 		.start  = (unsigned long)_stext,
 		.end    = (unsigned long)__init_begin,
 #ifdef CONFIG_ARM_LPAE
@@ -620,7 +624,6 @@ static struct section_perm ro_perms[] = {
 #endif
 	},
 };
-#endif
 
 /*
  * Updates section permissions only for the current mm (sections are
@@ -667,8 +670,8 @@ void set_section_perms(struct section_perm *perms, int n, bool set,
 	for (i = 0; i < n; i++) {
 		if (!IS_ALIGNED(perms[i].start, SECTION_SIZE) ||
 		    !IS_ALIGNED(perms[i].end, SECTION_SIZE)) {
-			pr_err("BUG: section %lx-%lx not aligned to %lx\n",
-				perms[i].start, perms[i].end,
+			pr_err("BUG: %s section %lx-%lx not aligned to %lx\n",
+				perms[i].name, perms[i].start, perms[i].end,
 				SECTION_SIZE);
 			continue;
 		}
@@ -709,7 +712,6 @@ void fix_kernmem_perms(void)
 	stop_machine(__fix_kernmem_perms, NULL, NULL);
 }
 
-#ifdef CONFIG_DEBUG_RODATA
 int __mark_rodata_ro(void *unused)
 {
 	update_sections_early(ro_perms, ARRAY_SIZE(ro_perms));
@@ -732,11 +734,10 @@ void set_kernel_text_ro(void)
 	set_section_perms(ro_perms, ARRAY_SIZE(ro_perms), true,
 				current->active_mm);
 }
-#endif /* CONFIG_DEBUG_RODATA */
 
 #else
 static inline void fix_kernmem_perms(void) { }
-#endif /* CONFIG_ARM_KERNMEM_PERMS */
+#endif /* CONFIG_DEBUG_RODATA */
 
 void free_tcmmem(void)
 {
-- 
1.9.1


-- 
Kees Cook
Chrome OS & Brillo Security
