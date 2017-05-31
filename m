Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C47C16B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:03:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k11so6740144qtk.4
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:03:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t187si16420127qkh.150.2017.05.31.08.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 08:03:53 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Date: Wed, 31 May 2017 11:03:49 -0400
Message-Id: <20170531150349.4816-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()")
we no longer cleanup stall pgd entries and thus the BUG_ON() inside
sync_global_pgds() is wrong.

This patch remove the BUG_ON() and unconditionaly update stall pgd
entries.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/init_64.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index ff95fe8..36b9020 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -123,12 +123,7 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
 			spin_lock(pgt_lock);
 
-			if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
-				BUG_ON(p4d_page_vaddr(*p4d)
-				       != p4d_page_vaddr(*p4d_ref));
-
-			if (p4d_none(*p4d))
-				set_p4d(p4d, *p4d_ref);
+			set_p4d(p4d, *p4d_ref);
 
 			spin_unlock(pgt_lock);
 		}
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
