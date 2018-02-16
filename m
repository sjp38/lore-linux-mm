Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42C8D6B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 06:49:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id l1so1976023pga.1
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 03:49:55 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v3-v6si367116ply.829.2018.02.16.03.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 03:49:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/3] x86/mm: Redefine some of page table helpers as macros
Date: Fri, 16 Feb 2018 14:49:47 +0300
Message-Id: <20180216114948.68868-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
References: <20180216114948.68868-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation for the next patch, which would change
pgtable_l5_enabled to be cpu_feature_enabled(X86_FEATURE_LA57).

The change makes few helpers in paravirt.h dependent on
cpu_feature_enabled() definition from cpufeature.h.
And cpufeature.h is dependent on paravirt.h.

Let's re-define some of helpers as macros to break this dependency loop.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 70d3c86927de..6d3b921ae43a 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -567,19 +567,22 @@ static inline p4dval_t p4d_val(p4d_t p4d)
 	return PVOP_CALLEE1(p4dval_t, pv_mmu_ops.p4d_val, p4d.p4d);
 }
 
-static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
+static inline void __set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
-	if (pgtable_l5_enabled)
-		PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgd));
-	else
-		set_p4d((p4d_t *)(pgdp), (p4d_t) { pgd.pgd });
+	PVOP_VCALL2(pv_mmu_ops.set_pgd, pgdp, native_pgd_val(pgd));
 }
 
-static inline void pgd_clear(pgd_t *pgdp)
-{
-	if (pgtable_l5_enabled)
-		set_pgd(pgdp, __pgd(0));
-}
+#define set_pgd(pgdp, pgdval) do {					\
+	if (pgtable_l5_enabled)						\
+		__set_pgd(pgdp, pgdval);				\
+	else								\
+		set_p4d((p4d_t *)(pgdp), (p4d_t) { (pgdval).pgd });	\
+} while (0)
+
+#define pgd_clear(pgdp) do {						\
+	if (pgtable_l5_enabled)						\
+		set_pgd(pgdp, __pgd(0));				\
+} while (0)
 
 #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
