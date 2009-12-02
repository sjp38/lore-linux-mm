From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 24/24] HWPOISON: show corrupted file info
Date: Wed, 02 Dec 2009 11:12:55 +0800
Message-ID: <20091202043046.791112765@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D908C6007BE
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-describe-page-file.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

If file data is corrupted, the user may want to know which file
is corrupted.

CC: Andi Kleen <andi@firstfloor.org> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   43 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

--- linux-mm.orig/mm/memory-failure.c	2009-12-01 09:56:21.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-12-01 09:56:23.000000000 +0800
@@ -56,6 +56,47 @@ u64 hwpoison_filter_flags_mask;
 u64 hwpoison_filter_flags_value;
 u32 hwpoison_filter_memcg;
 
+static void describe_page_file(struct page *page)
+{
+	char *name = "?";
+	struct inode *inode;
+	struct dentry *dentry;
+
+	if (PageAnon(page))
+		return;
+
+	if (!page->mapping)
+		return;
+
+	inode = igrab(page->mapping->host);
+	if (!inode)
+		return;
+
+	dentry = d_find_alias(inode);
+
+	if (dentry) {
+		spin_lock(&dentry->d_lock);
+		name = dentry->d_name.name;
+	}
+
+	printk(KERN_ERR
+	       "MCE %#lx: dev %d:%d inode %lu(%s) pgoff %lu%s\n",
+	       page_to_pfn(page),
+	       MAJOR(inode->i_sb->s_dev),
+	       MINOR(inode->i_sb->s_dev),
+	       inode->i_ino,
+	       name,
+	       page->index,
+	       PageDirty(page) ? " corrupted" : "");
+
+	if (dentry) {
+		spin_unlock(&dentry->d_lock);
+		dput(dentry);
+	}
+
+	iput(inode);
+}
+
 static int hwpoison_filter_dev(struct page *p)
 {
 	struct address_space *mapping;
@@ -525,6 +566,8 @@ static int me_pagecache_clean(struct hwp
 		} else {
 			ret = RECOVERED;
 		}
+		if (PageDirty(p) && !PageSwapBacked(p))
+			describe_page_file(p);
 	} else {
 		/*
 		 * If the file system doesn't support it just invalidate


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
