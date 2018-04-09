Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F58E6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 06:56:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t133so3969626wmt.6
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 03:56:06 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id j185si253617wma.32.2018.04.09.03.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 03:56:05 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: filemap: provide dummy filemap_page_mkwrite() for NOMMU
Date: Mon,  9 Apr 2018 12:55:42 +0200
Message-Id: <20180409105555.2439976-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jlayton@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Martin Brandenburg <martin@omnibond.com>, Mike Marshall <hubcap@omnibond.com>, Mel Gorman <mgorman@techsingularity.net>, Al Viro <viro@zeniv.linux.org.uk>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Building orangefs on MMU-less machines now results in a link error because
of the newly introduced use of the filemap_page_mkwrite() function:

ERROR: "filemap_page_mkwrite" [fs/orangefs/orangefs.ko] undefined!

This adds a dummy version for it, similar to the existing
generic_file_mmap and generic_file_readonly_mmap stubs in the same file,
to avoid the link error without adding #ifdefs in each file system that
uses these.

Cc: Martin Brandenburg <martin@omnibond.com>
Cc: Mike Marshall <hubcap@omnibond.com>
Fixes: a5135eeab2e5 ("orangefs: implement vm_ops->fault")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/filemap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ab77e19ab09c..9276bdb2343c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2719,7 +2719,6 @@ int filemap_page_mkwrite(struct vm_fault *vmf)
 	sb_end_pagefault(inode->i_sb);
 	return ret;
 }
-EXPORT_SYMBOL(filemap_page_mkwrite);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
@@ -2750,6 +2749,10 @@ int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
 	return generic_file_mmap(file, vma);
 }
 #else
+int filemap_page_mkwrite(struct vm_fault *vmf)
+{
+	return -ENOSYS;
+}
 int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
 	return -ENOSYS;
@@ -2760,6 +2763,7 @@ int generic_file_readonly_mmap(struct file * file, struct vm_area_struct * vma)
 }
 #endif /* CONFIG_MMU */
 
+EXPORT_SYMBOL(filemap_page_mkwrite);
 EXPORT_SYMBOL(generic_file_mmap);
 EXPORT_SYMBOL(generic_file_readonly_mmap);
 
-- 
2.9.0
