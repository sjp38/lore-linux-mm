Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6D06B025A
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:59:45 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so26704317pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 06:59:45 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id wa5si3874013pab.64.2015.08.27.06.59.44
        for <linux-mm@kvack.org>;
        Thu, 27 Aug 2015 06:59:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 7/7] mm: use 'unsigned int' for compound_dtor/compound_order on 64BIT
Date: Thu, 27 Aug 2015 16:59:21 +0300
Message-Id: <1440683961-32839-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1440683961-32839-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1440683961-32839-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 64 bit system we have enough space in struct page to encode
compound_dtor and compound_order with unsigned int.

On x86-64 it leads to slightly smaller code size due usesage of plain
MOV instead of MOVZX (zero-extended move) or similar effect.

allyesconfig:

   text	   data	    bss	    dec	    hex	filename
159520446	48146736	72196096	279863278	10ae5fee	vmlinux.pre
159520382	48146736	72196096	279863214	10ae5fae	vmlinux.post

On other architectures without native support of 16-bit data types the
difference can be bigger.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ecaf3b1d0216..39b0db74ba5e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -150,8 +150,13 @@ struct page {
 		/* First tail page of compound page */
 		struct {
 			unsigned long compound_head; /* If bit zero is set */
+#ifdef CONFIG_64BIT
+			unsigned int compound_dtor;
+			unsigned int compound_order;
+#else
 			unsigned short int compound_dtor;
 			unsigned short int compound_order;
+#endif
 		};
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
