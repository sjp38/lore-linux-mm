Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA976B003B
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:10 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2956952pdi.5
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/34] x86: add missed pgtable_pmd_page_ctor/dtor calls for preallocated pmds
Date: Thu, 10 Oct 2013 21:05:26 +0300
Message-Id: <1381428359-14843-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've missed that we preallocate few pmds on pgd_alloc() if X86_PAE
enabled. Let's add missed constructor/destructor calls.

I haven't noticed it during testing since prep_new_page() clears
page->mapping and therefore page->ptl. It's effectively equal to
spin_lock_init(&page->ptl).

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/pgtable.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index dfa537a03b..1a7d21342e 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -189,8 +189,10 @@ static void free_pmds(pmd_t *pmds[])
 	int i;
 
 	for(i = 0; i < PREALLOCATED_PMDS; i++)
-		if (pmds[i])
+		if (pmds[i]) {
+			pgtable_pmd_page_dtor(virt_to_page(pmds[i]));
 			free_page((unsigned long)pmds[i]);
+		}
 }
 
 static int preallocate_pmds(pmd_t *pmds[])
@@ -200,8 +202,13 @@ static int preallocate_pmds(pmd_t *pmds[])
 
 	for(i = 0; i < PREALLOCATED_PMDS; i++) {
 		pmd_t *pmd = (pmd_t *)__get_free_page(PGALLOC_GFP);
-		if (pmd == NULL)
+		if (!pmd)
+			failed = true;
+		if (pmd && !pgtable_pmd_page_ctor(virt_to_page(pmd))) {
+			free_page((unsigned long)pmds[i]);
+			pmd = NULL;
 			failed = true;
+		}
 		pmds[i] = pmd;
 	}
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
