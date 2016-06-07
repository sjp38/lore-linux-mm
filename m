Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C431F6B026E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:01:35 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u203so148288143itc.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:01:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fv2si32711653pad.86.2016.06.07.04.01.24
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 16/32] vmscan: split file huge pages before paging them out
Date: Tue,  7 Jun 2016 14:00:30 +0300
Message-Id: <1465297246-98985-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index 93ba33789ac6..21d417ccff69 100644
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
