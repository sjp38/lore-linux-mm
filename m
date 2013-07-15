Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2B8B16B00D3
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 06:45:09 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/8] thp, mm: locking tail page is a bug
Date: Mon, 15 Jul 2013 13:47:51 +0300
Message-Id: <1373885274-25249-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Locking head page means locking entire compound page.
If we try to lock tail page, something went wrong.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 mm/filemap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index f7c4ed5..e59049c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -639,6 +639,7 @@ void __lock_page(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
+	VM_BUG_ON(PageTail(page));
 	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
 							TASK_UNINTERRUPTIBLE);
 }
@@ -648,6 +649,7 @@ int __lock_page_killable(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
+	VM_BUG_ON(PageTail(page));
 	return __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sleep_on_page_killable, TASK_KILLABLE);
 }
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
