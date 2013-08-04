Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C52AF6B005C
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:35 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/23] mm, fs: avoid page allocation beyond i_size on read
Date: Sun,  4 Aug 2013 05:17:17 +0300
Message-Id: <1375582645-29274-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, NeilBrown <neilb@suse.de>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've noticed that we allocated unneeded page for cache on read beyond
i_size. Simple test case (I checked it on ramfs):

$ touch testfile
$ cat testfile

It triggers 'no_cached_page' code path in do_generic_file_read().

Looks like it's regression since commit a32ea1e. Let's fix it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: NeilBrown <neilb@suse.de>
---
 mm/filemap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 066bbff..c31d296 100644
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
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
