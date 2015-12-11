Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 994536B0256
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:20:34 -0500 (EST)
Received: by pfnn128 with SMTP id n128so58450552pfn.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:20:34 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id gl10si283964pac.164.2015.12.10.19.20.33
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:20:33 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 3/5] x86/vdso: Get pvclock data from the vvar VMA instead of the fixmap
Date: Thu, 10 Dec 2015 19:20:20 -0800
Message-Id: <9d37826fdc7e2d2809efe31d5345f97186859284.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
In-Reply-To: <cover.1449702533.git.luto@kernel.org>
References: <cover.1449702533.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vclock_gettime.c  | 20 ++++++++------------
 arch/x86/entry/vdso/vdso-layout.lds.S |  3 ++-
 arch/x86/entry/vdso/vdso2c.c          |  3 +++
 arch/x86/entry/vdso/vma.c             | 13 +++++++++++++
 arch/x86/include/asm/pvclock.h        |  9 +++++++++
 arch/x86/include/asm/vdso.h           |  1 +
 arch/x86/kernel/kvmclock.c            |  5 +++++
 7 files changed, 41 insertions(+), 13 deletions(-)

diff --git a/arch/x86/entry/vdso/vclock_gettime.c b/arch/x86/entry/vdso/vclock_gettime.c
index c325ba1bdddf..5dd363d54348 100644
--- a/arch/x86/entry/vdso/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vclock_gettime.c
@@ -36,6 +36,11 @@ static notrace cycle_t vread_hpet(void)
 }
 #endif
 
+#ifdef CONFIG_PARAVIRT_CLOCK
+extern u8 pvclock_page
+	__attribute__((visibility("hidden")));
+#endif
+
 #ifndef BUILD_VDSO32
 
 #include <linux/kernel.h>
@@ -62,23 +67,14 @@ notrace static long vdso_fallback_gtod(struct timeval *tv, struct timezone *tz)
 
 #ifdef CONFIG_PARAVIRT_CLOCK
 
-static notrace const struct pvclock_vsyscall_time_info *get_pvti(int cpu)
+static notrace const struct pvclock_vsyscall_time_info *get_pvti0(void)
 {
-	const struct pvclock_vsyscall_time_info *pvti_base;
-	int idx = cpu / (PAGE_SIZE/PVTI_SIZE);
-	int offset = cpu % (PAGE_SIZE/PVTI_SIZE);
-
-	BUG_ON(PVCLOCK_FIXMAP_BEGIN + idx > PVCLOCK_FIXMAP_END);
-
-	pvti_base = (struct pvclock_vsyscall_time_info *)
-		    __fix_to_virt(PVCLOCK_FIXMAP_BEGIN+idx);
-
-	return &pvti_base[offset];
+	return (const struct pvclock_vsyscall_time_info *)&pvclock_page;
 }
 
 static notrace cycle_t vread_pvclock(int *mode)
 {
-	const struct pvclock_vcpu_time_info *pvti = &get_pvti(0)->pvti;
+	const struct pvclock_vcpu_time_info *pvti = &get_pvti0()->pvti;
 	cycle_t ret;
 	u64 tsc, pvti_tsc;
 	u64 last, delta, pvti_system_time;
diff --git a/arch/x86/entry/vdso/vdso-layout.lds.S b/arch/x86/entry/vdso/vdso-layout.lds.S
index de2c921025f5..4158acc17df0 100644
--- a/arch/x86/entry/vdso/vdso-layout.lds.S
+++ b/arch/x86/entry/vdso/vdso-layout.lds.S
@@ -25,7 +25,7 @@ SECTIONS
 	 * segment.
 	 */
 
-	vvar_start = . - 2 * PAGE_SIZE;
+	vvar_start = . - 3 * PAGE_SIZE;
 	vvar_page = vvar_start;
 
 	/* Place all vvars at the offsets in asm/vvar.h. */
@@ -36,6 +36,7 @@ SECTIONS
 #undef EMIT_VVAR
 
 	hpet_page = vvar_start + PAGE_SIZE;
+	pvclock_page = vvar_start + 2 * PAGE_SIZE;
 
 	. = SIZEOF_HEADERS;
 
diff --git a/arch/x86/entry/vdso/vdso2c.c b/arch/x86/entry/vdso/vdso2c.c
index 785d9922b106..491020b2826d 100644
--- a/arch/x86/entry/vdso/vdso2c.c
+++ b/arch/x86/entry/vdso/vdso2c.c
@@ -73,6 +73,7 @@ enum {
 	sym_vvar_start,
 	sym_vvar_page,
 	sym_hpet_page,
+	sym_pvclock_page,
 	sym_VDSO_FAKE_SECTION_TABLE_START,
 	sym_VDSO_FAKE_SECTION_TABLE_END,
 };
@@ -80,6 +81,7 @@ enum {
 const int special_pages[] = {
 	sym_vvar_page,
 	sym_hpet_page,
+	sym_pvclock_page,
 };
 
 struct vdso_sym {
@@ -91,6 +93,7 @@ struct vdso_sym required_syms[] = {
 	[sym_vvar_start] = {"vvar_start", true},
 	[sym_vvar_page] = {"vvar_page", true},
 	[sym_hpet_page] = {"hpet_page", true},
+	[sym_pvclock_page] = {"pvclock_page", true},
 	[sym_VDSO_FAKE_SECTION_TABLE_START] = {
 		"VDSO_FAKE_SECTION_TABLE_START", false
 	},
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 64df47148160..aa828191c654 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -100,6 +100,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 		.name = "[vvar]",
 		.pages = no_pages,
 	};
+	struct pvclock_vsyscall_time_info *pvti;
 
 	if (calculate_addr) {
 		addr = vdso_addr(current->mm->start_stack,
@@ -169,6 +170,18 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	}
 #endif
 
+	pvti = pvclock_pvti_cpu0_va();
+	if (pvti && image->sym_pvclock_page) {
+		ret = remap_pfn_range(vma,
+				      text_start + image->sym_pvclock_page,
+				      __pa(pvti) >> PAGE_SHIFT,
+				      PAGE_SIZE,
+				      PAGE_READONLY);
+
+		if (ret)
+			goto up_fail;
+	}
+
 up_fail:
 	if (ret)
 		current->mm->context.vdso = NULL;
diff --git a/arch/x86/include/asm/pvclock.h b/arch/x86/include/asm/pvclock.h
index 7a6bed5c08bc..3864398c7cb2 100644
--- a/arch/x86/include/asm/pvclock.h
+++ b/arch/x86/include/asm/pvclock.h
@@ -4,6 +4,15 @@
 #include <linux/clocksource.h>
 #include <asm/pvclock-abi.h>
 
+#ifdef CONFIG_PARAVIRT_CLOCK
+extern struct pvclock_vsyscall_time_info *pvclock_pvti_cpu0_va(void);
+#else
+static inline struct pvclock_vsyscall_time_info *pvclock_pvti_cpu0_va(void)
+{
+	return NULL;
+}
+#endif
+
 /* some helper functions for xen and kvm pv clock sources */
 cycle_t pvclock_clocksource_read(struct pvclock_vcpu_time_info *src);
 u8 pvclock_read_flags(struct pvclock_vcpu_time_info *src);
diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index 756de9190aec..deabaf9759b6 100644
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -22,6 +22,7 @@ struct vdso_image {
 
 	long sym_vvar_page;
 	long sym_hpet_page;
+	long sym_pvclock_page;
 	long sym_VDSO32_NOTE_MASK;
 	long sym___kernel_sigreturn;
 	long sym___kernel_rt_sigreturn;
diff --git a/arch/x86/kernel/kvmclock.c b/arch/x86/kernel/kvmclock.c
index 2bd81e302427..ec1b06dc82d2 100644
--- a/arch/x86/kernel/kvmclock.c
+++ b/arch/x86/kernel/kvmclock.c
@@ -45,6 +45,11 @@ early_param("no-kvmclock", parse_no_kvmclock);
 static struct pvclock_vsyscall_time_info *hv_clock;
 static struct pvclock_wall_clock wall_clock;
 
+struct pvclock_vsyscall_time_info *pvclock_pvti_cpu0_va(void)
+{
+	return hv_clock;
+}
+
 /*
  * The wallclock is the time of day when we booted. Since then, some time may
  * have elapsed since the hypervisor wrote the data. So we try to account for
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
