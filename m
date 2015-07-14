Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 84576280246
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 10:04:32 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so6352038pac.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 07:04:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e3si1929315pdj.210.2015.07.14.07.04.31
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 07:04:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-27-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-27-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 26/36] mm: rework mapcount accounting to enable 4k mapping
 of THPs
Content-Transfer-Encoding: 7bit
Message-Id: <20150714140407.563E88B@black.fi.intel.com>
Date: Tue, 14 Jul 2015 17:04:07 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound.
> It means we need to track mapcount on per small page basis.
> 
> Straight-forward approach is to use ->_mapcount in all subpages to track
> how many time this subpage is mapped with PMDs or PTEs combined. But
> this is rather expensive: mapping or unmapping of a THP page with PMD
> would require HPAGE_PMD_NR atomic operations instead of single we have
> now.
> 
> The idea is to store separately how many times the page was mapped as
> whole -- compound_mapcount. This frees up ->_mapcount in subpages to
> track PTE mapcount.
> 
> We use the same approach as with compound page destructor and compound
> order to store compound_mapcount: use space in first tail page,
> ->mapping this time.
> 
> Any time we map/unmap whole compound page (THP or hugetlb) -- we
> increment/decrement compound_mapcount. When we map part of compound page
> with PTE we operate on ->_mapcount of the subpage.
> 
> page_mapcount() counts both: PTE and PMD mappings of the page.
> 
> Basically, we have mapcount for a subpage spread over two counters.
> It makes tricky to detect when last mapcount for a page goes away.
> 
> We introduced PageDoubleMap() for this. When we split THP PMD for the
> first time and there's other PMD mapping left we offset up ->_mapcount
> in all subpages by one and set PG_double_map on the compound page.
> These additional references go away with last compound_mapcount.
> 
> This approach provides a way to detect when last mapcount goes away on
> per small page basis without introducing new overhead for most common
> cases.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

checkpatch fixlet:

diff --git a/mm/rmap.c b/mm/rmap.c
index bae27e4608b5..b8da0cdf50ae 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1073,8 +1073,11 @@ void do_page_add_anon_rmap(struct page *page,
 	if (PageTransCompound(page)) {
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		if (compound) {
+			atomic_t *mapcount;
+
 			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-			first = atomic_inc_and_test(compound_mapcount_ptr(page));
+			mapcount = compound_mapcount_ptr(page);
+			first = atomic_inc_and_test(mapcount);
 		} else {
 			/* Anon THP always mapped first with PMD */
 			first = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
