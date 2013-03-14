Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2D5C96B0037
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:14 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 07/30] thp, mm: introduce mapping_can_have_hugepages() predicate
Date: Thu, 14 Mar 2013 19:50:12 +0200
Message-Id: <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Returns true if mapping can have huge pages. Just check for __GFP_COMP
in gfp mask of the mapping for now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..3521b0d 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -84,6 +84,16 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 				(__force unsigned long)mask;
 }
 
+static inline bool mapping_can_have_hugepages(struct address_space *m)
+{
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
+		gfp_t gfp_mask = mapping_gfp_mask(m);
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
