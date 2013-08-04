Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B82216B0036
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:31 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/23] mm: trace filemap: dump page order
Date: Sun,  4 Aug 2013 05:17:09 +0300
Message-Id: <1375582645-29274-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dump page order to trace to be able to distinguish between small page
and huge page in page cache.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 include/trace/events/filemap.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/filemap.h b/include/trace/events/filemap.h
index 0421f49..7e14b13 100644
--- a/include/trace/events/filemap.h
+++ b/include/trace/events/filemap.h
@@ -21,6 +21,7 @@ DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
 		__field(struct page *, page)
 		__field(unsigned long, i_ino)
 		__field(unsigned long, index)
+		__field(int, order)
 		__field(dev_t, s_dev)
 	),
 
@@ -28,18 +29,20 @@ DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
 		__entry->page = page;
 		__entry->i_ino = page->mapping->host->i_ino;
 		__entry->index = page->index;
+		__entry->order = compound_order(page);
 		if (page->mapping->host->i_sb)
 			__entry->s_dev = page->mapping->host->i_sb->s_dev;
 		else
 			__entry->s_dev = page->mapping->host->i_rdev;
 	),
 
-	TP_printk("dev %d:%d ino %lx page=%p pfn=%lu ofs=%lu",
+	TP_printk("dev %d:%d ino %lx page=%p pfn=%lu ofs=%lu order=%d",
 		MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
 		__entry->i_ino,
 		__entry->page,
 		page_to_pfn(__entry->page),
-		__entry->index << PAGE_SHIFT)
+		__entry->index << PAGE_SHIFT,
+		__entry->order)
 );
 
 DEFINE_EVENT(mm_filemap_op_page_cache, mm_filemap_delete_from_page_cache,
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
