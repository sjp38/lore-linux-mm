Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id AEC376B025A
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 08:36:17 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so47691119igb.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 05:36:17 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 5si41279706pdz.127.2015.09.03.05.36.11
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 05:36:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 7/7] mm: use 'unsigned int' for compound_dtor/compound_order on 64BIT
Date: Thu,  3 Sep 2015 15:35:58 +0300
Message-Id: <1441283758-92774-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1441283758-92774-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
Acked-by: Michal Hocko <mhocko@suse.com>
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
