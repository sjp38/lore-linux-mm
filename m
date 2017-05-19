Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5A072806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:58:32 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r27so27423705qtr.10
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:58:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m1si9047146qkc.24.2017.05.19.09.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 09:58:31 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH] x86/mm: synchronize pgd in vmemmap_free()
Date: Fri, 19 May 2017 14:01:27 -0400
Message-Id: <1495216887-3175-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
References: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>

When we free kernel virtual map we should synchronize p4d/pud for
all the pgds to avoid any stall entry in non canonical pgd.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@suse.de>
---
 arch/x86/mm/init_64.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index ff95fe8..df753f8 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -108,8 +108,6 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		BUILD_BUG_ON(pgd_none(*pgd_ref));
 		p4d_ref = p4d_offset(pgd_ref, address);
 
-		if (p4d_none(*p4d_ref))
-			continue;
 
 		spin_lock(&pgd_lock);
 		list_for_each_entry(page, &pgd_list, lru) {
@@ -123,12 +121,16 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
 			spin_lock(pgt_lock);
 
-			if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
-				BUG_ON(p4d_page_vaddr(*p4d)
-				       != p4d_page_vaddr(*p4d_ref));
-
-			if (p4d_none(*p4d))
+			if (p4d_none(*p4d_ref)) {
 				set_p4d(p4d, *p4d_ref);
+			} else {
+				if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
+					BUG_ON(p4d_page_vaddr(*p4d)
+					       != p4d_page_vaddr(*p4d_ref));
+
+				if (p4d_none(*p4d))
+					set_p4d(p4d, *p4d_ref);
+			}
 
 			spin_unlock(pgt_lock);
 		}
@@ -1024,6 +1026,7 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 void __ref vmemmap_free(unsigned long start, unsigned long end)
 {
 	remove_pagetable(start, end, false);
+	sync_global_pgds(start, end - 1);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
