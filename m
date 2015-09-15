Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4606B0258
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:29:01 -0400 (EDT)
Received: by iofh134 with SMTP id h134so195760774iof.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:29:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id j20si4722054ioe.208.2015.09.15.03.28.59
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 03:28:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 7/7] mm: use 'unsigned int' for compound_dtor/compound_order on 64BIT
Date: Tue, 15 Sep 2015 13:28:15 +0300
Message-Id: <1442312895-124384-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442312895-124384-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm_types.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 385604afbafa..82d7f6a72626 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -143,8 +143,19 @@ struct page {
 			unsigned long compound_head; /* If bit zero is set */
 
 			/* First tail page only */
+#ifdef CONFIG_64BIT
+			/*
+			 * On 64 bit system we have enough space in struct page
+			 * to encode compound_dtor and compound_order with
+			 * unsigned int. It can help compiler generate better or
+			 * smaller code on some archtectures.
+			 */
+			unsigned int compound_dtor;
+			unsigned int compound_order;
+#else
 			unsigned short int compound_dtor;
 			unsigned short int compound_order;
+#endif
 		};
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
