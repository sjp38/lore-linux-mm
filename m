Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B09056B009C
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 12:04:45 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so4928472pdi.2
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 09:04:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id kj6si31220539pbc.109.2014.06.09.09.04.44
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 09:04:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 02/10] mm: change PageAnon() to work on tail pages
Date: Mon,  9 Jun 2014 19:04:13 +0300
Message-Id: <1402329861-7037-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Current PageAnon() is always return false for tail. We need to look on
head page for correct answer. Let's change the function to give the
right result.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9f4960bf505b..a60e2db5f9f9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -983,6 +983,7 @@ struct address_space *page_file_mapping(struct page *page)
 
 static inline int PageAnon(struct page *page)
 {
+	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
-- 
2.0.0.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
