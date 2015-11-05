Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B313D82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 20:00:58 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so68953337pab.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:00:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ja8si3578395pbd.47.2015.11.04.17.00.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 17:00:57 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCH] arm: Use kernel mm when updating section permissions
Date: Wed,  4 Nov 2015 17:00:39 -0800
Message-Id: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>, Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, read only permissions are not being applied even
when CONFIG_DEBUG_RODATA is set. This is because section_update
uses current->mm for adjusting the page tables. current->mm
need not be equivalent to the kernel version. Use pgd_offset_k
to get the proper page directory for updating.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
I found this while trying to convince myself of something.
Dumping the page table via debugfs and writing to kernel text were both
showing the lack of mappings. This was observed on QEMU. Maybe it's just a
QEMUism but if not it probably should go to stable.
---
 arch/arm/mm/init.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 8a63b4c..4bb936a 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -629,11 +629,9 @@ static struct section_perm ro_perms[] = {
 static inline void section_update(unsigned long addr, pmdval_t mask,
 				  pmdval_t prot)
 {
-	struct mm_struct *mm;
 	pmd_t *pmd;
 
-	mm = current->active_mm;
-	pmd = pmd_offset(pud_offset(pgd_offset(mm, addr), addr), addr);
+	pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
 
 #ifdef CONFIG_ARM_LPAE
 	pmd[0] = __pmd((pmd_val(pmd[0]) & mask) | prot);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
