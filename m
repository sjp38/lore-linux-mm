Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id DF89E6B0038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:30:13 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so89981386igc.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:30:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id y10si13633156igy.54.2015.10.06.08.24.27
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:24:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 28/37] mm, numa: skip PTE-mapped THP on numa fault
Date: Tue,  6 Oct 2015 18:23:55 +0300
Message-Id: <1444145044-72349-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to have THP mapped with PTEs. It will confuse numabalancing.
Let's skip them for now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/memory.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index f6e3c3b1aa29..d69e9ae023ce 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3184,6 +3184,12 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
+	/* TODO: handle PTE-mapped THP */
+	if (PageCompound(page)) {
+		pte_unmap_unlock(ptep, ptl);
+		return 0;
+	}
+
 	/*
 	 * Avoid grouping on RO pages in general. RO pages shouldn't hurt as
 	 * much anyway since they can be in shared cache state. This misses
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
