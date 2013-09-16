Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B462E6B00AA
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 07:25:57 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 3/9] mm: introduce api for split page table lock for PMD level
Date: Mon, 16 Sep 2013 14:25:34 +0300
Message-Id: <1379330740-5602-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Basic api, backed by mm->page_table_lock for now. Actual implementation
will be added later.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6cf8ddb..e3481c6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1294,6 +1294,19 @@ static inline void pgtable_page_dtor(struct page *page)
 	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
 		NULL: pte_offset_kernel(pmd, address))
 
+static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
+{
+	return &mm->page_table_lock;
+}
+
+
+static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
+{
+	spinlock_t *ptl = pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
+	return ptl;
+}
+
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
