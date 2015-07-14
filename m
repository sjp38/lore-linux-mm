Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4C79B280246
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 10:05:04 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so6553296pdr.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 07:05:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ci16si2003673pdb.76.2015.07.14.07.05.03
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 07:05:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-33-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-33-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 32/36] thp: reintroduce split_huge_page()
Content-Transfer-Encoding: 7bit
Message-Id: <20150714140457.AD1338B@black.fi.intel.com>
Date: Tue, 14 Jul 2015 17:04:57 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> This patch adds implementation of split_huge_page() for new
> refcountings.
> 
> Unlike previous implementation, new split_huge_page() can fail if
> somebody holds GUP pin on the page. It also means that pin on page
> would prevent it from bening split under you. It makes situation in
> many places much cleaner.
> 
> The basic scheme of split_huge_page():
> 
>   - Check that sum of mapcounts of all subpage is equal to page_count()
>     plus one (caller pin). Foll off with -EBUSY. This way we can avoid
>     useless PMD-splits.
> 
>   - Freeze the page counters by splitting all PMD and setup migration
>     PTEs.
> 
>   - Re-check sum of mapcounts against page_count(). Page's counts are
>     stable now. -EBUSY if page is pinned.
> 
>   - Split compound page.
> 
>   - Unfreeze the page by removing migration entries.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

checkpatch fixlet:

749ab1c0df4a thp: reintroduce split_huge_page() fix
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5df1b76837c7..a200ed579e1f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2998,7 +2998,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
  * Both head page and tail pages will inherit mapping, flags, and so on from
  * the hugepage.
  *
- * GUP pin and PG_locked transfered to @page. Rest subpages can be freed if
+ * GUP pin and PG_locked transferred to @page. Rest subpages can be freed if
  * they are not mapped.
  *
  * Returns 0 if the hugepage is split successfully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
