Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A56E26B00AE
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:20 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 08/34] thp, mm: introduce mapping_can_have_hugepages() predicate
Date: Fri,  5 Apr 2013 14:59:32 +0300
Message-Id: <1365163198-29726-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Returns true if mapping can have huge pages. Just check for __GFP_COMP
in gfp mask of the mapping for now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..56debde 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -84,6 +84,17 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 				(__force unsigned long)mask;
 }
 
+static inline bool mapping_can_have_hugepages(struct address_space *m)
+{
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
+		gfp_t gfp_mask = mapping_gfp_mask(m);
+		/* __GFP_COMP is key part of GFP_TRANSHUGE */
+		return !!(gfp_mask & __GFP_COMP);
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
