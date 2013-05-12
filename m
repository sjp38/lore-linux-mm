Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BE3056B0034
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:33 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 09/39] thp, mm: introduce mapping_can_have_hugepages() predicate
Date: Sun, 12 May 2013 04:23:06 +0300
Message-Id: <1368321816-17719-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Returns true if mapping can have huge pages. Just check for __GFP_COMP
in gfp mask of the mapping for now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..28597ec 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -84,6 +84,18 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 				(__force unsigned long)mask;
 }
 
+static inline bool mapping_can_have_hugepages(struct address_space *m)
+{
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)) {
+		gfp_t gfp_mask = mapping_gfp_mask(m);
+		/* __GFP_COMP is key part of GFP_TRANSHUGE */
+		return !!(gfp_mask & __GFP_COMP) &&
+			transparent_hugepage_pagecache();
+	}
+
+	return false;
+}
+
 /*
  * The page cache can done in larger chunks than
  * one page, because it allows for more efficient
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
