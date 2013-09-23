Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E77546B0038
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:10 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so3126201pdj.40
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 11/22] thp, mm: warn if we try to use replace_page_cache_page() with THP
Date: Mon, 23 Sep 2013 15:05:39 +0300
Message-Id: <1379937950-8411-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

replace_page_cache_page() is only used by FUSE. It's unlikely that we
will support THP in FUSE page cache any soon.

Let's pospone implemetation of THP handling in replace_page_cache_page()
until any will use it. -EINVAL and WARN_ONCE() for now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 60478ebeda..3421bcaed4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -417,6 +417,10 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 {
 	int error;
 
+	if (WARN_ONCE(PageTransHuge(old) || PageTransHuge(new),
+		     "unexpected transhuge page\n"))
+		return -EINVAL;
+
 	VM_BUG_ON(!PageLocked(old));
 	VM_BUG_ON(!PageLocked(new));
 	VM_BUG_ON(new->mapping);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
