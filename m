Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF0C6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:38:17 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e65so103370481pfe.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:38:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id u84si3439856pfa.199.2016.01.26.10.38.16
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 10:38:16 -0800 (PST)
Subject: [PATCH] mm: fix pfn_t to page conversion in vm_insert_mixed
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 26 Jan 2016 10:37:51 -0800
Message-ID: <20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, Tomi Valkeinen <tomi.valkeinen@ti.com>, akpm@linux-foundation.org

pfn_t_to_page() honors the flags in the pfn_t value to determine if a
pfn is backed by a page.  However, vm_insert_mixed() was originally
written to use pfn_valid() to make this determination.  To restore the
old/correct behavior, ignore the pfn_t flags in the !pfn_t_devmap() case
and fallback to trusting pfn_valid().

Fixes: 01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
Cc: Dave Hansen <dave@sr71.net>
Cc: David Airlie <airlied@linux.ie>
Reported-by: Julian Margetson <runaway@candw.ms>
Reported-by: Tomi Valkeinen <tomi.valkeinen@ti.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 30991f83d0bf..93ce37989471 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1591,10 +1591,15 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
 	 * without pte special, it would there be refcounted as a normal page.
 	 */
-	if (!HAVE_PTE_SPECIAL && pfn_t_valid(pfn)) {
+	if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
 		struct page *page;
 
-		page = pfn_t_to_page(pfn);
+		/*
+		 * At this point we are committed to insert_page()
+		 * regardless of whether the caller specified flags that
+		 * result in pfn_t_has_page() == false.
+		 */
+		page = pfn_to_page(pfn_t_to_pfn(pfn));
 		return insert_page(vma, addr, page, vma->vm_page_prot);
 	}
 	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
