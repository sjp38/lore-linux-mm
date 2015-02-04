Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2791D6B0038
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 06:54:45 -0500 (EST)
Received: by pdjz10 with SMTP id z10so277144pdj.13
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 03:54:44 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id re7si1944350pab.63.2015.02.04.03.54.44
        for <linux-mm@kvack.org>;
        Wed, 04 Feb 2015 03:54:44 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] hugetlb, x86: register 1G page size if we can allocate them runtime
Date: Wed,  4 Feb 2015 13:54:31 +0200
Message-Id: <1423050871-122636-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

After commit 944d9fec8d7a we can allocate 1G pages runtime if CMA is
enabled.

Let's register 1G pages into hugetlb even if user hasn't requested them
explicitly at boot time with hugepagesz=1G.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/mm/hugetlbpage.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 9161f764121e..42982b26e32b 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -172,4 +172,15 @@ static __init int setup_hugepagesz(char *opt)
 	return 1;
 }
 __setup("hugepagesz=", setup_hugepagesz);
+
+#ifdef CONFIG_CMA
+static __init int gigantic_pages_init(void)
+{
+	/* With CMA we can allocate gigantic pages at runtime */
+	if (cpu_has_gbpages && !size_to_hstate(1UL << PUD_SHIFT))
+		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
+	return 0;
+}
+arch_initcall(gigantic_pages_init);
+#endif
 #endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
