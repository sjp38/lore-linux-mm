Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f49.google.com (mail-vk0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id F136F6B0254
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 19:14:20 -0500 (EST)
Received: by vkgy188 with SMTP id y188so6832094vkg.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:14:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 66si1718579vkm.45.2015.11.18.16.14.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 16:14:20 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2] arm: Update all mm structures with section adjustments
Date: Wed, 18 Nov 2015 16:14:14 -0800
Message-Id: <1447892054-8095-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>, Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, when updating section permissions to mark areas RO
or NX, the only mm updated is current->mm. This is working off
the assumption that there are no additional mm structures at
the time. This may not always hold true. (Example: calling
modprobe early will trigger a fork/exec). Ensure all mm structres
get updated with the new section information.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
I don't think we can get away from updating the sections if the initmem is
going to be freed back to the buddy allocator. I think this should cover
everything based on my understanding but my knowledge may be incomplete.
---
 arch/arm/mm/init.c | 92 ++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 30 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 8a63b4c..7f8cd1b 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -22,6 +22,7 @@
 #include <linux/memblock.h>
 #include <linux/dma-contiguous.h>
 #include <linux/sizes.h>
+#include <linux/stop_machine.h>
 
 #include <asm/cp15.h>
 #include <asm/mach-types.h>
@@ -627,12 +628,10 @@ static struct section_perm ro_perms[] = {
  * safe to be called with preemption disabled, as under stop_machine().
  */
 static inline void section_update(unsigned long addr, pmdval_t mask,
-				  pmdval_t prot)
+				  pmdval_t prot, struct mm_struct *mm)
 {
-	struct mm_struct *mm;
 	pmd_t *pmd;
 
-	mm = current->active_mm;
 	pmd = pmd_offset(pud_offset(pgd_offset(mm, addr), addr), addr);
 
 #ifdef CONFIG_ARM_LPAE
@@ -656,49 +655,82 @@ static inline bool arch_has_strict_perms(void)
 	return !!(get_cr() & CR_XP);
 }
 
-#define set_section_perms(perms, field)	{				\
-	size_t i;							\
-	unsigned long addr;						\
-									\
-	if (!arch_has_strict_perms())					\
-		return;							\
-									\
-	for (i = 0; i < ARRAY_SIZE(perms); i++) {			\
-		if (!IS_ALIGNED(perms[i].start, SECTION_SIZE) ||	\
-		    !IS_ALIGNED(perms[i].end, SECTION_SIZE)) {		\
-			pr_err("BUG: section %lx-%lx not aligned to %lx\n", \
-				perms[i].start, perms[i].end,		\
-				SECTION_SIZE);				\
-			continue;					\
-		}							\
-									\
-		for (addr = perms[i].start;				\
-		     addr < perms[i].end;				\
-		     addr += SECTION_SIZE)				\
-			section_update(addr, perms[i].mask,		\
-				       perms[i].field);			\
-	}								\
+void set_section_perms(struct section_perm *perms, int n, bool set,
+			struct mm_struct *mm)
+{
+	size_t i;
+	unsigned long addr;
+
+	if (!arch_has_strict_perms())
+		return;
+
+	for (i = 0; i < n; i++) {
+		if (!IS_ALIGNED(perms[i].start, SECTION_SIZE) ||
+		    !IS_ALIGNED(perms[i].end, SECTION_SIZE)) {
+			pr_err("BUG: section %lx-%lx not aligned to %lx\n",
+				perms[i].start, perms[i].end,
+				SECTION_SIZE);
+			continue;
+		}
+
+		for (addr = perms[i].start;
+		     addr < perms[i].end;
+		     addr += SECTION_SIZE)
+			section_update(addr, perms[i].mask,
+				set ? perms[i].prot : perms[i].clear, mm);
+	}
+
 }
 
-static inline void fix_kernmem_perms(void)
+static void update_sections_early(struct section_perm perms[], int n)
 {
-	set_section_perms(nx_perms, prot);
+	struct task_struct *t, *s;
+
+	read_lock(&tasklist_lock);
+	for_each_process(t) {
+		if (t->flags & PF_KTHREAD)
+			continue;
+		for_each_thread(t, s)
+			set_section_perms(perms, n, true, s->mm);
+	}
+	read_unlock(&tasklist_lock);
+	set_section_perms(perms, n, true, current->active_mm);
+	set_section_perms(perms, n, true, &init_mm);
+}
+
+int __fix_kernmem_perms(void *unused)
+{
+	update_sections_early(nx_perms, ARRAY_SIZE(nx_perms));
+	return 0;
+}
+
+void fix_kernmem_perms(void)
+{
+	stop_machine(__fix_kernmem_perms, NULL, NULL);
 }
 
 #ifdef CONFIG_DEBUG_RODATA
+int __mark_rodata_ro(void *unused)
+{
+	update_sections_early(ro_perms, ARRAY_SIZE(ro_perms));
+	return 0;
+}
+
 void mark_rodata_ro(void)
 {
-	set_section_perms(ro_perms, prot);
+	stop_machine(__mark_rodata_ro, NULL, NULL);
 }
 
 void set_kernel_text_rw(void)
 {
-	set_section_perms(ro_perms, clear);
+	set_section_perms(ro_perms, ARRAY_SIZE(ro_perms), false,
+				current->active_mm);
 }
 
 void set_kernel_text_ro(void)
 {
-	set_section_perms(ro_perms, prot);
+	set_section_perms(ro_perms, ARRAY_SIZE(ro_perms), true,
+				current->active_mm);
 }
 #endif /* CONFIG_DEBUG_RODATA */
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
