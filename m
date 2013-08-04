Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5526E6B005C
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:36 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 18/23] thp: libfs: introduce simple_thp_release()
Date: Sun,  4 Aug 2013 05:17:20 +0300
Message-Id: <1375582645-29274-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

simple_thp_release() is a dummy implementation of fops->release with
transparent huge page support. It's required to minimize memory overhead
of huge pages for small files.

It checks whether we should split the last page in the file to give
memory back to the system.

We split the page if it meets following criteria:
 - nobody has the file opened on write;
 - spliting will actually free any memory (at least one small page);
 - if it's a huge page ;)

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/libfs.c         | 27 +++++++++++++++++++++++++++
 include/linux/fs.h |  2 ++
 2 files changed, 29 insertions(+)

diff --git a/fs/libfs.c b/fs/libfs.c
index 934778b..c43b055 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -488,6 +488,33 @@ int simple_thp_write_begin(struct file *file, struct address_space *mapping,
 	}
 	return 0;
 }
+
+int simple_thp_release(struct inode *inode, struct file *file)
+{
+	pgoff_t last_index;
+	struct page *page;
+
+	/* check if anybody still writes to file */
+	if (atomic_read(&inode->i_writecount) != !!(file->f_mode & FMODE_WRITE))
+		return 0;
+
+	last_index = i_size_read(inode) >> PAGE_CACHE_SHIFT;
+
+	/* check if splitting the page will free any memory */
+	if ((last_index & HPAGE_CACHE_INDEX_MASK) + 1 == HPAGE_CACHE_NR)
+		return 0;
+
+	page = find_get_page(file->f_mapping,
+			last_index & ~HPAGE_CACHE_INDEX_MASK);
+	if (!page)
+		return 0;
+
+	if (PageTransHuge(page))
+		split_huge_page(page);
+
+	page_cache_release(page);
+	return 0;
+}
 #endif
 
 /*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c1dbf43..b594f10 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2557,8 +2557,10 @@ extern int simple_write_end(struct file *file, struct address_space *mapping,
 extern int simple_thp_write_begin(struct file *file,
 		struct address_space *mapping, loff_t pos, unsigned len,
 		unsigned flags,	struct page **pagep, void **fsdata);
+extern int simple_thp_release(struct inode *inode, struct file *file);
 #else
 #define simple_thp_write_begin simple_write_begin
+#define simple_thp_release NULL
 #endif
 
 extern struct dentry *simple_lookup(struct inode *, struct dentry *, unsigned int flags);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
