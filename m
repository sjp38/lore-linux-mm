From: Andi Kleen <andi@firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
In-Reply-To: <20080317258.659191058@firstfloor.org>
Subject: [PATCH] [17/18] Add huge pud support to mm/memory.c
Message-Id: <20080317015831.297501B41E0@basil.firstfloor.org>
Date: Mon, 17 Mar 2008 02:58:31 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

mm/memory.c seems to have already gained some knowledge about huge pages:
in particularly in get_user_pages.  Fix that code up to support huge 
puds.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 mm/memory.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c
+++ linux/mm/memory.c
@@ -931,7 +931,13 @@ struct page *follow_page(struct vm_area_
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
 		goto no_page_table;
-	
+
+	if (pud_huge(*pud)) {
+		BUG_ON(flags & FOLL_GET);
+		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
+		goto out;
+	}
+
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto no_page_table;
@@ -1422,6 +1428,8 @@ static int apply_to_pmd_range(struct mm_
 	unsigned long next;
 	int err;
 
+	BUG_ON(pud_huge(*pud));
+
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
