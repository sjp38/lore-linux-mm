Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64686828E5
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:42:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so152262094pfb.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:42:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vy4si18289353pab.231.2016.05.12.08.41.36
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 08:41:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv8 16/32] vmscan: split file huge pages before paging them out
Date: Thu, 12 May 2016 18:40:56 +0300
Message-Id: <1463067672-134698-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index e9fe17c96ef8..df56f6a2dbfe 100644
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
