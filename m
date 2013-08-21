Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 026BC6B00B7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 11:38:16 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, fs: avoid page allocation beyond i_size on read
Date: Wed, 21 Aug 2013 18:37:21 +0300
Message-Id: <1377099441-2224-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've noticed that we allocated unneeded page for cache on read beyond
i_size. Simple test case (I checked it on ramfs):

$ touch testfile
$ cat testfile

It triggers 'no_cached_page' code path in do_generic_file_read().

Looks like it's regression since commit a32ea1e. Let's fix it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: NeilBrown <neilb@suse.de>
---
 mm/filemap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 1905f0e..b1a4d35 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1163,6 +1163,10 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
 		loff_t isize;
 		unsigned long nr, ret;
 
+		isize = i_size_read(inode);
+		if (!isize || index > (isize - 1) >> PAGE_CACHE_SHIFT)
+			goto out;
+
 		cond_resched();
 find_page:
 		page = find_get_page(mapping, index);
-- 
1.8.4.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
