Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 502A16B0289
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:57:44 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id fe3so41732755pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:57:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z4si7237954par.198.2016.04.06.15.51.35
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 17/30] vmscan: split file huge pages before paging them out
Date: Thu,  7 Apr 2016 01:51:07 +0300
Message-Id: <1459983080-106718-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation of vmscan for file huge pages. We cannot write out
huge pages, so we need to split them on the way out.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/vmscan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b934223eaa45..4cc96ba44a34 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1055,8 +1055,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 			/* Adding to swap updated mapping */
 			mapping = page_mapping(page);
+		} else if (unlikely(PageTransHuge(page))) {
+			/* Split file THP */
+			if (split_huge_page_to_list(page, page_list))
+				goto keep_locked;
 		}
 
+		VM_BUG_ON_PAGE(PageTransHuge(page), page);
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
