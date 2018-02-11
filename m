Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB61A6B0003
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 23:34:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e74so1243771wmg.0
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 20:34:02 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id p13si4387121wrd.431.2018.02.10.20.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 20:34:01 -0800 (PST)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 11 Feb 2018 04:31:11 +0000
Message-ID: <lsq.1518323471.705119318@decadent.org.uk>
Subject: [PATCH 3.16 131/136] x86/vdso: Get pvclock data from the vvar VMA
 instead of the fixmap
In-Reply-To: <lsq.1518323469.348919605@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>

3.16.54-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit dac16fba6fc590fa7239676b35ed75dae4c4cd2b upstream.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/9d37826fdc7e2d2809efe31d5345f97186859284.1449702533.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
[bwh: Backported to 3.16: adjust filenames]
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/vdso/vclock_gettime.c  | 20 ++++++++------------
 arch/x86/vdso/vdso-layout.lds.S |  3 ++-
 arch/x86/vdso/vdso2c.c          |  3 +++
 arch/x86/vdso/vma.c             | 13 +++++++++++++
 arch/x86/include/asm/pvclock.h  |  9 +++++++++
 arch/x86/include/asm/vdso.h     |  1 +
 arch/x86/kernel/kvmclock.c      |  5 +++++
 7 files changed, 41 insertions(+), 13 deletions(-)

--- a/arch/x86/vdso/vclock_gettime.c
+++ b/arch/x86/vdso/vclock_gettime.c
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
@@ -62,23 +67,14 @@ notrace static long vdso_fallback_gtod(s
 
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
--- a/arch/x86/vdso/vdso-layout.lds.S
+++ b/arch/x86/vdso/vdso-layout.lds.S
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
 
--- a/arch/x86/vdso/vdso2c.c
+++ b/arch/x86/vdso/vdso2c.c
@@ -23,6 +23,7 @@ enum {
 	sym_vvar_start,
 	sym_vvar_page,
 	sym_hpet_page,
+	sym_pvclock_page,
 	sym_VDSO_FAKE_SECTION_TABLE_START,
 	sym_VDSO_FAKE_SECTION_TABLE_END,
 };
@@ -30,6 +31,7 @@ enum {
 const int special_pages[] = {
 	sym_vvar_page,
 	sym_hpet_page,
+	sym_pvclock_page,
 };
 
 struct vdso_sym {
@@ -41,6 +43,7 @@ struct vdso_sym required_syms[] = {
 	[sym_vvar_start] = {"vvar_start", true},
 	[sym_vvar_page] = {"vvar_page", true},
 	[sym_hpet_page] = {"hpet_page", true},
+	[sym_pvclock_page] = {"pvclock_page", true},
 	[sym_VDSO_FAKE_SECTION_TABLE_START] = {
 		"VDSO_FAKE_SECTION_TABLE_START", false
 	},
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -113,6 +113,7 @@ static int map_vdso(const struct vdso_im
 		.name = "[vvar]",
 		.pages = no_pages,
 	};
+	struct pvclock_vsyscall_time_info *pvti;
 
 	if (calculate_addr) {
 		addr = vdso_addr(current->mm->start_stack,
@@ -182,6 +183,18 @@ static int map_vdso(const struct vdso_im
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
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -22,6 +22,7 @@ struct vdso_image {
 
 	long sym_vvar_page;
 	long sym_hpet_page;
+	long sym_pvclock_page;
 	long sym_VDSO32_NOTE_MASK;
 	long sym___kernel_sigreturn;
 	long sym___kernel_rt_sigreturn;
--- a/arch/x86/kernel/kvmclock.c
+++ b/arch/x86/kernel/kvmclock.c
@@ -44,6 +44,11 @@ early_param("no-kvmclock", parse_no_kvmc
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
