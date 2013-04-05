Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id BDE176B00BB
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:24 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 23/34] thp, mm: split huge page on mmap file page
Date: Fri,  5 Apr 2013 14:59:47 +0300
Message-Id: <1365163198-29726-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are not ready to mmap file-backed tranparent huge pages. Let's split
them on fault attempt.

Later in the patchset we'll implement mmap() properly and this code path
be used for fallback cases.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 3296f5c..6f0e3be 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1683,6 +1683,8 @@ retry_find:
 			goto no_cached_page;
 	}
 
+	if (PageTransCompound(page))
+		split_huge_page(compound_trans_head(page));
 	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
 		page_cache_release(page);
 		return ret | VM_FAULT_RETRY;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
