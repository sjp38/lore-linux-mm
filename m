Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8195D6B025C
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:22:00 -0500 (EST)
Received: by pfbu66 with SMTP id u66so14692508pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:22:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id 85si161453pfn.11.2015.12.10.19.21.59
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:21:59 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 6/6] x86/vdso: Disallow vvar access to vclock IO for never-used vclocks
Date: Thu, 10 Dec 2015 19:21:47 -0800
Message-Id: <3edcff8e6f4169cccbb227d74fc65bf061ded6e2.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

It makes me uncomfortable that even modern systems grant every
process direct read access to the HPET.

While fixing this for real without regressing anything is a mess
(unmapping the HPET is tricky because we don't adequately track all
the mappings), we can do almost as well by tracking which vclocks
have ever been used and only allowing pages associated with used
vclocks to be faulted in.

This will cause rogue programs that try to peek at the HPET to get
SIGBUS instead on most systems.

We can't restrict faults to vclock pages that are associated with
the currently selected vclock due to a race: a process could start
to access the HPET for the first time and race against a switch away
from the HPET as the current clocksource.  We can't segfault the
process trying to peek at the HPET in this case, even though the
process isn't going to do anything useful with the data.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vma.c               | 4 ++--
 arch/x86/entry/vsyscall/vsyscall_gtod.c | 9 ++++++++-
 arch/x86/include/asm/clocksource.h      | 9 +++++----
 arch/x86/include/asm/vgtod.h            | 6 ++++++
 4 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 02221e98b83f..aa4f5b99f1f3 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -130,7 +130,7 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 				    __pa_symbol(&__vvar_page) >> PAGE_SHIFT);
 	} else if (sym_offset == image->sym_hpet_page) {
 #ifdef CONFIG_HPET_TIMER
-		if (hpet_address) {
+		if (hpet_address && vclock_was_used(VCLOCK_HPET)) {
 			ret = vm_insert_pfn_prot(
 				vma,
 				(unsigned long)vmf->virtual_address,
@@ -141,7 +141,7 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 	} else if (sym_offset == image->sym_pvclock_page) {
 		struct pvclock_vsyscall_time_info *pvti =
 			pvclock_pvti_cpu0_va();
-		if (pvti) {
+		if (pvti && vclock_was_used(VCLOCK_PVCLOCK)) {
 			ret = vm_insert_pfn(
 				vma,
 				(unsigned long)vmf->virtual_address,
diff --git a/arch/x86/entry/vsyscall/vsyscall_gtod.c b/arch/x86/entry/vsyscall/vsyscall_gtod.c
index 51e330416995..0fb3a104ac62 100644
--- a/arch/x86/entry/vsyscall/vsyscall_gtod.c
+++ b/arch/x86/entry/vsyscall/vsyscall_gtod.c
@@ -16,6 +16,8 @@
 #include <asm/vgtod.h>
 #include <asm/vvar.h>
 
+int vclocks_used __read_mostly;
+
 DEFINE_VVAR(struct vsyscall_gtod_data, vsyscall_gtod_data);
 
 void update_vsyscall_tz(void)
@@ -26,12 +28,17 @@ void update_vsyscall_tz(void)
 
 void update_vsyscall(struct timekeeper *tk)
 {
+	int vclock_mode = tk->tkr_mono.clock->archdata.vclock_mode;
 	struct vsyscall_gtod_data *vdata = &vsyscall_gtod_data;
 
+	/* Mark the new vclock used. */
+	BUILD_BUG_ON(VCLOCK_MAX >= 32);
+	WRITE_ONCE(vclocks_used, READ_ONCE(vclocks_used) | (1 << vclock_mode));
+
 	gtod_write_begin(vdata);
 
 	/* copy vsyscall data */
-	vdata->vclock_mode	= tk->tkr_mono.clock->archdata.vclock_mode;
+	vdata->vclock_mode	= vclock_mode;
 	vdata->cycle_last	= tk->tkr_mono.cycle_last;
 	vdata->mask		= tk->tkr_mono.mask;
 	vdata->mult		= tk->tkr_mono.mult;
diff --git a/arch/x86/include/asm/clocksource.h b/arch/x86/include/asm/clocksource.h
index eda81dc0f4ae..d194266acb28 100644
--- a/arch/x86/include/asm/clocksource.h
+++ b/arch/x86/include/asm/clocksource.h
@@ -3,10 +3,11 @@
 #ifndef _ASM_X86_CLOCKSOURCE_H
 #define _ASM_X86_CLOCKSOURCE_H
 
-#define VCLOCK_NONE 0  /* No vDSO clock available.	*/
-#define VCLOCK_TSC  1  /* vDSO should use vread_tsc.	*/
-#define VCLOCK_HPET 2  /* vDSO should use vread_hpet.	*/
-#define VCLOCK_PVCLOCK 3 /* vDSO should use vread_pvclock. */
+#define VCLOCK_NONE	0  /* No vDSO clock available.	*/
+#define VCLOCK_TSC	1  /* vDSO should use vread_tsc.	*/
+#define VCLOCK_HPET	2  /* vDSO should use vread_hpet.	*/
+#define VCLOCK_PVCLOCK	3 /* vDSO should use vread_pvclock. */
+#define VCLOCK_MAX	3
 
 struct arch_clocksource_data {
 	int vclock_mode;
diff --git a/arch/x86/include/asm/vgtod.h b/arch/x86/include/asm/vgtod.h
index f556c4843aa1..e728699db774 100644
--- a/arch/x86/include/asm/vgtod.h
+++ b/arch/x86/include/asm/vgtod.h
@@ -37,6 +37,12 @@ struct vsyscall_gtod_data {
 };
 extern struct vsyscall_gtod_data vsyscall_gtod_data;
 
+extern int vclocks_used;
+static inline bool vclock_was_used(int vclock)
+{
+	return READ_ONCE(vclocks_used) & (1 << vclock);
+}
+
 static inline unsigned gtod_read_begin(const struct vsyscall_gtod_data *s)
 {
 	unsigned ret;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
