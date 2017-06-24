Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15C146B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 14:05:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k14so31625018qkl.11
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 11:05:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r25si6976608qtb.66.2017.06.24.11.05.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 11:05:19 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not freeing pud v3
Date: Sat, 24 Jun 2017 14:05:14 -0400
Message-Id: <20170624180514.3821-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Andrew Morton <akpm@linux-foundation.org>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

With commit af2cf278ef4f we no longer free pud so that we do not
have synchronize all pgd on hotremove/vfree. But the new 5 level
page table patchset reverted that for 4 level page table.

This patch restore af2cf278ef4f and disable free_pud() if we are
in the 4 level page table case thus avoiding BUG_ON() after hot-
remove.

af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()

Changed since v2:
  - nove to if the callsite instead of having special version of
    free_pud for 4 level page table
Changed since v1:
  - make free_pud() conditional on the number of page table
    level
  - improved commit message

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviwed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/init_64.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 95651dc58e09..dc4c99f9ca58 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -990,7 +990,13 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 
 		pud_base = pud_offset(p4d, 0);
 		remove_pud_table(pud_base, addr, next, direct);
-		free_pud_table(pud_base, p4d);
+		/*
+		 * For 4 levels page table we do not want to free puds but for
+		 * 5 levels we should free them. This code also need to change
+		 * to adapt for boot time switching between 4 and 5 level.
+		 */
+		if (CONFIG_PGTABLE_LEVELS == 5)
+			free_pud_table(pud_base, p4d);
 	}
 
 	if (direct)
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
