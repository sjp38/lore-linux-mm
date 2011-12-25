Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DF6E66B005A
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 15:46:24 -0500 (EST)
Message-ID: <4EF78B99.1020109@parallels.com>
Date: Mon, 26 Dec 2011 00:46:17 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] mincore: Introduce the MINCORE_ANON bit
References: <4EF78B6A.8020904@parallels.com>
In-Reply-To: <4EF78B6A.8020904@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

When creating a memory dump of a running application it is better to have
the smallest possible set of pages. Using the existing mincore() bit helps,
but not much -- it repotes pages from page cache, which have not necessarily
being mapped by an application, and pages from private file mappings, that
are not yet being cow-ed and thus their contents doesn't differ from file.

Introduce the 2nd bit of mincore, that reports whether a page is not backed
by a file on disk. I.e. all pages from anonymous mappings and those pages
from private file mappings, that have already being cow-ed by write.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/mman.h |    1 +
 mm/mincore.c         |   15 +++++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index e4fda1e..9d1de16 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -11,6 +11,7 @@
 #define OVERCOMMIT_NEVER		2
 
 #define MINCORE_RESIDENT	0x1
+#define MINCORE_ANON		0x2
 
 #ifdef __KERNEL__
 #include <linux/mm.h>
diff --git a/mm/mincore.c b/mm/mincore.c
index b719cdd..3163dfb 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -38,7 +38,7 @@ static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
 				       addr & huge_page_mask(h));
 		present = ptep && !huge_pte_none(huge_ptep_get(ptep));
 		while (1) {
-			*vec = (present ? MINCORE_RESIDENT : 0);
+			*vec = (present ? MINCORE_RESIDENT : 0) | MINCORE_ANON;
 			vec++;
 			addr += PAGE_SIZE;
 			if (addr == end)
@@ -86,6 +86,17 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 	return present ? MINCORE_RESIDENT : 0;
 }
 
+static unsigned char mincore_pte(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
+{
+	struct page *pg;
+
+	pg = vm_normal_page(vma, addr, pte);
+	if (!pg)
+		return 0;
+	else
+		return PageAnon(pg) ? MINCORE_ANON : 0;
+}
+
 static void mincore_unmapped_range(struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
 				unsigned char *vec)
@@ -122,7 +133,7 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (pte_none(pte))
 			mincore_unmapped_range(vma, addr, next, vec);
 		else if (pte_present(pte))
-			*vec = MINCORE_RESIDENT;
+			*vec = MINCORE_RESIDENT | mincore_pte(vma, addr, pte);
 		else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
 			*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
