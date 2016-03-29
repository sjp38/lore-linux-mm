Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 86A716B0260
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 12:39:48 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so18533967pfn.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:39:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ol15si5363853pab.45.2016.03.29.09.39.47
        for <linux-mm@kvack.org>;
        Tue, 29 Mar 2016 09:39:47 -0700 (PDT)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH] mm: Exclude HugeTLB pages from THP page_mapped logic
Date: Tue, 29 Mar 2016 17:39:41 +0100
Message-Id: <1459269581-21190-1-git-send-email-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, will.deacon@arm.com, dwoods@mellanox.com, mhocko@suse.com, mingo@kernel.org, Steve Capper <steve.capper@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

HugeTLB pages cannot be split, thus use the compound_mapcount to
track rmaps.

Currently the page_mapped function will check the compound_mapcount, but
will also go through the constituent pages of a THP compound page and
query the individual _mapcount's too.

Unfortunately, the page_mapped function does not distinguish between
HugeTLB and THP compound pages and assumes that a compound page always
needs to have HPAGE_PMD_NR pages querying.

For most cases when dealing with HugeTLB this is just inefficient, but
for scenarios where the HugeTLB page size is less than the pmd block
size (e.g. when using contiguous bit on ARM) this can lead to crashes.

This patch adjusts the page_mapped function such that we skip the
unnecessary THP reference checks for HugeTLB pages.

Fixes: e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount() for compound pages")
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
---

Hi,

This patch is my approach to fixing a problem that unearthed with
HugeTLB pages on arm64. We ran with PAGE_SIZE=64KB and placed down 32
contiguous ptes to create 2MB HugeTLB pages. (We can provide hints to
the MMU that page table entries are contiguous thus larger TLB entries
can be used to represent them).

The PMD_SIZE was 512MB thus the old version of page_mapped would read
through too many struct pages and lead to BUGs.

Original problem reported here:
http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/414657.html

Having examined the HugeTLB code, I understand that only the
compound_mapcount_ptr is used to track rmap presence so going through
the individual _mapcounts for HugeTLB pages is superfluous? Or should I
instead post a patch that changes hpage_nr_pages to use the compound
order?

Also, for the sake of readability, would it be worth changing the
definition of PageTransHuge to refer to only THPs (not both HugeTLB
and THP)?

(I misinterpreted PageTransHuge in hpage_nr_pages initially which is one
reason this problem took me longer than normal to pin down this issue).

Cheers,
-- 
Steve

---
 include/linux/mm.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ed6407d..4b223dc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1031,6 +1031,8 @@ static inline bool page_mapped(struct page *page)
 	page = compound_head(page);
 	if (atomic_read(compound_mapcount_ptr(page)) >= 0)
 		return true;
+	if (PageHuge(page))
+		return false;
 	for (i = 0; i < hpage_nr_pages(page); i++) {
 		if (atomic_read(&page[i]._mapcount) >= 0)
 			return true;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
